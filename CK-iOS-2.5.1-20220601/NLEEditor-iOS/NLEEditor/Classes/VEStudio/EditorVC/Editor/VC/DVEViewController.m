//
//  DVEViewController.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEViewController.h"
#import "DVEVideoCutBaseViewController+Private.h"
#import "DVEVideoCutBaseViewController+layout.h"
#import "DVEResourcePickerProtocol.h"
#import "DVEVCContext.h"
#import "DVELoggerImpl.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>
#import <DVETrackKit/DVETransformEditView.h>
#import "DVEPreview.h"
#import "DVEEffectsBarBottomView.h"
#import "DVECanvasVideoBorderView.h"
#import <DVETrackKit/DVEVideoTransitionModel.h>
#import "DVEComponentViewManager.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVETextTemplateInputManager.h"
#import <DVETrackKit/DVECustomResourceProvider.h>
#import <DVETrackKit/DVEUILayout.h>
#import "DVEReportUtils.h"
#import "NSBundle+DVE.h"
#import "DVEEditorEventProtocol.h"
#import "DVENotification.h"
#import "DVECoreDraftServiceProtocol.h"
#import "DVEComponentModelFactory.h"
#import "DVEServiceLocator.h"
#import "DVEGlobalExternalInjectProtocol.h"
#import "DVECoreMaskProtocol.h"
#import "DVEToast.h"
#import "DVEStickerEditAdpter.h"

@interface DVEViewController () <
DVEMediaTimelineViewDelegate,
DVEVideoTrackPreviewTransitionDelegate,
UIGestureRecognizerDelegate,
DVECoreActionNotifyProtocol,
DVEStickerEditAdpterDelegate
>

@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;

@end

@implementation DVEViewController

DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)

@synthesize vcContext = _vcContext;

#pragma mark - instance LifeCycle

- (void)dealloc
{
    [[DVEComponentViewManager sharedManager] unSetupTreeComponents];
    DVELogInfo(@"DVEViewController dealloc");
    _vcContext = nil;
}

+ (instancetype)vcWithResources:(NSArray<id<DVEResourcePickerModel>> *)resources
{
    return [[self alloc] initWithResources:resources injectService:nil];;
}

+ (instancetype)vcWithResources:(NSArray<id<DVEResourcePickerModel>> *)resources
                  injectService:(id<DVEVCContextExternalInjectProtocol>)injectService
{
    return [[self alloc] initWithResources:resources injectService:injectService];
}

- (instancetype)initWithResources:(NSArray<id<DVEResourcePickerModel>> *)resources
                    injectService:(id<DVEVCContextExternalInjectProtocol>)injectService
{
    self = [super init];
    if (self) {
        _resources = [resources copy];
        if (_resources.count > 0) {
            self.vcContext = [[DVEVCContext alloc] initWithModels:resources injectService:injectService];
            [DVETextTemplateInputManager sharedInstance].parentVC = self;
        }
    }
    return self;
}

- (instancetype)initWithDraftModel:(DVEDraftModel *)draftModel
                     injectService:(id<DVEVCContextExternalInjectProtocol>)injectService
{
    self = [super init];
    if (self) {
        self.vcContext = [[DVEVCContext alloc] initWithDraftModel:draftModel injectService:injectService];
        [DVETextTemplateInputManager sharedInstance].parentVC = self;
    }
    return self;
}

- (instancetype)initWithModelString:(NSString *)nleModelString draftFolder:(NSString *)draftFolder injectService:injectService
{
    self = [super init];
    if (self) {
        self.vcContext = [[DVEVCContext alloc] initWithNLEModelString:nleModelString draftFolder:draftFolder injectService:injectService];
        [DVETextTemplateInputManager sharedInstance].parentVC = self;
        [self.vcContext.mediaContext updateMappingTimelineVideoSlot];
    }
    
    return self;
}

