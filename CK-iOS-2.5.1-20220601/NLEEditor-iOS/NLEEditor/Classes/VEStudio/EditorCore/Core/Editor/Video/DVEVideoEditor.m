//
//   DVEVideoEditor.m
//   NLEEditor
//
//   Created  by bytedance on 2021/4/26.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEVideoEditor.h"
#import "DVEVCContext.h"
#import "NSDictionary+DVE.h"
#import "DVECustomerHUD.h"
#import "NSString+DVE.h"
#import "NSString+VEIEPath.h"
#import "DVELoggerImpl.h"
#import "DVEMacros.h"
#import "DVEMediaContext+VideoOperation.h"
#import "DVECoreKeyFrameProtocol.h"
#import "DVEComponentViewManager.h"
#import <DVETrackKit/NLESegment_OC+NLE.h>
#import <DVETrackKit/NLETrack_OC+NLE.h>
#import <DVETrackKit/NLESegmentTransition_OC+NLE.h>
#import <TTVideoEditor/IESAVAssetReverse.h>
#import <TTVideoEditor/HTSVideoData+CacheDirPath.h>

#define kNLECurveSpeedNameKey @"curve_speed_name"

@interface DVEVideoEditor() <NLEKeyFrameCallbackProtocol>

@property (nonatomic) NSMutableDictionary <NSString *,AVURLAsset *> *reverseAssetMap;
@property (nonatomic, strong) IESAVAssetReverse *reverseSession;

@property (nonatomic, weak) id<DVECoreDraftServiceProtocol> draftService;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;

@property (nonatomic, weak) id<DVECoreKeyFrameProtocol> keyFrameEditor;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@end

@implementation DVEVideoEditor

@synthesize vcContext = _vcContext;
@synthesize keyFrameDeleagte = _keyFrameDeleagte;

DVEAutoInject(self.vcContext.serviceProvider, draftService, DVECoreDraftServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, keyFrameEditor, DVECoreKeyFrameProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if(self = [super init]) {
        self.vcContext = context;
        [self.nle addKeyFrameListener:self];
    }
    return self;
}

+ (CMTime)kDefaultPhotoResourceDuration
{
    return CMTimeMakeWithSeconds(2400, USEC_PER_SEC);
}

- (void)videoSplitForSlot:(NLETrackSlot_OC *)slot isMain:(BOOL)main {
    if (!slot) {
        [DVECustomerHUD showMessage:@"请选择要处理的轨道"];
        return;
    }
    
    
    CGFloat start = CMTimeGetSeconds(slot.startTime);
    CGFloat end = CMTimeGetSeconds(slot.endTime);
    CGFloat current = CMTimeGetSeconds(self.vcContext.mediaContext.currentTime);
    if (fabs(start- current) < 0.1 || fabs(current - end) < 0.1) {
        [DVECustomerHUD showMessage:NLELocalizedString(@"ck_tips_current_position_split_fail", @"当前位置不可拆分") afterDele:1];
        return;
    }
    
    if (current < start || current > end) {
        [DVECustomerHUD showMessage:NLELocalizedString(@"ck_tips_current_position_split_fail", @"当前位置不可拆分") afterDele:1];
        return;
    }
    
    AVURLAsset *asset = [self.nle assetFromSlot:slot];
    AVURLAsset *copyAsset = [AVURLAsset assetWithURL:[asset URL]];

    if (main) {
        //  1. 先操作NLE
        [self splitVideoSlot:self.vcContext.mediaContext.selectMainVideoSegment.nle_nodeId
                                          splitTime:self.vcContext.mediaContext.currentTime
                                              asset:copyAsset
                                             commit:YES];
    } else {
        [self splitVideoSlot:slot.nle_nodeId
                                          splitTime:self.vcContext.mediaContext.currentTime
                                              asset:copyAsset
                                             commit:YES];
    }
}

