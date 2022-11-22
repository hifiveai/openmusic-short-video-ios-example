//
//  VECapManager.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECapManager.h"
#import "VECapManager+Private.h"
#import "VECapManager+Action.h"
#import "VEEBeautyDataSource.h"
#import "VEMotionHelper.h"
#import "VECustomerHUD.h"
#import "VEDVideoTool.h"
#import <TTVideoEditor/IESMMDeviceAuthor.h>
#import <TTVideoEditor/IESMMCameraDeviceAuthor.h>
#import <TTVideoEditor/IESAnimationSticker.h>
#import <TTVideoEditor/IESMMCaptureKit.h>
#import <TTVideoEditor/IESMMCamera+Effect.h>
#import <TTVideoEditor/IESMMTransProcessData.h>
#import <TTVideoEditor/IESMMBlankResource.h>
#import <TTVideoEditor/IESMMBaseDefine.h>
#import <TTVideoEditor/HTSVideoData+CacheDirPath.h>
#import <TTVideoEditor/VECompileTaskManagerSession.h>
#import <NLEEditor/DVEBundleLoader.h>
#import <NLEEditor/DVENotification.h>
#import <KVOController/KVOController.h>
#import <TTVideoEditor/IESMMAVExporter.h>
#import <mach/mach_time.h>
#import "DVEBundleLoader.h"
#import "VEResourceLoader.h"
#import "VEResourcePicker.h"

#define useFastExport 0

#define UseAVAssetExportPresetPassthrough 1

@interface VECapManager ()<VEMotionHelperProtocol>

@property (nonatomic, copy) VECapFragmentBlock fragmentBlock;

@property (nonatomic, assign) NSTimeInterval lastDuration;


@property (nonatomic, assign) BOOL recording;

@property (nonatomic, strong) NSMutableDictionary *userParm;

@property (nonatomic, weak) UIView *curPreview;

@property (nonatomic, strong) NSMutableArray  <VEComposerInfo *>*beautyFaceTags;
@property (nonatomic, strong) NSMutableArray  <VEComposerInfo *>*beautyVFaceTags;
@property (nonatomic, strong) NSMutableArray  <VEComposerInfo *>*beautyBodyTags;
@property (nonatomic, strong) NSMutableArray  <VEComposerInfo *>*beautyMakeupTags;

@property (nonatomic, strong) NSArray *lastDuetTags;
@property (nonatomic, weak) id periodicTimeObserver;
@property (nonatomic, strong) NSMutableArray *duetPlayerTimes;

@property (nonatomic, strong) IESMMAVExporter *avExport;

@end


@implementation VECapManager
@synthesize VECameraDurationBlock = _VECameraDurationBlock;
@synthesize recordRate = _recordRate;
@synthesize isShowEffectBox = _isShowEffectBox;
@synthesize curZoomScal = _curZoomScal;
@synthesize durationType = _durationType;
@synthesize capWaitTime = _capWaitTime;
@synthesize lightValue = _lightValue;
@synthesize isVideoPreviewing = _isVideoPreviewing;
@synthesize isAudioPreviewing = _isAudioPreviewing;
@synthesize boxState = _boxState;
@synthesize preDeviceOrientation = _preDeviceOrientation;
@synthesize disableLandscap = _disableLandscap;
@synthesize duetURL = _duetURL;
@synthesize duetPresent = _duetPresent;
@synthesize currentDuetLayoutType = _currentDuetLayoutType;
@synthesize currentPreviewType = _currentPreviewType;
@synthesize isDuetComplet = _isDuetComplet;
@synthesize isDeviceChang = _isDeviceChang;
@synthesize isRecordComplet = _isRecordComplet;



- (void)dealloc
{
    [[VEMotionHelper shareManager] stopWithDelegate:self];
    NSLog(@"VECapManager dealloc");
    [self.KVOController unobserveAll];
    self.curPreview = nil;
    [IESMMCaptureKit releaseCaptureKit];

}

- (void)sycUserParm
{
    [[NSUserDefaults standardUserDefaults] setObject:self.userParm forKey:kUserParmForCamare];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IESMMAVExporter *)avExport
{
  if (!_avExport) {
    _avExport = [[IESMMAVExporter alloc] init];
    _avExport.presetName = AVAssetExportPresetPassthrough;
    _avExport.disableVideoCompostion = YES;
  }
   
  return _avExport;
}


- (instancetype)init {
    if (self = [super init]) {
        [self preInit];
    }
    return self;
}

- (void)preInit
{
    self.curPreset = AVCaptureSessionPreset1280x720;
    self.curRatio = IESMMCaptureRatio16_9;
    _recordRate = 1;
    self.pSize = CGSizeMake(VE_SCREEN_WIDTH, VE_SCREEN_HEIGHT);
    self.lSize = CGSizeMake(VE_SCREEN_HEIGHT, VE_SCREEN_WIDTH);
    self.lastDuration = 0;
    
    self.userParm = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kUserParmForCamare]];
    if (!self.userParm) {
        self.userParm = [NSMutableDictionary new];
    }
//    NSNumber *ratio = [self.userParm valueForKey:kUserParmForRatio];
//    if (ratio) {
//        switch (ratio.integerValue) {
//            case VEEventCallRatioSubType1_1:
//            {
//                self.curRatio = IESMMCaptureRatio1_1;
//            }
//                break;
//            case VEEventCallRatioSubType9_16:
//            {
//                self.curRatio = IESMMCaptureRatio16_9;
//            }
//                break;
//            case VEEventCallRatioSubType16_9:
//            {
//                self.curRatio = IESMMCaptureRatio9_16;
//            }
//                break;
//
//            case VEEventCallRatioSubType3_4:
//            {
//                self.curRatio = IESMMCaptureRatio4_3;
//            }
//                break;
//            case VEEventCallRatioSubType4_3:
//            {
//                self.curRatio = IESMMCaptureRatio4_3;
//            }
//                break;
//
//            default:
//                break;
//        }
//    }

    
    NSNumber *reslution = [self.userParm valueForKey:kUserParmForReslution];
    
    if (reslution) {
        switch (reslution.integerValue) {
    
            case VEEventCallResolutionSubType540P:
            {
                self.curPreset = AVCaptureSessionPresetiFrame960x540;
            }
                break;
            case VEEventCallResolutionSubType720P:
            {
                self.curPreset = AVCaptureSessionPreset1280x720;
            }
                break;
            case VEEventCallResolutionSubType1080P:
            {
                self.curPreset = AVCaptureSessionPreset1920x1080;
            }
                break;
            case VEEventCallResolutionSubType4K:
            {
                self.curPreset = AVCaptureSessionPreset3840x2160;
            }
                break;
                
            default:
                break;
        }
    }
    
    
    
    NSNumber *time = [self.userParm valueForKey:kUserParmForTime];
    if (time) {
        VEBarValue *bar = [VEBarValue new];
        bar.curIndex = time.unsignedIntValue;
        self.capWaitTime = bar;
    }
    
    self.beautyFaceTags = [NSMutableArray new];
    self.beautyBodyTags = [NSMutableArray new];
    self.beautyMakeupTags = [NSMutableArray new];
    
}

- (void)initMotion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[VEMotionHelper shareManager] startWithDelegate:self];
    });
    
}

- (void)directionChange:(UIDeviceOrientation)direction
{
    if (self.currentPreviewType == VECPCurrentPreViewTypeDuet) {
        return;
    }
    if (self.preDeviceOrientation != direction) {
        if (self.recording) return; // 如果正在录制，不响应横竖屏切换
        if (self.boxState > 0) return; // 已录制一段视频，不响应横竖屏切换
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.preDeviceOrientation = direction;
            NSLog(@"pre orientation:%zd",self.preDeviceOrientation);
            
            [self ratioWithCommand:self.curRatio orientation:direction];
        });
    }
}