#pragma mark - VC LifeCycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.vcContext.playerService pause];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = HEXRGBCOLOR(0x181718);
    self.navigationController.navigationBar.hidden = YES;
    
    [self initBarManager];
    
    [self p_createSenceWithPreview:self.videoView.preview];
    self.videoView.vcContext = self.vcContext;
    [self buildVEVCLayout];

    self.timeLineView.timelineDelegate = self;
    self.timeLineView.containerView.transitionDelegate = self;
    self.stickerEditAdatper.delegate = self;
    [self initAddMethod];

    [self initRACObserve];
    [DVEAutoInline(self.vcContext.serviceProvider, DVECoreActionServiceProtocol) refreshUndoRedo];

    self.videoView.parentVC = self;
    self.videoView.toolview.parentVC = self;
    
    //非草稿路径进入时，应用自定义画布比例
    if (self.resources.count > 0) {
        [self setCanvasRatio:(DVECanvasRatio)[DVEUILayout dve_sizeNumberWithName:DVEUILayoutDefaultCanvasRatio]];
    }
    NSDictionary *dic = [[NSDictionary alloc] init];
    [DVEReportUtils logEvent:@"video_edit_page_show" params:dic];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
#ifdef DEBUG
   return YES; //YES：允许右滑返回 NO：禁止右滑返回
#else
    return NO;
#endif
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [DVEUILayout dve_styleWithName:DVEUILayoutStatusBarStyle];
}

- (void)releaseResouce
{
    [[DVECustomResourceProvider shareManager] clearCache];
}

#pragma mark - VC Data init

- (void)initAddMethod
{
    @weakify(self);
    [[self.addButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        id<DVEResourcePickerProtocol> resourcePicker = DVEOptionalInline(self.vcContext.serviceProvider, DVEResourcePickerProtocol);
        [resourcePicker pickResourcesWithCompletion:^(NSArray<id<DVEResourcePickerModel>> * _Nonnull resources, NSError * _Nullable error, BOOL cancel) {
            @strongify(self);
            [DVEAutoInline(self.vcContext.serviceProvider, DVECoreImportServiceProtocol) addResources:resources completion:^{
                @strongify(self);
                self.vcContext.mediaContext.selectMainVideoSegment = nil;
            }];
            
            if (resources.count > 0) {
                NSDictionary *dic = @{@"type": @"main"};
                [DVEReportUtils logEvent:@"video_edit_import_complete_click" params:dic];
            }
        }];
    }];
}

- (void)initBarManager
{
    id<DVEBarComponentProtocol> comp = [DVEComponentModelFactory createComponentWithType:DVEBarComponentTypeRoot parent:nil createSubComponent:YES];
    [[DVEComponentViewManager sharedManager] setupTreeComponents:comp parentVC:self context:self.vcContext];
}

