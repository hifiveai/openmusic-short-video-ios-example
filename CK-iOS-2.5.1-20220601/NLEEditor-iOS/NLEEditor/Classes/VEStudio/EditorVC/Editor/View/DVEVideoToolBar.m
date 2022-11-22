//
//  DVEVideoToolBar.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEVideoToolBar.h"
#import "NSString+DVEToPinYin.h"
#import "NSString+VEToImage.h"
#import "DVEVCContext.h"
#import "DVEToast.h"
#import "DVECoreKeyFrameProtocol.h"
#import "DVEServiceLocator.h"
#import "DVEGlobalExternalInjectProtocol.h"
#import <DVETrackKit/DVEUILayout.h>
#import <DVETrackKit/UIView+VEExt.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface DVEVideoToolBar ()<NLEEditorDelegate>

@property (nonatomic, strong) UIButton *fullScreenButton;

@property (nonatomic, strong) UIButton *undoButton;

@property (nonatomic, strong) UIButton *redoButton;

@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, strong) UIButton *keyframeButton;

@property (nonatomic, strong) UILabel *durationLable;

@property (nonatomic, strong) void(^updateVideoDataBlock)(void);

@property (nonatomic, weak) id<DVECoreKeyFrameProtocol> keyFrameEditor;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@end

@implementation DVEVideoToolBar

@synthesize vcContext = _vcContext;

DVEAutoInject(self.vcContext.serviceProvider, keyFrameEditor, DVECoreKeyFrameProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        [self buildLayout];
        @weakify(self);
        self.updateVideoDataBlock = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self updateVideoInfo];
            });
            
        };
    }
    
    return self;
}

- (void)buildLayout
{
    [self addSubview:self.fullScreenButton];
    [self addSubview:self.undoButton];
    [self addSubview:self.redoButton];
    [self addSubview:self.durationLable];
    [self addSubview:self.playButton];
    
    id<DVEGlobalExternalInjectProtocol> config = DVEOptionalInline(DVEGlobalServiceProvider(), DVEGlobalExternalInjectProtocol);
    if ([config respondsToSelector:@selector(enableKeyframeAbility)] && [config enableKeyframeAbility]) {
        [self addSubview:self.keyframeButton];
    }
    
    if ([DVEUILayout dve_alignmentWithName:DVEUILayoutFullScreenOpenButtonPosition] == DVEUILayoutAlignmentRight) {
        self.fullScreenButton.right = VE_SCREEN_WIDTH - 15;
        self.fullScreenButton.centerY = self.height * 0.5;
        self.undoButton.left = 15;
    } else {
        self.fullScreenButton.left = 15;
        self.fullScreenButton.centerY = self.height * 0.5;
        self.undoButton.left = self.fullScreenButton.right + 15;
    }
    self.undoButton.centerY = self.height * 0.5;
    
    self.redoButton.left = self.undoButton.right + 15;
    self.redoButton.centerY = self.undoButton.centerY;
    
    self.keyframeButton.left = self.redoButton.right + 15;
    self.keyframeButton.centerY = self.redoButton.centerY;
       
    self.playButton.centerY = self.height * 0.5;
    self.durationLable.centerY = self.playButton.centerY;
    
    self.playButton.centerX = self.width * 0.5;
    self.durationLable.left = self.playButton.right + 10;
    if ([DVEUILayout dve_alignmentWithName:DVEUILayoutFullScreenOpenButtonPosition] == DVEUILayoutAlignmentRight) {
        self.durationLable.right = self.fullScreenButton.left - 15;
    } else {
        self.durationLable.width = VE_SCREEN_WIDTH - 20;
    }
    [self setKeyframeHidden:YES];
}

