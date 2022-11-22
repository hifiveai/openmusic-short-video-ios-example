//
//  DVECanvasBlurContentView.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/3.
//

#import "DVECanvasBlurContentView.h"
#import "DVEModuleBaseCategoryModel.h"
#import "DVECanvasUIConfiguration.h"
#import "DVEPickerView.h"
#import "DVEMacros.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface DVECanvasBlurContentView () <DVEPickerViewDelegate,DVECoreActionNotifyProtocol>

@property (nonatomic, strong) DVEPickerView *pickerView;
@property (nonatomic, strong) NSArray<DVEModuleBaseCategoryModel *> *categoryData;
@property (nonatomic, strong) DVEEffectValue *currentSelected;
@property (nonatomic, strong) NSArray<NSNumber *> *blurRadiusArray;

@property (nonatomic, strong) NLETrackSlot_OC *currentSlot;

@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;

@end

@implementation DVECanvasBlurContentView

DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.pickerView];
        self.blurRadiusArray = @[@(0.1), @(0.45), @(0.75), @(1)];
    }
    return self;
}

- (float)currentSelectedBlurRadius {
    if (self.currentSelected) {
        return [self.currentSelected indesty] * 16;
    }
    return -1.0f;
}

- (DVEPickerView *)pickerView {
    if (!_pickerView) {
        DVECanvasBlurUIConfiguration *config = [[DVECanvasBlurUIConfiguration alloc] init];
        _pickerView = [[DVEPickerView alloc] initWithUIConfig:config];
        _pickerView.delegate = self;
        _pickerView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    }
    return _pickerView;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        return;
    }
    [self setUpRACObserver];
}

- (void)setUpRACObserver {
    @weakify(self);
    [[[RACObserve(self.vcContext.mediaContext, mappingTimelineVideoSegment) deliverOnMainThread] distinctUntilChanged] subscribeNext:^(DVESelectSegment *  _Nullable selectSegment) {
        @strongify(self);
        if (![self.currentSlot.nle_nodeId isEqualToString:selectSegment.slot.nle_nodeId]) {
            self.currentSlot = selectSegment.slot;
            [self setUpData];
        }
    }];
    [self.actionService addUndoRedoListener:self];
}

- (void)setUpData {
    @weakify(self);
    [self processCurrentSelectSegmentImageWithCompletion:^(UIImage * _Nullable uiImage) {
        @strongify(self);
        DVEEffectValue *noneValue = [[DVEEffectValue alloc] init];
        noneValue.name = NLELocalizedString(@"ck_none", @"无");
        noneValue.assetImage = [@"iconFilterwu" dve_toImage];
        noneValue.identifier = noneValue.name;
        NSMutableArray<DVEEffectValue *> *values = [NSMutableArray arrayWithArray:@[noneValue]];
        for (NSNumber *blurRadius in self.blurRadiusArray) {
            DVEEffectValue *value = [[DVEEffectValue alloc] init];
            float blurRadiusValue = [blurRadius floatValue];
            value.indesty = blurRadiusValue;
            value.assetImage = [self processBlurImageWithImage:uiImage radius:blurRadiusValue * 16.0];
            value.identifier = [NSString stringWithFormat:@"%.10f", blurRadiusValue * 16.0];
            [values addObject:value];
        }
        DVEModuleBaseCategoryModel *categoryModel = [[DVEModuleBaseCategoryModel alloc] init];
        DVEEffectCategory* category = [[DVEEffectCategory alloc] init];
        category.models = values;
        categoryModel.category = category;
        self.categoryData = @[categoryModel];
        [self restoreData];
        [self.pickerView updateCategory:self.categoryData];
    }];
}

