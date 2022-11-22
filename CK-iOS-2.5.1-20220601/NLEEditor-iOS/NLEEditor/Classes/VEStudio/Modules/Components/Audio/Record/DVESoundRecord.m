//
//   DVESoundRecord.m
//   NLEEditor
//
//   Created  by ByteDance on 2021/6/15.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVESoundRecord.h"
#import <Masonry/Masonry.h>
#import "DVEEffectsBarBottomView.h"
#import "DVEUIHelper.h"
#import "DVECustomerHUD.h"
#import "DVELoggerImpl.h"
#import <TTVideoEditor/VEAudioRecorder.h>
#import <DVETrackKit/NLESegmentAudio_OC+NLE.h>
#import "DVECustomerHUD.h"
#import "DVEReportUtils.h"
#import "DVENotification.h"

#define timelineWidthPerFrame (50.0)
#define maxTimeScale (30.0)
#define minTimeScale (0.1)
#define wavePerSecondsCount (timelineWidthPerFrame * 0.5)
#define minSegmentDuration (0.1)
#define maxRecordTime (5 * 60)   //5分钟

@interface DVESoundRecord()<AVAudioRecorderDelegate>

///底部区域
@property (nonatomic, strong) DVEEffectsBarBottomView *bottomView;

/// 录音按钮
@property (nonatomic, strong) UIButton *recorderBtn;

/// 录音对象
@property (nonatomic, strong) VEAudioRecorder *recorder;

/// 当前正在录音的Slot
@property (nonatomic, strong) NLETrackSlot_OC* currentAudioSlot;

/// 当前录音Tack
@property (nonatomic, strong) NLETrack_OC* currentAudioTrack;

/// 是否正在录音
@property (nonatomic, assign) BOOL recording;

///当前录音波形数据
@property (nonatomic, strong) NSMutableArray* wavePoints;

/// 已录音成功的录音Slot数组
@property (nonatomic, strong) NSMutableArray<NLETrackSlot_OC*>* audioDoneSlots;

@property (nonatomic, strong) UILongPressGestureRecognizer* longRecognizer;

@property (nonatomic, weak) id<DVECoreAudioProtocol> audioEditor;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;

@end

@implementation DVESoundRecord

DVEAutoInject(self.vcContext.serviceProvider, audioEditor, DVECoreAudioProtocol)
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

    UIView* view = [UIView new];
    [self addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
    }];
    
    [view addSubview:self.recorderBtn];
    [self.recorderBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(view);
    }];
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.bottomView.frame.size.height);
        make.left.right.equalTo(self);
        make.top.equalTo(view.mas_bottom);
        make.bottom.equalTo(self).offset(-VEBottomMargn);
    }];
}

- (void)initData
{
    // 注册打断通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:nil];
    self.recorderBtn.enabled = NO;
    [self recorderStateWorking:NO];
}

-(void)dismiss:(BOOL)animation
{
    [super dismiss:animation];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
}

-(void)showInView:(UIView *)view animation:(BOOL)animation{
    [super showInView:view animation:(BOOL)animation];
    [self initData];
    [self checkPermission];
}


#pragma mark --layze method ---
- (DVEEffectsBarBottomView*)bottomView
{
    if(!_bottomView) {
        @weakify(self);
        _bottomView = [DVEEffectsBarBottomView newActionBarWithTitle:NLELocalizedString(@"ck_hold_to_record",@"按住录音") action:^{
            @strongify(self);
            [self finishRecord];
            [self dismiss:YES];
            [self.actionService refreshUndoRedo];
        }];
        
    }
    return _bottomView;
}

- (UIButton *)recorderBtn
{
    if(!_recorderBtn){
        _recorderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recorderBtn setImage:@"icon_vevc_recorder".dve_toImage forState:UIControlStateNormal];
//        [_recorderBtn addTarget:self action:@selector(clickRecorderBtn:) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer*longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(recorderLongPress:)];
        longPress.minimumPressDuration = 0.5;//定义按的时间
        [_recorderBtn addGestureRecognizer:longPress];
        self.longRecognizer = longPress;
    }
    
    return _recorderBtn;
}