- (void)setVcContext:(DVEVCContext *)vcContext
{
    _vcContext = vcContext;
    [_vcContext.playerService setVideoDataChangBlock:self.updateVideoDataBlock];
    @weakify(self);
    [_vcContext.playerService setPlayerTimeChangBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self updateVideoInfo];
            [self updateKeyframeButtonStatues];
        });
        
    }];
    [_vcContext.playerService setPlayerStatuseChangBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self updateVideoInfo];
        });
    }];
    
    [_vcContext.playerService setPlayerCompleteBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            self.vcContext.playerService.isPlayComplete = YES;
            [self updateVideoInfo];
        });
    }];
    [self updateVideoInfo];
    id<DVECoreActionServiceProtocol> actionService = DVEAutoInline(_vcContext.serviceProvider, DVECoreActionServiceProtocol);
    [RACObserve(actionService, canUndo) subscribeNext:^(NSNumber *x) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            self.undoButton.enabled = x.boolValue;
        });
    }];
    
    [RACObserve(actionService, canRedo) subscribeNext:^(NSNumber *x) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            self.redoButton.enabled = x.boolValue;
        });
    }];
    
    [RACObserve(actionService, isNeedHideUnReDo) subscribeNext:^(NSNumber *x) {
        if (!x) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            self.redoButton.enabled = NO;
            self.undoButton.enabled = NO;
        });
    }];
    
    
    id<DVEGlobalExternalInjectProtocol> config = DVEOptionalInline(DVEGlobalServiceProvider(), DVEGlobalExternalInjectProtocol);
    if ([config respondsToSelector:@selector(enableKeyframeAbility)] && [config enableKeyframeAbility]) {
        [[RACObserve(self.vcContext.mediaContext, timeScale).distinctUntilChanged skip:1] subscribeNext:^(NLETrackSlot_OC *  _Nullable selectedSegment) {
            @strongify(self);
            [self updateKeyframeButtonStatues];
        }];
        
        [[RACObserve(self.vcContext.mediaContext, selectMainVideoSegment).distinctUntilChanged skip:1] subscribeNext:^(NLETrackSlot_OC *  _Nullable selectedSegment) {
            @strongify(self);
            [self updateKeyframeButtonStatues];
        }];
     
        
        [[RACObserve(self.vcContext.mediaContext, selectBlendVideoSegment).distinctUntilChanged skip:1] subscribeNext:^(NLETrackSlot_OC *  _Nullable selectedSegment) {
            @strongify(self);
            [self updateKeyframeButtonStatues];
        }];

        [[[RACObserve(self.vcContext.mediaContext, changedTimeRangeSlot) distinctUntilChanged] skip:1] subscribeNext:^(NSString *  _Nullable segmentId) {
            @strongify(self);
            [self updateKeyframeButtonStatues];
        }];

        
        [[[RACObserve(self.vcContext.mediaContext, selectTextSlot) distinctUntilChanged] skip:1] subscribeNext:^(NLETrackSlot_OC *_Nullable slot) {
            @strongify(self);
            [self updateKeyframeButtonStatues];
        }];
        
        [[[RACObserve(self.vcContext.mediaContext, selectFilterSegment) distinctUntilChanged] skip:1] subscribeNext:^(NLETrackSlot_OC *_Nullable slot) {
            @strongify(self);
            [self updateKeyframeButtonStatues];
        }];
        
        [[[RACObserve(self.vcContext.mediaContext, selectAudioSegment) distinctUntilChanged] skip:1]
            subscribeNext:^(NLETrackSlot_OC *  _Nullable x) {
            @strongify(self);
            [self updateKeyframeButtonStatues];
        }];
    }
    
    [self.nleEditor addDelegate:self];
}

- (UIButton *)fullScreenButton
{
    if (!_fullScreenButton) {
        _fullScreenButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        [_fullScreenButton setImage:@"icon_vevc_fullscreen".dve_toImage forState:UIControlStateNormal];
        @weakify(self);
        [[_fullScreenButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self turnFullScreen];
        }];
    }
    
    return _fullScreenButton;
}

- (UIButton *)undoButton
{
    if (!_undoButton) {
        _undoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        [_undoButton setImage:@"icon_vevc_undo".dve_toImage forState:UIControlStateNormal];
        @weakify(self);
        [[_undoButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            NSString* desc = [[[self.nleEditor branch] getHead] getDescription];
            if([DVEAutoInline(self.vcContext.serviceProvider, DVECoreActionServiceProtocol) excuteUndo]){
                [self clickRedo:NO msg:desc];
            }
        }];
    }
    
    return _undoButton;
}

