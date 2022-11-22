//
// Created by bytedance on 2021/6/21.
//

#import "DVECurveSpeedCanvas.h"
#import "DVECurveSpeedEditBar.h"
#import <Masonry/Masonry.h>
#import <TTVideoEditor/UIColor+Utils.h>
#import <DVEEffectsBarBottomView.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "DVELoggerImpl.h"
#import "DVEViewController.h"
#import <TTVideoEditor/VECurveTransUtils.h>

@interface DVECurveSpeedEditBar()

@property (nonatomic, strong) UIView *toolbar;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UILabel *origDurationLabel;
@property (nonatomic, strong) UILabel *destDurationLabel;
@property (nonatomic, strong) DVECurveSpeedCanvas *canvas;
///底部区域
@property (nonatomic, strong) DVEEffectsBarBottomView *bottomView;
/// 在改变的速度
@property (nonatomic, strong) UILabel *speedLabel;
@property (nonatomic, strong) UIButton *playBtn;
// 时间转换对象
@property (nonatomic, strong) VECurveTransUtils *transUtil;
@property (nonatomic, weak) id<DVECoreVideoProtocol> videoEditor;

@end

@implementation DVECurveSpeedEditBar

DVEAutoInject(self.vcContext.serviceProvider, videoEditor, DVECoreVideoProtocol)

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {

        [self buildLayout];
        @weakify(self);
        [RACObserve(self.canvas, progress) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            NSNumber *xn = x;

            [self updateProgress:xn.floatValue];
        }];
        [[RACObserve(self.canvas, updatingSpeed) distinctUntilChanged] subscribeNext:^(id y) {
           @strongify(self);
           NSNumber *yn = y;
            [self updateSpeed:yn.floatValue];
        }];
        
        [[RACObserve(self.canvas, currentPoints) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self updateCurve];
        }];
    }

    return self;
}

- (void)buildLayout
{
    [self.slider removeFromSuperview];
    [self addSubview:self.toolbar];
    [self.toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.equalTo(@50);
    }];
    
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self).inset(VEBottomMargn);
        make.height.equalTo(@50);
    }];

    [self addSubview:self.canvas];
    [self.canvas mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self).inset(20);
        make.top.equalTo(self.toolbar.mas_bottom).offset(36);
        make.bottom.equalTo(self.bottomView.mas_top).inset(17);
    }];

    [self addSubview:self.speedLabel];
    [self.speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.canvas.mas_top).inset(6);
    }];
}

- (void)touchOutSide {
    [self dismiss:YES];
}

- (void)showInView:(UIView *)view animation:(BOOL)animation {
    [super showInView:view animation:animation];
    DVEViewController *vc = (DVEViewController *)self.parentVC;
    vc.videoPreview.userInteractionEnabled = NO;//禁止预览区交互，防止编辑曲线变速点的时候，点击预览区导致底部BottomBar切换
    if (self.currentPoints) {
        [self.canvas updateCurveWithPoints:self.currentPoints];
    }
}

- (void)dismiss:(BOOL)animation {
    self.currentPoints = nil;
    DVEViewController *vc = (DVEViewController *)self.parentVC;
    vc.videoPreview.userInteractionEnabled = YES;
    [super dismiss:animation];
    
}

- (void)updateProgress:(CGFloat)x {
    DVELogInfo(@"-----------%f",x);
    // 更新按钮标题：删除/添加
    [self updateActionTitle];

    // update media and seek to time, 注意slot起始时间
//    CMTime duration = self.editingSlot.duration;
    
    int64_t videoTime = x * self.videoEditor.currentSrcDuration;
//    int64_t playTime = [self.canvas.transUtil transVideoTimeToPlayTime:videoTime];
    int64_t playTime = [self.canvas.transUtil segmentDelToSequenceDel:videoTime seqDurationUs:self.seqDurationUs];

    CMTime offset = CMTimeMake(playTime, NSEC_PER_MSEC);

    
    offset = CMTimeAdd(self.editingSlot.startTime, offset);
    [self.vcContext.mediaContext updateCurrentTime:offset];
    [self.vcContext.playerService seekToTime:offset isSmooth:YES];
    self.vcContext.playerService.currentPlayerTime = CMTimeGetSeconds(offset);
}

- (void)updateSpeed:(CGFloat)y {
    if (y == 0) {
        self.speedLabel.text = @"";
    } else {
        self.speedLabel.text = [NSString stringWithFormat:@"%.1f x", y];
    }
}