- (void)videoFreezeForSlot:(NLETrackSlot_OC *)slot isMain:(BOOL)main
{
    if (!slot) {
        [DVECustomerHUD showMessage:@"请选择要处理的轨道"];
        return;
    }
    
    //时间轴对应的slot的时间，注意主轨和副轨不一样
    NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)slot.segment;
    //定格前先暂停
    [self.vcContext.playerService pause];
    
    CMTime currentTime = CMTimeAdd(CMTimeSubtract(self.vcContext.mediaContext.currentTime, slot.startTime), segment.timeClipStart);
    
    CGFloat start = CMTimeGetSeconds(slot.startTime);
    CGFloat end = CMTimeGetSeconds(slot.endTime);
    CGFloat current = CMTimeGetSeconds(self.vcContext.mediaContext.currentTime);
    
    AVURLAsset *asset = [self.nle assetFromSlot:slot];
    NSString *slotId = self.vcContext.mediaContext.selectMainVideoSegment.nle_nodeId;
    if (!main) {
        slotId = slot.nle_nodeId;
    }
    
    //若时间轴处于slot中间位置，先拆分
    if (fabs(start - current) >= 0.1 && fabs(end - current) >= 0.1) {
        AVURLAsset *copyAsset = [AVURLAsset assetWithURL:[(AVURLAsset *)asset URL]];
        [self splitVideoSlot:slotId
                   splitTime:self.vcContext.mediaContext.currentTime
                       asset:copyAsset
                      commit:NO];
    }
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    // 禁止抽取的帧自动旋转
    generator.appliesPreferredTrackTransform = YES;

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    //抽取slot在当前时间轴所处的那一帧
    __block UIImage *frameImage = nil;
    // 限制抽帧时间点的范围为 [0, asset.duration]
    currentTime = CMTimeMinimum(CMTimeMaximum(currentTime, kCMTimeZero), asset.duration);
    
    [generator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:currentTime]]
                                    completionHandler:^(CMTime requestedTime,
                                                        CGImageRef  _Nullable image,
                                                        CMTime actualTime,
                                                        AVAssetImageGeneratorResult result,
                                                        NSError * _Nullable error) {
        if (result == AVAssetImageGeneratorSucceeded && image) {
            frameImage = [UIImage imageWithCGImage:image];
        }
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSString *filePath = [self.draftService.currentDraftPath stringByAppendingPathComponent:[NSString VEUUIDString]];
        [UIImageJPEGRepresentation(frameImage, 1) writeToFile:filePath atomically:YES];
        
        CMTime duration = CMTimeMakeWithSeconds(3, USEC_PER_SEC);

        NLEResourceAV_OC *videoResource = [[NLEResourceAV_OC alloc] init];
        videoResource.resourceType = NLEResourceTypeImage;
        videoResource.width = frameImage.size.width;
        videoResource.height = frameImage.size.height;
        videoResource.resourceFile = filePath.lastPathComponent;
        videoResource.duration = [DVEVideoEditor kDefaultPhotoResourceDuration];

        NLESegmentVideo_OC *videoSegment = [[NLESegmentVideo_OC alloc] init];
        videoSegment.videoFile = videoResource;
        videoSegment.timeClipStart = CMTimeMake(0 * USEC_PER_SEC, USEC_PER_SEC);
        videoSegment.timeClipEnd = duration;
        videoSegment.canvasStyle = [[NLEStyCanvas_OC alloc] init];

        NLETrackSlot_OC *trackSlot = [self p_imageSlotForVideoFreezeWithSlot:slot];
        videoSegment.alpha = ((NLESegmentVideo_OC *)slot.segment).alpha;
        [trackSlot setSegmentVideo:videoSegment];
        [trackSlot setLayer:slot.layer];
        trackSlot.startTime = self.vcContext.mediaContext.currentTime;
        
        [self freezeVideoSlot:slotId splitTime:self.vcContext.mediaContext.currentTime slot:trackSlot];
    });
}

- (NLETrackSlot_OC *)p_imageSlotForVideoFreezeWithSlot:(NLETrackSlot_OC *)slot {
    NLETrackSlot_OC *trackSlot = [[NLETrackSlot_OC alloc] init];
    trackSlot.rotation = slot.rotation;
    trackSlot.scale = slot.scale;
    trackSlot.transformX = slot.transformX;
    trackSlot.transformY = slot.transformY;
    trackSlot.transformZ = slot.transformZ;
    return trackSlot;
}

- (void)copyVideoOrImageSlot:(NLETrackSlot_OC *)slot
{
    NLETrackSlot_OC *newSlot = [slot deepClone:YES];

    NLETrack_OC *track = [self.nleEditor.nleModel trackContainSlotId:slot.nle_nodeId];
    if([track isMainTrack]){
        [track addSlot:newSlot afterSlot:slot];
        self.vcContext.mediaContext.selectMainVideoSegment = newSlot;
    }else {
        NSInteger maxLayer = -1;
        NLETrack_OC* targetTrack = nil;
        newSlot.startTime = slot.endTime;
        newSlot.endTime = CMTimeAdd(newSlot.startTime, slot.duration);
        for(NLETrack_OC* t in [self.nleEditor.nleModel nle_allTracksOfType:NLETrackVIDEO]){
            if([t isMainTrack]) continue;
            maxLayer = MAX(maxLayer, track.layer);
            BOOL contain = NO;
            for(NLETrackSlot_OC* slot in [t slots]){
                CMTimeRange range = CMTimeRangeGetIntersection(slot.nle_targetTimeRange, newSlot.nle_targetTimeRange);
                if(CMTIMERANGE_IS_VALID(range) && !CMTIMERANGE_IS_EMPTY(range)){
                    contain = YES;
                    break;
                }
            }
            if(!contain){
                targetTrack = t;
                break;
            }
        }
        if(!targetTrack) {
            targetTrack = [[NLETrack_OC alloc] init];
            targetTrack.extraTrackType = NLETrackVIDEO;
            targetTrack.layer = maxLayer + 1;
            [self.nleEditor.nleModel addTrack:targetTrack];
        }
        [targetTrack addSlot:newSlot];
        self.vcContext.mediaContext.selectBlendVideoSegment = newSlot;
    }
    [self.vcContext.mediaContext updateTargetOffsetWithTime:newSlot.startTime];

    [self.actionService commitNLE:YES];
}

