//
//  DVEMixedEffectBar.m
//  Pods
//
//  Created by bytedance on 2021/4/19.
//

#import "DVEMixedEffectBar.h"
#import "DVEMacros.h"
#import "DVEBundleLoader.h"
#import "DVEMixedEffectItem.h"
#import "DVEMixedEffectSlider.h"
#import "DVEPickerView.h"
#import "DVEModuleBaseCategoryModel.h"
#import "DVEEffectsBarBottomView.h"
#import "DVEMixedEffectUIConfiguration.h"
#import "DVECustomerHUD.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVELoggerImpl.h"
#import <NLEPlatform/NLETrackSlot+iOS.h>
#import <Masonry/Masonry.h>

static NSString * const kDVEMixedEffectItemIdentifier = @"kDVEMixedEffectItemIdentifier";

@interface DVEMixedEffectBar ()
<
DVEMixedEffectSliderDelegate,
DVEPickerViewDelegate,
DVEVideoKeyFrameProtocol
>

@property (nonatomic, strong) DVEPickerView *pickerView;
///底部区域
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) DVEMixedEffectSlider *transparentSlider;
@property (nonatomic, strong) UILabel *transparentLabel;
@property (nonatomic, strong) DVEModuleBaseCategoryModel *categoryData;
@property (nonatomic, strong) DVEEffectValue *currentSelected;
@property (nonatomic, assign) float currentSliderValue;

@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVECoreVideoProtocol> videoEditor;

@end

@implementation DVEMixedEffectBar

DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, videoEditor, DVECoreVideoProtocol)

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setUpData {
    _currentSliderValue = 1.0;
    DVEEffectValue *noneValue = [[DVEEffectValue alloc] init];
    noneValue.name = NLELocalizedString(@"ck_none", @"无");
    noneValue.assetImage = [@"iconFilterwu" dve_toImage];
    noneValue.identifier = noneValue.name;
    NSMutableArray<DVEEffectValue *> *values = [NSMutableArray arrayWithObject:noneValue];
    
    [self.pickerView updateLoading];
    @weakify(self);
    [[DVEBundleLoader shareManager] mixedEffect:self.vcContext handler:^(NSArray<DVEEffectValue *> * _Nullable datas, NSString * _Nullable error) {
        @strongify(self);
        DVEModuleBaseCategoryModel *categoryModel = [DVEModuleBaseCategoryModel new];
        DVEEffectCategory* category = [DVEEffectCategory new];
        [values addObjectsFromArray:datas];
        category.models = values;
        categoryModel.category = category;
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if(!error){
                self.categoryData = categoryModel;
                [self.pickerView updateCategory:@[categoryModel]];
                [self.pickerView updateFetchFinish];
                self.currentSelected = (DVEEffectValue*)[self.categoryData.models firstObject];
                [self restoreData];
            }else{
                [DVECustomerHUD showMessage:error];
                [self.pickerView updateFetchError];
            }
        });
    }];
}

- (void)restoreData {
    NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)[self.vcContext.mediaContext currentMainVideoSlot].segment;
    _currentSliderValue = segment.alpha;
    if (segment.blendFile) {
        NSString *resourceId = segment.blendFile.resourceId;
        NSArray<DVEEffectValue *> *models = (NSArray<DVEEffectValue *> *)self.categoryData.models;
        for (NSInteger j = 0; j < models.count; j++) {
            if ([models[j].identifier isEqualToString:resourceId]) {
                _currentSelected = models[j];
                DVELogInfo(@"restoreData selected %ld and slider value:%.10f", (long)j, segment.alpha);
                break;
            }
        }
    }
    
    [self.transparentSlider setValue:_currentSliderValue * 100];
}

- (void)setUpLayout {

    [self addSubview:self.transparentLabel];
    //移除baseBar的slider
    [self.slider removeFromSuperview];
    
    [self addSubview:self.transparentSlider];
    self.transparentSlider.centerY = self.transparentLabel.centerY;
    [self.transparentSlider setValueRange:DVEMakeFloatRang(0, 100) defaultProgress:_currentSliderValue * 100];
    
    [self addSubview:self.pickerView];
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        id<DVEPickerUIConfigurationProtocol> config = self.pickerView.uiConfig;
        make.height.mas_equalTo(config.effectUIConfig.effectListViewHeight + config.categoryUIConfig.categoryTabListViewHeight);
        make.left.right.equalTo(self);
        make.top.equalTo(self).offset(80);
    }];
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pickerView.mas_bottom);
        make.left.right.bottom.equalTo(self);
    }];
}

- (void)setVcContext:(DVEVCContext *)vcContext {
    [super setVcContext:vcContext];
    self.videoEditor.keyFrameDeleagte = self;
}

- (DVEPickerView *)pickerView {
    if (!_pickerView) {
        DVEMixedEffectUIConfiguration *config = [[DVEMixedEffectUIConfiguration alloc] init];
        _pickerView = [[DVEPickerView alloc] initWithUIConfig:config];
        _pickerView.delegate = self;
    }
    return _pickerView;
}

- (UIView*)bottomView
{
    if(!_bottomView) {
        @weakify(self);
        _bottomView = [DVEEffectsBarBottomView newActionBarWithTitle:NLELocalizedString(@"ck_mix_mode",@"混合模式") action:^{
            @strongify(self);
            [self.actionService commitNLE:YES];
            [self dismiss:YES];
            [self.actionService refreshUndoRedo];

        }];
    }
    return _bottomView;
}