- (void)updateCurve {
//    NSArray *currentPoints = [self.videoEditor currentCurveSpeedPoints];
    if (!self.superview) return;
    self.curValue.speedPoints = self.canvas.currentPoints;
    [self.videoEditor updateVideoCurveSpeedInfo:self.curValue slot:self.editingSlot isMain:self.isMainTrack shouldCommit:NO];
    self.vcContext.playerService.needPausePlayerTime = CMTimeGetSeconds(self.editingSlot.startTime)+[self getPlayDuration];
    
    [self updateDestTime];
}

- (void)updateDestTime {
    if (self.canvas.transUtil.getAveCurveSpeedRatio != 0) {
        self.destDurationLabel.text = [NSString stringWithFormat:@"%.1f", [self.videoEditor srcDurationWithSlot:self.editingSlot]/(NSEC_PER_MSEC*self.canvas.transUtil.getAveCurveSpeedRatio)];
    }
}

- (void)updateActionTitle {
    NSString *title = self.canvas.actionType != DVECurveSpeedCanvasActionAdd ? NLELocalizedString(@"ck_remove",@"删除") : NLELocalizedString(@"ck_add", @"添加" );
    [self.actionButton setTitle:title forState:UIControlStateNormal];
    self.actionButton.enabled = self.canvas.actionType != DVECurveSpeedCanvasActionDisable;
}

- (void)setOriginPoints:(NSArray<NSValue *> *)initialPoints {
    _originPoints = initialPoints;
    [self.canvas updateCurveWithPoints:initialPoints];
}

- (void)togglePlay:(UIButton *)sender {
    self.playBtn.selected = !self.playBtn.selected;

    if (self.playBtn.selected) {
        // 当前播放时间不在范围时，从头开始播放；否则继续播放
        if (self.vcContext.playerService.currentPlayerTime >= self.vcContext.playerService.needPausePlayerTime
            || (self.vcContext.playerService.currentPlayerTime < CMTimeGetSeconds(self.editingSlot.startTime))
            || self.vcContext.playerService.isPlayComplete) {
            [self seekToStartAndPlay];
        } else {
            [self.vcContext.playerService play];
        }
        
    } else {
        [self.vcContext.playerService pause];
        self.vcContext.playerService.needPausePlayerTime = CMTimeGetSeconds(self.editingSlot.endTime);
    }
}

- (void)save {
//    if (self.pointChanged) {
        [self.vcContext.mediaContext notifyEditorChanged];
//    }
}

- (void)reset {
    [self.canvas reset];
}

- (void)seekToStartAndPlay {
    CGFloat duration = [self getPlayDuration];
    // todo 第一次打开时候可能不播放
    [self.vcContext.playerService playFrom:self.editingSlot.startTime duration:duration completeBlock:^{
    }];
}

- (CGFloat)getPlayDuration {
    CGFloat originDuration = CMTimeGetSeconds(self.editingSlot.duration);
    return originDuration;// / self.canvas.transUtil.avgSpeedRatio;
}

- (BOOL)pointChanged {
    NSArray<NSValue *> *currentPts = self.canvas.currentPoints;
    NSArray<NSValue *> *currentPoints = self.currentPoints;
    if (currentPts.count != currentPoints.count) {
        return YES;
    }
    
    for (int i = 0; i < currentPts.count; i++) {
        CGFloat deltax = fabs(currentPts[i].CGPointValue.x - currentPoints[i].CGPointValue.x);
        CGFloat deltay = fabs(currentPts[i].CGPointValue.y - currentPoints[i].CGPointValue.y);
        if (deltax + deltay > 0.0001) {
            return YES;
        }

    }
    
    return NO;
}

#pragma mark - setter & getter

- (int64_t)seqDurationUs {
    int64_t ussec = CMTimeGetSeconds(self.editingSlot.duration) * USEC_PER_SEC;
    return ussec;
}

- (void)setCurValue:(id<DVEResourceCurveSpeedModelProtocol>)curValue {
    _curValue = curValue;
    self.bottomView.titleText = curValue.identifier;
}

- (VECurveTransUtils *)transUtil {
    return self.canvas.transUtil;
}

- (void)setVcContext:(DVEVCContext *)vcContext {
    [super setVcContext:vcContext];
    
    self.canvas.vcContext = self.vcContext;
    if (vcContext.mediaContext.duration.timescale <= 0) { return; }
    self.origDurationLabel.text = [NSString stringWithFormat:@"%@%.1f", NLELocalizedString(@"ck_duration", @"时长"),[DVEAutoInline(vcContext.serviceProvider, DVECoreVideoProtocol) currentSrcDuration]*1.0f/NSEC_PER_MSEC];
    
    @weakify(self);
    [RACObserve(self.vcContext.playerService, status) subscribeNext:^(id y) {
        @strongify(self);
        self.playBtn.selected = self.vcContext.playerService.status == DVEPlayerStatusPlaying;
    }];
    [RACObserve(self.vcContext.playerService, currentPlayerTime) subscribeNext:^(id y) {
        @strongify(self);
        self.vcContext.playerService.needPausePlayerTime = CMTimeGetSeconds(self.editingSlot.startTime)+[self getPlayDuration];
        [self updateActionTitle];
    }];
}

