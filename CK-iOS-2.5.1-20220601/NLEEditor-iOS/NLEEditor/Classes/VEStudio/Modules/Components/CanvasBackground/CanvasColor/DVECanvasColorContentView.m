//
//  DVECanvasColorContentView.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/3.
//

#import "DVECanvasColorContentView.h"
#import "DVECanvasUIConfiguration.h"
#import "DVEPickerView.h"
#import "DVEModuleBaseCategoryModel.h"
#import "DVEMacros.h"
#import "DVEBundleLoader.h"
#import "DVECustomerHUD.h"

@interface DVECanvasColorContentView () <DVEPickerViewDelegate>

@property (nonatomic, strong) DVEPickerView *pickerView;
@property (nonatomic, strong) NSArray<DVEModuleBaseCategoryModel *> *categoryData;
@property (nonatomic, strong) DVEEffectValue *currentSelected;

@end

@implementation DVECanvasColorContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.pickerView];
    }
    return self;
}

- (DVEPickerView *)pickerView {
    if (!_pickerView) {
        DVECanvasColorUIConfiguration *config = [[DVECanvasColorUIConfiguration alloc] init];
        _pickerView = [[DVEPickerView alloc] initWithUIConfig:config];
        _pickerView.delegate = self;
        _pickerView.frame = CGRectMake(0, 10, self.bounds.size.width, self.bounds.size.height);
    }
    return _pickerView;
}

- (NSNumber *)currentSelectedColorValue {
    return [NSNumber numberWithUnsignedInt:[self p_colorValueFromColorArray:self.currentSelected.color]];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        return;
    }
    [self setUpData];
}

- (void)setUpData {
//    NSArray<NSNumber *> *canvasColors = @[@(0xffffff),@(0xcccccc),@(0x999999),@(0x666666),@(0x000000),
//                                          @(0xffcdd2),@(0xfe8a80),@(0xfe5252),@(0xe8073d),@(0x961332),
//                                          @(0xffd9c6),@(0xffb18c),@(0xff8b40),@(0xf56b00),@(0xab3837),
//                                          @(0xfff9c4),@(0xfefe8d),@(0xfbd96d),@(0xffbb01),@(0xab7433),
//                                          @(0xfac9e1),@(0xf598bf),@(0xec6095),@(0xcf2179),@(0x901e4b),
//                                          @(0xe7e2ff),@(0xc5c4ff),@(0x807fda),@(0x664dcd),@(0x443a6c),
//                                          @(0xb7dcf6),@(0x8ec2f9),@(0x469df3),@(0x1385d4),@(0x334d80),
//                                          @(0xbcf8ff),@(0x67e2f1),@(0x1cc8dd),@(0x12a4b6),@(0x225f75),
//                                          @(0xd4f1e9),@(0xa1d5c5),@(0x17b39d),@(0x00917e),@(0x00624b),
//                                          @(0xe9eac8),@(0xc3cf47),@(0x899f23),@(0x517933),@(0x3c5c37),
//                                          @(0xdad1cf),@(0xb3a6a1),@(0x87776d),@(0x6a5a4f),@(0x4a4238),
//                                          @(0xf0d2cd),@(0xd47971),@(0xa74f59),@(0xf1c196),@(0xdd9775),
//                                          @(0xbb7d55),@(0xe9d7a4),@(0xedc65d),@(0xc9af62),@(0xbfc37e),
//                                          @(0x889b73),@(0x506f59),@(0x70a19c),@(0x009388),@(0x277e73),
//                                          @(0x90c2cd),@(0x70bdc2),@(0x177e9e),@(0xa4bdd2),@(0x6a8fc0),
//                                          @(0x465773),@(0xcdb7c8),@(0xa993a9),@(0x7e526c)];
    
    @weakify(self);
    [[DVEBundleLoader shareManager] textColor:self.vcContext
                                      handler:^(NSArray<DVEEffectValue *> * _Nullable datas, NSString * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if (!error) {
                for (DVEEffectValue *data in datas) {
                    NSArray<NSNumber *> *color = data.color;
                    data.identifier = [NSString stringWithFormat:@"CanvasColor:%u", [self p_colorValueFromColorArray:color]];
                }
                DVEModuleBaseCategoryModel *categoryModel = [[DVEModuleBaseCategoryModel alloc] init];
                DVEEffectCategory* category = [[DVEEffectCategory alloc] init];
                category.models = datas;
                categoryModel.category = category;
                self.categoryData = @[categoryModel];
                [self restoreData];
                [self.pickerView updateCategory:self.categoryData];
            } else {
                [DVECustomerHUD showMessage:error];
                [self.pickerView updateFetchError];
            }
        });
    }];
}

- (void)restoreData {
    NLETrackSlot_OC *slot = self.vcContext.mediaContext.mappingTimelineVideoSegment.slot;
    NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)slot.segment;
    if (!segment.canvasStyle) {
        return;
    }
    uint32_t colorValue = segment.canvasStyle.color;
    NSString *colorValueString = [NSString stringWithFormat:@"CanvasColor:%u", colorValue];
    NSArray<id<DVEResourceModelProtocol>> *values = [self.categoryData firstObject].category.models;
    for (DVEEffectValue *value in values) {
        if ([value.identifier isEqualToString:colorValueString]) {
            self.currentSelected = value;
            break;
        }
    }
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
    
    if (sticker.status == DVEResourceModelStatusDefault) {
        if ([sticker.identifier isEqualToString:self.currentSelected.identifier]) {
            return;
        }
        
        self.currentSelected = sticker;
        [self.delegate applyCanvasColorWithValue:[NSNumber numberWithUnsignedInt:[self p_colorValueFromColorArray:sticker.color]]];
    } else if (sticker.status == DVEResourceModelStatusNeedDownlod ||
               sticker.status == DVEResourceModelStatusDownlodFailed) {
        @weakify(self);
        [sticker downloadModel:^(id<DVEResourceModelProtocol>  _Nonnull model) {
            [pickerView updateStickerStatusForId:model.identifier];
            if (model.status != DVEResourceModelStatusDefault) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self pickerView:pickerView didSelectSticker:sticker category:category indexPath:indexPath];
            });
        }];
    }
    [pickerView currentCategorySelectItemAtIndexPath:indexPath
                                            animated:YES
                                      scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    [pickerView updateStickerStatusForId:sticker.identifier];
}


- (uint32_t)p_colorValueFromColorArray:(NSArray<NSNumber *> *)colors {
    NSString *colorValue = [NSString stringWithFormat:@"%02lX%02lX%02lX%02lX", 255L, lroundf([colors[0] floatValue] * 255), lroundf([colors[1] floatValue] * 255), lroundf([colors[2] floatValue] * 255)];
    uint32_t value = 0;
    sscanf([colorValue UTF8String], "%x", &value);
    return value;
}

@end