- (NSMutableArray *)wavePoints
{
    if(!_wavePoints) {
        _wavePoints = [NSMutableArray array];
    }
    return _wavePoints;
}

- (NSMutableArray *)audioDoneSlots
{
    if(!_audioDoneSlots){
        _audioDoneSlots = [NSMutableArray array];
    }
    return _audioDoneSlots;
}

#pragma mark --action method---

- (void)clickRecorderBtn:(id)sender
{
    if(!self.recording){
        self.recording = YES;
        [self startRecord];
    }else{
        self.recording = NO;
        [self stopRecord];
    }
}

- (void)recorderLongPress:(UILongPressGestureRecognizer*)gestureRecognizer{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        [self clickRecorderBtn:nil];
        NSDictionary *dic = [[NSDictionary alloc] init];
        [DVEReportUtils logEvent:@"video_edit_dub_click" params:dic];
    }else if(gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled || gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        [self clickRecorderBtn:nil];
    }
}

- (void)startRecord {
    self.recorder = [self createRecorder];
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&setCategoryError];
    if (!success) {
        [DVECustomerHUD showMessage:@"打开录音失败"];
        self.recorder = nil;
        return;
    }
    @weakify(self);
    [self.recorder prepare:^(BOOL success, NSError * _Nullable error) {
        @strongify(self);
        if(success){
            [self audioRecorderDidStart];
        }else{
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            [DVECustomerHUD showMessage:@"录音失败"];
        }
    }];
    
}

- (void)stopRecord {
    [self audioRecorderWillFinish];
    @weakify(self);
    [self.recorder stopRecord:^(NSURL * _Nullable fileUrl, NSError * _Nullable error) {
        @strongify(self);
        [self audioRecorderDidFinishRecording:fileUrl success:( error == nil && fileUrl != nil)];
        self.recorder = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }];
}

- (void)interruptRecord:(BOOL)overTime {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.longRecognizer.enabled = NO;
        if(overTime){
            [DVECustomerHUD showMessage:[NSString stringWithFormat:@"录音超出最大时长%d秒",maxRecordTime]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.longRecognizer.enabled = YES;
        });
    });
}

- (void)finishRecord {
    self.vcContext.mediaContext.recordingTrack = nil;
}

- (void)audioRecorderDidStart {
    DVELogInfo(@"【录音】录音开始");
    [self.wavePoints removeAllObjects];
    CMTime start = self.vcContext.mediaContext.currentTime;
    
    // 寻找当前时间之后是空的音频轨道
    NLETrack_OC *audioTrack = nil;
    if(self.currentAudioTrack != nil){///优先考虑添加到当前录音轨道
        if (CMTimeCompare([self.currentAudioTrack getMaxEnd], start) <= 0) {
            audioTrack = self.currentAudioTrack;
        }
    }
    
    if(!audioTrack){
        NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel nle_allTracksOfType:NLETrackAUDIO];
        for (NLETrack_OC *track in tracks) {
            if(track.getSortedSlots.firstObject.segment.getResNode.resourceType == NLEResourceTypeRecord){//过滤非录音轨道的音频轨道
                if (CMTimeCompare([track getMaxEnd], start) <= 0) {
                    audioTrack = track;
                }
            }
        }
    }
    
    if (!audioTrack) {
        audioTrack = [self addRecorderTrack];
    }
    
    self.currentAudioTrack = audioTrack;
    self.currentAudioSlot = [self addRecorderSlot:[NSString stringWithFormat:@"%@%ld",[self.audioEditor recordDefaultName],[self.audioEditor maxRecoderNumberSlot] + 1] startTime:start toTrack:self.currentAudioTrack];
    [self.recorder startRecord];
    [self recorderStateWorking:YES];
}

- (void)audioRecorderRecording:(NSArray *)volumeArray{
//    DVELogInfo(@"【录音】录音中");
    [self.wavePoints addObjectsFromArray:volumeArray];
    [self updateRecorderSlot:self.currentAudioSlot time:[self realDuration] toTrack:self.currentAudioTrack wavePoints:self.wavePoints];
    if([self realDuration] > maxRecordTime){
        [self interruptRecord:YES];
    }
}