- (void)processCurrentSelectSegmentImageWithCompletion:(void(^)(UIImage * _Nullable))completion {
    dispatch_group_t group = dispatch_group_create();
    __block UIImage *uiImage = nil;
    NLETrackSlot_OC *slot = self.vcContext.mediaContext.mappingTimelineVideoSegment.slot;
    NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)slot.segment;
    NLEResourceNode_OC *resource = [segment getResNode];
    if (resource.resourceType == NLEResourceTypeImage) {
        NSString *path = [self.nle getAbsolutePathWithResource:resource];
        uiImage = [UIImage imageWithContentsOfFile:path];
    } else {
        AVURLAsset *asset = [self.nle assetFromSlot:slot];
        CMTime currentTime = CMTimeAdd(CMTimeSubtract(self.vcContext.mediaContext.currentTime, slot.startTime), segment.timeClipStart);
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.requestedTimeToleranceAfter = kCMTimeZero;
        generator.requestedTimeToleranceBefore = kCMTimeZero;
        generator.appliesPreferredTrackTransform = YES;
        generator.maximumSize = CGSizeMake(150, 150);
        
        currentTime = CMTimeMinimum(CMTimeMaximum(currentTime, kCMTimeZero), asset.duration);
        dispatch_group_enter(group);
        [generator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:currentTime]]
                                        completionHandler:^(CMTime requestedTime,
                                                            CGImageRef  _Nullable image,
                                                            CMTime actualTime,
                                                            AVAssetImageGeneratorResult result,
                                                            NSError * _Nullable error) {
            if (result == AVAssetImageGeneratorSucceeded && image) {
                uiImage = [UIImage imageWithCGImage:image];
            }
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completion) {
            completion(uiImage);
        }
    });
}

- (void)restoreData {
    NLETrackSlot_OC *slot = self.vcContext.mediaContext.mappingTimelineVideoSegment.slot;
    NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)slot.segment;
    self.currentSelected = [[self.categoryData firstObject].models firstObject];
    NSInteger selectIndex = 0;
    if (segment.canvasStyle) {
        float blurRadius = segment.canvasStyle.blurRadius;
        NSString *identifier = [NSString stringWithFormat:@"%.10f", blurRadius];
        NSArray<id<DVEResourceModelProtocol>> *values = [self.categoryData firstObject].category.models;
        
        for (NSInteger i = 0; i < values.count; i++) {
            DVEEffectValue *value = (DVEEffectValue *)values[i];
            if ([value.identifier isEqualToString:identifier]) {
                self.currentSelected = value;
                selectIndex = i;
                break;
            }
        }
    }
    
    [self.pickerView currentCategorySelectItemAtIndexPath:[NSIndexPath indexPathForRow:selectIndex inSection:0]
                                                 animated:NO
                                           scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    [self.pickerView updateSelectedStickerForId:self.currentSelected.identifier];
}

- (UIImage *)processBlurImageWithImage:(UIImage *)image
                                radius:(float)radius {
    
    CIImage *cImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    
    [filter setValue:cImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:radius] forKey:kCIInputRadiusKey];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *resultCImage = [filter valueForKey:kCIOutputImageKey];
    
    CGImageRef imageRef = [context createCGImage:resultCImage fromRect:cImage.extent];
    
    return [UIImage imageWithCGImage:imageRef];
}

- (BOOL)pickerView:(DVEPickerView *)pickerView
        isSelected:(DVEEffectValue *)sticker {
    BOOL isSelected = [sticker.identifier isEqualToString:self.currentSelected.identifier];
    if (isSelected) {
        NSInteger selectedIndex = [[self.categoryData firstObject].category.models indexOfObject:self.currentSelected];
        if (selectedIndex != NSNotFound) {
            [pickerView currentCategorySelectItemAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]
                                                    animated:NO
                                              scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        }
    }
    return isSelected;
}

- (void)pickerView:(DVEPickerView *)pickerView
willDisplaySticker:(DVEEffectValue *)sticker
         indexPath:(NSIndexPath *)indexPath {
    
}

- (void)pickerView:(DVEPickerView *)pickerView
  didSelectSticker:(DVEEffectValue *)sticker
          category:(id<DVEPickerCategoryModel>)category
         indexPath:(NSIndexPath *)indexPath {
    
    if ([sticker.identifier isEqualToString:self.currentSelected.identifier]) {
        return;
    }
    
    self.currentSelected = sticker;
    switch (indexPath.row) {
        case 0: {
            [self.delegate cancelApplyCanvasBlurIfNeed];
            break;
        }
        default: {
            [self.delegate applyCanvasBlurWithBlurRadius:sticker.indesty * 16];
            break;
        }
    }
    [pickerView currentCategorySelectItemAtIndexPath:indexPath
                                            animated:YES
                                      scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    [pickerView updateSelectedStickerForId:sticker.identifier];
}

- (void)undoRedoClikedByUser
{
    [self restoreData];
}

@end