- (void)ratioWithCommand:(IESMMCaptureRatio)ratio orientation:(UIDeviceOrientation)orientation{
    if (self.currentPreviewType == VECPCurrentPreViewTypeDuet) {
        return;
    }
    BOOL portrait = NO;
    
    @weakify(self);
    portrait = (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown)  ? YES : NO;
    void(^finishRatioBlock)(void)=^void(){
        @strongify(self);
        NSLog(@"--------targetVideoSize--------%@",NSStringFromCGSize(self.recorder.videoData.transParam.targetVideoSize));

        switch (orientation) {
            case UIDeviceOrientationPortrait:
                [self.recorder setOutputDirection:UIImageOrientationUp];
                break;
            case UIDeviceOrientationLandscapeLeft:
                [self.recorder setOutputDirection:UIImageOrientationLeft];
                break;
            case UIDeviceOrientationLandscapeRight:
                [self.recorder setOutputDirection:UIImageOrientationRight];
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                [self.recorder setOutputDirection:UIImageOrientationDown];
                break;
            default:
                [self.recorder setOutputDirection:UIImageOrientationUp];
                break;
        }
    };
    
    IESMMCaptureRatio curratio = 0;
    switch (self.curRatio) {
        case IESMMCaptureRatio9_16:
            curratio = portrait ? IESMMCaptureRatio9_16 : IESMMCaptureRatio16_9;
            break;
        case IESMMCaptureRatio16_9:
            curratio = portrait ? IESMMCaptureRatio16_9 : IESMMCaptureRatio16_9;
            break;
        case IESMMCaptureRatio4_3:
            curratio = portrait ? IESMMCaptureRatio4_3 : IESMMCaptureRatio4_3;
            break;
        case IESMMCaptureRatio3_4:
            curratio = portrait ? IESMMCaptureRatio3_4 : IESMMCaptureRatio4_3;
            break;
        case IESMMCaptureRatio1_1:
            curratio = portrait ? IESMMCaptureRatio1_1 : IESMMCaptureRatio1_1;
            break;
            
        default:
            break;
    }
    
    
    [self.recorder resetCaptureRatio:curratio then:finishRatioBlock];
    
}

- (IESMMCameraConfig *)config
{
    if (!_config) {
        
        _config = [[IESMMCameraConfig alloc] init];
        _config.enableFaceuExposureOptimize  = YES;
        _config.cameraPosition               = AVCaptureDevicePositionBack;
        _config.previewModeType              = IESPreviewModePreserveAspectRatio;
        
        _config.videoData                    = [HTSVideoData videoData];
        _config.videoData.transParam.bitrate = 5120000;
        
        _config.capturePreset                = self.curPreset;
        if (_currentPreviewType == VECPCurrentPreViewTypeDuet) {
            self.duetPlayerTimes = [NSMutableArray new];
            _config.captureRatio                 = IESMMCaptureRatioAuto;
        } else {
            _config.captureRatio                 = self.curRatio;
        }
        
        
        _config.customSwitchAnimation        = NO;
        _config.noDropFirstStartCaptureFrame = YES;
        _config.dropFrameCount               = 3;
        if (self.duetURL) {
            _config.isProcessMultiInput          = YES;
        } else {
            _config.isProcessMultiInput          = NO;
        }
        _config.noNeedEffectFrameCount       = 3;
        _config.enableTapFocus = YES;
        _config.useSDKGesture = NO;
        _config.enableTapexposure = YES;
        _config.preferredBackZoomFactor = 1;
        _config.preferredFrontZoomFactor = 1;
        
        
        if (@available(iOS 13.0,*)) {
            _config.preferredRearCameraDeviceTypes = @[AVCaptureDeviceTypeBuiltInTripleCamera,AVCaptureDeviceTypeBuiltInDualWideCamera,AVCaptureDeviceTypeBuiltInDualCamera];
        }
        
        _config.landscapeDetectEnable = YES;
    }
    
    return _config;
}

- (void)addWaterMark:(IESMMCameraConfig *)config
{
    UIImage *image = [UIImage imageNamed:@"last_movelogo_00003"];

    UIImage *image0 = [UIImage imageNamed:@"last_movelogo_00000"];
    UIImage *image1 = [UIImage imageNamed:@"last_movelogo_00001"];
    UIImage *image2 = [UIImage imageNamed:@"last_movelogo_00002"];
    UIImage *image3 = [UIImage imageNamed:@"last_movelogo_00003"];
    UIImage *image4 = [UIImage imageNamed:@"last_movelogo_00004"];
    
    CGSize imageSize = CGSizeMake(image.size.width / _config.outputSize.width, image.size.height / _config.outputSize.height);
    
    CGRect frame                  = CGRectMake(0.5, 0.5, imageSize.width, imageSize.height);
    IESAnimationSticker *sticker = [IESAnimationSticker stickerWithImage:image frame:frame rotate:1 opaque:1.0];
    IESStickerAnimation *animation = [[IESStickerAnimation alloc] init];
    
    animation.frameTs              = @[
                                       [NSValue valueWithCMTime:CMTimeMake(10, 30)],
                                       [NSValue valueWithCMTime:CMTimeMake(36, 30)],
                                       [NSValue valueWithCMTime:CMTimeMake(46, 30)],
                                       [NSValue valueWithCMTime:CMTimeMake(54, 30)],
                                       [NSValue valueWithCMTime:CMTimeMake(70, 30)],
                                       ];
//    animation.frameTs              = @[
//                                       [NSValue valueWithCMTimeRange:CMTimeRangeMake(CMTimeMake(0, 500), CMTimeMake(1000, 500))],
//                                       [NSValue valueWithCMTimeRange:CMTimeRangeMake(CMTimeMake(1000, 500), CMTimeMake(1000, 500))],
//                                       [NSValue valueWithCMTimeRange:CMTimeRangeMake(CMTimeMake(2000, 500), CMTimeMake(1000, 500))],
//                                       [NSValue valueWithCMTimeRange:CMTimeRangeMake(CMTimeMake(3000, 500), CMTimeMake(1000, 500))],
//                                       [NSValue valueWithCMTimeRange:CMTimeRangeMake(CMTimeMake(4000, 500), CMTimeMake(1000, 500))],
//                                       ];
    animation.values               = @[image0, image1, image2, image3, image4];
    
    animation.repeatType           = kIESAnimationRepeatFromBegin;
    animation.type                 = kIESStickerAttributeTypeImage;
    animation.isAbsoluteFrameTs    = NO;
    [sticker addAnimation:animation];
    
//    config.isRecordWithWaterMark = YES;
//    config.recorderSticker       = sticker;
}

- (void)startPreviewWithView:(UIView *)preview
{
    self.curPreview = preview;
    @weakify(self);
    self.recorder                       = [[IESMMRecoder alloc] initWithView:preview
                                                                     config:self.config
                                                             cameraComplete:^{
        @strongify(self);
        [self parmSet];
        [self startAuthor];
        [self addObserver];
        [self initProcessBlock];
        
    }];
    
    
}

- (void)parmSet
{
    [self.recorder cameraSetZoomFactor:1];
    self.curZoomScal = 1;
    [self.recorder setMaxZoomFactor:6];
    
    NSLog(@"---------minZoom:%0.2f---maxZoom:%0.2f----curZoom:%0.2f",self.recorder.minAvailableVideoZoomFactor,self.recorder.maxCameraZoomFactor,self.recorder.currentCameraZoomFactor);
}