- (void)initRACObserve
{
    @weakify(self);
    [[RACObserve(self.vcContext.mediaContext, selectMainVideoSegment).distinctUntilChanged skip:1] subscribeNext:^(NLETrackSlot_OC *  _Nullable selectedSegment) {
        @strongify(self);
        [self showCanvasBorderIfNeededEnableGesture:YES];
        
        if (selectedSegment) {
            [self.vcContext.playerService pause];///选中轨道要停止播放
            [[DVEComponentViewManager sharedManager] showComponentType:DVEBarComponentTypeCut];
            
            [DVEAutoInline(self.vcContext.serviceProvider, DVECoreKeyFrameProtocol) refreshAllKeyFrameIfNeedWithSlot:selectedSegment];
        } else {
            [self dismissEditStickerView];
//            if ([[DVEComponentViewManager sharedManager] currentBarType] == DVEBarComponentTypeCut) {
                ///返回编辑节点的父节点层级
//                [[DVEComponentViewManager sharedManager] backToParentComponent];
            /*
             如果不弹出到根，则在有多级子菜单时，只是弹出到上一个菜单，不合理，比如主
             轨里有动画，动画里有入场和出场动画。
             1、用户滑动出当前选择范围，应该显示混合多轨
             2、用户选择一个贴纸，应该显示贴纸
            */
//            [[DVEComponentViewManager sharedManager] backToParentComponent];
            [[DVEComponentViewManager sharedManager] popToRoot];
//            }
        }

    }];
 
    
    [[RACObserve(self.vcContext.mediaContext, selectBlendVideoSegment).distinctUntilChanged skip:1] subscribeNext:^(NLETrackSlot_OC *  _Nullable selectedSegment) {
        @strongify(self);
        [self showCanvasBorderIfNeededEnableGesture:YES];
        if (selectedSegment) {
            [self.vcContext.playerService pause];///选中轨道要停止播放
            [[DVEComponentViewManager sharedManager] showComponentType:DVEBarComponentTypeBlendCut];
            
            [DVEAutoInline(self.vcContext.serviceProvider, DVECoreKeyFrameProtocol) refreshAllKeyFrameIfNeedWithSlot:selectedSegment];
        } else {
            [self dismissEditStickerView];
            if ([[DVEComponentViewManager sharedManager] currentBarType] == DVEBarComponentTypeCut) {
                ///返回编辑节点的父节点层级
                [[DVEComponentViewManager sharedManager] backToParentComponent];
            } else {
                [[DVEComponentViewManager sharedManager] popToComponent:DVEBarComponentTypePicInPic groupTpye:DVEBarSubComponentGroupAdd];
            }
        }
    }];

    
    // 轨道区片段时长调整 (任意轨道)
    [[[RACObserve(self.vcContext.mediaContext, changedTimeRangeSlot) distinctUntilChanged] skip:1] subscribeNext:^(NSString *  _Nullable segmentId) {
        @strongify(self);
        DVELogInfo(@"changed time range:%@",[segmentId class]);
        [self p_handleChangedSlotTimeRange:segmentId];
    }];
    
    // 当前时间标尺下是否有选中的一个文本&贴纸片段
    [[[RACObserve(self.vcContext.mediaContext, selectTextSlotAtCurrentTime) distinctUntilChanged] skip:1] subscribeNext:^(NLETrackSlot_OC *  _Nullable selectedSlot) {
        @strongify(self);
        DVELogInfo(@"----------%@",[selectedSlot.segment class]);
        if (selectedSlot) {
            BOOL isTextSticker = [selectedSlot.segment isKindOfClass:NLESegmentTextSticker_OC.class];
            BOOL isTextTemplateSticker = [selectedSlot.segment isKindOfClass:NLESegmentTextTemplate_OC.class];
            VEVCStickerEditType editType = VEVCStickerEditTypeSticker;
            if (isTextSticker) {
                editType = VEVCStickerEditTypeText;
            } else if (isTextTemplateSticker) {
                editType = VEVCStickerEditTypeTextTemplate;
            }
            [self.stickerEditAdatper showInPreview:self.videoView.preview withType:editType];
            [self.stickerEditAdatper activeEditBox:selectedSlot.nle_nodeId];
            self.vcContext.mediaContext.selectMainVideoSegment = nil;
            self.vcContext.mediaContext.selectBlendVideoSegment = nil;
            
            [self showCanvasBorderIfNeededEnableGesture:NO];
        } else {
            [self.stickerEditAdatper activeEditBox:nil];
            [self.stickerEditAdatper hideFromPreview];
        }
    }];
    
    [[[RACObserve(self.vcContext.mediaContext, selectTextSlot) distinctUntilChanged] skip:1] subscribeNext:^(NLETrackSlot_OC *_Nullable slot) {
        @strongify(self);
        
        if (self.nleEditor.nleModel.coverModel.enable) {
            return;
        }
        DVEComponentViewManager* manager = [DVEComponentViewManager sharedManager];
        if (slot) {
            BOOL isTextTemplate = [slot.segment getType] == NLEResourceTypeTextTemplate;
            BOOL isTextSticker = [slot.segment isKindOfClass:NLESegmentTextSticker_OC.class];
            ///目前文本、贴纸、文字模板是可以在预览界面来回切换的，为了防止切换过程中不停叠加component，会触发selectTextSlot，
            ///这里判断当前ComponentType是不是另外两种类型则先移除bar，再下一步展示
            VEVCStickerEditType editType = VEVCStickerEditTypeNone;

            if (isTextSticker) {
                editType = VEVCStickerEditTypeText;
            
                if (manager.currentBarType == DVEBarComponentTypeSticker || manager.currentBarType == DVEBarComponentTypeTextTemplate ) {
                    manager.enable = NO;
                    [manager backToParentComponent];
                    manager.enable = YES;
                }
                [manager showComponentType:DVEBarComponentTypeText groupTpye:DVEBarSubComponentGroupEdit];
            } else if (isTextTemplate) {
                editType = VEVCStickerEditTypeTextTemplate;
                if (manager.currentBarType == DVEBarComponentTypeText || manager.currentBarType == DVEBarComponentTypeSticker ) {
                    manager.enable = NO;
                    [manager backToParentComponent];
                    manager.enable = YES;
                }
                [manager showComponentType:DVEBarComponentTypeText groupTpye:DVEBarSubComponentGroupEdit];
            } else {
                editType = VEVCStickerEditTypeSticker;
                if (manager.currentBarType == DVEBarComponentTypeText || manager.currentBarType == DVEBarComponentTypeTextTemplate ) {
                    manager.enable = NO;
                    [manager backToParentComponent];
                    manager.enable = YES;
                }
                [manager showComponentType:DVEBarComponentTypeSticker groupTpye:DVEBarSubComponentGroupEdit];
            }
            if (CMTimeRangeContainsTime(slot.nle_targetTimeRange, self.vcContext.mediaContext.currentTime)) {
                // note(caishaowu): 修复快速切换轨道 crash 问题
                manager.enable = NO;
                [self.stickerEditAdatper showInPreview:self.videoView.preview withType:editType];
                [self.stickerEditAdatper activeEditBox:slot.nle_nodeId];
                manager.enable = YES;
            }
            self.vcContext.mediaContext.selectMainVideoSegment = nil;
            self.vcContext.mediaContext.selectBlendVideoSegment = nil;
            
            [self showCanvasBorderIfNeededEnableGesture:NO];
        } else {
            [self.stickerEditAdatper activeEditBox:nil];
            DVEBarComponentType type = [DVEComponentViewManager sharedManager].currentBarType;
            if (type == DVEBarComponentTypeText || type == DVEBarComponentTypeSticker || type == DVEBarComponentTypeTextTemplate ) {
                [[DVEComponentViewManager sharedManager] updateCurrentBarGroupTpye:DVEBarSubComponentGroupAdd];
            } else {
                [self.stickerEditAdatper hideFromPreview];
            }
        }
    }];
    
    // 选中一个音频片段
    [[[RACObserve(self.vcContext.mediaContext, selectAudioSegment) distinctUntilChanged] skip:1] subscribeNext:^(NLETrackSlot_OC *  _Nullable selectedSegment) {
        @strongify(self);
        if (selectedSegment) {
            [[DVEComponentViewManager sharedManager] showComponentType:DVEBarComponentTypeAudio groupTpye:DVEBarSubComponentGroupEdit];
            [DVEAutoInline(self.vcContext.serviceProvider, DVECoreKeyFrameProtocol) refreshAllKeyFrameIfNeedWithSlot:selectedSegment];
        } else {
            if ([DVEComponentViewManager sharedManager].currentBarType == DVEBarComponentTypeAudio) {
                [[DVEComponentViewManager sharedManager] updateCurrentBarGroupTpye:DVEBarSubComponentGroupAdd];
            }
            DVELogInfo(@"selectAudioSegment nil");
        }
    }];
    
    [[[RACObserve(self.vcContext.mediaContext, selectFilterSegment) distinctUntilChanged] skip:1] subscribeNext:^(NLETrackSlot_OC *_Nullable slot) {
        @strongify(self);
        if (slot) {
            NLEResourceType type = [slot.segment getType];
            if(type == NLEResourceTypeNone){
                type = [[slot getFilter].firstObject.segmentFilter getType];
            }
            
            if (type == NLEResourceTypeFilter) {
                [[DVEComponentViewManager sharedManager] showComponentType:DVEBarComponentTypeFilterGobal groupTpye:DVEBarSubComponentGroupEdit];
            } else if (type == NLEResourceTypeAdjust) {
                [[DVEComponentViewManager sharedManager] showComponentType:DVEBarComponentTypeRegulate groupTpye:DVEBarSubComponentGroupEdit];
            }
            
            //选中时，更新滤镜调节参数
            [DVEAutoInline(self.vcContext.serviceProvider, DVECoreKeyFrameProtocol) refreshAllKeyFrameIfNeedWithSlot:slot];
        } else {
            if ([DVEComponentViewManager sharedManager].currentBarType == DVEBarComponentTypeRegulate){
                [[DVEComponentViewManager sharedManager] showComponentType:DVEBarComponentTypeRegulate groupTpye:DVEBarSubComponentGroupAdd];
            } else if ([DVEComponentViewManager sharedManager].currentBarType == DVEBarComponentTypeFilterGobal) {
                [[DVEComponentViewManager sharedManager] showComponentType:DVEBarComponentTypeFilterGobal groupTpye:DVEBarSubComponentGroupAdd];
            }
        }
    }];
    
    // 选中特效区域
    [[[RACObserve(self.vcContext.mediaContext, selectEffectSegment) distinctUntilChanged] skip:1] subscribeNext:^(NLETrackSlot_OC *  _Nullable selectedSegment) {
        if (selectedSegment) {
            [[DVEComponentViewManager sharedManager] showComponentType:DVEBarComponentTypeEffect groupTpye:DVEBarSubComponentGroupEdit];
        } else {
            if ([DVEComponentViewManager sharedManager].currentBarType == DVEBarComponentTypeEffect) {
                [[DVEComponentViewManager sharedManager] updateCurrentBarGroupTpye:DVEBarSubComponentGroupAdd];
            }
            DVELogInfo(@"selectEffectSegment nil");
        }
    }];

    
    [[[RACObserve(self.vcContext.mediaContext, multipleTrackType) skip:1] deliverOnMainThread] subscribeNext:^(NSNumber * _Nullable currentType) {
        @strongify(self);
        DVEMultipleTrackType multipleTrackMode = (DVEMultipleTrackType)(currentType.integerValue);
        [self updateAddButtonConstraintWithModuleType:multipleTrackMode];
    }];
    
    [[[RACObserve(self.vcContext.mediaContext, enableCanvasBackgroundEdit) skip:1] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (self.vcContext.mediaContext.enableCanvasBackgroundEdit) {
            [self showCanvasBorderIfNeededEnableGesture:YES];
        } else if (!self.vcContext.mediaContext.selectMainVideoSegment && !self.vcContext.mediaContext.enableCanvasBackgroundEdit) {
            [self showCanvasBorderIfNeededEnableGesture:NO];
            [[DVEComponentViewManager sharedManager] popToRoot];
        }
    }];
    
    [[[[RACObserve(self.vcContext.mediaContext, mappingTimelineVideoSegment) skip:1] distinctUntilChanged] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (!self.vcContext.mediaContext.enableCanvasBackgroundEdit) {
            return;
        }
        [self showCanvasBorderIfNeededEnableGesture:YES];
    }];
    [self.actionService addUndoRedoListener:self];
}