- (UIButton *)redoButton
{
    if (!_redoButton) {
        _redoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        [_redoButton setImage:@"icon_vevc_redo".dve_toImage forState:UIControlStateNormal];
        @weakify(self);
        [[_redoButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            if([DVEAutoInline(self.vcContext.serviceProvider, DVECoreActionServiceProtocol) excuteRedo]){
                NSString* desc = [[[self.nleEditor branch] getHead] getDescription];
                [self clickRedo:YES msg:desc];
            }
        }];
    }
    
    return _redoButton;
}

- (UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        [_playButton setImage:@"icon_vevc_play".dve_toImage forState:UIControlStateNormal];
        [_playButton setImage:@"icon_vevc_pause".dve_toImage forState:UIControlStateSelected];
        @weakify(self);
        [[_playButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self actionMethod:x];
        }];
    }
    
    return _playButton;
}

- (UIButton *)keyframeButton
{
    if (!_keyframeButton) {
        _keyframeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        @weakify(self);
        [[_keyframeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self actionKeyframe];
        }];
    }
    
    return _keyframeButton;
}

- (UILabel *)durationLable
{
    if (!_durationLable) {
        _durationLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 25)];
        _durationLable.textColor = [UIColor whiteColor];
        _durationLable.font = SCRegularFont(14);
        _durationLable.textAlignment = NSTextAlignmentRight;
    }
    
    return _durationLable;
}

- (void)turnFullScreen
{
    if(_delegate) {
        [_delegate showInFullScreen];
    }else {
        NSLog(@"delegate 为空");
    }
}

- (void)actionMethod:(UIButton *)button
{
    _playButton.selected = !button.selected;
    
    if (_playButton.selected) {
        [self play];
    } else {
        [self pause];
    }
}

- (void)play
{
    // 曲线变速情况下禁止切换选中的slot
    if (self.vcContext.mediaContext.disableUpdateSelectedVideoSegment) {
        self.vcContext.playerService.needPausePlayerTime = CMTimeGetSeconds([self.vcContext.mediaContext currentMainVideoSlot].endTime);
        if (fabs(self.vcContext.playerService.currentPlayerTime - self.vcContext.playerService.needPausePlayerTime) < 0.016) {
            [self playFromSlotStart];
            return;
        }
    }
    
    [self.vcContext.playerService play];
}

- (void)pause
{
    [self.vcContext.playerService pause];
}

- (void)playFromSlotStart {
    
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentMainVideoSlot];
    if (!slot) return;
    @weakify(self);
    [self.vcContext.playerService seekToTime:slot.startTime isSmooth:YES completionHandler:^(BOOL finished) {
        @strongify(self);
        if (finished) {
            self.vcContext.playerService.needPausePlayerTime = CMTimeGetSeconds(slot.endTime);
            [self.vcContext.playerService play];
        }
    }];
}

- (NLETrackSlot_OC *)currentSupportKeyframeSlot {
    if(self.vcContext.mediaContext.selectMainVideoSegment){
        return self.vcContext.mediaContext.selectMainVideoSegment;
    }
    
    if(self.vcContext.mediaContext.selectBlendVideoSegment){
        return self.vcContext.mediaContext.selectBlendVideoSegment;
    }
    
    if(self.vcContext.mediaContext.selectTextSlot){
        return self.vcContext.mediaContext.selectTextSlot;
    }
    
    if(self.vcContext.mediaContext.selectFilterSegment){
        return self.vcContext.mediaContext.selectFilterSegment;
    }
    
    if (self.vcContext.mediaContext.selectAudioSegment) {
        return self.vcContext.mediaContext.selectAudioSegment;
    }
    
    return nil;
}

