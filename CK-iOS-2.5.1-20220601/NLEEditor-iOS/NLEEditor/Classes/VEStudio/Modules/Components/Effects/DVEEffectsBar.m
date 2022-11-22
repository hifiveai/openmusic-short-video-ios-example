//
//   DVEEffectsBar.m
//   NLEEditor
//
//   Created  by bytedance on 2021/4/12.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEEffectsBar.h"
#import "DVEPickerView.h"
#import "DVEVCContext.h"
#import "DVEBundleLoader.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEEffectsPickerUIDefaultConfiguration.h"
#import "DVEEffectsBarBottomView.h"
#import "DVEModuleBaseCategoryModel.h"
#import "DVECustomerHUD.h"
#import "DVEMixedEffectItem.h"
#import "DVEEditorEventProtocol.h"
#import "DVEServiceLocator.h"
#import <Masonry/Masonry.h>

@interface DVEEffectsBar() <DVEPickerViewDelegate>

///特效区域
@property (nonatomic, strong) DVEPickerView *effectsPickerView;
///底部区域
@property (nonatomic, strong) UIView *bottomView;
///当前选中特效
@property (nonatomic, strong) DVEEffectValue *curValue;
///特效数据源
@property (nonatomic, strong) NSArray<DVEModuleBaseCategoryModel *> *effectsDataSource;
///新增特效ID
@property (nonatomic, strong) NSString* effectObjID;
///初始特效
@property (nonatomic, strong) NSString *itValue;

@property (nonatomic, weak) id<DVECoreEffectProtocol> effectEditor;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;

@end

@implementation DVEEffectsBar

DVEAutoInject(self.vcContext.serviceProvider, effectEditor, DVECoreEffectProtocol)
DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    
    return self;
}


#pragma mark - private Method

- (void)initView
{
    [self addSubview:self.effectsPickerView];
    [self.effectsPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        id<DVEPickerUIConfigurationProtocol> config = self.effectsPickerView.uiConfig;
        make.height.mas_equalTo(config.effectUIConfig.effectListViewHeight + config.categoryUIConfig.categoryTabListViewHeight);
        make.top.left.right.equalTo(self);
    }];
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.effectsPickerView.mas_bottom);
        make.left.right.bottom.equalTo(self);
    }];
}

- (void)initData
{
    [self.effectsPickerView updateLoading];
    
    [self.vcContext.playerService pause];
    NLETimeSpaceNode_OC *timespaceNode = self.vcContext.mediaContext.selectEffectSegment;
    NLETrackSlot_OC* slot = nil;
    NLESegmentEffect_OC* seg = nil;
    NSString* inUse = nil;
    NSString* sourcePath = nil;
    
    
    if ([timespaceNode isKindOfClass:NLETrackSlot_OC.class]) {
        slot = (NLETrackSlot_OC *)timespaceNode;
        seg =  (NLESegmentEffect_OC*)slot.segment;
        NLEResourceNode_OC *resEffect = seg.effectSDKEffect;
        sourcePath = resEffect.resourceFile;
        inUse = seg.effectName;
        sourcePath = seg.effectSDKEffect.resourceFile;
        self.effectObjID = seg.effectSDKEffect.nle_nodeId;
    }else if([timespaceNode isKindOfClass:NLEEffect_OC.class]){//局部特效
        NLEEffect_OC* effect = (NLEEffect_OC*)timespaceNode;
        seg =  effect.segmentEffect;
        self.effectObjID = seg.effectSDKEffect.nle_nodeId;
        inUse = seg.effectName;
        sourcePath = seg.effectSDKEffect.resourceFile;
    }

    ///检查当前使用特效名称
    if(inUse && sourcePath){
        DVEEffectValue* eff = [DVEEffectValue new];
        eff.name = inUse;
        eff.sourcePath = sourcePath;
        eff.identifier = eff.name;
        eff.valueState = VEEffectValueStateInUse;
        _curValue = eff;
        self.itValue = eff.identifier;
    }
    
    @weakify(self);
    [[DVEBundleLoader shareManager] effectCategory:self.vcContext handler:^(NSArray<DVEEffectCategory *> * _Nullable categorys, NSString * _Nullable error) {
        @strongify(self);
        NSMutableArray *valueArr = [NSMutableArray new];
        for(DVEEffectCategory* cat in categorys){
            DVEModuleBaseCategoryModel* category = [DVEModuleBaseCategoryModel new];
            category.category = cat;
            [valueArr addObject:category];
        }
        
        @weakify(self);
        ///目前贴纸只支持单类
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if(!error){
                self.effectsDataSource = valueArr;
                [self.effectsPickerView updateCategory:self.effectsDataSource];
                if(self.effectsDataSource.count > 0){
                    [self pickerView:self.effectsPickerView didSelectTabIndex:0];
                }
                [self.effectsPickerView updateFetchFinish];
            }else{
                [DVECustomerHUD showMessage:error];
                [self.effectsPickerView updateFetchError];
            }
        });
    }];
}

-(void)showInView:(UIView *)view animation:(BOOL)animation{
    [super showInView:view animation:(BOOL)animation];
    [self initData];
}


#pragma mark - layz Method

