//
//  DVEAnimationBar.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEAnimationBar.h"
#import "DVEAnimationItemCell.h"
#import "NSString+DVEToPinYin.h"
#import "DVEBundleLoader.h"
#import "DVEVCContext.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEUIHelper.h"
#import "DVEEffectsBarBottomView.h"
#import "NSString+VEToImage.h"
#import "DVEPickerView.h"
#import "DVELoggerImpl.h"
#import "DVEModuleBaseCategoryModel.h"
#import "DVEAnimationPickerUIDefaultConfiguration.h"
#import <NLEPlatform/NLETrackSlot+iOS.h>
#import <NLEPlatform/NLEEditor+iOS.h>
#import <NLEPlatform/NLEVideoAnimation+iOS.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>
#import <DVETrackKit/UIView+VEExt.h>

#define kVEVCAnimationBarIdentifier @"kVEVCAnimationBarIdentifier"

static const CGFloat kAnimationMinSec = 0.3;

@interface DVEAnimationBar ()<DVEPickerViewDelegate>

@property (nonatomic, strong) DVEEffectValue *curValue;
@property (nonatomic) BOOL isValueChanged;
///动画区域
@property (nonatomic, strong) DVEPickerView *animationPickerView;
///底部区域
@property (nonatomic, strong) DVEEffectsBarBottomView *bottomView;
///动画数据源
@property (nonatomic, strong) NSArray<DVEModuleBaseCategoryModel *> *animationDataSource;
//动画时长标签
@property (nonatomic, strong) UILabel *animationLabel;

@property (nonatomic, weak) id<DVECoreAnimationProtocol> animationEditor;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@end

@implementation DVEAnimationBar

DVEAutoInject(self.vcContext.serviceProvider, animationEditor, DVECoreAnimationProtocol)
DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

- (void)dealloc
{
    DVELogInfo(@"VEVCAnimationBar dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    
    return self;
}

- (void)initView
{
    [self addSubview:self.animationPickerView];
    [self.animationPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        id<DVEPickerUIConfigurationProtocol> config = self.animationPickerView.uiConfig;
        make.height.mas_equalTo(config.effectUIConfig.effectListViewHeight + config.categoryUIConfig.categoryTabListViewHeight);
        make.top.equalTo(self).mas_offset(60);
        make.left.right.equalTo(self);
    }];
    
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.animationPickerView.mas_bottom);
        make.left.right.bottom.equalTo(self);
    }];

    CGFloat sliderY = 18;
    CGFloat sliderWidth = CGRectGetWidth(self.frame) * 0.75;

    self.animationLabel.frame = CGRectMake(16, sliderY, 60, 20);
    [self addSubview:self.animationLabel];

    [self.slider removeFromSuperview];
    self.slider = [[DVEStepSlider alloc] initWithStep:1 defaultValue:kAnimationMinSec frame:CGRectMake(self.animationLabel.right + 10, sliderY, sliderWidth, 20)];
    self.slider.valueType = DVEStepSliderValueTypeSecond;
    self.slider.backgroundColor = self.backgroundColor;
    [self addSubview:self.slider];

    [self initSlider];
}

- (void)initData
{
    @weakify(self);
    DVEModuleModelHandler handler = ^(NSArray<DVEEffectValue *> * _Nullable datas, NSString * _Nullable error){
        @strongify(self);
        [self performSelectorOnMainThread:@selector(initData:) withObject:datas waitUntilDone:NO];
    };
    switch (self.type) {
        case DVEModuleCutSubTypeAnimationTypeAdmission:
        {
            [self.bottomView setTitleText: NLELocalizedString(@"ck_anim_in",@"入场动画")];
            [[DVEBundleLoader shareManager] animationIn:self.vcContext handler:handler];
        }
            break;
        case DVEModuleCutSubTypeAnimationTypeDisappear:
        {
            [self.bottomView setTitleText:NLELocalizedString(@"ck_anim_out",@"出场动画")];
            [[DVEBundleLoader shareManager] animationOut:self.vcContext handler:handler];
        }
            break;
        case DVEModuleCutSubTypeAnimationTypeCombination:
        {
            [self.bottomView setTitleText:NLELocalizedString(@"ck_anim_all",@"组合动画")];
            [[DVEBundleLoader shareManager] animationCombin:self.vcContext handler:handler];
        }
            break;
            
        default:
            break;
    }
}