- (void)deleteVideoClip:(NLETrackSlot_OC *)slot isMain:(BOOL)main {
    
    if (!slot) return;
    if (main) {
        NLEModel_OC *model = self.nleEditor.nleModel;
        NLETrack_OC *mainTrack = [model nle_getMainVideoTrack];
        if (mainTrack.slots.count < 2) {
            [DVECustomerHUD showMessage:NLELocalizedString(@"ck_tips_main_track_must_have_material", @"主轨至少保留一段视频") afterDele:1];
            return;
        }
        
        [self deleteSlotOnMainTrack:slot];
    } else {
        [self deleteBlendSlot:slot.nle_nodeId];
    }
    
    [self.actionService commitNLE:YES];
}

// 旋转
- (void)changeVideoRotate:(NLETrackSlot_OC *)slot {
    if (slot) {
        float rotation = -slot.rotation;
        rotation += 90;
        slot.rotation = -rotation;
        [self p_updateRotationScale:slot];
        [slot addOrUpdateKeyframe:CMTimeMake(self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC, USEC_PER_SEC)
                       timeRange:[self.keyFrameEditor currentKeyframeTimeRange] forceAdd:NO];
        [self.actionService commitNLE:YES];
    }
}

// 在90,270的情况下 更新scale
- (void)p_updateRotationScale:(NLETrackSlot_OC *)slot
{
    int rotation = fmod(-slot.rotation/90, 2);
    NLESegmentVideo_OC *segVideo =  (NLESegmentVideo_OC *)slot.segment;
    NLEResourceAV_OC *resAV =  (NLEResourceAV_OC *)segVideo.getResNode;
    CGSize videoSize = CGSizeMake(resAV.width, resAV.height);
    CGSize canvasSize = [DVEAutoInline(self.vcContext.serviceProvider, DVECoreCanvasProtocol) canvasSize];
    float scale = (float)[self p_calculateScale:canvasSize videoSize:videoSize];
    if (rotation == 1) {
        if (slot.scale == 1.f) {
            slot.scale = scale;
        }
    } else {
        if (fabs(slot.scale - scale) < 0.001f) {//考虑到关键帧回调可能会存在偏差，这里用偏差值比较
            slot.scale = 1.f;
        }
    }
}

- (CGFloat)p_calculateScale:(CGSize)canvasSize videoSize:(CGSize)videoSize {
    CGFloat scale = 1.0;
    if (canvasSize.width <= 0 || canvasSize.height <= 0 || videoSize.width <= 0 || videoSize.height <= 0) {
        return scale;
    }
    CGFloat videoRatio = videoSize.width / videoSize.height;
    CGFloat canvasRatio = canvasSize.width / canvasSize.height;
    if (videoRatio > 1.0 && canvasRatio > 1.0) {
        if (videoRatio > canvasRatio) {
            scale = canvasSize.height / canvasSize.width;
        } else {
            scale = videoSize.height / videoSize.width;
        }
    } else if (videoRatio < 1.0 && canvasRatio < 1.0) {
        if (videoRatio < canvasRatio) {
            scale = canvasSize.width / canvasSize.height;
        } else {
            scale = videoSize.width / videoSize.height;
        }
    } else {
        if (videoRatio > 1.0) {
            if (1 / videoRatio < canvasRatio) {
                scale = canvasSize.height / canvasSize.width;
            } else {
                scale = videoSize.width / videoSize.height;
            }
        } else {
            if (1 / canvasRatio > videoRatio) {
                scale = canvasSize.width / canvasSize.height;
            } else {
                scale = videoSize.height / videoSize.width;
            }
        }
    }
    return scale;
}

- (void)changeVideoVolume:(CGFloat)volume slot:(NLETrackSlot_OC *)slot  isMain:(BOOL)main {
    if (!slot) {
        return;
    }
    [self changeSlot:slot volume:volume];
}

- (void)changeVideoFlip:(NLETrackSlot_OC *)slot {
    
    if (slot) {
        slot.Mirror_X = slot.Mirror_X ? 0 : 1;
        [self.actionService commitNLE:YES];
    }
}

- (void)changeVideoSpeed:(CGFloat)speed slot:(NLETrackSlot_OC *)slot isMain:(BOOL)main shouldKeepTone:(BOOL)shouldKeepTone{
    if (!slot) return;
    if (![slot.segment isKindOfClass:[NLESegmentVideo_OC class]]) return;
    // 变速曲线、常规变速二选一
    if (speed != 1) {
        [self updateVideoCurveSpeedInfo:nil slot:slot isMain:main shouldCommit:NO];
    }
    if (main) {
        [self updateVideo:slot speed:speed shouldKeepTone:shouldKeepTone];
    } else {
        [self updateBlendVideo:slot speed:speed shouldKeepTone:shouldKeepTone];
    }
    
    [self.actionService commitNLE:YES];
    [self.vcContext.mediaContext seekToCurrentTime];
}