#pragma mark - DVEMediaTimelineViewDelegate

- (void)timelineDidZoom:(DVEMediaTimelineView *)timeline
{
    
}

- (void)timeline:(DVEMediaTimelineView *)timeline didChangeTime:(CMTime)time
{
    if (![self.vcContext.playerService isPlaying]) {
        [self.vcContext.playerService seekToTime:time isSmooth:NO];
    }
    [self dealRedLine];
}

- (void)timelineWillBeginDragging:(DVEMediaTimelineView *)timeline
{
    [self.vcContext.playerService pause];
}

- (void)dealRedLine
{
    [self.videoView.preview isShow];
}

#pragma mark - DVEVideoTrackPreviewTransitionDelegate

- (void)didSelectTransition:(DVEVideoTransitionModel *)transition
{
    [self.vcContext.playerService pause];
    NLETrackSlot_OC *slot = transition.relatedSlot;
    [[DVEComponentViewManager sharedManager] pushComponent:DVEBarComponentTypeTransitionAnimation param:slot];
    NSDictionary *dic = [[NSDictionary alloc] init];
    [DVEReportUtils logEvent:@"video_edit_trans_show" params:dic];
}

- (void)didTapMediaTimeline:(UITapGestureRecognizer *)tap
{
    [[DVEComponentViewManager sharedManager] dismissCurrentActionView];
}
- (void)closeMethod {
    NSString *title = NLELocalizedString(@"ck_back_to_home", @"返回首页");
    NSString *message = NLELocalizedString(@"ck_save_content_hint", @"创作尚未保存，是否存入草稿箱？") ;
    NSString *leftAction = NLELocalizedString(@"ck_cancel",@"取消");
    NSString *rightAction = NLELocalizedString(@"ck_confirm",@"确定");
    
    id<DVEEditorEventProtocol> config = DVEOptionalInline(self.vcContext.serviceProvider, DVEEditorEventProtocol);
    id<DVECoreDraftServiceProtocol> draftService = DVEAutoInline(self.vcContext.serviceProvider, DVECoreDraftServiceProtocol);
    
    @weakify(self);
    DVEActionBlock cancel = ^(UIView * _Nonnull view) {
        DVELogInfo(@"取消按钮被点击了");
        @strongify(self);
        BOOL hasStored = NO;
        NSArray<DVEDraftModel *> *drafts = [draftService getAllDrafts];
        for (DVEDraftModel *draft in drafts) {
            if ([draft.draftID isEqualToString:draftService.draftModel.draftID]) {
                hasStored = YES;
                break;
            }
        }
        if (!hasStored) {
            NSError *error = nil;
            [NSFileManager.defaultManager removeItemAtPath:draftService.currentDraftPath error:&error];
        }
        
        [self releaseResouce];
        NSDictionary *dic = @{@"action":@"cancel"};
        [DVEReportUtils logEvent:@"video_edit_back_click" params:dic];
        if(config && [config respondsToSelector:@selector(editorDidDismissView:cancel:status:draftID:)]){
            [config editorDidDismissView:self cancel:YES status:hasStored draftID:hasStored ? draftService.draftModel.draftID : nil];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    };
    
    if(config && [config respondsToSelector:@selector(onlyExportVideo)] && [config onlyExportVideo]){
        cancel([UIView new]);
        return;
    }
    
    
    DVEActionBlock save = ^(UIView * _Nonnull view) {
        DVELogInfo(@"保存按钮被点击了");
        @strongify(self);
        [self saveDraft];
        [self releaseResouce];
        NSDictionary *dic = @{@"action":@"confirm"};
        [DVEReportUtils logEvent:@"video_edit_back_click" params:dic];
        if(config && [config respondsToSelector:@selector(editorDidDismissView:cancel:status:draftID:)]){
            [config editorDidDismissView:self cancel:NO status:YES draftID:draftService.draftModel.draftID];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        [DVEToast showInfo:NLELocalizedString(@"ck_tips_draft_save_success", @"草稿保存成功")];
    };

    DVENotificationAlertView *alerView = [DVENotification showTitle:title message:message leftAction:leftAction rightAction:rightAction];
    alerView.leftActionBlock = cancel;
    alerView.rightActionBlock = save;
}

#pragma mark --DVECoreActionNotifyProtocol

- (void)undoRedoWillClikeByUser
{
    
}

- (void)undoRedoClikedByUser
{
    [[DVEComponentViewManager sharedManager] refreshCurrentBarGroupTpye];
}

#pragma mark - Private

- (void)buildVEVCLayout
{
    [super buildVEVCLayout];
    CGFloat centerY = (self.vcContext.mediaContext.multipleTrackType == DVEMultipleTrackTypeNone) ? DVEMediaTimelineView.centerY : DVEMediaTimelineView.centerY2;
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.timeLineView.mas_top).offset(centerY);
        make.centerX.equalTo(self.view.mas_trailing).offset(-30);
    }];
}