- (void)dealDuet
{
    if (self.duetURL) {
        @weakify(self);
        [[VEResourceLoader new] duetValueArr:^(NSArray<DVEEffectValue *> * _Nullable datas, NSString * _Nullable error) {
            @strongify(self);
            @weakify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                DVEEffectValue *value = datas.firstObject;
                [self setDuetValue:value];
                @weakify(self);
                [self.recorder setMultiVideoWithVideoURL:self.duetURL
                                                    rate:1
                                           completeBlock:^(NSError *_Nullable error) {
                    @strongify(self);
                    AVPlayer *player = [self.recorder getMultiPlayer];
                    self.periodicTimeObserver =
                    [player addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                        @strongify(self);
                        float seconds = time.value / (time.timescale * 1.f);
                        if (seconds > 0.f) {
                            [self.recorder multiVideoIsReady];
                        }
                    }];
                    [self.recorder setMultiVideoAutoRepeat:NO];
                    AVPlayerItem *item = player.currentItem;
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishPlayDuetVideo:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
                }];
            });

        }];
        
        
//        DVEEffectValue *value = [[TTResourceLoader new] duetValueArr].firstObject;
//        [self setDuetValue:value];
//        [self.recorder setMultiVideoWithVideoURL:self.duetURL
//                                            rate:1
//                                   completeBlock:^(NSError *_Nullable error) {
//            @strongify(self);
//            AVPlayer *player = [self.recorder getMultiPlayer];
//            self.periodicTimeObserver =
//            [player addPeriodicTimeObserverForInterval:CMTimeMake(1, 2) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
//                @strongify(self);
//                float seconds = time.value / (time.timescale * 1.f);
//                if (seconds > 0.f) {
//                    [self.recorder multiVideoIsReady];
//                }
//            }];
//            [self.recorder setMultiVideoAutoRepeat:NO];
//            AVPlayerItem *item = player.currentItem;
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishPlayDuetVideo:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
//        }];
    }
}

- (void)didFinishPlayDuetVideo:(NSNotification *)noti {
    if ([noti.name isEqualToString:AVPlayerItemDidPlayToEndTimeNotification]) {
        [self pauseVideoRecord];
    }
}

- (void)startAuthor
{
    
    [IESMMCameraDeviceAuthor cameraAuthorzied:^(BOOL authorzied) {
        if (authorzied) {
            [self.recorder startVideoCapture];
            self.isVideoPreviewing = @(YES);
            
            
            [self initMotion];
            [self dealDuet];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [DVEToast showInfo:@"请开启摄像头权限"];

            });
        }
    }];
    [IESMMCameraDeviceAuthor microphoneAuthorzied:^(BOOL authorzied) {
        if (authorzied) {
            [self.recorder startAudioCapture];
            self.isAudioPreviewing = @(YES);
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [DVEToast showInfo:@"请开启麦克风权限"];

            });
        }
    }];
    
    //control by your choice
    [IESMMDeviceAuthor setCustomPlayBackCategoryOption:AVAudioSessionCategoryOptionMixWithOthers];
    [IESMMDeviceAuthor allowMixAudioWithOthersDuringRecord:YES];
    
}

- (void)addObserver
{
    [self.KVOController observe:self.recorder
                        keyPath:@"status"
                        options:NSKeyValueObservingOptionNew
                          block:^(typeof(self) _Nullable observer, IESMMRecoder *_Nonnull object, NSDictionary<NSString *, id> *_Nonnull change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (observer.recorder.status) {
                case IESMMCameraStatusStopped:
                case IESMMCameraStatusIdle:
                    break;
                case IESMMCameraStatusProcessing:
                    break;
                case IESMMCameraStatusRecording:
                    break;
                default:
                    break;
            }
        });
    }];
}

- (void)initProcessBlock
{
    @weakify(self);
//    [self.recorder setVideoBufferCallback:^(CVPixelBufferRef  _Nonnull pixelBuffer, CMTime pts) {
//
//    }];
//
//    [self.recorder setVideoProcessedBufferCallback:^(CVPixelBufferRef  _Nonnull pixelBuffer, CMTime pts) {
//
//    }];
//
//    [self.recorder setAudioBufferCallback:^(CMSampleBufferRef  _Nonnull samplebuffer) {
//
//        CMBlockBufferRef blockBUfferRef = CMSampleBufferGetDataBuffer(samplebuffer);//取出数据
//        size_t length = CMBlockBufferGetDataLength(blockBUfferRef);   //返回一个大小，size_t针对不同的品台有不同的实现，扩展性更好
//        NSLog(@"blockBUfferRef---length-----%zd",length);
//    }];
//
    
    
    [self.recorder setIESCameraActionBlock:^(IESCameraAction action, NSError * _Nullable error, id  _Nullable data) {
        @strongify(self);
        switch (action) {
            case IESCameraDidFirstFrameRender:
            {
                NSLog(@"IESCameraDidFirstFrameRender IESCameraAction");
            }
            
                break;
            case IESCameraDidStartVideoCapture:
            
                break;
            case IESCameraDidStartAudioCapture:
                NSLog(@"IESflow--IESCameraDidStartAudioCapture");
                break;
            case IESCameraDidStopVideoCapture:
            {
                [self.recorder setTorchOn:NO];
            }
                break;
            case IESCameraDidStartVideoRecord:
            {
                if (self.duetURL) {
                    self.durationType = VECPRecordDurationTypeDuet;
                    if ([self.recorder multiVideoCurrentPlayPercent] > 0.99) {
                        [self.recorder multiVideoSeekToTime:CMTimeMake(0, 1) completeBlock:^(BOOL finished) {
                            @strongify(self);
                            [self.recorder multiVideoPlay];
                        }];
                    } else {
                        [self.duetPlayerTimes addObject:@(CMTimeGetSeconds(self.recorder.multiVideoCurrentTime))];
                        [self.recorder multiVideoPlay];
                    }
                    
                    
                }
            }
                break;
            case IESCameraDidPauseVideoRecord:
                
                [self updateFragment];
                if (self.duetURL && self.recorder.multiVideoCurrentPlayPercent > 0.99) {
                    self.isDuetComplet = YES;
                }
                break;
            case IESCameraDidReachMaxTimeVideoRecord:
                [self pauseVideoRecord];
                [self updateFragment];
                break;
            case IESCameraDidChangeCameraDeviceType:
            {
                self.isDeviceChang = YES;
                if (self.recorder.currentCameraPosition == AVCaptureDevicePositionFront) {
                    [self.recorder cameraSetZoomFactor:1];
                    self.curZoomScal = 1;
                } else {
                    [self.recorder cameraSetZoomFactor:1];
                    self.curZoomScal = 1;
                }
            }
                break;
            case IESCameraDidChangeCameraZoomFactor:
                break;
            default:
                break;
        }
    }];
    
    [self.recorder setFirstRenderBlock:^{
        NSLog(@"setFirstRenderBlock------");
    }];
    
    [self.recorder setIESCameraDurationBlock:^(CGFloat duration, CGFloat totalDuration) {
        @strongify(self);
        
        NSLog(@"----------------duration:%0.2f-----totalDuration:%0.2f",duration,totalDuration);

        if (self.VECameraDurationBlock) {
            self.VECameraDurationBlock(totalDuration, totalDuration);
        }
        [self DealDurationWithCurToatal:totalDuration];
    }];
    
}

- (void)DealDurationWithCurToatal:(NSTimeInterval)duration