- (void)updateVideoCurveSpeedInfo:(id<DVEResourceCurveSpeedModelProtocol>)curveSpeedInfo slot:(NLETrackSlot_OC *)slot isMain:(BOOL)main shouldCommit:(BOOL)commit {

    if (!slot || ![slot.segment isKindOfClass:[NLESegmentVideo_OC class]]) return;
    NSArray *speedPoint;
    if ([curveSpeedInfo respondsToSelector:@selector(speedPoints)]) {
        speedPoint = curveSpeedInfo.speedPoints;
        // 与现在的曲线一样，return
        if ([self curvePointsEqualToCurrentPoints:speedPoint]) {
            return;
        }
        // 保存曲线名到extra
        [slot setExtra:curveSpeedInfo.name forKey:kNLECurveSpeedNameKey];
    } else {
        [slot setExtra:@"" forKey:kNLECurveSpeedNameKey];
    }
    
    // 变速曲线、常规变速二选一
    if (speedPoint.count > 0) {
        // 直接设置，不用commit
        [(NLESegmentVideo_OC *)slot.segment setSpeed:1];
    }
    
    if (main) {
        [self updateVideo:slot curveSpeedPoint:speedPoint shouldCommit:commit];
    } else {
        [self updateBlendVideo:slot curveSpeedPoint:speedPoint shouldCommit:commit];
    }
    
    [self.actionService commitNLE:commit];
}

- (NSArray *)currentCurveSpeedPoints
{
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentBlendVideoSlot];
    
    if (![slot.segment isKindOfClass:NLESegmentVideo_OC.class]) {
        return nil;
    }
    NLESegmentVideo_OC *videoSegment = (NLESegmentVideo_OC *)slot.segment;

    NSArray *points = [videoSegment getSegCurvePoints];
    NSArray *sortedPoints = [points sortedArrayUsingComparator:^NSComparisonResult(NSValue *  _Nonnull obj1, NSValue * _Nonnull obj2) {
        return obj1.CGPointValue.x > obj2.CGPointValue.x;
    }];
    
    return sortedPoints;
}

- (NSString *)currentCurveSpeedName
{
    NLETrackSlot_OC *slot =  [self.vcContext.mediaContext currentBlendVideoSlot];
    
    if (![slot.segment isKindOfClass:NLESegmentVideo_OC.class]) {
        return nil;
    }
    
    return [slot getExtraForKey:kNLECurveSpeedNameKey];
}

- (int64_t)currentSrcDuration
{
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentBlendVideoSlot];
        
    return [self srcDurationWithSlot:slot];
}

- (int64_t)srcDurationWithSlot:(NLETrackSlot_OC *)slot {
    NLESegmentAudio_OC *videoSegment = (NLESegmentAudio_OC *)slot.segment;
    if (![videoSegment isKindOfClass:NLESegmentAudio_OC.class]) {
        return CMTimeGetSeconds(slot.duration) * USEC_PER_SEC ;
    }
    
    return videoSegment.getDurationWithoutCurveSpeed;
}

- (BOOL)curvePointsEqualToCurrentPoints:(NSArray<NSValue *> *)points {
    NSArray<NSValue *> *currentPts = [self currentCurveSpeedPoints];
    if (currentPts.count != points.count) {
        return NO;
    }
    
    for (int i = 0; i < currentPts.count; i++) {
        CGFloat deltax = fabs(currentPts[i].CGPointValue.x - points[i].CGPointValue.x);
        CGFloat deltay = fabs(currentPts[i].CGPointValue.y - points[i].CGPointValue.y);
        if (deltax + deltay > 0.0001) {
            return NO;
        }

    }
    
    return YES;
}

- (void)handleVideoReverse:(NLETrackSlot_OC *)slot isMain:(BOOL)main {
    if (!slot) {
        return;
    }
    NLESegmentVideo_OC *videoSegment = nil;
    if (![slot.segment isKindOfClass:NLESegmentVideo_OC.class]) {
        return;
    }
    videoSegment = (NLESegmentVideo_OC *)slot.segment;
    
    @weakify(self);
    void(^handleReverse)(AVURLAsset *,AVURLAsset *,BOOL) = ^(AVURLAsset *before, AVURLAsset *after, BOOL isReallyReverse) {
        @strongify(self);
        [self reverseSlot:slot withAsset:after forMainTrack:main isReallyReverse:isReallyReverse];
        if (isReallyReverse) {
            [self changeAudioVolumeForSlot:slot volume:0];
            NSString *normalCacheKey = videoSegment.videoFile.resourceFile;
            [self.reverseAssetMap setObject:before forKey:normalCacheKey];
        } else {
            [self changeAudioVolumeForSlot:slot volume:1];
            NSString *reverseCacheKey = videoSegment.reversedAVFile.resourceFile;
            [self.reverseAssetMap setObject:before forKey:reverseCacheKey];
        }
        [[DVEComponentViewManager sharedManager] refreshCurrentBarGroupTpye];
        [self.actionService commitNLE:YES];
        [self.vcContext.mediaContext seekToCurrentTime];
    };
    AVURLAsset *selectAsset = [self.nle assetFromSlot:slot];
    if (!videoSegment.rewind) { // 正序
        NSString *reverseCacheKey = videoSegment.reversedAVFile.resourceFile;
        AVURLAsset *reverseAsset =  self.reverseAssetMap[reverseCacheKey];
        if (reverseAsset) {// key里有 肯定是正序，而且已经倒序过
            [DVECustomerHUD showMessage:NLELocalizedString(@"ck_reverse_play_success", @"倒放成功")];
            handleReverse(selectAsset, reverseAsset, YES);
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [DVECustomerHUD hidProgress];
                [DVECustomerHUD showProgress];
            });
            [self reverseAsset:selectAsset processBlock:^(CGFloat process) {
                DVELogInfo(@"reverse process;%f",process);
                [DVECustomerHUD setProgressLableWithText:[NSString stringWithFormat:@"%@...%0.2f%%",NLELocalizedString(@"ck_reversing", @"倒放中"),process * 100]];
                
            } complete:^(AVURLAsset * _Nullable reverAsset) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [DVECustomerHUD hidProgress];
                    if (reverAsset) {
                        [DVECustomerHUD showMessage:NLELocalizedString(@"ck_reverse_play_success", @"倒放成功")];
                        handleReverse(selectAsset, reverAsset, YES);
                    } else {
                        [DVECustomerHUD showMessage:NLELocalizedString(@"ck_reverse_video_failed", @"倒放失败")];
                    }
                });
            }];
        }
    } else {
        NSString *normalCacheKey = videoSegment.videoFile.resourceFile;
        AVURLAsset *originalAsset = self.reverseAssetMap[normalCacheKey];
        if (originalAsset) {
            [DVECustomerHUD showMessage:NLELocalizedString(@"ck_reverse_play_cancel",@"取消倒放")];
            handleReverse(selectAsset, originalAsset, NO);
        }
    }
}

