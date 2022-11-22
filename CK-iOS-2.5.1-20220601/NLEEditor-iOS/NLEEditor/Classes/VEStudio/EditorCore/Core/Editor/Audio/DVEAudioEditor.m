//
//   DVEAudioEditor.m
//   NLEEditor
//
//   Created  by bytedance on 2021/4/26.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEAudioEditor.h"
#import "NSDictionary+DVE.h"
#import "DVECustomerHUD.h"
#import "NSString+DVE.h"
#import "DVEVCContext.h"
#import <DVETrackKit/NLETrack_OC+NLE.h>
#import <DVETrackKit/NLEModel_OC+NLE.h>

@interface DVEAudioEditor ()

@property (nonatomic, weak) id<DVECoreDraftServiceProtocol> draftService;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;
@property (nonatomic, weak) id<DVECoreKeyFrameProtocol> keyFrameEditor;
@end

@implementation DVEAudioEditor

@synthesize vcContext = _vcContext;

DVEAutoInject(self.vcContext.serviceProvider, draftService, DVECoreDraftServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, keyFrameEditor, DVECoreKeyFrameProtocol)

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if(self = [super init]) {
        self.vcContext = context;
    }
    return self;
}

- (NLETrackSlot_OC*)addAudioResource:(NSURL *)audioUrl audioName:(NSString *)audioName
{
    // copy resource
    NSString *relativePath = [self.draftService copyResourceToDraft:audioUrl resourceType:NLEResourceTypeAudio];
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:audioUrl];
    
    NSTimeInterval startTime = CMTimeGetSeconds(self.vcContext.mediaContext.currentTime);
    
    NLETrack_OC *track = [[NLETrack_OC alloc] init];
    track.extraTrackType = NLETrackAUDIO;
    track.layer = (int)([self.nleEditor.nleModel nle_getMaxTrackLayer:NLETrackAUDIO] + 1);

    NLEResourceAV_OC *audioResource = [[NLEResourceAV_OC alloc] init];
    [audioResource nle_setupForAudio:asset];
    audioResource.resourceName = audioName;
    audioResource.resourceFile = relativePath;
    audioResource.resourceType = NLEResourceTypeAudio;
    
    NLESegmentAudio_OC *audioSegment = [[NLESegmentAudio_OC alloc] init];
    audioSegment.audioFile = audioResource;
    audioSegment.timeClipStart = CMTimeMake(0 * USEC_PER_SEC, USEC_PER_SEC);
    audioSegment.timeClipEnd = [asset duration];;
    
    NLETrackSlot_OC *trackSlot = [[NLETrackSlot_OC alloc] init];
    [trackSlot setSegmentAudio:audioSegment];
    trackSlot.startTime = CMTimeMake(startTime * USEC_PER_SEC, USEC_PER_SEC);
    trackSlot.duration = [asset duration];
    
    [track addSlot:trackSlot];
    [self.nleEditor.nleModel addTrack:track];
    
    [self.actionService commitNLE:YES];
    
    [self.vcContext.playerService seekToTime:self.vcContext.mediaContext.currentTime isSmooth:NO];
    
    return trackSlot;
}

- (NLETrackSlot_OC*)addAudioEffectResource:(NSURL *)audioUrl audioName:(NSString *)audioName
{
    // copy resource
    // copy resource
    NSString *relativePath = [self.draftService copyResourceToDraft:audioUrl resourceType:NLEResourceTypeAudio];
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:audioUrl];
    
    NSTimeInterval startTime = CMTimeGetSeconds(self.vcContext.mediaContext.currentTime);
    
    NLETrack_OC *track = [[NLETrack_OC alloc] init];
    track.extraTrackType = NLETrackAUDIO;
    track.layer = (int)([self.nleEditor.nleModel nle_getMaxTrackLayer:NLETrackAUDIO] + 1);

    NLEResourceAV_OC *audioResource = [[NLEResourceAV_OC alloc] init];
    [audioResource nle_setupForAudio:asset];
    audioResource.resourceName = audioName;
    audioResource.resourceType = NLEResourceTypeSound;
    audioResource.resourceFile = relativePath;
    
    NLESegmentAudio_OC *audioSegment = [[NLESegmentAudio_OC alloc] init];
    audioSegment.audioFile = audioResource;
    audioSegment.timeClipStart = CMTimeMake(0 * USEC_PER_SEC, USEC_PER_SEC);
    audioSegment.timeClipEnd = [asset duration];;
    
    NLETrackSlot_OC *trackSlot = [[NLETrackSlot_OC alloc] init];
    [trackSlot setSegmentAudio:audioSegment];
    trackSlot.startTime = CMTimeMake(startTime * USEC_PER_SEC, USEC_PER_SEC);
    trackSlot.duration = [asset duration];
    
    [track addSlot:trackSlot];
    [self.nleEditor.nleModel addTrack:track];
    
    [self.actionService commitNLE:YES];
    
    [self.vcContext.playerService seekToTime:self.vcContext.mediaContext.currentTime isSmooth:NO];
    
    return trackSlot;
}