{
    if (self.durationType > 0 && self.durationType != VECPRecordDurationTypeDuet) {
        NSTimeInterval total = 0;
        if (self.durationType == VECPRecordDurationType15s) {
            total = 15.0;
        } else if (self.durationType == VECPRecordDurationType60s) {
            total = 60;
        }
        
        if (total - duration < kStopRecordDeviation) {
            [self pauseVideoRecord];
        }
    }
}



    
- (void)pausePreview
{
    if (self.recorder.status != IESMMCameraStatusIdle) {
        [self pauseVideoRecord];
    }

    if (self.isAudioPreviewing && (self.isAudioPreviewing.boolValue == YES)) {
        [self.recorder stopAudioCapture];
        self.isAudioPreviewing = @(NO);
    }
    
    if (self.isVideoPreviewing && (self.isVideoPreviewing.boolValue == YES)) {
        [self.recorder stopVideoCapture];
        self.isVideoPreviewing = @(NO);
    }
    
}
- (void)resumPreview
{
    if (self.isAudioPreviewing && (self.isAudioPreviewing.boolValue == NO)) {
        [self.recorder startAudioCapture];
        self.isAudioPreviewing = @(YES);
    }
    
    if (self.isVideoPreviewing && (self.isVideoPreviewing.boolValue == NO)) {
        [self.recorder startVideoCapture];
        self.isVideoPreviewing = @(YES);
    }
        
}
- (void)endPreview
{
    if (self.isAudioPreviewing && (self.isAudioPreviewing.boolValue == YES)) {
        [self.recorder stopAudioCapture];
        self.isAudioPreviewing = @(NO);
    }
    
    if (self.isVideoPreviewing && (self.isVideoPreviewing.boolValue == YES)) {
        [self.recorder stopVideoCapture];
        self.isVideoPreviewing = @(NO);
    }
    self.curPreview.hidden = YES;
}


- (void)captureStillImageByUser:(BOOL)byUser
                     completion:(void (^_Nullable)(UIImage *_Nullable processedImage, NSError *_Nullable error))block
{
    switch (self.lightValue.subTypeIndex) {
        case VEEventCallLightSubStateOff:
        {
            self.recorder.cameraFlashMode = IESCameraFlashModeOff;
        }
            break;
        case VEEventCallLightSubStateOn:
        {
            self.recorder.cameraFlashMode = IESCameraFlashModeOn;
        }
            break;
            
        default:
            break;
    }
    [self.recorder captureStillImageByUser:byUser completion:block];
    
    
}

- (void)startVideoRecordWithRate:(CGFloat)rate WithResult:(nonnull VECapFragmentBlock)block
{
    
    switch (self.lightValue.subTypeIndex) {
        case VEEventCallLightSubStateOff:
        {
            self.recorder.torchOn = NO;
        }
            break;
        case VEEventCallLightSubStateOn:
        {
            self.recorder.torchOn = YES;
        }
            break;
            
        default:
            break;
    }
    
    self.fragmentBlock = block;
    switch (self.durationType) {
        case VECPRecordDurationType15s:
        {
            [self.recorder setMaxLimitTime:CMTimeMake(15, 1)];
        }
            break;
            
        case VECPRecordDurationType60s:
        {
            [self.recorder setMaxLimitTime:CMTimeMake(60, 1)];
        }
            break;
            
        default:
            [self.recorder setMaxLimitTime:CMTimeMake(3600*24*365, 1)];
            break;
    }
    [self.recorder startVideoRecordWithRate:self.recordRate];
    
}

- (void)pauseVideoRecord
{
   
    if (self.recorder.status != IESMMCameraStatusRecording) {
        return;
    }

    [self.recorder pauseVideoRecord];
    
    if (self.duetURL) {
        [self.recorder multiVideoPause];
    }
   
}

- (void)stopVideoRecordWithVideoData:(void (^)(id _Nonnull, NSError * _Nullable))completeBlock
{
    [self pausePreview];
    
    @weakify(self);
    [self.recorder exportWithVideo:self.recorder.videoData completion:^(HTSVideoData * _Nullable newVideoData, NSError * _Nullable error) {
        @strongify(self);
        VECustomerHUD *hud = [VECustomerHUD showProgress];
        [hud setProgressLableWithText:[NSString stringWithFormat:@"%0.1f%%",0.0]];
        [self exportVideoWithVideoData:newVideoData
                              Progress:^(CGFloat progress) {
            [hud setProgressLableWithText:[NSString stringWithFormat:@"%0.1f%%",progress]];
        } resultBlock:^(NSError * _Nonnull error, NSURL  *result) {
            [VECustomerHUD hidProgress];
            
            if (error) {
                [DVEToast showInfo:CKEditorLocStringWithKey(@"ck_video_synthesis_failed", @"合成失败")];
            } else  {
                [DVEToast showInfo:CKEditorLocStringWithKey(@"ck_video_synthesis_success", @"合成成功")];
                completeBlock(result,error);
            }
            
        }];
    }];
}

- (void)stopVideoRecordWithVideoFragments:(void (^)(NSArray * _Nonnull, NSError * _Nullable))completeBlock
{
    [self pausePreview];
    
    @weakify(self);
    [self.recorder exportWithVideo:self.recorder.videoData completion:^(HTSVideoData * _Nullable newVideoData, NSError * _Nullable error) {
        @strongify(self);
        if (!error) {
            [self creatResourceModelsWithVideoData:newVideoData complet:completeBlock];
        } else {
            NSLog(@"exportWithVideo error :%@",error.localizedDescription);
        }
        
    }];
}

- (void)creatResourceModelsWithVideoData:(HTSVideoData *)videoData complet:(void (^)(NSArray * _Nonnull, NSError * _Nullable))completeBlock
{
    NSArray<AVAsset *> *fragments = videoData.videoAssets;
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:fragments.count];
    for (NSInteger i = 0; i < fragments.count; i ++) {
        AVAsset *asset = fragments[i];
        
        if ([videoData.photoAssetsInfo objectForKey:asset]) {
            VEResourcePickerModel *model = [[VEResourcePickerModel alloc] init];
            model.videoSpeed = 1;
            model.URL = [videoData.photoAssetsInfo objectForKey:asset];
            model.type =  DVEResourceModelPickerTypeImage;
            [models addObject:model];
        } else {
            NSURL *fileURL = ((AVURLAsset *)asset).URL;
            float speed = [videoData.videoSpeeds objectForKey:asset].floatValue;
            VEResourcePickerModel *model = [[VEResourcePickerModel alloc] initWithURL:fileURL];
            model.videoSpeed = speed;
            [models addObject:model];
        }
        
    }
    
    if (completeBlock) {
        completeBlock(models,nil);
    }
}



- (void)cancelVideoRecord
{
    [self.recorder cancelVideoRecord];
}


- (void)resetVideoRecordReady
{
    [self.recorder resetVideoRecordReady];
}

- (void)removeAllVideoFragments:(dispatch_block_t _Nullable)completion
{
    [self.recorder removeAllVideoFragments:completion];
}

- (CGFloat)maxExposureBias
{
    return [self.recorder maxExposureBias];
}

- (CGFloat)minExposureBias
{
    return [self.recorder minExposureBias];
}

- (CGFloat)exposureBias
{
    return [self.recorder exposureBias];
}

- (void)tapAtPoint:(CGPoint)point
{
    [self.recorder tapFocusAtPoint:point];
    [self.recorder tapExposureAtPoint:point];
    NSLog(@"---------minZoom:%0.2f---maxZoom:%0.2f----curZoom:%0.2f",self.recorder.minExposureBias,self.recorder.maxExposureBias,self.recorder.exposureBias);
}

- (CGFloat)currentCameraZoomFactor
{
    return [self.recorder currentCameraZoomFactor];
}

- (BOOL)cameraSetZoomFactor:(CGFloat)zoomFactor
{
    NSLog(@"---------minZoom:%0.2f---maxZoom:%0.2f----curZoom:%0.2f--%@",self.recorder.minAvailableVideoZoomFactor,self.recorder.maxAvailableVideoZoomFactor,self.recorder.videoZoomFactorUpscaleThreshold,self.recorder.virtualDeviceSwitchOverVideoZoomFactors);

    if ([self.recorder cameraSetZoomFactor:zoomFactor]) {
        self.curZoomScal = self.recorder.currentCameraZoomFactor;
        return YES;
    }
    
    return NO;
}