- (void)updateVideoInfo
{
    static NSTimeInterval staticDuration = 0;
    static NSString* staticDurationStr = @"00:00";
    NSTimeInterval duration = [self.vcContext.playerService updateVideoDuration];
    if(duration != staticDuration){
        staticDuration = duration;
        staticDurationStr = [NSString DVE_timeFormatWithTimeInterval:ceil(staticDuration)];
    }
    NSTimeInterval curTime = self.vcContext.playerService.currentPlayerTime;
    
    self.durationLable.text = [NSString stringWithFormat:@"%@ / %@",[NSString DVE_timeFormatWithTimeInterval:ceil(curTime)],staticDurationStr];
    self.playButton.selected = self.vcContext.playerService.status == DVEPlayerStatusPlaying;
}

-(void)updateKeyframeButtonStatues
{
    NLETrackSlot_OC* slot = [self currentSupportKeyframeSlot];
    if (!slot || ![self isAdaptKeyFrameWithSlot:slot]) {
        [self setKeyframeHidden:YES];
        return;
    }
    CMTime time = self.vcContext.mediaContext.currentTime;
    if(CMTimeRangeContainsTime(slot.nle_targetTimeRange, time)){
        [self setKeyframeHidden:NO];
        if([slot keyframe:time timeRange:[self.keyFrameEditor currentKeyframeTimeRange]]){
            [self showRemoveKeyframe];
        }else{
            [self showAddKeyframe];
        }
    }else{
        [self setKeyframeHidden:YES];
    }
}

-(void)showAddKeyframe
{
    [self.keyframeButton setImage:@"icon_cutsub_addkeyframe".dve_toImage forState:UIControlStateNormal];
    self.keyframeButton.selected = YES;
}

-(void)showRemoveKeyframe
{
    [self.keyframeButton setImage:@"icon_cutsub_removekeyframe".dve_toImage forState:UIControlStateNormal];
    self.keyframeButton.selected = NO;
}

-(void)setKeyframeHidden:(BOOL)hidden
{
    self.keyframeButton.hidden = hidden;
}

-(void)actionKeyframe
{
    NLETrackSlot_OC* slot = [self currentSupportKeyframeSlot];
    CMTime time = CMTimeMake(self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC, USEC_PER_SEC);
    if(self.keyframeButton.selected){
        if([slot addOrUpdateKeyframe:time timeRange:[self.keyFrameEditor currentKeyframeTimeRange] forceAdd:YES]){
            [self.actionService commitNLE:YES message:DVEEditorDoneEventAddKeyframe];
            [self showRemoveKeyframe];
        }
    }else{
        if([slot removeKeyframe:time timeRange:[self.keyFrameEditor currentKeyframeTimeRange]]){
            [self.actionService commitNLE:YES message:DVEEditorDoneEventRemoveKeyframe];
            [self showAddKeyframe];
        }
    }
}


- (BOOL)isAdaptKeyFrameWithSlot:(NLETrackSlot_OC *)slot {
    return [slot.segment getType] != NLEResourceTypeTextTemplate;
}

- (void)clickRedo:(BOOL)redo msg:(NSString*)msg
{
    if (redo) {
        if ([msg isEqualToString:DVEEditorDoneEventAddKeyframe]) {
            [DVEToast showInfo:@"%@",NLELocalizedString(@"ck_redo_keyframe_success", @"恢复关键帧成功")];
        } else if ([msg isEqualToString:DVEEditorDoneEventRemoveKeyframe]) {
            [DVEToast showInfo:@"%@",NLELocalizedString(@"ck_undo_keyframe_success", @"撤销关键帧成功")];
        }
    } else {
        if ([msg isEqualToString:DVEEditorDoneEventAddKeyframe]) {
            [DVEToast showInfo:@"%@",NLELocalizedString(@"ck_undo_keyframe_success", @"撤销关键帧成功")];
        } else if ([msg isEqualToString:DVEEditorDoneEventRemoveKeyframe]) {
            [DVEToast showInfo:@"%@",NLELocalizedString(@"ck_redo_keyframe_success", @"恢复关键帧成功")];
        }
    }

}

#pragma mark - NLEEditorDelegate

- (void)nleEditorDidChange:(NLEEditor_OC *)editor
{
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self updateVideoInfo];
        [self updateKeyframeButtonStatues];
    });
}

@end