- (void)audioRecorderWillFinish {
    DVELogInfo(@"【录音】RecorderWillFinish");
    [self recorderStateWorking:NO];
}

- (void)audioRecorderDidFinishRecording:(NSURL*)file success:(BOOL)success {
    if(!success){
        [DVECustomerHUD showMessage:@"录音失败"];
        [self removeRecorderSlot];
        return;
    }

    if([self realDuration] < minSegmentDuration) {
        [DVECustomerHUD showMessage:@"录音时长过短"];
        [self removeRecorderSlot];
        return;
    }

    id<DVECoreDraftServiceProtocol> draftService = DVEAutoInline(self.vcContext.serviceProvider, DVECoreDraftServiceProtocol);
    NSString *relativePath = [draftService copyResourceToDraft:file resourceType:NLEResourceTypeAudio];
    NSString *destPath = [draftService.currentDraftPath stringByAppendingPathComponent:relativePath];
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:destPath]];

    NLESegmentAudio_OC *audioSegment = (NLESegmentAudio_OC*)[self.currentAudioSlot segment];
    NLEResourceAV_OC *audioResource = audioSegment.audioFile;
    [audioResource nle_setupForRecord:asset];
    audioResource.resourceFile = relativePath;
    [self updateRecorderSlot:self.currentAudioSlot time:[self realDuration] toTrack:self.currentAudioTrack wavePoints:self.wavePoints];
    [self.audioDoneSlots addObject:self.currentAudioSlot];
    self.currentAudioSlot = nil;
    [self.wavePoints removeAllObjects];
    [self.actionService commitNLE:YES];
}

- (NSTimeInterval)realDuration {
    return self.recorder.recordDuration;
}

#pragma mark --privace method---
///添加录音Track
- (NLETrack_OC*)addRecorderTrack
{
    NLETrack_OC *track = [[NLETrack_OC alloc] init];
    track.extraTrackType = NLETrackAUDIO;
    track.layer = (int)([self.nleEditor.nleModel nle_getMaxTrackLayer:NLETrackAUDIO] + 1);
    [self.nleEditor.nleModel addTrack:track];
    return track;
}
///添加录音slot
- (NLETrackSlot_OC*)addRecorderSlot:(NSString *)audioName startTime:(CMTime)startTime toTrack:(NLETrack_OC*)track
{
    NLEResourceAV_OC *audioResource = [[NLEResourceAV_OC alloc] init];
    audioResource.resourceName = audioName;
    audioResource.resourceType = NLEResourceTypeRecord;
    audioResource.resourceFile = [self recordFilePath];
    
    NLESegmentAudio_OC *audioSegment = [[NLESegmentAudio_OC alloc] init];
    audioSegment.audioFile = audioResource;
    audioSegment.timeClipStart = CMTimeMake(0, USEC_PER_SEC);
    
    NLETrackSlot_OC *trackSlot = [[NLETrackSlot_OC alloc] init];
    [trackSlot setSegmentAudio:audioSegment];
    trackSlot.startTime = startTime;
    
    [track addSlot:trackSlot];
    
    track.endTime = trackSlot.endTime;
    self.vcContext.mediaContext.recordingTrack = track;
    
    [self.vcContext.mediaContext updateTargetOffsetWithTime:startTime];
    
    return trackSlot;
}
///更新录音slot
-(void)updateRecorderSlot:(NLETrackSlot_OC*)slot time:(NSTimeInterval)time toTrack:(NLETrack_OC*)track wavePoints:(NSArray*)points
{
    NLESegmentAudio_OC *audioSegment = (NLESegmentAudio_OC*)[slot segment];

    CMTime newTime = CMTimeMake(time * NSEC_PER_SEC, NSEC_PER_SEC);
    audioSegment.nle_wavePoints = points;
    audioSegment.timeClipEnd = newTime;
    slot.duration = newTime;
    
    NLEResourceAV_OC *audioResource = audioSegment.audioFile;
    audioResource.duration = newTime;
    
    track.endTime = slot.endTime;
    
    self.vcContext.mediaContext.recordingTrack = self.vcContext.mediaContext.recordingTrack;
    
    [self.vcContext.mediaContext updateTargetOffsetWithTime:slot.endTime];

}
///移除录音slot
-(void)removeRecorderSlot
{
    NLEModel_OC* model = self.nleEditor.nleModel;
    NLETrack_OC* track = [model trackContainSlotId:self.currentAudioSlot.nle_nodeId];
    [track removeSlot:self.currentAudioSlot];
    self.currentAudioSlot = nil;
    if(track.slots.count == 0){
        [model removeTrack:track];
        if(track == self.currentAudioTrack){
            self.currentAudioTrack = nil;
        }
    }
}