- (BOOL)cameraRampToZoomFactor:(CGFloat)zoomFactor withRate:(CGFloat)rate;
{
    NSLog(@"---------minZoom:%0.2f---maxZoom:%0.2f----curZoom:%0.2f",self.recorder.minAvailableVideoZoomFactor,self.recorder.maxAvailableVideoZoomFactor,self.recorder.exposureBias);
    if ([self.recorder cameraRampToZoomFactor:zoomFactor withRate:rate]) {
        if (zoomFactor > self.recorder.maxCameraZoomFactor) {
            zoomFactor = self.recorder.maxCameraZoomFactor;
        }
        self.curZoomScal = zoomFactor;
        return YES;
    }
    
    return NO;
}

- (void)changeExposureBias:(CGFloat)bias;
{
    [self.recorder changeExposureBias:bias];
}
    
- (void)switchFilterWithLeftPath:(NSString *_Nullable)left
                       rightPath:(NSString *_Nullable)right
                        progress:(CGFloat)progress
{
    [self.recorder switchFilterWithLeftPath:left rightPath:right progress:progress];
}

- (void)switchCameraSource
{
    [self.recorder switchCameraSource];
    
    NSLog(@"---------currentCameraZoomFactor:%0.2f",self.recorder.currentCameraZoomFactor);
}

- (AVCaptureDevicePosition)GetCurrentCameraPosition
{
    return self.recorder.currentCameraPosition;
}

- (void)dealWithValue:(VEBarValue *)barValue
{
    switch (barValue.eventType) {
        case VEEventCallCaptureTimeType:
        {
            [self.userParm setObject:@(barValue.subTypeIndex) forKey:kUserParmForTime];
            [self sycUserParm];
            self.capWaitTime = barValue;
        }
            break;
    
        case VEEventCallFlashState:
        {
            [self dealFlashWithValue:barValue];
        }
            break;
        case VEEventCallLightState:
        {
            [self dealLightWithValue:barValue];
        }
            break;
        case VEEventCallRatioType:
        {
            if (self.currentPreviewType != VECPCurrentPreViewTypeDuet) {
                [self dealRatioWithValue:barValue];
            }            
        }
            break;
        case VEEventCallResolutionType:
        {
            [self dealResolutionWithValue:barValue];
        }
            break;
        case VEEventCallCamraPosion:
        {
            [self dealCamraPositionWithValue:barValue];
        }
            break;
            
        default:
            break;
    }
}

- (void)dealFlashWithValue:(VEBarValue *)barValue
{
    switch (barValue.subTypeIndex) {
        case VEEventCallFlashSubStateOn:
        {
            self.recorder.torchOn = YES;
        }
            break;
        case VEEventCallFlashSubStateOff:
        {
            self.recorder.torchOn = NO;
        }
            break;
            
        default:
            break;
    }
}

- (void)dealLightWithValue:(VEBarValue *)barValue
{
    self.lightValue = barValue;
    
}

- (void)dealRatioWithValue:(VEBarValue *)barValue
{
//    [self.userParm setValue:@(barValue.subTypeIndex) forKey:kUserParmForRatio];
//    [self sycUserParm];
    switch (barValue.subTypeIndex) {
        case VEEventCallRatioSubType1_1:
        {
            self.curRatio = IESMMCaptureRatio1_1;
        }
            break;
        case VEEventCallRatioSubType9_16:
        {
            self.curRatio = IESMMCaptureRatio16_9;
        }
            break;
        case VEEventCallRatioSubType16_9:
        {
            self.curRatio = IESMMCaptureRatio9_16;
        }
            break;
       
        case VEEventCallRatioSubType3_4:
        {
            self.curRatio = IESMMCaptureRatio4_3;
        }
            break;
        case VEEventCallRatioSubType4_3:
        {
            self.curRatio = IESMMCaptureRatio3_4;
        }
            break;
            
        default:
            break;
    }
    
    [self ratioWithCommand:self.curRatio orientation:self.preDeviceOrientation];

}

- (void)dealResolutionWithValue:(VEBarValue *)barValue
{
    [self.userParm setValue:@(barValue.subTypeIndex) forKey:kUserParmForReslution];
    [self sycUserParm];
    switch (barValue.subTypeIndex) {
        case VEEventCallResolutionSubType540P:
        {
            self.curPreset = AVCaptureSessionPresetiFrame960x540;
            _config.videoData.transParam.bitrate = 2560000;
        }
            break;
        case VEEventCallResolutionSubType720P:
        {
            self.curPreset = AVCaptureSessionPreset1280x720;
            _config.videoData.transParam.bitrate = 5120000;
        }
            break;
        case VEEventCallResolutionSubType1080P:
        {
            self.curPreset = AVCaptureSessionPreset1920x1080;
            _config.videoData.transParam.bitrate = 10240000;
        }
            break;
        case VEEventCallResolutionSubType4K:
        {
            self.curPreset = AVCaptureSessionPreset3840x2160;
            _config.videoData.transParam.bitrate = 40000000;
        }
            break;
            
        default:
            break;
    }
    
    
    @weakify(self);
    if (self.currentPreviewType == VECPCurrentPreViewTypeDuet) {
        CGSize targetVideoSize = CGSizeMake(720, 640);
        CGFloat height = 960;
        CGFloat width = 540;
        if (self.curPreset == AVCaptureSessionPresetiFrame960x540) {
            height = 960;
            width = 540;
            _config.videoData.transParam.bitrate = 2560000;
        }
        if (self.curPreset == AVCaptureSessionPreset1280x720) {
            height = 1280;
            width = 720;
            _config.videoData.transParam.bitrate = 5120000;
        }
        if (self.curPreset == AVCaptureSessionPreset1920x1080) {
            height = 1920;
            width = 1080;
            _config.videoData.transParam.bitrate = 10240000;
        }
    
        switch (self.currentDuetLayoutType) {
            case VECPDuetLayoutTypeHorizontal:
                targetVideoSize = CGSizeMake(width, height * 0.5);
                break;
            case VECPDuetLayoutTypeVertical:
                targetVideoSize = CGSizeMake(width, height);
                break;
            case VECPDuetLayoutTypeThree:
                targetVideoSize = CGSizeMake(width, height);
                break;
                
            default:
                break;
        }
        
        [self.recorder resetCaptureRatio:IESMMCaptureRatioAuto preferredPreset:self.curPreset previewSize:self.curPreview.size outputSize:targetVideoSize then:^{
            @strongify(self);
            self.curZoomScal = self.recorder.currentCameraZoomFactor;
            NSLog(@"--------targetVideoSize------%@",NSStringFromCGSize(self.recorder.videoData.transParam.targetVideoSize));
            if (self.recorder.currentCameraPosition == AVCaptureDevicePositionFront) {
            } else {
                [self.recorder cameraSetZoomFactor:1];
                self.curZoomScal = 1;
            }
        }];
    } else {
        [self.recorder resetCapturePreset:self.curPreset then:^{
            @strongify(self);
            self.curZoomScal = self.recorder.currentCameraZoomFactor;
            NSLog(@"--------targetVideoSize------%@",NSStringFromCGSize(self.recorder.videoData.transParam.targetVideoSize));
            if (self.recorder.currentCameraPosition == AVCaptureDevicePositionFront) {
            } else {
                [self.recorder cameraSetZoomFactor:1];
                self.curZoomScal = 1;
            }
        }];
    }
    

}