- (NLETrackSlot_OC *)copyAudioSlot:(NLETrackSlot_OC*)audioSlot{

    NLEModel_OC *model = self.nleEditor.nleModel;

    NLETrack_OC* audioTrack = [model trackContainSlotId:audioSlot.nle_nodeId];
    CMTimeRange copyTimeRange = CMTimeRangeMake(audioSlot.endTime, audioSlot.duration);//时间段默认在被复制音频Slot后面
    BOOL containAudio = NO;
    for(NLETrackSlot_OC* slot in audioTrack.slots){
        CMTimeRange range = CMTimeRangeGetIntersection(copyTimeRange, slot.nle_targetTimeRange);
        if(CMTIMERANGE_IS_VALID(range) && !CMTIMERANGE_IS_EMPTY(range)){
            containAudio = YES;
            break;
        }
    }
    
    NSInteger sourceLayer = audioTrack.layer;
    NLETrack_OC* targetTrack = nil;
    if(containAudio){//如果被复制Slot所在Track的后面已存在Slot，则查找该Track以下的其他Track
        for(NLETrack_OC* track in [model nle_allTracksOfType:NLETrackAUDIO]){
            if(track.layer <= sourceLayer) continue;///过滤层级比被复制的audio小的队列
            containAudio = NO;
            for(NLETrackSlot_OC* slot in track.slots){
                CMTimeRange range = CMTimeRangeGetIntersection(copyTimeRange, slot.nle_targetTimeRange);
                if(CMTIMERANGE_IS_VALID(range) && !CMTIMERANGE_IS_EMPTY(range)){
                    containAudio = YES;break;
                }
            }
            if(!containAudio){
                targetTrack = track;
                break;
            }
        }
    }else{
        targetTrack = audioTrack;
    }
    
    if(!targetTrack){
        targetTrack = [[NLETrack_OC alloc] init];
        targetTrack.extraTrackType = NLETrackAUDIO;
        targetTrack.layer = [self.nleEditor.nleModel nle_getMaxTrackLayer:NLETrackAUDIO] + 1;
        [model addTrack:targetTrack];
    }
    
    NLETrackSlot_OC *trackSlot = [audioSlot deepClone];
    ///deepClone的时候name是不变的，但是ID是改变的，导致轨道使用name查找唯一Slot会有问题，这里需要把ID重新赋值给name
    trackSlot.name = @(trackSlot.getID).stringValue;
    trackSlot.startTime = copyTimeRange.start;
    trackSlot.duration = copyTimeRange.duration;
    [targetTrack addSlot:trackSlot];
    [self.actionService commitNLE:YES];
    return trackSlot;
    
}

- (NSString*)recordDefaultName {
    return NLELocalizedString(@"ck_record_audio",@"录音");
}

-(NSInteger)numberOfRecoderSlot{
    NSInteger number = 0;
    
    for(NLETrack_OC* track in [self.nleEditor.nleModel getTracks] ) {
        if([track getTrackType] == NLETrackAUDIO){
            for(NLETrackSlot_OC* slot in track.slots){
                if([slot segment].getResNode.resourceType == NLEResourceTypeRecord){
                    number++;
                }
            }
        }
    }
    return number;
}

-(NSInteger)maxRecoderNumberSlot{
    NSInteger number = 0;
    
    for(NLETrack_OC* track in [self.nleEditor.nleModel getTracks] ) {
        if([track getTrackType] == NLETrackAUDIO){
            for(NLETrackSlot_OC* slot in track.slots){
                NLEResourceNode_OC* node = [slot segment].getResNode;
                if(node.resourceType == NLEResourceTypeRecord){
                    NSString* str = [node.resourceName stringByReplacingOccurrencesOfString:[self recordDefaultName] withString:@""];
                    number = MAX([str integerValue], number);
                }
            }
        }
    }
    return number;
}