///创建录音对象
-(VEAudioRecorder*)createRecorder
{
    
    IESWaveformConfig* config = [IESWaveformConfig new];
    config.waveType = WaveformTypeMAX;
    config.durationPerFrame = 1 / wavePerSecondsCount;
    config.pointPersec = wavePerSecondsCount;
    
    VEAudioRecorder* recorder = [[VEAudioRecorder alloc] initWithWaveformConfig:config];
    @weakify(self);
    recorder.waveResultBlock = ^(NSArray * _Nonnull volumeArray) {
        @strongify(self);
        [self audioRecorderRecording:volumeArray];
    };
    
    return recorder;
}

///录音临时文件，暂时无使用只是加路径
-(NSString*)recordFilePath
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"record.mp3"];
}

///权限检查
-(void)checkPermission
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    AVAudioSessionRecordPermission permission = session.recordPermission;
    if (permission == AVAudioSessionRecordPermissionUndetermined) {
        @weakify(self);
        [session requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                if (granted) {
                    self.recorderBtn.enabled = YES;
                } else {
                    self.recorderBtn.enabled = NO;
                    [DVECustomerHUD showMessage:@"请在系统设置中打开录音权限" afterDele:2];
                }
            });
        }];
    } else if (permission == AVAudioSessionRecordPermissionGranted) {
        self.recorderBtn.enabled = YES;
    } else if (permission == AVAudioSessionRecordPermissionDenied) {
        self.recorderBtn.enabled = NO;
        DVENotificationAlertView *alerView = [DVENotification showTitle:@"权限设置" message:@"请在系统设置中打开录音权限" leftAction:@"取消" rightAction:@"设置"];
        alerView.leftActionBlock = ^(UIView * _Nonnull view) {
            DVELogInfo(@"取消按钮被点击了");
        };
        alerView.rightActionBlock = ^(UIView * _Nonnull view) {
            DVELogInfo(@"设置按钮被点击了");
            NSURL *settingUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:settingUrl]) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:settingUrl options:@{} completionHandler:nil];
                } else {
                    [[UIApplication sharedApplication] openURL:settingUrl];
                }
            }
        };
    }
}

///录音按钮状态
- (void)recorderStateWorking:(BOOL)normal
{
    if(normal){
        [self.recorderBtn setBackgroundImage:@"icon_dve_background_recoding".dve_toImage forState:UIControlStateNormal];
        self.bottomView.titleText = NLELocalizedString(@"ck_recoding",@"正在录音");
        self.bottomView.userInteractionEnabled = NO;
    }else{
        [self.recorderBtn setBackgroundImage:@"icon_dve_background_recod".dve_toImage forState:UIControlStateNormal];
        self.bottomView.titleText = NLELocalizedString(@"ck_hold_to_record",@"按住录音");
        self.bottomView.userInteractionEnabled = YES;
    }
}

// 接收通知方法
- (void)audioSessionInterruptionNotification: (NSNotification *)notificaiton {
    DVELogInfo(@"audioSessionInterruptionNotification %@", notificaiton.userInfo);
    
    AVAudioSessionInterruptionType type = [notificaiton.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        if(self.recording){
            [self interruptRecord:NO];
        }
    }
}

- (void)undoRedoClikedByUser
{
    NLETrack_OC* track = nil;
    for(NLETrack_OC* t in [self.nleEditor.nleModel nle_allTracksOfType:NLETrackAUDIO]) {
        if([t.getName isEqualToString:self.currentAudioTrack.name]){
            track = t;break;
        }
    }
    self.vcContext.mediaContext.recordingTrack = track;
}

@end