-(void)initData:(NSArray<DVEEffectValue *> *)animationArr
{
    if (![self.vcContext.mediaContext currentBlendVideoSlot]) {
        return;
    }
    NSMutableArray *valueArr = [NSMutableArray new];
    DVEEffectValue *none = [DVEEffectValue new];
    none.valueState = VEEffectValueStateShuntDown;
    none.assetImage = @"iconFilterwu".dve_toImage;
    none.name = NLELocalizedString(@"ck_none", @"无");
    none.identifier = none.name;
    none.sourcePath = none.name;
    [valueArr addObject:none];

    DVEModuleBaseCategoryModel *categoryModel = [DVEModuleBaseCategoryModel new];
    DVEEffectCategory* category = [DVEEffectCategory new];
    categoryModel.category = category;
    [valueArr addObjectsFromArray:animationArr];
    category.models = valueArr;
    
    self.animationDataSource = @[categoryModel];
    [self.animationPickerView updateCategory:self.animationDataSource];

    CGFloat maxTransition = CMTimeGetSeconds([[self.vcContext.mediaContext currentBlendVideoSlot] duration]);
    
    [self.slider setValueRange:DVEMakeFloatRang(kAnimationMinSec, maxTransition) defaultProgress:self.type == DVEModuleCutSubTypeAnimationTypeCombination ? maxTransition:kAnimationMinSec];
    
    DVEEffectValue *evalue = [self currentSlotEffectValue:self.type];
    if (!evalue) {
        evalue = none;
    }
    
    for(NSInteger index = 0 ;index < valueArr.count ; index++){
        DVEEffectValue* value = valueArr[index];
        if([value.identifier isEqualToString:evalue.identifier]){
            value.indesty = evalue.indesty;
            if(value.valueState == VEEffectValueStateShuntDown){
                [self setSliderHidden:YES];
            }else{
                value.valueState = VEEffectValueStateInUse;
                [self setSliderHidden:NO];
                self.slider.value = evalue.indesty;
            }
            _curValue = value;
            [self.animationPickerView currentCategorySelectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
            return;
        }
    }
    
    if (![self updateAnimationSlider]) {
        _curValue = none;
        [self setSliderHidden:YES];
    }
}

- (void)initSlider
{
    [self setSliderHidden:YES];
    @weakify(self);
    [[self.slider rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        DVELogInfo(@"-----------%@",x);
        self.isValueChanged = YES;
        self.curValue.indesty = self.slider.value;
        [self playAnimationWithDuration:self.slider.value value:self.curValue];
        if ([self.vcContext.mediaContext currentBlendVideoSlot]) {///刷新轨道动画遮罩
            self.vcContext.mediaContext.videoAnimationValueChangePayload = [[DVEVideoAnimationChangePayload alloc] initWithSlotId:[self.vcContext.mediaContext currentBlendVideoSlot].nle_nodeId duration:self.curValue.indesty];
        }
        
    }];
}

- (void)setSliderHidden:(BOOL)hidden
{
    self.slider.hidden = hidden;
    self.animationLabel.hidden = hidden;
}

- (void)commitChange
{
    self.vcContext.playerService.needPausePlayerTime = -1;
    if (self.isValueChanged) {
        self.isValueChanged = NO;
        [self.actionService commitNLE:YES];
    }

    [self.actionService refreshUndoRedo];
    self.vcContext.mediaContext.shouldShowVideoAnimation = NO;
}

- (UIView*)bottomView
{
    if(!_bottomView) {
        @weakify(self);
        _bottomView = [DVEEffectsBarBottomView newActionBarWithTitle:@"动画" action:^{
            @strongify(self);
            [self commitChange];
            [self dismiss:YES];
        }];
    }
    return _bottomView;
}

- (UILabel *)animationLabel {
    if (!_animationLabel) {
        _animationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 48, 20)];
        _animationLabel.text = NLELocalizedString(@"ck_anim_duration", @"动画时长");
        _animationLabel.font = SCRegularFont(12);
        _animationLabel.textColor = [UIColor whiteColor];
        _animationLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _animationLabel;
}

- (DVEPickerView *)animationPickerView {
    if(!_animationPickerView) {
        _animationPickerView = [[DVEPickerView alloc] initWithUIConfig:[DVEAnimationPickerUIDefaultConfiguration new]];
        _animationPickerView.delegate = self;
        _animationPickerView.backgroundColor = [UIColor clearColor];
    }
    
    return _animationPickerView;
}