- (void)addText2AudioResource:(NSURL *)audioUrl
                    audioName:(NSString *)audioName
                    startTime:(CMTime)startTime
                   replaceOld:(BOOL)repalceOld
{
    NLEModel_OC *model = self.nleEditor.nleModel;
    
    // copy resource
    NSString *relativePath = [self.draftService copyResourceToDraft:audioUrl resourceType:NLEResourceTypeAudio];

    AVURLAsset *asset = [AVURLAsset assetWithURL:audioUrl];

    NLEResourceAV_OC *audioResource = [[NLEResourceAV_OC alloc] init];
    [audioResource nle_setupForAudio:asset];
    audioResource.resourceName = audioName;
    audioResource.resourceFile = relativePath;

    NLESegmentAudio_OC *audioSegment = [[NLESegmentAudio_OC alloc] init];
    audioSegment.audioFile = audioResource;
    audioSegment.timeClipStart = CMTimeMake(0 * USEC_PER_SEC, USEC_PER_SEC);
    audioSegment.timeClipEnd = [asset duration];
    
    NLETrackSlot_OC *audioSlot = [[NLETrackSlot_OC alloc] init];
    [audioSlot setSegmentAudio:audioSegment];
    audioSlot.startTime = startTime;
    audioSlot.duration = [asset duration];
    [audioSlot setExtra:@"1" forKey:@"isText2Audio"];
    
    // 如果覆盖，则先删除所有之前添加的字幕语音
    if (repalceOld) {
        NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel nle_allTracksOfType:NLETrackAUDIO];
        for (NLETrack_OC *track in tracks) {
            NSArray<NLETrackSlot_OC *> *slots = track.slots;
            for (NLETrackSlot_OC *slot in slots) {
                NSString *resourceStr = [slot getExtraForKey:@"isText2Audio"];
                if ([resourceStr isEqualToString:@"1"]
                    && [[slot.segment getResNode].resourceName isEqualToString:audioName]) {
                    [track removeSlot:slot];
                }
            }
        }
        [self.nleEditor.nleModel nle_removeLastEmptyTracksForType:NLETrackSTICKER];
    }
    
    
    // 寻找一个有空位的track
    NLETrack_OC *audioTrack = nil;
    NSArray<NLETrack_OC *> *tracks = [model nle_allTracksOfType:NLETrackAUDIO];
    for (NLETrack_OC *track in tracks) {
        if (!audioTrack) {
            audioTrack = track;
            for (NLETrackSlot_OC *slot in track.slots) {
                if (!CMTIMERANGE_IS_EMPTY(CMTimeRangeGetIntersection(audioSlot.nle_targetTimeRange, slot.nle_targetTimeRange))) {
                    audioTrack = nil;
                    break;
                }
            }
        } else {
            break;
        }
    }
    
    if (!audioTrack) {
        audioTrack = [[NLETrack_OC alloc] init];
        audioTrack.extraTrackType = NLETrackAUDIO;
        audioTrack.layer = [self.nleEditor.nleModel nle_getMaxTrackLayer:NLETrackAUDIO] + 1;
        [model addTrack:audioTrack];
    }
    
    [audioTrack addSlot:audioSlot];

    [self.actionService commitNLE:YES];

    [self.vcContext.playerService seekToTime:self.vcContext.mediaContext.currentTime isSmooth:NO];
}

- (void)removeAudioSegment:(NSString *)segmentId
{
    if (self.vcContext.mediaContext.selectAudioSegment) {
        [self.nleEditor.nleModel nle_removeSlots:@[self.vcContext.mediaContext.selectAudioSegment.nle_nodeId] inTrackType:NLETrackAUDIO];
        [self.actionService commitNLE:YES];
    }
    
    [self.vcContext.playerService seekToTime:self.vcContext.mediaContext.currentTime isSmooth:NO];;
    
}

- (void)changeAudioSpeed:(CGFloat)speed slot:(NLETrackSlot_OC *)slot shouldKeepTone:(BOOL)shouldKeepTone
{
    if (!slot) return;
    if (![slot.segment isKindOfClass:[NLESegmentAudio_OC class]]) return;
    NLESegmentAudio_OC *audioSegment = (NLESegmentAudio_OC *)slot.segment;
    NLETrack_OC *track = [self.nleEditor.nleModel trackContainSlotId:slot.nle_nodeId];
    // 更新speed
    [audioSegment setAbsSpeed:speed > 0? speed : audioSegment.absSpeed];
    [audioSegment setKeepTone:shouldKeepTone];
    slot.endTime = CMTimeAdd([audioSegment getDuration], slot.startTime);
    // 如果与同轨道的其他slot重叠，则轨道调整
    for (NLETrackSlot_OC *trackSlot in track.slots) {
        if (![trackSlot.nle_nodeId isEqualToString:slot.nle_nodeId]
            && CMTimeRangeContainsTime(slot.nle_targetTimeRange, trackSlot.startTime)) {
            NLETrack_OC *newTrack = [[NLETrack_OC alloc] init];
            newTrack.extraTrackType = NLETrackAUDIO;
            newTrack.layer = [self.nleEditor.nleModel nle_getMaxTrackLayer:NLETrackAUDIO] + 1;
            [track removeSlot:slot];
            [newTrack addSlot:slot];
            [self.nleEditor.nleModel addTrack:newTrack];
            break;
        }
    }
    
    [slot adjustKeyFrame];
    [self.actionService commitNLE:YES];
    //时间轴线移动到音频slot的开始位置
    [self.vcContext.mediaContext updateTargetOffsetWithTime:slot.startTime];
}