- (void)dealCamraPositionWithValue:(VEBarValue *)barValue
{
    switch (barValue.subTypeIndex) {
        case VEEventCallCamraSubPosionBack:
        {
            [self.recorder switchCameraSource];
            
        }
            break;
        case VEEventCallCamraSubPosionFront:
        {
            
            if (self.curPreset == AVCaptureSessionPreset1920x1080 && ([VEDVideoTool deviceVersion].integerValue < 91)  && (self.recorder.currentCameraPosition == AVCaptureDevicePositionBack) ) {
                [VECustomerHUD showMessage:@"当前分辨率1080P不支持切换到前置摄像头，请降低分辨率" afterDele:3];
            } else {
                [self.recorder switchCameraSource];
            }
        }
            break;
            
        default:
            break;
    }
    
    NSLog(@"---------currentCameraZoomFactor:%0.2f",self.recorder.currentCameraZoomFactor);
//    self.curZoomScal = self.recorder.currentCameraZoomFactor;
}


- (void)setFliter:(DVEEffectValue *)evalue
{
    if (!evalue || evalue.valueState != VEEffectValueStateInUse) {
        [self.recorder applyEffect:nil type:IESEffectFilter];
        IESIndensityParam param = {0};
        param.indensity = 0;
        [self.recorder applyIndensity:param type:IESEffectFilter];
    } else {
        [self.recorder applyEffect:evalue.sourcePath type:IESEffectFilter];
        IESIndensityParam param = {0};
        param.indensity = evalue.indesty;
        [self.recorder applyIndensity:param type:IESEffectFilter];
    }
    
}

- (void)setSticker:(DVEEffectValue *)evalue
{
    //action
    if (evalue && evalue.valueState == VEEffectValueStateInUse) {
        [self.recorder applyEffect:evalue.sourcePath type:IESEffectGroup];
    } else {
        [self.recorder applyEffect:nil type:IESEffectGroup];
    }
    
}

- (void)removeSticker
{
    [self.recorder applyEffect:nil type:IESEffectGroup];
}

- (BOOL)isContainObj:(DVEEffectValue *)obj inArr:(NSArray *)arr
{
    for (VEComposerInfo *composer in arr) {
        if ([composer.tag isEqualToString:obj.key]) {
            composer.node = obj.composerPath;
            return YES;
        }
    }
    return NO;
}

- (void)setMakeup:(DVEEffectValue *)evalue
{
    VEComposerInfo *composer = [[VEComposerInfo alloc] init];
    composer.node = evalue.composerPath;
    composer.tag = evalue.key;
    //action
    if (evalue && evalue.valueState == VEEffectValueStateInUse) {
        
        switch (evalue.beautyType) {
            case VEEffectBeautyTypeFace:
                
                if (![self isContainObj:evalue inArr:self.beautyFaceTags]) {
                    [self.beautyFaceTags addObject:composer];
                    // 添加特效
                    [self.recorder appendComposerNodesWithTags:@[composer]];
                } else {
                    [self updateMakeup:evalue];
                }
                
                break;
            case VEEffectBeautyTypeVFace:
                
                if (![self isContainObj:evalue inArr:self.beautyVFaceTags]) {
                    [self.beautyVFaceTags addObject:composer];
                    // 添加特效
                    [self.recorder appendComposerNodesWithTags:@[composer]];
                } else {
                    [self updateMakeup:evalue];
                }
                
                break;
            case VEEffectBeautyTypeBody:
                
                if (![self isContainObj:evalue inArr:self.beautyBodyTags]) {
                    [self.beautyBodyTags addObject:composer];
                    // 添加特效
                    [self.recorder appendComposerNodesWithTags:@[composer]];
                } else {
                    [self updateMakeup:evalue];
                }
                
                break;
            case VEEffectBeautyTypeMakeup:
            {
                for (VEComposerInfo *composer0 in self.beautyMakeupTags) {
                    if ([composer0.tag isEqualToString:evalue.key]) {
                        
                        [self.recorder removeComposerNodesWithTags:@[composer0]];
                        [self.beautyMakeupTags removeObject:composer0];
                        break;
                        
                    }
                }
                
                [self.beautyMakeupTags addObject:composer];
                // 添加特效
                [self.recorder appendComposerNodesWithTags:@[composer]];
            }
                
                break;
                
            default:
                break;
        }
       
        
    } else {
        [self.recorder removeComposerNodesWithTags:@[composer]];
        
    }
    NSArray *arr = [self.recorder getCurrentComposerNodes];
    NSLog(@"-------------%zd",arr.count);
}

- (void)updateMakeup:(DVEEffectValue *)evalue
{
    switch (evalue.beautyType) {
        case VEEffectBeautyTypeFace:
            [self isContainObj:evalue inArr:self.beautyFaceTags];
            break;
        case VEEffectBeautyTypeVFace:
            [self isContainObj:evalue inArr:self.beautyVFaceTags];
            break;
        case VEEffectBeautyTypeBody:
            [self isContainObj:evalue inArr:self.beautyBodyTags];
            break;
        case VEEffectBeautyTypeMakeup:
            [self isContainObj:evalue inArr:self.beautyMakeupTags];
            break;
        default:
            break;
    }
                
    [self.recorder updateComposerNode:evalue.composerTag key:evalue.key value:evalue.indesty];
    NSArray *arr = [self.recorder getCurrentComposerNodes];
    NSLog(@"-------------%zd",arr.count);
}

- (void)removeMakeup:(DVEEffectValue *)evalue
{
 
    if (evalue) {
        
        switch (evalue.beautyType) {
            case VEEffectBeautyTypeFace:
                [self removeComposWithValue:evalue inArr:self.beautyFaceTags];
                
                break;
            case VEEffectBeautyTypeBody:
                [self removeComposWithValue:evalue inArr:self.beautyBodyTags];
                
                break;
            case VEEffectBeautyTypeMakeup:
                [self removeComposWithValue:evalue inArr:self.beautyMakeupTags];
                break;
                
            default:
                break;
        }
    }
}

- (void)removeComposWithValue:(DVEEffectValue *)value inArr:(NSMutableArray *)tagArr
{
    for (VEComposerInfo *composer in tagArr) {
        if ([composer.tag isEqualToString:value.key]) {
            
            [self.recorder removeComposerNodesWithTags:@[composer]];
            [tagArr removeObject:composer];
            break;
        }
    }
}

- (void)setBeautyFaceWithArr:(NSArray <DVEEffectValue *>*)values
{
    NSMutableArray *tagArr = [NSMutableArray new];
    for (DVEEffectValue *value in values) {
        VEComposerInfo *composer = [[VEComposerInfo alloc] init];
        composer.node = value.composerPath;
        composer.tag = value.key;
        [tagArr addObject:composer];
    }
    [self.recorder removeComposerNodesWithTags:self.beautyFaceTags];
    
    if (self.beautyFaceTags.count > 0) {
        [self.recorder replaceComposerNodesWithNewTag:tagArr old:self.beautyFaceTags];
    } else {
        [self.recorder appendComposerNodesWithTags:tagArr];
    }
    
    self.beautyFaceTags = tagArr;
    NSArray *arr = [self.recorder getCurrentComposerNodes];
    NSLog(@"-------------%zd",arr.count);
}

- (void)setBeautyVFaceWithArr:(NSArray<DVEEffectValue *> *)values
{
    NSMutableArray *tagArr = [NSMutableArray new];
    for (DVEEffectValue *value in values) {
        VEComposerInfo *composer = [[VEComposerInfo alloc] init];
        composer.node = value.composerPath;
        composer.tag = value.key;
        [tagArr addObject:composer];
    }
    [self.recorder removeComposerNodesWithTags:self.beautyVFaceTags];
    
    if (self.beautyVFaceTags.count > 0) {
        [self.recorder replaceComposerNodesWithNewTag:tagArr old:self.beautyVFaceTags];
    } else {
        [self.recorder appendComposerNodesWithTags:tagArr];
    }
    
    self.beautyVFaceTags = tagArr;
    NSArray *arr = [self.recorder getCurrentComposerNodes];
    NSLog(@"-------------%zd",arr.count);
}