- (void)setCurValue:(DVEEffectValue *)curValue {
    if(curValue){
        if (curValue.valueState == VEEffectValueStateShuntDown) {////选择“无”
            if(_curValue != nil &&_curValue.valueState != VEEffectValueStateShuntDown){//如果原来就是“无”，则不需要播放
                [self.animationEditor deleteVideoAnimation];
                [self playFromCurrentTime:_curValue.indesty];
            }
        }else{///选择”动画“
            if(_curValue == curValue){///跟现有动画相同则只做播放
                [self playFromCurrentTime:curValue.indesty];
                return;
            }else{///添加动画
                [self playAnimationWithDuration:curValue.indesty value:curValue];
            }
        }
    }///设置为nil，如果现在有动画，则删除动画
    else if(_curValue && _curValue.valueState != VEEffectValueStateShuntDown){
        [self.animationEditor deleteVideoAnimation];
        [self playFromCurrentTime:_curValue.indesty];
    }
    
    _curValue = curValue;
    
    if ([self.vcContext.mediaContext currentBlendVideoSlot]) {///刷新轨道动画遮罩
        self.vcContext.mediaContext.videoAnimationValueChangePayload = [[DVEVideoAnimationChangePayload alloc] initWithSlotId:[self.vcContext.mediaContext currentBlendVideoSlot].nle_nodeId duration:curValue.indesty];
    }
    
}

#pragma mark - AWEStickerPickerViewDelegate

- (BOOL)pickerView:(DVEPickerView *)pickerView isSelected:(DVEEffectValue*)sticker{
    return [sticker.identifier isEqualToString:self.curValue.identifier];
}