- (void)changeAudioVolumeForSlot:(NLETrackSlot_OC *)slot volume:(CGFloat)volume
{
    if (![slot.segment isKindOfClass:NLESegmentAudio_OC.class]) {
        return;
    }
    NLESegmentAudio_OC *segmentVideo = (NLESegmentAudio_OC *)slot.segment;
    segmentVideo.volume = volume;
}

- (void)reverseSlot:(NLETrackSlot_OC *)slot
          withAsset:(AVURLAsset *)asset
       forMainTrack:(BOOL)forMainTrack
    isReallyReverse:(BOOL)isReallyReverse
{
    NLETrack_OC *videoTrack = [self.nleEditor.nleModel trackContainSlotId:slot.nle_nodeId];
    if (![slot.segment isKindOfClass:NLESegmentVideo_OC.class]) {
        return;
    }
    // copy resource
    NSString *relativePath = [self.draftService copyResourceToDraft:asset.URL resourceType:NLEResourceTypeVideo];
    
    NLESegmentVideo_OC *segmentVideo = (NLESegmentVideo_OC *)slot.segment;
    
    CMTimeRange sourceTimeRange = slot.nle_sourceTimeRange;
    NLEResourceAV_OC *videoResource = [[NLEResourceAV_OC alloc] init];
    [videoResource nle_setupForVideo:asset];
    videoResource.resourceFile = relativePath;
    if (isReallyReverse) {
        segmentVideo.reversedAVFile = videoResource;
    } else {
        segmentVideo.videoFile = videoResource;
    }
    
    BOOL needUpdateTimeRange = segmentVideo.rewind != isReallyReverse;
    if (needUpdateTimeRange) {
        // ----s-------e-
        // -s-------e----
        CMTime sourceStart = CMTimeSubtract(segmentVideo.nle_resourceDuration, CMTimeRangeGetEnd(sourceTimeRange));
        CMTime sourceEnd = CMTimeSubtract(segmentVideo.nle_resourceDuration, sourceTimeRange.start);
        segmentVideo.timeClipStart = sourceStart;
        segmentVideo.timeClipEnd = sourceEnd;
    }
    
    if (forMainTrack) {
        [videoTrack nle_rescheduleTrackForTransitionChanged];
    }
    
    [segmentVideo setRewind:isReallyReverse];
    [slot adjustKeyFrame];
    
    self.vcContext.mediaContext.didReversedSlotID = slot.nle_nodeId;
}

- (void)reverseAsset:(AVURLAsset *)asset
        processBlock:(void(^)(CGFloat process))process
            complete:(void(^)(AVURLAsset * _Nullable reverAsset))complete {
    self.reverseSession = [[IESAVAssetReverse alloc] initWithAVAsset:asset];
    [self.reverseSession reverseAsset:^(NSURL * _Nullable ouputUrl, NSError * _Nullable error) {
        if (!error) {
            AVURLAsset *asset1 = [AVURLAsset URLAssetWithURL:ouputUrl options:nil];
            if (complete) {
                complete(asset1);
            }
        } else {
            DVELogError(@"reverse fail %@", error);
            if (complete) {
                complete(nil);
            }
        }
    } progressBlock:process];
}

- (NSMutableDictionary<NSString *,AVURLAsset *> *)reverseAssetMap
{
    if (!_reverseAssetMap) {
        _reverseAssetMap = [NSMutableDictionary dictionary];
    }
    return _reverseAssetMap;
}

#pragma mark - Speed