- (void)updateAddButtonConstraintWithModuleType:(DVEMultipleTrackType)type
{
    if (type != DVEMultipleTrackTypeNone &&
        type != DVEMultipleTrackTypeAudio &&
        type != DVEMultipleTrackTypeSticker &&
        type != DVEMultipleTrackTypeTextSticker &&
        type != DVEMultipleTrackTypeGlobalFilter &&
        type != DVEMultipleTrackTypeGlobalAdjust &&
        type != DVEMultipleTrackTypeEffect &&
        type != DVEMultipleTrackTypeBlend &&
        type != DVEMultipleTrackTypeAudioAndBlend) {
        return;
    }

    CGFloat centerY = (type == DVEMultipleTrackTypeNone) ? DVEMediaTimelineView.centerY : DVEMediaTimelineView.centerY2;
    
    [self.addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.timeLineView.mas_top).offset(centerY);
        make.centerX.equalTo(self.view.mas_trailing).offset(-30);
    }];
    ////开启动画会crash，暂时屏蔽
//    [UIView animateWithDuration:0.25f animations:^{
//        [self.view setNeedsLayout];
//        [self.view layoutIfNeeded];
//    }];
}

- (void)p_handleChangedSlotTimeRange:(NSString *)segmentId
{
    NLEModel_OC *model = self.nleEditor.nleModel;
    NLETrackSlot_OC *slot = [model slotOf:segmentId];
    DVELogDebug(@"slot type:%@", @(slot.segment.getType));

    CMTime currentTime = self.vcContext.mediaContext.currentTime;
    switch (slot.segment.getType) {
        case NLEResourceTypeVideo:
        case NLEResourceTypeImage:
        case NLEResourceTypeAudio: {
            [self.vcContext.playerService seekToTime:currentTime isSmooth:NO];
            break;
        }
        case NLEResourceTypeSticker:
        case NLEResourceTypeTextSticker: {
            [DVEAutoInline(self.vcContext.serviceProvider, DVECoreStickerProtocol) setSticker:segmentId startTime:CMTimeGetSeconds(slot.startTime) duration:CMTimeGetSeconds(slot.duration)];
            [self.vcContext.playerService seekToTime:currentTime isSmooth:NO];
            break;
        }
        case NLEResourceTypeTextTemplate: {
            [DVEAutoInline(self.vcContext.serviceProvider, DVECoreTextTemplateProtocol) setSticker:segmentId startTime:CMTimeGetSeconds(slot.startTime) duration:CMTimeGetSeconds(slot.duration)];
            [self.vcContext.playerService seekToTime:currentTime isSmooth:NO];
            break;
        }
        case NLEResourceTypeEffect:
        default:
            break;
    }
}