- (void)audioSplitForSlot:(NLETrackSlot_OC *)slot
{
    [self audioSplitForSlot:slot newSlotName:nil];
}

- (void)audioSplitForSlot:(NLETrackSlot_OC *)slot newSlotName:(NSString*)newSlotName
{
    if (!slot) { return; }
        
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
    
    AVURLAsset *asset =  [self.nle assetFromSlot:slot];
    AVURLAsset *copyAsset = [AVURLAsset assetWithURL:[asset URL]];

    if(newSlotName){
        [self splitAudioSlot:self.vcContext.mediaContext.selectAudioSegment.nle_nodeId
                                        newSlotName:newSlotName
                                          splitTime:self.vcContext.mediaContext.currentTime
                                              asset:copyAsset
                                             commit:YES];
    }else{
        [self splitAudioSlot:self.vcContext.mediaContext.selectAudioSegment.nle_nodeId
                                          splitTime:self.vcContext.mediaContext.currentTime
                                              asset:copyAsset
                                             commit:YES];
    }
}

- (NSString*)audioChangeForSlot:(NLETrackSlot_OC *)slot sourcePath:(NSString*)sourcePath sourceName:(NSString*)sourceName
{
    if (!slot) { return nil; }
    
    NSString *relativePath = [self.draftService copyResourceToDraft:[NSURL fileURLWithPath:sourcePath] resourceType:NLEResourceTypeFilter];
    
    NLEResourceNode_OC* node = [NLEResourceNode_OC new];
    node.resourceFile = relativePath;
    node.resourceName = sourceName;
    node.resourceType = NLEResourceTypeVoiceChangerFilter;
     
    NLESegmentFilter_OC* seg = [NLESegmentFilter_OC new];
    seg.effectSDKFilter = node;
    seg.filterName = sourceName;
    
    NLEFilter_OC* filter = [NLEFilter_OC new];
    filter.segmentFilter = seg;
    
    slot.audioFilter = filter;
    
    [self.actionService commitNLE:YES];
    
    return node.nle_nodeId;

}

- (void)removeAudioChangeForSlot:(NLETrackSlot_OC *)slot
{
    if (!slot) { return; }
    slot.audioFilter = nil;
    [self.actionService commitNLE:YES];

}

- (void)splitAudioSlot:(NSString *)slotId
             splitTime:(CMTime)splitTime
                 asset:(AVURLAsset *)asset
                commit:(BOOL)commit
{
    [self splitAudioSlot:slotId newSlotName:nil splitTime:splitTime asset:asset commit:commit];
}

- (void)splitAudioSlot:(NSString *)slotId
           newSlotName:(NSString * _Nullable)newSlotName
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
    NSTimeInterval duration = CMTimeGetSeconds(slot.duration);
    // 新的start = action.sourceStartTime
    [slot adjustKeyFrame:[self.keyFrameEditor currentKeyframeTimeRange]];
    NLETrackSlot_OC *newSlot = [track splitFromTime:CMTimeGetSeconds(splitTime) * USEC_PER_SEC];
    
    
    NSTimeInterval fadeIn = CMTimeGetSeconds(((NLESegmentAudio_OC *)slot.segment).fadeInLength);
    NSTimeInterval fadeOut = CMTimeGetSeconds(((NLESegmentAudio_OC *)slot.segment).fadeOutLength);
    NSTimeInterval lastDuration = duration - CMTimeGetSeconds(newSlot.duration);
    NSTimeInterval newDuration = CMTimeGetSeconds(newSlot.duration);
    
    if (fadeIn > lastDuration) {
        fadeIn = lastDuration;
    }
    
    if (fadeOut > newDuration) {
        fadeOut = newDuration;
    }
    
    NLESegmentAudio_OC *segmentAudio =  (NLESegmentAudio_OC *)slot.segment;
    NLESegmentAudio_OC *newSegmentAudio =  (NLESegmentAudio_OC *)newSlot.segment;
    
    segmentAudio.fadeInLength = CMTimeMake(fadeIn * USEC_PER_SEC, USEC_PER_SEC);
    segmentAudio.fadeOutLength = CMTimeMake(0 * USEC_PER_SEC, USEC_PER_SEC);
    
    newSegmentAudio.fadeInLength = CMTimeMake(0 * USEC_PER_SEC, USEC_PER_SEC);
    newSegmentAudio.fadeOutLength = CMTimeMake(fadeOut * USEC_PER_SEC, USEC_PER_SEC);
    
    if (newSlotName) {
        newSegmentAudio.getResNode.resourceName = newSlotName;
    }
    
    // 重排时间轴
    [track nle_rescheduleTrackForTransitionChanged];
    
    [self.actionService commitNLE:commit];
}

@end