- (void)updateBlendVideo:(NLETrackSlot_OC *)slot
                   speed:(CGFloat)speed
          shouldKeepTone:(BOOL)shouldKeepTone
{
    if (![slot.segment isKindOfClass:NLESegmentVideo_OC.class]) {
        return;
    }
    NLEModel_OC *model = self.nleEditor.nleModel;
    NLESegmentVideo_OC *videoSegment = (NLESegmentVideo_OC *)slot.segment;
    NLETrack_OC *track = [model trackContainSlotId:slot.nle_nodeId];
    NLETrack_OC *videoTrack = [model nle_getMainVideoTrack];
    
    BOOL isInMainTrack = NO;
    for (NLETrackSlot_OC *childSlot in videoTrack.slots) {
        if ([childSlot.nle_nodeId isEqualToString:slot.nle_nodeId]) {
            isInMainTrack = YES;
            break;
        }
    }
    if (isInMainTrack) {
        return;
    }
    
    // 计算更新贴纸、特效的offset和duration的改动
    CGFloat oldSpeed = [videoSegment absSpeed];
    CGFloat actionSpeedValue = speed;
    
    // 更新speed payload
    

    [videoSegment setSpeed:speed];
    [slot adjustKeyFrame];
    
    [videoSegment setKeepTone:shouldKeepTone];
    slot.endTime = CMTimeAdd(slot.startTime, videoSegment.duration);
    
    // 调整视频动画
    NLEVideoAnimation_OC *payload = [slot getVideoAnims].firstObject;
    if (payload) {
        // 计算倍速
        CGFloat timeScale = oldSpeed / actionSpeedValue;
        Float64 value = CMTimeGetSeconds(payload.segmentVideoAnimation.animationDuration) * timeScale;
        Float64 max = 60.f;
        Float64 timeSecond = (value > max) ? max : value;
        payload.segmentVideoAnimation.animationDuration = CMTimeMake(timeSecond * USEC_PER_SEC, USEC_PER_SEC);
    }
    
    // 轨道调整
    for (NLETrackSlot_OC *trackSlot in track.slots) {
        if (![trackSlot.nle_nodeId isEqualToString:slot.nle_nodeId]
            && CMTimeRangeContainsTime(slot.nle_targetTimeRange, trackSlot.startTime)) {
            
            NLETrack_OC *newTrack = [[NLETrack_OC alloc] init];
            newTrack.extraTrackType = NLETrackVIDEO;
            newTrack.layer = [model nle_getMaxTrackLayer:NLETrackVIDEO] + 1;
            [track removeSlot:slot];
            [newTrack addSlot:slot];
            [model addTrack:newTrack];
            break;
        }
    }
    
    [self.actionService commitNLE:YES];
}

- (void)updateBlendVideo:(NLETrackSlot_OC *)slot
         curveSpeedPoint:(NSArray<NSValue *> *)points
            shouldCommit:(BOOL)commit
{
    if (![slot.segment isKindOfClass:NLESegmentVideo_OC.class]) {
        return;
    }
    NLEModel_OC *model = self.nleEditor.nleModel;
    NLESegmentVideo_OC *videoSegment = (NLESegmentVideo_OC *)slot.segment;
    NLETrack_OC *track = [model trackContainSlotId:slot.nle_nodeId];
    NLETrack_OC *videoTrack = [model nle_getMainVideoTrack];
    
    BOOL isInMainTrack = NO;
    for (NLETrackSlot_OC *childSlot in videoTrack.slots) {
        if ([childSlot.nle_nodeId isEqualToString:slot.nle_nodeId]) {
            isInMainTrack = YES;
            break;
        }
    }
    if (isInMainTrack) {
        return;
    }
    

    [videoSegment setSegCurvePoints:points];

    // 更新slot结束时间
    slot.endTime = CMTimeAdd(slot.startTime, videoSegment.duration);

    [slot adjustKeyFrame];
    
    // 轨道调整
    for (NLETrackSlot_OC *trackSlot in track.slots) {
        if (![trackSlot.nle_nodeId isEqualToString:slot.nle_nodeId]
            && CMTimeRangeContainsTime(slot.nle_targetTimeRange, trackSlot.startTime)) {
            
            NLETrack_OC *newTrack = [[NLETrack_OC alloc] init];
            newTrack.extraTrackType = NLETrackVIDEO;
            newTrack.layer = [model nle_getMaxTrackLayer:NLETrackVIDEO] + 1;
            [track removeSlot:slot];
            [newTrack addSlot:slot];
            [model addTrack:newTrack];
            break;
        }
    }
    
    [self.actionService commitNLE:commit];
}