- (void)setEditingSlot:(NLETrackSlot_OC *)editingSlot {
    _editingSlot = editingSlot;
    self.canvas.editingSlot = _editingSlot;
    self.canvas.isMainTrack = self.isMainTrack;
    self.origDurationLabel.text = [NSString stringWithFormat:@"时长%.1f", [self.videoEditor srcDurationWithSlot:_editingSlot]*1.0f/NSEC_PER_MSEC];
    [self seekToStartAndPlay];
    [self updateDestTime];

}

- (DVECurveSpeedCanvas *)canvas {
    if (!_canvas) {
        _canvas = [[DVECurveSpeedCanvas alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, 170)];
    }
    return _canvas;
}


- (DVEEffectsBarBottomView *)bottomView
{
    if(!_bottomView) {
        @weakify(self);
        _bottomView = [DVEEffectsBarBottomView newActionBarWithTitle:@"自定义" action:^{
            @strongify(self);
            [self save];
            [self dismiss:YES];
        }];
        [_bottomView setupResetBlock:^{
            @strongify(self);
            [self reset];
        }];
        [_bottomView setResetButtonEnable:YES];
    }
    return _bottomView;
}

- (UILabel *)speedLabel {
    if (!_speedLabel) {
        _speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 10)];
        _speedLabel.textColor = UIColor.whiteColor;
        _speedLabel.text = @"0 x";
        _speedLabel.font = SCRegularFont(10);
    }
    return _speedLabel;
}

- (UIView *)toolbar {
    if (!_toolbar) {
        _toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, 20)];
        [_toolbar addSubview:self.origDurationLabel];
        [_toolbar addSubview:self.destDurationLabel];
        [_toolbar addSubview:self.actionButton];
        [_toolbar addSubview:self.playBtn];

        [self.origDurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.toolbar);
            make.left.equalTo(@16);
        }];
        [self.destDurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.toolbar);
            make.left.equalTo(self.origDurationLabel.mas_right).offset(20);
        }];
        [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.toolbar.mas_centerY);
            make.height.equalTo(@28);
            make.right.equalTo(@-16);
            make.width.equalTo(@49);
        }];
        [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.toolbar);
            make.width.height.equalTo(@20);
        }];
        
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,20,20)];
        imgv.image = @"icon_vevcspeed_time".dve_toImage;
        imgv.contentMode = UIViewContentModeScaleAspectFit;
        [_toolbar addSubview:imgv];
        [imgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@5);
            make.left.equalTo(self.origDurationLabel.mas_right);
            make.right.equalTo(self.destDurationLabel.mas_left);
            make.centerY.equalTo(self.origDurationLabel.mas_centerY);
        }];
    }
    return _toolbar;
}

- (UILabel *)origDurationLabel {
    if (!_origDurationLabel) {
        _origDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 50, 52)];
        _origDurationLabel.textColor = [UIColor.whiteColor colorWithAlphaComponent:0.5];
        _origDurationLabel.font = SCRegularFont(12);
        _origDurationLabel.text = @"时长%.1f";
    }
    return _origDurationLabel;
}

- (UILabel *)destDurationLabel {
    if (!_destDurationLabel) {
        _destDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 0, 50, 52)];
        _destDurationLabel.textColor = UIColor.whiteColor;
        _destDurationLabel.font = SCRegularFont(12);
        _destDurationLabel.text = @"00.0";
    }
    return _destDurationLabel;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 16)];
        _actionButton.layer.cornerRadius = 14;
        _actionButton.layer.masksToBounds = YES;
        [_actionButton setTitle:NLELocalizedString(@"ck_add", @"添加" ) forState:UIControlStateNormal];
        [_actionButton setTitleColor:[UIColor colorWithHex:0xFE6646] forState:UIControlStateNormal];
        _actionButton.titleLabel.font = BoldFont(12);
        _actionButton.backgroundColor = [UIColor colorWithHex:0x353434];
        [_actionButton addTarget:self.canvas action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
        [_actionButton setTitleColor:[UIColor.whiteColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    }
    return _actionButton;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [_playBtn setImage:@"icon_vevc_play".dve_toImage forState:UIControlStateNormal];
        [_playBtn setImage:@"icon_vevc_pause".dve_toImage forState:UIControlStateSelected];

        [_playBtn addTarget:self action:@selector(togglePlay:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _playBtn;
}

@end