- (void)setBeautyBodyWithArr:(NSArray <DVEEffectValue *>*)values
{
    NSMutableArray *tagArr = [NSMutableArray new];
    for (DVEEffectValue *value in values) {
        VEComposerInfo *composer = [[VEComposerInfo alloc] init];
        composer.node = value.composerPath;
        composer.tag = value.key;
        [tagArr addObject:composer];
    
    }
    
    if (self.beautyBodyTags.count > 0) {
        [self.recorder replaceComposerNodesWithNewTag:tagArr old:self.beautyBodyTags];
    } else {
        [self.recorder appendComposerNodesWithTags:tagArr];
    }
    
    self.beautyBodyTags = tagArr;
    NSArray *arr = [self.recorder getCurrentComposerNodes];
    NSLog(@"-------------%zd",arr.count);
    
}

- (void)setBeautyMakeupWithArr:(NSArray <DVEEffectValue *>*)values
{
    NSMutableArray *tagArr = [NSMutableArray new];
    for (DVEEffectValue *value in values) {
        VEComposerInfo *composer = [[VEComposerInfo alloc] init];
        composer.node = value.composerPath;
        composer.tag = value.key;
        [tagArr addObject:composer];
    }
    
    
    if (self.beautyMakeupTags.count > 0) {
        [self.recorder replaceComposerNodesWithNewTag:tagArr old:self.beautyMakeupTags];
    } else {
        [self.recorder appendComposerNodesWithTags:tagArr];
    }
    
    self.beautyMakeupTags = tagArr;
    NSArray *arr = [self.recorder getCurrentComposerNodes];
    NSLog(@"-------------%zd",arr.count);
}

- (void)dismissMakeUp
{
    if (self.beautyFaceTags.count > 0) {
        [self.recorder removeComposerNodesWithTags:self.beautyFaceTags];
    }
    
    if (self.beautyVFaceTags.count > 0) {
        [self.recorder removeComposerNodesWithTags:self.beautyVFaceTags];
    }
    
    if (self.beautyBodyTags.count > 0) {
        [self.recorder removeComposerNodesWithTags:self.beautyBodyTags];
    }
    
    if (self.beautyMakeupTags.count > 0) {
        [self.recorder removeComposerNodesWithTags:self.beautyMakeupTags];
    }
    
}

- (void)resetMakeUp
{
    
    
}

- (void)showMakeUp
{
    if (self.beautyFaceTags.count > 0) {
        [self.recorder appendComposerNodesWithTags:self.beautyFaceTags];
    }
    
    if (self.beautyVFaceTags.count > 0) {
        [self.recorder appendComposerNodesWithTags:self.beautyVFaceTags];
    }
    
    if (self.beautyBodyTags.count > 0) {
        [self.recorder appendComposerNodesWithTags:self.beautyBodyTags];
    }
    
    if (self.beautyMakeupTags.count > 0) {
        [self.recorder appendComposerNodesWithTags:self.beautyMakeupTags];
    }
    
}

- (void)addOneImageVideo:(UIImage *)image
{
    NSString *filePath = [[HTSVideoData cacheDirPath] stringByAppendingPathComponent:[NSString VEUUIDString]];
    [UIImageJPEGRepresentation(image, 1) writeToFile:filePath atomically:YES];
    NSURL *picURL = [NSURL fileURLWithPath:filePath];
    
    AVAsset *asset = [IESMMBlankResource getBlackVideoAsset];
    [self.recorder.videoData.videoAssets addObject:asset];
    [self.recorder.videoData.photoAssetsInfo setObject:picURL forKey:asset];
    IESMMVideoDataClipRange *clipRang = IESMMVideoDataClipRangeMake(0, 3);
    [self.recorder.videoData.videoTimeClipInfo setObject:clipRang forKey:asset];
    
    NSTimeInterval totalDuration = self.recorder.videoData.totalVideoDuration;
    if (self.VECameraDurationBlock) {
        self.VECameraDurationBlock(totalDuration, totalDuration);
    }
    
   
}
// MARK: removeLastVideoFragment
- (void)removeLastVideoAsset
{
    [self.recorder removeLastVideoFragment];
    
    NSTimeInterval totalDuration = self.recorder.videoData.totalVideoDuration;
    self.lastDuration = self.recorder.getTotalDuration;
    
    if (_currentPreviewType == VECPCurrentPreViewTypeDuet) {
        @weakify(self);
        NSTimeInterval duetDuration = [VEDVideoTool getVideoDurationWithVideoURL:self.duetURL];
        NSTimeInterval seekTime = totalDuration;
        while (seekTime > duetDuration) {
            seekTime -= duetDuration;
        }

        
        NSNumber *time = self.duetPlayerTimes.lastObject;
        if (time) {
            seekTime = time.doubleValue;
            if (self.recorder.fragmentCount == 0) {
                seekTime = 0;
            }
        } else {
            seekTime = 0;
        }
        [self.duetPlayerTimes removeLastObject];
        [self.recorder multiVideoSeekToTime:CMTimeMake(seekTime * 6000, 6000) completeBlock:^(BOOL finished) {
            @strongify(self);
            if (self.VECameraDurationBlock) {
                self.VECameraDurationBlock(totalDuration, totalDuration);
            }
        }];
    }
    
    if (self.VECameraDurationBlock) {
        self.VECameraDurationBlock(totalDuration, totalDuration);
    }
}

- (void)updateFragment
{
    self.recorder.torchOn = NO;
    self.lastDuration = self.recorder.getTotalDuration;
    NSLog(@"updateFragment----------%zd,%zd",self.recorder.fragmentCount,self.recorder.videoData.videoAssets.count);
    if (self.fragmentBlock) {
        self.fragmentBlock(self.recorder.videoData.videoAssets);
    }
    
    
}


- (void)resetBeautyFace
{
    if (self.beautyFaceTags.count > 0) {
        [self.recorder removeComposerNodesWithTags:self.beautyFaceTags];
    }
    
    
}

- (void)resetBeautyVFace
{
    if (self.beautyVFaceTags.count > 0) {
        [self.recorder removeComposerNodesWithTags:self.beautyVFaceTags];
    }
}

- (void)resetBeautyBody
{
    if (self.beautyBodyTags.count > 0) {
        [self.recorder removeComposerNodesWithTags:self.beautyBodyTags];
    }
    
}
- (void)resetBeautyMakeUp
{
    if (self.beautyMakeupTags.count > 0) {
        [self.recorder removeComposerNodesWithTags:self.beautyMakeupTags];
    }

}

- (void)closeBeautyFace
{
    if (self.beautyFaceTags.count > 0) {
        [self.recorder removeComposerNodesWithTags:self.beautyFaceTags];
        [self.beautyFaceTags removeAllObjects];
    }
    
}

- (void)closeBeautyVFace
{
    if (self.beautyVFaceTags.count > 0) {
        [self.recorder removeComposerNodesWithTags:self.beautyVFaceTags];
        [self.beautyVFaceTags removeAllObjects];
    }
}

- (void)closeBeautyBody
{
    if (self.beautyBodyTags.count > 0) {
        [self.recorder removeComposerNodesWithTags:self.beautyBodyTags];
        [self.beautyBodyTags removeAllObjects];
    }
    
    
}
- (void)closeBeautyMakeUp
{
    if (self.beautyMakeupTags.count > 0) {
        [self.recorder removeComposerNodesWithTags:self.beautyMakeupTags];
        [self.beautyMakeupTags removeAllObjects];
    }
}

