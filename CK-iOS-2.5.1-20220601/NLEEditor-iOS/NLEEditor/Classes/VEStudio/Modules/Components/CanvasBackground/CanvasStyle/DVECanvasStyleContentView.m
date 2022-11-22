//
//  DVECanvasStyleContentView.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/3.
//

#import "DVECanvasStyleContentView.h"
#import "DVECanvasUIConfiguration.h"
#import "DVECanvasStyleItem.h"
#import "DVEModuleBaseCategoryModel.h"
#import "DVEBundleLoader.h"
#import "DVEPickerView.h"
#import "DVEMacros.h"
#import "DVECustomerHUD.h"

@interface DVECanvasStyleContentView () <DVEPickerViewDelegate,DVECoreActionNotifyProtocol>

@property (nonatomic, strong) DVEPickerView *pickerView;
@property (nonatomic, strong) NSArray<DVEModuleBaseCategoryModel *> *categoryData;
@property (nonatomic, strong) DVEEffectValue *currentSelected;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@end

@implementation DVECanvasStyleContentView

DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.pickerView];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)addObserver
{
    [self.actionService addUndoRedoListener:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelApplyCanvasStyleIfNeed)
                                                 name:DVECanvasStyleItemDeSelectLocalImageNotification
                                               object:nil];
}

- (DVEEffectValue *)currentSelectedValue {
    return self.currentSelected;
}

- (DVEPickerView *)pickerView {
    if (!_pickerView) {
        DVECanvasStyleUIConfiguration *config = [[DVECanvasStyleUIConfiguration alloc] init];
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
    [self setUpData];
    [self addObserver];
}

- (void)setUpData {
    
    DVEEffectValue *noneValue = [[DVEEffectValue alloc] init];
    noneValue.name = NLELocalizedString(@"ck_none", @"无");
    noneValue.assetImage = [@"iconFilterwu" dve_toImage];
    noneValue.identifier = @"none";
    noneValue.valueType = VEEffectValueTypeCanvasStyleNone;
    DVEEffectValue *selectImageValue = [[DVEEffectValue alloc] init];
    selectImageValue.name = @"选择图片";
    selectImageValue.identifier = @"selected";
    selectImageValue.valueType = VEEffectValueTypeCanvasStyleLocal;
    selectImageValue.assetImage = [@"icon_vevc_upload_pic" dve_toImage];
    NSMutableArray<DVEEffectValue *> *values = [NSMutableArray arrayWithArray:@[noneValue, selectImageValue]];
    [self.pickerView updateLoading];
    @weakify(self);
    [[DVEBundleLoader shareManager] canvasStyleEffectList:self.vcContext
                                                  handler:^(NSArray<DVEEffectValue *> * _Nullable datas, NSString * _Nullable error) {
        @strongify(self);
        for (DVEEffectValue *dataValue in datas) {
            dataValue.valueType = VEEffectValueTypeCanvasStyleNetwork;
        }
        DVEModuleBaseCategoryModel *categoryModel = [[DVEModuleBaseCategoryModel alloc] init];
        DVEEffectCategory* category = [[DVEEffectCategory alloc] init];
        [values addObjectsFromArray:datas];
        category.models = values;
        categoryModel.category = category;
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if(!error){
                self.categoryData = @[categoryModel];
                [self.pickerView updateCategory:self.categoryData];
                [self.pickerView updateFetchFinish];
                @weakify(self);
                [self.pickerView performBatchUpdates:^{
                    
                } completion:^(BOOL finished) {
                    @strongify(self);
                    if (finished) {
                        [self restoreData];
                    }
                }];
            }else{
                [DVECustomerHUD showMessage:error];
                [self.pickerView updateFetchError];
            }
        });
    }];
}

- (void)restoreData {
    NLETrackSlot_OC *timeLineSlot = self.vcContext.mediaContext.mappingTimelineVideoSegment.slot;
    NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)timeLineSlot.segment;
    self.currentSelected = (DVEEffectValue *)[[self.categoryData firstObject].category.models firstObject];
    NSInteger selectIndex = 0;
    if (segment.canvasStyle) {
        NLEResourceNode_OC *resource = segment.canvasStyle.imageSource;
        NSArray<id<DVEResourceModelProtocol>> *values = [self.categoryData firstObject].category.models;
        for (NSInteger i = 0; i < values.count; i++) {
            DVEEffectValue *value = (DVEEffectValue *)values[i];
            if ([resource.resourceId isEqualToString:value.identifier]) {
                if (!value.sourcePath) {
                    value.sourcePath = resource.resourceFile;
                }
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

#pragma mark - DVEPickerView Delegate

- (BOOL)pickerView:(DVEPickerView *)pickerView
        isSelected:(DVEEffectValue *)sticker {
    BOOL isSelected = [sticker.identifier isEqualToString:self.currentSelected.identifier];
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

    NSString *identifier = sticker.identifier;
    if ([identifier isEqualToString:self.currentSelected.identifier] &&
        ![identifier isEqualToString:@"selected"]) {
        return;
    }
    
    dispatch_group_t group = dispatch_group_create();
    switch (indexPath.row) {
        case 0: {
            self.currentSelected = sticker;
            [self cancelApplyCanvasStyleIfNeed];
            break;
        }
        case 1: {
            self.currentSelected = sticker;
            dispatch_group_enter(group);
            @weakify(self);
            [DVEOptionalInline(self.vcContext.serviceProvider, DVEResourcePickerProtocol) pickSingleImageResourceWithCompletion:^(NSArray<id<DVEResourcePickerModel>> * _Nonnull resources, NSError * _Nullable error, BOOL cancel) {
                if (resources.count <= 0) {
                    self.currentSelected = nil;
                } else {
                    id<DVEResourcePickerModel> resourcePickerModel = [resources firstObject];
                    @strongify(self);
                    self.currentSelected.sourcePath = [resourcePickerModel URL].absoluteString;
                }
                dispatch_group_leave(group);
            }];
            break;
        }
        default: {
            if (sticker.status == DVEResourceModelStatusNeedDownlod ||
                sticker.status == DVEResourceModelStatusDownlodFailed) {
                @weakify(self);
                [sticker downloadModel:^(id<DVEResourceModelProtocol>  _Nonnull model) {
                    [pickerView updateStickerStatusForId:model.identifier];
                    if(model.status != DVEResourceModelStatusDefault) {
                        return;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        @strongify(self);
                        [self pickerView:pickerView didSelectSticker:sticker category:category indexPath:indexPath];
                    });
                }];
            } else {
                self.currentSelected = sticker;
            }
            break;
        }
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (![self.currentSelected.identifier isEqualToString:@"none"]) {
            [self.delegate applyCanvasStyleWithValue:self.currentSelected];
        }
        [pickerView currentCategorySelectItemAtIndexPath:indexPath
                                                animated:YES
                                          scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        [pickerView updateSelectedStickerForId:sticker.identifier];
    });
}

- (void)cancelApplyCanvasStyleIfNeed {
    if ([self.currentSelected.identifier isEqualToString:@"selected"]) {
        self.currentSelected = (DVEEffectValue *)[[self.categoryData firstObject].category.models firstObject];
        [self.pickerView updateSelectedStickerForId:self.currentSelected.identifier];
    }
    [self.delegate cancelApplyCanvasStyleIfNeed];
}


- (void)undoRedoClikedByUser
{
    [self restoreData];
}

@end
