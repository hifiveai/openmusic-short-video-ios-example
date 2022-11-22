//
//  DVEChangAudioBar.m
//  NLEEditor
//
//  Created by bytedance on 2021/7/6.
//

#import "DVEChangAudioBar.h"
#import "DVEChangAudioItem.h"
#import "NSString+DVEToPinYin.h"
#import "DVEBundleLoader.h"
#import "DVEVCContext.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEUIHelper.h"
#import "NSString+VEToImage.h"
#import <NLEPlatform/NLETrackSlot+iOS.h>
#import <NLEPlatform/NLEEditor+iOS.h>
#import <NLEPlatform/NLEVideoAnimation+iOS.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "NSString+VEToImage.h"
#import "DVEViewController.h"
#import "DVEMaskConfigModel.h"
#import "DVEVideoCutBaseViewController+Private.h"
#import "DVEPickerView.h"
#import "DVEModuleBaseCategoryModel.h"
#import "DVEChangAudioPickerUIDefaultConfiguration.h"
#import "DVELoggerImpl.h"
#import "DVEEffectsBarBottomView.h"
#import <Masonry/Masonry.h>

#define kDVEChangAudioItemIdentifier @"kDVEChangAudioItemIdentifier"

@interface DVEChangAudioBar ()<DVEPickerViewDelegate>

@property (nonatomic, strong) DVEPickerView *pickerView;
@property (nonatomic, strong) NSArray<DVEEffectValue *> *maskModels;

@property (nonatomic, strong) DVEEffectValue *selectedModel;
///底部区域
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, weak) id<DVECoreAudioProtocol> audioEditor;

@end

@implementation DVEChangAudioBar

DVEAutoInject(self.vcContext.serviceProvider, audioEditor, DVECoreAudioProtocol)

- (void)dealloc
{
    DVELogInfo(@"DVEChangAudioBar dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.pickerView];
        [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            id<DVEPickerUIConfigurationProtocol> config = self.pickerView.uiConfig;
            make.height.mas_equalTo(config.effectUIConfig.effectListViewHeight + config.categoryUIConfig.categoryTabListViewHeight);
            make.left.right.equalTo(self);
            make.top.equalTo(self).offset(8);
        }];
        [self addSubview:self.bottomView];
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.pickerView.mas_bottom);
            make.left.right.bottom.equalTo(self);
        }];
    }
    return self;
}

- (DVEPickerView *)pickerView {
    if (!_pickerView) {
        DVEChangAudioPickerUIConfiguration *config = [DVEChangAudioPickerUIConfiguration new];
        _pickerView = [[DVEPickerView alloc] initWithUIConfig:config];
        _pickerView.delegate = self;
    }
    return _pickerView;
}

- (UIView*)bottomView
{
    if(!_bottomView) {
        @weakify(self);
        _bottomView = [DVEEffectsBarBottomView newActionBarWithTitle:NLELocalizedString(@"ck_change_voice",@"变声") action:^{
            @strongify(self);
            [self dismiss:YES];
            [DVEAutoInline(self.vcContext.serviceProvider, DVECoreActionServiceProtocol) refreshUndoRedo];
        }];
    }
    return _bottomView;
}



- (void)setUpData {
    @weakify(self);
    [[DVEBundleLoader shareManager] audioChange:self.vcContext handler:^(NSArray<DVEEffectValue *> * _Nullable datas, NSString * _Nullable error) {
        if(!error){
            NSMutableArray *effectValues = [NSMutableArray new];
            
            DVEEffectValue *value = [DVEEffectValue new];
            value.name = NLELocalizedString(@"ck_none", @"无");
            value.valueState = VEEffectValueStateShuntDown;
            value.assetImage = @"iconFilterwu".dve_toImage;
            value.identifier = value.name;
            [effectValues addObject:value];
            [effectValues addObjectsFromArray:datas];

            DVEModuleBaseCategoryModel *categoryModel = [DVEModuleBaseCategoryModel new];
            DVEEffectCategory* category = [DVEEffectCategory new];
            category.models = effectValues;
            categoryModel.category = category;
            @strongify(self);
            @weakify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                self.maskModels = effectValues;
                self->_selectedModel = [self modelInSlot:[self.vcContext.mediaContext currentMainVideoSlotWithAudioFirst]];
                [self.pickerView updateCategory:@[categoryModel]];
            });

        }
    }];
}

- (void)setSelectedModel:(DVEEffectValue *)selectedModel
{
    NLETrackSlot_OC* slot = [self.vcContext.mediaContext currentMainVideoSlotWithAudioFirst];
    if(_selectedModel == selectedModel || slot == nil)return;
    _selectedModel = selectedModel;

    if(selectedModel == nil || selectedModel.valueState == VEEffectValueStateShuntDown){
        [self.audioEditor removeAudioChangeForSlot:slot];
    }else{
        [self.audioEditor audioChangeForSlot:slot sourcePath:selectedModel.sourcePath sourceName:selectedModel.name];
    }
    [self.vcContext.playerService playFrom:slot.startTime
                                duration:CMTimeGetSeconds(slot.duration)
                           completeBlock:nil];
}

- (BOOL)pickerView:(DVEPickerView *)pickerView isSelected:(DVEEffectValue*)sticker {
    DVEEffectValue *model = (DVEEffectValue*)sticker;
    return [self.selectedModel.identifier isEqualToString:model.identifier];
}

- (void)pickerViewDidClearSticker:(DVEPickerView *)pickerView {
    self.selectedModel = self.maskModels.firstObject;
}

- (void)pickerView:(DVEPickerView *)pickerView
willDisplaySticker:(DVEEffectValue*)sticker
         indexPath:(NSIndexPath *)indexPath {
    
}

- (void)pickerView:(DVEPickerView *)pickerView
  didSelectSticker:(DVEEffectValue*)sticker
          category:(id<DVEPickerCategoryModel>)category
         indexPath:(NSIndexPath *)indexPath {
    
    if ([self.selectedModel.identifier isEqualToString:sticker.identifier]) {
        return;
    }
    DVEEffectValue *model = (DVEEffectValue*)sticker;
    self.selectedModel = model;
    [pickerView updateSelectedStickerForId:model.identifier];
}

- (DVEEffectValue*)modelInSlot:(NLETrackSlot_OC*) slot {
    NLEFilter_OC* filter = slot.audioFilter;
    NLESegmentFilter_OC *seg = filter.segmentFilter;
    NLEResourceNode_OC *node = seg.effectSDKFilter;
    for(DVEEffectValue* model in self.maskModels){
        if([model.name isEqualToString:node.resourceName]){
            return model;
        }
    }
    return self.maskModels.firstObject;//没找到就默认第一个“无”
}

- (void)selectItemAtIndex:(NSInteger)index {
    if(index >= 0 && index < self.maskModels.count){
        [self.pickerView currentCategorySelectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
                                                animated:NO
                                          scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
}

- (void)showInView:(UIView *)view animation:(BOOL)animation
{
    [super showInView:view animation:(BOOL)animation];
    [self setUpData];
    
}

- (void)undoRedoClikedByUser
{
    _selectedModel = [self modelInSlot:[self.vcContext.mediaContext currentMainVideoSlotWithAudioFirst]];
    [self.pickerView updateSelectedStickerForId:self.selectedModel.identifier];
    [self selectItemAtIndex:[self.maskModels indexOfObject:self.selectedModel]];
}

@end