- (UILabel *)transparentLabel {
    if (!_transparentLabel) {
        _transparentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 16, 48, 20)];
        _transparentLabel.textAlignment = NSTextAlignmentCenter;
        _transparentLabel.font = SCRegularFont(12);
        _transparentLabel.textColor = [UIColor whiteColor];
        _transparentLabel.text = NLELocalizedString(@"ck_opacity", @"不透明度");
    }
    return _transparentLabel;
}

- (DVEMixedEffectSlider *)transparentSlider {
    if (!_transparentSlider) {
        _transparentSlider = [[DVEMixedEffectSlider alloc] initWithFrame:CGRectMake(107, 0, self.bounds.size.width - 150, 50)];
        _transparentSlider.delegate = self;
    }
    return _transparentSlider;
}

#pragma mark - Override
- (void)showInView:(UIView *)view animation:(BOOL)animation{
    [super showInView:view animation:(BOOL)animation];
    [self setUpData];
    [self setUpLayout];
}

#pragma mark - DVEMixedEffectSliderDelegate
- (void)sliderValueChanged:(float)value {
    DVELogInfo(@"DVEMixedEffect sliderValueChanged:%.10f currentSliderValue:%.10f", value, _currentSliderValue);
//    if (_currentSelected < 0) {
//        return;
//    }
    if (_currentSliderValue != value) {
        _currentSliderValue = value;
        [self applyMixedEffectWithAlpha:_currentSliderValue];
    }
}

#pragma mark - DVEPickerViewDelegate

- (BOOL)pickerView:(DVEPickerView *)pickerView isSelected:(DVEEffectValue*)sticker {
    NSAssert([sticker isKindOfClass:[DVEEffectValue class]], @"should be DVEEffectValue");
    DVEEffectValue *model = (DVEEffectValue*)sticker;
    BOOL isSelected = [self.currentSelected.identifier isEqualToString:model.identifier];
    if (isSelected) {
        NSInteger selectedIndex = [self.categoryData.models indexOfObject:self.currentSelected];
        if (selectedIndex != NSNotFound) {
            [pickerView currentCategorySelectItemAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]
                                                    animated:NO
                                              scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        }
    }
    return isSelected;
}

- (void)pickerViewDidClearSticker:(DVEPickerView *)pickerView {
    
}

- (void)pickerView:(DVEPickerView *)pickerView didSelectTabIndex:(NSInteger)index {
    
}

- (void)pickerView:(DVEPickerView *)pickerView
willDisplaySticker:(DVEEffectValue*)sticker
         indexPath:(NSIndexPath *)indexPath {
    
}

- (void)pickerView:(DVEPickerView *)pickerView
  didSelectSticker:(DVEEffectValue*)sticker
          category:(id<DVEPickerCategoryModel>)category
         indexPath:(NSIndexPath *)indexPath {
    
    if(sticker.status == DVEResourceModelStatusDefault){
        if ([sticker.identifier isEqualToString:self.currentSelected.identifier]) {
            return;
        }
        
        DVEEffectValue *model = (DVEEffectValue*)sticker;
        self.currentSelected = model;
        
        [self applyMixedEffectWithData:model];
        [pickerView currentCategorySelectItemAtIndexPath:indexPath
                                                animated:YES
                                          scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        [pickerView updateSelectedStickerForId:model.identifier];
        return;
    }else if(sticker.status == DVEResourceModelStatusNeedDownlod || sticker.status == DVEResourceModelStatusDownlodFailed){
        @weakify(self);
        [sticker downloadModel:^(id<DVEResourceModelProtocol>  _Nonnull model) {
            [pickerView updateStickerStatusForId:model.identifier];
            if(model.status != DVEResourceModelStatusDefault) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self pickerView:pickerView didSelectSticker:sticker category:category indexPath:indexPath];
            });
        }];
    }
    [pickerView updateStickerStatusForId:sticker.identifier];

}

- (void)applyMixedEffectWithData:(DVEEffectValue *)effectValue {
    if ([self.currentSelected.identifier isEqualToString:@"无"]) {
        [self.videoEditor applyMixedEffectWithSlot:[self.vcContext.mediaContext currentMainVideoSlot]
                                          blendFile:nil
                                             alpha:1.0];
    } else if ([self.currentSelected.identifier isEqualToString:@"正常"]){
        NLEResourceNode_OC *blendFile = [[NLEResourceNode_OC alloc] init];
        blendFile.resourceName = @"正常";
        blendFile.resourceId = @"正常";
        [self.videoEditor applyMixedEffectWithSlot:[self.vcContext.mediaContext currentMainVideoSlot]
                                         blendFile:blendFile
                                             alpha:self.currentSliderValue];
    } else {
        NLEResourceNode_OC *blendFile = [[NLEResourceNode_OC alloc] init];
        blendFile.resourceType = NLEResourceTypeEffect;
        blendFile.resourceId = effectValue.identifier;
        blendFile.resourceName = effectValue.name;
        blendFile.resourceFile = effectValue.sourcePath;
        [self.videoEditor applyMixedEffectWithSlot:[self.vcContext.mediaContext currentMainVideoSlot]
                                         blendFile:blendFile
                                             alpha:self.currentSliderValue];
    }
}

- (void)applyMixedEffectWithAlpha:(float)alpha {
    [self.videoEditor applyMixedEffectWithSlot:[self.vcContext.mediaContext currentMainVideoSlot]
                                         alpha:alpha];
}

#pragma mark - DVEVideoKeyFrameProtocol

- (void)videoKeyFrameDidChangedWithSlot:(NLETrackSlot_OC *)slot {
    if (!slot) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)slot.segment;
        self.currentSliderValue = segment.alpha;
        [self.transparentSlider setSliderValue:self.currentSliderValue * 100];
    });
}


@end