- (void)updateVideo:(NLETrackSlot_OC *)slot speed:(CGFloat)speed shouldKeepTone:(BOOL)shouldKeepTone
{
    if (![slot.segment isKindOfClass:NLESegmentVideo_OC.class]) {
        return;
    }
    NLEModel_OC *model = self.nleEditor.nleModel;
    NLESegmentVideo_OC *videoSegment = (NLESegmentVideo_OC *)slot.segment;
    NLETrack_OC *videoTrack = [model nle_getMainVideoTrack];
    
    BOOL isInMainTrack = NO;
    for (NLETrackSlot_OC *childSlot in videoTrack.slots) {
        if ([childSlot.nle_nodeId isEqualToString:slot.nle_nodeId]) {
            isInMainTrack = YES;
            break;
        }
    }
    if (!isInMainTrack) {
        return;
    }
    
    // 计算更新贴纸、特效的offset和duration的改动
    CGFloat oldSpeed = [videoSegment absSpeed];
    CGFloat actionSpeedValue = speed;
    
    [videoSegment setSpeed:speed];
    [slot adjustKeyFrame];

    [videoSegment setKeepTone:shouldKeepTone];
    slot.endTime = CMTimeAdd(slot.startTime, videoSegment.duration);
    
    // 调整视频动画
    NLEVideoAnimation_OC *payload = [slot getVideoAnims].firstObject;
    if (payload) {
        // 计算倍速
        CGFloat timeScale = oldSpeed / actionSpeedValue;
        Float64 value = CMTimeGetSeconds(payload.segmentVideoAnimation.animationDuration) * timeScale;
        Float64 max = 60.f;
        Float64 timeSecond = (value > max) ? max : value;
        payload.segmentVideoAnimation.animationDuration = CMTimeMake(timeSecond * USEC_PER_SEC, USEC_PER_SEC);
    }
    
    [videoTrack nle_rescheduleTrackForTransitionChanged];
    
    [self.actionService commitNLE:YES];
}

- (void)updateVideo:(NLETrackSlot_OC *)slot curveSpeedPoint:(NSArray *)points shouldCommit:(BOOL)commit {
    if (![slot.segment isKindOfClass:NLESegmentVideo_OC.class]) {
        return;
    }
    NLEModel_OC *model = self.nleEditor.nleModel;
    NLESegmentVideo_OC *videoSegment = (NLESegmentVideo_OC *)slot.segment;
    NLETrack_OC *videoTrack = [model nle_getMainVideoTrack];

    BOOL isInMainTrack = NO;
    for (NLETrackSlot_OC *childSlot in videoTrack.slots) {
        if ([childSlot.nle_nodeId isEqualToString:slot.nle_nodeId]) {
            isInMainTrack = YES;
            break;
        }
    }
    if (!isInMainTrack) {
        return;
    }

    [videoSegment setSegCurvePoints:points];

    // 更新slot结束时间
    slot.endTime = CMTimeAdd(slot.startTime, videoSegment.duration);
    [slot adjustKeyFrame];
    
    [videoTrack nle_rescheduleTrackForTransitionChanged];
    [self.actionService commitNLE:commit];
}


#pragma mark - Split

- (void)splitVideoSlot:(NSString *)slotId
             splitTime:(CMTime)splitTime
                 asset:(AVURLAsset *)asset {
    [self splitVideoSlot:slotId
               splitTime:splitTime
                   asset:asset
                  commit:YES];
}

- (void)splitVideoSlot:(NSString *)slotId
             splitTime:(CMTime)splitTime
                 asset:(AVURLAsset *)asset
                commit:(BOOL)commit
{
    NLEModel_OC *model = self.nleEditor.nleModel;
    NLETrack_OC *track = [model trackContainSlotId:slotId];
    NLETrackSlot_OC *slot = [track slotOfId:slotId];
    
    if (!slot) {
        return;
    }
    NSInteger index = [track nle_indexOfSlotId:slotId];
    [slot adjustKeyFrame:[self.keyFrameEditor currentKeyframeTimeRange]];
    // 新的start = action.sourceStartTime
    NLETrackSlot_OC *newSlot = [track splitFromTime:CMTimeGetSeconds(splitTime) * USEC_PER_SEC];
    // 提取转场
    if (slot.endTransition) {
        // 当前视频如果有转场，则取消
        slot.endTransition = nil;
        
        // 如果后一个的长度小于转场限制时间也去掉
        if (CMTimeCompare(newSlot.duration, NLESegmentTransition_OC.transitionRequireMinDuration) < 0) {
            newSlot.endTransition = nil;
        }
        
        // 如果时长小于转场最小时长限制，将转场设置为无
        if (CMTimeCompare(slot.duration, NLESegmentTransition_OC.transitionRequireMinDuration) < 0) {
            NLETrackSlot_OC *before = track.slots[index - 1];
            before.endTransition = nil;
        }
    }
    
    // 重排时间轴
    [track nle_rescheduleTrackForTransitionChanged];
    
    // 视频动画 分割的时候 入场&组合跟随左边 出场跟随右边
    [model spliteVideoAnimation:slot copiedSlot:newSlot];
    
    //拆分后所有选中的视频slot置空
    self.vcContext.mediaContext.selectMainVideoSegment = nil;
    self.vcContext.mediaContext.selectBlendVideoSegment = nil;
    
    [self.actionService commitNLE:commit];
    [self.vcContext.mediaContext seekToCurrentTime];
}


#pragma mark - Add or Delete