- (void)p_createSenceWithPreview:(UIView *)view
{
    [self.nle resetPlayerWithViews:@[view]];
    [DVEAutoInline(self.vcContext.serviceProvider, DVECoreCanvasProtocol) saveCanvasSize];
    
    id<DVEGlobalExternalInjectProtocol> config = DVEOptionalInline(DVEGlobalServiceProvider(), DVEGlobalExternalInjectProtocol);
    if ([config respondsToSelector:@selector(enableKeyframeAbility)] && [config enableKeyframeAbility]) {
        [self.nle enableKeyFrameCallback];
    }
}

#pragma mark - Sticker

- (void)showEditStickerViewWithType:(VEVCStickerEditType)type
{
    [self.stickerEditAdatper showInPreview:self.videoView.preview withType:type];

}
- (void)dismissEditStickerView
{
//    [self.editContainer removeFromSuperview];
    [self.stickerEditAdatper activeEditBox:nil];
    [self.stickerEditAdatper hideFromPreview];
}

- (DVEStickerEditAdpter *)stickerEditAdatper
{
    if (!_stickerEditAdatper) {
        _stickerEditAdatper = [[DVEStickerEditAdpter alloc] init];
        _stickerEditAdatper.vcContext = self.vcContext;
    }
    return _stickerEditAdatper;;
}