- (void)setCurValue:(DVEEffectValue *)curValue {
    
    if(curValue){
        if(_curValue){///已有特效，则做替换操作
            [self.effectEditor updateNLEEffect:self.effectObjID
                                    resourceId:curValue.identifier
                                          name:curValue.name
                                       resPath:curValue.sourcePath
                                    needCommit:NO];
            NLETrackSlot_OC* slot = [self.effectEditor slotByeffectObjID:self.effectObjID];
            [self.vcContext.playerService playFrom:slot.startTime
                                        duration:CMTimeGetSeconds(slot.duration)
                                   completeBlock:nil];
        }else{//没有特效，默认添加特效到主轨道
            CGFloat endSecond = MIN((CMTimeGetSeconds(self.vcContext.mediaContext.currentTime) + 3), CMTimeGetSeconds(self.vcContext.mediaContext.duration));
            id<DVEEditorEventProtocol> config = DVEOptionalInline(self.vcContext.serviceProvider, DVEEditorEventProtocol);
            if ([config respondsToSelector:@selector(onlyUseGlobalEffect)] && [config onlyUseGlobalEffect]) {
                self.effectObjID = [self.effectEditor addGlobalNewEffectWithPath:curValue.sourcePath
                                                                            name:curValue.name
                                                                       startTime:self.vcContext.mediaContext.currentTime
                                                                         endTime:CMTimeMakeWithSeconds(endSecond, USEC_PER_SEC)
                                                                     resourceTag:(NLEResourceTag)curValue.resourceTag
                                                                      resourceId:curValue.identifier
                                                                           layer:-1
                                                                      needCommit:NO];
            } else {
                self.effectObjID = [self.effectEditor addPartlyNewEffectWithPath:curValue.sourcePath
                                                                            name:curValue.name
                                                                      identifier:curValue.identifier
                                                                       startTime:self.vcContext.mediaContext.currentTime
                                                                         endTime:CMTimeMakeWithSeconds(endSecond, USEC_PER_SEC)
                                                                         forNode:[self.nleEditor.nleModel nle_getMainVideoTrack]
                                                                     resourceTag:(NLEResourceTag)curValue.resourceTag
                                                                      needCommit:NO];
            }
            NLETrackSlot_OC* slot = [self.effectEditor slotByeffectObjID:self.effectObjID];
            [self.vcContext.playerService playFrom:slot.startTime
                                        duration:CMTimeGetSeconds(slot.duration)
                                   completeBlock:nil];
        }
    }
    else if(_curValue){//删除特效
        [self.effectEditor deleteNLEEffect:self.effectObjID needCommit:NO];
        self.effectObjID = nil;
    }
    _curValue = curValue;
}

- (DVEPickerView *)effectsPickerView {

    if (!_effectsPickerView) {
        _effectsPickerView = [[DVEPickerView alloc] initWithUIConfig:[DVEEffectsPickerUIDefaultConfiguration new]];
        _effectsPickerView.delegate = self;
        _effectsPickerView.backgroundColor = [UIColor clearColor];
    }
    return _effectsPickerView;
}

- (UIView*)bottomView
{
    if(!_bottomView) {
        @weakify(self);
        _bottomView = [DVEEffectsBarBottomView newActionBarWithTitle:NLELocalizedString(@"ck_effect",@"特效") action:^{
            @strongify(self);
            
            if(!(self.itValue == nil && self.curValue == nil) && ![self.itValue isEqualToString:self.curValue.identifier]){
                [self.actionService commitNLE:YES];
            }

            [self dismiss:YES];
            [self.actionService refreshUndoRedo];
            if(self.effectObjID && !self.vcContext.mediaContext.selectEffectSegment){
                NLETrackSlot_OC* slot = [self.effectEditor slotByeffectObjID:self.effectObjID];
                self.vcContext.mediaContext.selectEffectSegment = slot;
                [DVECustomerHUD showMessage:NLELocalizedString(@"ck_tips_add_effect_track_success",@"添加特效轨道成功") afterDele:1.0];
            }
        }];
    }
    return _bottomView;
}

#pragma mark - AWEStickerPickerViewDelegate

- (void)pickerView:(DVEPickerView *)pickerView didSelectTabIndex:(NSInteger)index{
    DVEModuleBaseCategoryModel* ca = self.effectsDataSource[index];
    if(ca.category.models.count == 0){
        [pickerView updateLoadingWithTabIndex:index];
        [[DVEBundleLoader shareManager] effect:self.vcContext category:ca.category handler:^(NSArray<DVEEffectValue *> * _Nullable datas, NSString * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!error){
                    ca.category.models = datas;
                    [pickerView updateFetchFinishWithTabIndex:index];
                }else{
                    [DVECustomerHUD showMessage:error];
                }
            });
        }];
    }
}

- (BOOL)pickerView:(DVEPickerView *)pickerView isSelected:(DVEEffectValue*)sticker{
    return [sticker.name isEqualToString:self.curValue.name];
}

- (void)pickerView:(DVEPickerView *)pickerView
         didSelectSticker:(DVEEffectValue*)sticker
                 category:(id<DVEPickerCategoryModel>)category
         indexPath:(NSIndexPath *)indexPath{
    DVEEffectValue* model = sticker;
    if(model.status == DVEResourceModelStatusDefault){
        if([self.curValue.identifier isEqualToString:model.identifier]){
            self.curValue = nil;
            [pickerView updateSelectedStickerForId:@""];
            return;
        }
        
        self.curValue = model;
        [pickerView updateSelectedStickerForId:model.identifier];
        return;
    }else if(model.status == DVEResourceModelStatusNeedDownlod || model.status == DVEResourceModelStatusDownlodFailed){
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
    [pickerView updateStickerStatusForId:model.identifier];
}

- (void)pickerViewDidClearSticker:(DVEPickerView *)pickerView{
    self.curValue = nil;
    [pickerView updateSelectedStickerForId:@""];
}

- (void)pickerView:(DVEPickerView *)pickerView willDisplaySticker:(DVEEffectValue*)sticker indexPath:(NSIndexPath *)indexPath{
    
}
@end