- (void)pickerView:(DVEPickerView *)pickerView
         didSelectSticker:(DVEEffectValue*)sticker
                 category:(id<DVEPickerCategoryModel>)category
         indexPath:(NSIndexPath *)indexPath{

    
    DVEEffectValue *animationValue = sticker;
    if(animationValue.status == DVEResourceModelStatusDefault){
        if(self.curValue == animationValue){
            self.curValue = animationValue;///触发重新播放逻辑
            return;
        }
        
        //更新上次选择的“动画”状态为none，如果是清空“动画”对象不做状态更新
        if(self.curValue.valueState == VEEffectValueStateShuntDown){
            
        }else{
            self.curValue.valueState = VEEffectValueStateNone;
        }
        
        //更新目前选择的“动画”状态为inUse，如果是清空“动画”对象不做状态更新
        if(indexPath.row == 0){
            [self setSliderHidden:YES];
        }else{
            [self setSliderHidden:NO];
            animationValue.valueState = VEEffectValueStateInUse;
        }
        
        animationValue.indesty = self.slider.value;
        self.curValue = animationValue;
        self.isValueChanged = YES;
        [pickerView updateSelectedStickerForId:self.curValue.identifier];
        return;
    }else if(animationValue.status == DVEResourceModelStatusNeedDownlod || animationValue.status == DVEResourceModelStatusDownlodFailed){
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
    [self updateAnimationSlider];
    [pickerView updateStickerStatusForId:animationValue.identifier];
    
}

- (void)pickerView:(DVEPickerView *)pickerView didSelectTabIndex:(NSInteger)index{
    
}


- (void)pickerViewDidClearSticker:(DVEPickerView *)pickerView {
    
}

#pragma mark -

- (void)playAnimationWithDuration:(NSTimeInterval)duration value:(DVEEffectValue *)value  {
    if (![self.vcContext.mediaContext currentBlendVideoSlot]) {
        return;
    }
    DVELogInfo(@"playAnimationWithDuration----%0.1f",duration);

    [self.animationEditor addAnimation:value.sourcePath identifier:value.identifier withType:self.type duration:duration];
    [self playFromCurrentTime:duration];
}

-(void)playFromCurrentTime:(NSTimeInterval)duration {
    CMTime startTime = kCMTimeZero;
    CGFloat playDuration = duration;
    
    switch (self.type) {
        case DVEModuleCutSubTypeAnimationTypeCombination:///组合动画从头播放
        case DVEModuleCutSubTypeAnimationTypeAdmission:///入场动画从头播放
        {
            startTime = [self.vcContext.mediaContext currentBlendVideoSlot].startTime;
        }
            break;
        case DVEModuleCutSubTypeAnimationTypeDisappear:///出场动画从结尾往前duration开始播放
        {
            startTime =  CMTimeMakeWithSeconds(CMTimeGetSeconds([self.vcContext.mediaContext currentBlendVideoSlot].endTime) - playDuration, USEC_PER_SEC);
            
        }
            break;
            
        default:
            break;
    }
    
    

    [self.vcContext.playerService playFrom:startTime duration:playDuration completeBlock:nil];
}

#pragma mark - show view

- (void)setType:(DVEModuleCutSubTypeAnimationType)type
{
    _type = type;
    [self initData];
}

- (void)showInView:(UIView *)view animation:(BOOL)animation
{
    [super showInView:view animation:(BOOL)animation];
    self.vcContext.mediaContext.disableUpdateSelectedVideoSegment = YES;
    self.actionService.isNeedHideUnReDo = YES;
    [self initData];
}

- (void)dismiss:(BOOL)animation
{
    [super dismiss:animation];
    self.vcContext.mediaContext.disableUpdateSelectedVideoSegment = NO;
    [self commitChange];
}

- (void)undoRedoClikedByUser
{
    ///前次特效对象状态重制，跳过VEEffectValueStateShuntDown态的“无”选项
    if(_curValue && _curValue.valueState != VEEffectValueStateShuntDown){
        _curValue.valueState = VEEffectValueStateNone;
    }
    _curValue = nil;
    [self setSliderHidden:YES];
    [self.animationPickerView reloadData];
    
    
    CGFloat maxTransition = CMTimeGetSeconds([[self.vcContext.mediaContext currentBlendVideoSlot] duration]);
    [self.slider setValueRange:DVEMakeFloatRang(kAnimationMinSec, maxTransition) defaultProgress:self.type == DVEModuleCutSubTypeAnimationTypeCombination ? maxTransition:kAnimationMinSec];
    
    DVEEffectValue *evalue = [self currentSlotEffectValue:self.type];
    if (evalue) {
        NSArray *valueArr = self.animationDataSource.firstObject.models;
        for(NSInteger index = 0 ;index < valueArr.count ; index++){
            DVEEffectValue* value = valueArr[index];
            if([value.sourcePath isEqualToString:evalue.sourcePath]){
                value.indesty = evalue.indesty;
                if(value.valueState == VEEffectValueStateShuntDown){
                    [self setSliderHidden:YES];
                }else{
                    value.valueState = VEEffectValueStateInUse;
                    [self setSliderHidden:NO];
                    self.slider.value = evalue.indesty;
                }
                _curValue = value;
                [self.animationPickerView currentCategorySelectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
                break;
            }
        }
    }
    [self updateAnimationSlider];
}

- (DVEEffectValue *)currentSlotEffectValue:(DVEModuleCutSubTypeAnimationType)type
{
    NLETrackSlot_OC* selectSlot = [self.vcContext.mediaContext currentBlendVideoSlot];
    
    AVURLAsset *asset = [self.nle assetFromSlot:selectSlot];
    if (!asset) return nil;
    
    NLEVideoAnimationType animationType = [self videoAnimationFor:type];
    
    for(NLEVideoAnimation_OC *animation in [selectSlot getVideoAnims]){
        if(animation.nle_animationType == animationType){
            NLESegmentVideoAnimation_OC* segmentVideoAnimation = animation.segmentVideoAnimation;
            NLEResourceNode_OC *resource = segmentVideoAnimation.effectSDKVideoAnimation;
            DVEEffectValue* value = [DVEEffectValue new];
            value.indesty = CMTimeGetSeconds(segmentVideoAnimation.animationDuration);
            value.sourcePath = resource.resourceFile;
            value.identifier = resource.resourceId;
            return value;
        }
    }
    
    return nil;
}

-(NLEVideoAnimationType)videoAnimationFor:(DVEModuleCutSubTypeAnimationType)type {
    NLEVideoAnimationType animationType = NLEVideoAnimationTypeNone;
    switch (type) {
        case DVEModuleCutSubTypeAnimationTypeAdmission: {
            animationType = NLEVideoAnimationTypeIn;
        }
            break;
        case DVEModuleCutSubTypeAnimationTypeCombination: {
            animationType = NLEVideoAnimationTypeCombination;
        }
            break;
        case DVEModuleCutSubTypeAnimationTypeDisappear: {
            animationType = NLEVideoAnimationTypeOut;
        }
            break;
    }
    return animationType;
}

- (BOOL)updateAnimationSlider
{
    NLEVideoAnimationType type = [self videoAnimationFor:self.type];
    NSDictionary *dic = [self.animationEditor currentAnimationDuration:type];
    NSString *identifier = [dic objectForKey:@"identifier"];
    if (dic && identifier) {
        NSNumber *animationDuration = [dic objectForKey:identifier];
        if (animationDuration.floatValue >= kAnimationMinSec) {
            self.slider.value = animationDuration.floatValue;
            NSArray* models = self.animationDataSource.firstObject.models;
            for (NSInteger i = 1; i < models.count; i ++) {//忽略第一个“无”
                DVEEffectValue *model = models[i];
                if ([model.identifier isEqualToString:identifier]) {
                    model.indesty = animationDuration.floatValue;
                    _curValue = model;
                    model.valueState = VEEffectValueStateInUse;
                    [self setSliderHidden:NO];
                    [self.animationPickerView updateSelectedStickerForId:identifier];
                    return YES;
                }
            }
        }
    }
    return NO;
}


@end