#pragma mark - Mask

- (void)showEditMaskViewConfigModel:(DVEMaskConfigModel *)model withBar:(DVEMaskBar*)bar
{
    self.maskEditAdpter.vcContext = self.vcContext;
    [self.maskEditAdpter showInPreview:self.videoView.preview withConfigModel:model];
    [self.maskEditAdpter setupMaskBar:bar];
    [self.videoView.preview disableGesture:YES];
}

- (void)dismissEditMaskView
{
    [self.maskEditAdpter hideFromPreview];
    [self.videoView.preview disableGesture:NO];
    _maskEditAdpter = nil;
}

- (DVEMaskEditAdpter *)maskEditAdpter
{
    if (!_maskEditAdpter) {
        _maskEditAdpter = [DVEMaskEditAdpter new];
    }
    return _maskEditAdpter;
}

#pragma mark - Canvas

- (void)setCanvasRatio:(DVECanvasRatio )ratio
{
    [DVEAutoInline(self.vcContext.serviceProvider, DVECoreCanvasProtocol) setCanvasRatio:ratio inPreviewView:self.videoView.preview needCommit:YES];
    [self.videoView updatePreviewSize]; // 更改preview大小
}

- (void)showCanvasBorderIfNeededEnableGesture:(BOOL)enableGesture
{
    BOOL enable = enableGesture;
    BOOL selectMain = self.vcContext.mediaContext.selectMainVideoSegment ? YES :NO;
    if (!selectMain) {
        selectMain = self.vcContext.mediaContext.mappingTimelineVideoSegment ? YES : NO;
    }
    BOOL selectBlend = self.vcContext.mediaContext.selectBlendVideoSegment ? YES :NO;
    
    if (selectMain || selectBlend) {
        [self.videoView.preview showCanvasBorderEnableGesture:enable];
    } else {
        [self.videoView.preview hideCanvasBorder];
    }
    
    if (enable) {
        [self.stickerEditAdatper activeEditBox:nil];
        [self.stickerEditAdatper hideFromPreview];
    }
}

#pragma mark - Preciew

- (DVEPreview *)videoPreview
{
    return self.videoView.preview;
}

- (void)resetVideoPreview
{
    [self.videoView addSubview:self.videoView.preview];
    [self.videoView updatePreviewSize];
}

#pragma mark - Setter && Getter

- (void)setVcContext:(DVEVCContext *)vcContext
{
    _vcContext = vcContext;
    [DVETextTemplateInputManager sharedInstance].vcContext = vcContext;
}

#pragma mark - DVEStickerEditAdpterDelegate

- (BOOL)doubleClick:(NSString *)segmentId
{
    if (self.nleEditor.nleModel.coverModel.enable) {
        return NO;
    }
    
    [[DVEComponentViewManager sharedManager] triggerCurrentComponentWithTitle:@"编辑"];
    return YES;
}

@end