- (void)deleteBlendSlot:(NSString *)slotId
{
    NLEModel_OC *model = self.nleEditor.nleModel;
    NSMutableArray *subVideoTracks = [NSMutableArray array];
    for (NLETrack_OC *track in [model getTracks]) {
        if (track.extraTrackType == NLETrackVIDEO && !track.isMainTrack) {
            [subVideoTracks addObject:track];
        }
    }
    NLETrackSlot_OC *result = nil;
    NLETrack_OC *targetTrack = nil;
    
    for (NLETrack_OC *track in subVideoTracks) {
        for (NLETrackSlot_OC *slot in track.slots) {
            if ([slot.nle_nodeId isEqualToString:slotId]) {
                result = slot;
                break;
            }
        }
        if (result != nil) {
            targetTrack = track;
            break;
        }
    }
    
    if (!result || !targetTrack) {
        return;
    }
    
    [targetTrack removeSlot:result];
    [model nle_removeLastEmptyTracksForType:NLETrackVIDEO];
    
    [self.actionService commitNLE:YES];
    [self.vcContext.playerService seekToTime:self.vcContext.mediaContext.currentTime isSmooth:NO];
}

- (void)deleteSlotOnMainTrack:(NLETrackSlot_OC *)slot
{
    NLEModel_OC *model = self.nleEditor.nleModel;
    NLETrack_OC *mainTrack = [model nle_getMainVideoTrack];
    
    if (!mainTrack) {
        NSAssert(NO, @"current has no main track");
        return;
    }
    
    for (NLETrackSlot_OC *childSlot in mainTrack.slots) {
        if ([childSlot.nle_nodeId isEqualToString:slot.nle_nodeId]) {
            [mainTrack removeSlot:childSlot];
            self.vcContext.mediaContext.selectMainVideoSegment = nil;
            break;
        }
    }
    // 重排时间轴
    [mainTrack nle_rescheduleTrackForTransitionChanged];
    [self.actionService commitNLE:YES];
    [self.vcContext.playerService seekToTime:self.vcContext.mediaContext.currentTime isSmooth:NO];
}


#pragma mark - 定格

- (void)freezeVideoSlot:(NSString *)slotId
              splitTime:(CMTime)splitTime
                   slot:(NLETrackSlot_OC *)slot {
    
    NLEModel_OC *model = self.nleEditor.nleModel;
    NLETrack_OC *track = [model trackContainSlotId:slotId];
    
    [track nle_insertSlot:slot atTime:splitTime];
    [track nle_rescheduleTrackForTransitionChanged];

    NSMutableArray *slotIds = [[NSMutableArray alloc] init];
    for (NLETrackSlot_OC *slot in track.slots) {
        [slotIds addObject:slot.nle_nodeId];
    }
    
    self.vcContext.mediaContext.changedOrderSlots = [slotIds copy];
    
    [self.actionService commitNLE:YES];
    
    if ([track isMainTrack]) {
        self.vcContext.mediaContext.selectMainVideoSegment = slot;
    } else {
        self.vcContext.mediaContext.selectBlendVideoSegment = slot;
    }
}

#pragma mark - Volume

- (void)changeSlot:(NLETrackSlot_OC *)slot volume:(CGFloat)volume
{
    if ([slot.segment isKindOfClass:NLESegmentAudio_OC.class]) {
        NLESegmentAudio_OC *segmentAudio = (NLESegmentAudio_OC *)slot.segment;
        segmentAudio.volume = volume;
    }
    
    [slot addOrUpdateKeyframe:CMTimeMake(self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC, USEC_PER_SEC)
                   timeRange:[self.keyFrameEditor currentKeyframeTimeRange] forceAdd:NO];
    [self.actionService commitNLE:NO];
}

#pragma mark - Mixed Effect
- (void)applyMixedEffectWithSlot:(NLETrackSlot_OC *)slot
                           alpha:(CGFloat)alpha {
    NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)slot.segment;
    segment.alpha = alpha;
    [slot addOrUpdateKeyframe:CMTimeMake(self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC, USEC_PER_SEC)
                   timeRange:[self.keyFrameEditor currentKeyframeTimeRange] forceAdd:NO];
    [self.actionService commitNLEWithoutNotify:NO];
}

- (void)applyMixedEffectWithSlot:(NLETrackSlot_OC *)slot
                       blendFile:(NLEResourceNode_OC * _Nullable)blendFile
                           alpha:(CGFloat)alpha {
    NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)slot.segment;
    segment.blendFile = blendFile;
    segment.alpha = alpha;
    [slot addOrUpdateKeyframe:CMTimeMake(self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC, USEC_PER_SEC)
                   timeRange:[self.keyFrameEditor currentKeyframeTimeRange] forceAdd:NO];
    [self.actionService commitNLEWithoutNotify:NO];
}

- (void)nleDidChangedWithPTS:(CMTime)time
                keyFrameInfo:(NLEAllKeyFrameInfo *)info {
    
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentMainVideoSlotWithAudio];
    
    if (!slot) {
        return;
    }
    
    slot = [self.nle refreshAllKeyFrameInfo:info pts:self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC inSlot:slot];
    if ([self.keyFrameDeleagte respondsToSelector:@selector(videoKeyFrameDidChangedWithSlot:)]) {
        [self.keyFrameDeleagte videoKeyFrameDidChangedWithSlot:slot];
    }
}


@end