- (void)setRecordRate:(CGFloat)recordRate
{
    _recordRate = recordRate;
    if (_duetURL) {
        @weakify(self);
        [self.recorder multiVideoChangeRate:1/recordRate completeBlock:^(NSError * _Nullable error) {
            NSLog(@"multiVideoChangeRate:%0.1f",recordRate);
            @strongify(self);
            AVPlayer *player = [self.recorder getMultiPlayer];
            self.periodicTimeObserver =
            [player addPeriodicTimeObserverForInterval:CMTimeMake(1, 2) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                float seconds = time.value / (time.timescale * 1.f);
                if (seconds > 0.f) {
                    [self.recorder multiVideoIsReady];
                }
            }];
            [self.recorder setMultiVideoAutoRepeat:NO];
            AVPlayerItem *item = player.currentItem;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishPlayDuetVideo:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
        }];
    }
}

- (CGFloat)duetPresent
{
    if (_duetURL) {
        return [self.recorder multiVideoCurrentPlayPercent];;
    } else {
        return 0;
    }
}

- (void)exportVideoWithVideoData:(HTSVideoData *)videodata Progress:(void (^_Nullable )(CGFloat progress))progressBlock resultBlock:(void (^)(NSError *error,id result))exportBlock
{
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    
    uint64_t start = mach_absolute_time();
    if (useFastExport) {
        HTSVideoData *videoData = [videodata copy];
        videoData.canvasSize = videodata.transParam.targetVideoSize;
        videoData.transParam.allowFrameReordering = NO; // 建议设置为NO,否则很影响转码耗时
        [self.avExport exportVideoData:videodata completeBlock:^(NSURL *outUrl, NSError *error) {
            if (outUrl) {
                
                //这部分为需要统计时间的代码
                
                uint64_t end = mach_absolute_time();
                
                uint64_t cost = (end - start) * timebase.numer / timebase.denom;
                NSTimeInterval time = (CGFloat)cost / NSEC_PER_SEC;
                NSLog(@"方法耗时: %f s",time);
                [self saveVideoToAlbum:outUrl.path];
#if DEBUG
                DVENotificationAlertView *alertView = [DVENotification showTitle:@"导出耗时" message:[NSString stringWithFormat:@"本次导出耗时：%0.2f 秒",time] leftAction:@"取消" rightAction:@"好的"];
                alertView.leftActionBlock = ^(UIView * _Nonnull view) {
                    if (exportBlock) {
                        exportBlock(nil, outUrl);
                    }
                };
                alertView.rightActionBlock = ^(UIView * _Nonnull view) {
                    if (exportBlock) {
                        exportBlock(nil, outUrl);
                    }
                };

            NSLog(@"--------------%@",outUrl);
    
#else
    
                if (exportBlock) {
                    exportBlock(nil,outUrl);
                }
  
#endif
                
                
                
            } else {
                NSLog(@"IESflow--%@",error.localizedDescription);
                [VECustomerHUD showMessage:@"导出失败" afterDele:3];
            }
        }];
    } else {
        HTSVideoData *videoData = [videodata copy];
        
        IESMMTransProcessData *config = [[IESMMTransProcessData alloc] init];
        config.useNewMudule           = YES;
        config.enableMultiTrack      = YES;
        config.exportFps = 30; // 导出帧率
        config.enableOptExportFps = YES;
        config.timeOutPeriod = 4;
        config.infoStickerForceAmazing = YES;
        config.disableEffectGroup = YES;
        config.enableKeyFrameFeature = YES;
        config.infostickerTextureRelease = YES;
        config.disableEffectProcess = NO;
        config.disableExtracFilter = YES;
        config.encodeUseFenceRender = YES;
        config.disableInfoSticker = NO;
        
        if (self.currentPreviewType != VECPCurrentPreViewTypeDuet) {
            videoData.canvasSize = videodata.transParam.targetVideoSize;
        } else {
            CGSize targetVideoSize = CGSizeMake(720, 640);
            CGFloat height = 960;
            CGFloat width = 540;
            if (self.curPreset == AVCaptureSessionPresetiFrame960x540) {
                height = 960;
                width = 540;
            }
            if (self.curPreset == AVCaptureSessionPreset1280x720) {
                height = 1280;
                width = 720;
            }
            if (self.curPreset == AVCaptureSessionPreset1920x1080) {
                height = 1920;
                width = 1080;
            }
        
            switch (self.currentDuetLayoutType) {
                case VECPDuetLayoutTypeHorizontal:
                    targetVideoSize = CGSizeMake(width, height * 0.5);
                    break;
                case VECPDuetLayoutTypeVertical:
                    targetVideoSize = CGSizeMake(width, height);
                    break;
                case VECPDuetLayoutTypeThree:
                    targetVideoSize = CGSizeMake(width, height);
                    break;
                    
                default:
                    break;
            }
            videodata.transParam.videoSize = targetVideoSize;
            videodata.transParam.targetVideoSize = targetVideoSize;

            videoData.canvasSize = targetVideoSize;
        }
        
        videoData.transParam.allowFrameReordering = NO; // 建议设置为NO,否则很影响转码耗时

    //    videoData.transParam.bitrate = [VECapManager s_p_exportBitRateWithResolution:self.exportResolution fps:self.expotFps];
        NSLog(@"--------targetVideoSize--------%@",NSStringFromCGSize(videodata.transParam.targetVideoSize));
       
        
        @weakify(self);
        [[VECompileTaskManagerSession sharedInstance] transWithVideoData:videoData
                                                                 transConfig:config
                                                                videoProcess:nil
                                                               completeBlock:^(IESMMTranscodeRes *result) {
            NSLog(@"------%@",result.mergeUrl);
            @strongify(self);
            if (result.mergeUrl) {
                [self saveVideoToAlbum:result.mergeUrl.path];
                if (exportBlock) {
                    exportBlock(nil,result.mergeUrl);
                }
                
            } else {
                NSLog(@"IESflow--%@",result.error.localizedDescription);
                [VECustomerHUD showMessage:@"导出失败" afterDele:3];
                if (exportBlock) {
                    exportBlock(nil,nil);
                }
            }
        }];
        
        [[VECompileTaskManagerSession sharedInstance] setProgressBlock:^(CGFloat progress) {
            if (progressBlock) {
                progressBlock(progress);
            }
        }];
    }

    

}

- (void)saveVideoToAlbum:(NSString *)path {
    
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"error - %@", error);
    } else {
        NSLog(@"保存到相册成功");
    }
}

- (void)setDuetValue:(DVEEffectValue *)evalue
{
    VEComposerInfo *one = [[VEComposerInfo alloc] init];
    one.node            = evalue.sourcePath;
    one.tag             = @"";
    
    if (self.lastDuetTags) {
        [self.recorder replaceComposerNodesWithNewTag:@[one] old:self.lastDuetTags];
    } else {
        [self.recorder appendComposerNodesWithTags:@[one]];
    }
    
    self.lastDuetTags = @[one];
}

- (void)updateDuetValue:(DVEEffectValue *)evalue
{
    VEComposerInfo *one = self.lastDuetTags.firstObject;
    one.node            = evalue.sourcePath;
    one.tag             = @"";
    
    if (one) {
        [self.recorder updateComposerNode:evalue.sourcePath key:evalue.key value:evalue.indesty];
    } else {
        [self.recorder appendComposerNodesWithTags:@[one]];
    }
    
    self.lastDuetTags = @[one];
}

- (void)setDuetURL:(NSURL *)URL;
{
    _duetURL = URL;
    self.currentPreviewType = VECPCurrentPreViewTypeDuet;
}

@end
