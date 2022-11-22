//
//  DVEFlexibleEditor.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/6.
//

#import "DVESlotEditor.h"
#import "DVEVCContext.h"

#import <DVETrackKit/NLETrack_OC+NLE.h>
#import <DVETrackKit/NLEModel_OC+NLE.h>
#import <DVETrackKit/NLEVideoFrameModel_OC+NLE.h>


@interface DVESlotEditor()

@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVECoreKeyFrameProtocol> keyFrameEditor;
@end

@implementation DVESlotEditor

@synthesize vcContext;

DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if (self = [super init]) {
        self.vcContext = context;
    }
    
    return self;
}

- (NLETrackSlot_OC *)addSlot:(NLETrackType)trackType
                resourceType:(NLEResourceType)resourceType
                     segment:(NLESegment_OC *)segment
                   startTime:(CMTime)startTime
                    duration:(CMTime)duration
{
    NLEModel_OC *model = self.nleEditor.nleModel;
    
    NLETrack_OC *track = [[NLETrack_OC alloc] init];
    track.extraTrackType = trackType;
    track.nle_extraResourceType = resourceType;
    track.layer = (int)([model nle_getMaxTrackLayer:trackType] + 1);
    [model addTrack:track];
        
    NLETrackSlot_OC *trackSlot = [[NLETrackSlot_OC alloc] init];
    trackSlot.startTime = startTime;
    trackSlot.endTime = CMTimeAdd(startTime, duration);
    trackSlot.scale = 1;
    trackSlot.rotation = 0;
    trackSlot.segment = segment;
    
    [track addSlot:trackSlot];
        
    return trackSlot;
}

- (NLETrackSlot_OC *)splitForSlot:(NLETrackSlot_OC *)slot
{
    if (!slot) { return nil; }
    
    DVEMediaContext *mediaContext = self.vcContext.mediaContext;
    
    CMTime leftDuration = CMTimeSubtract(mediaContext.currentTime, slot.startTime);
    float scale = CMTimeGetSeconds(slot.duration) == 0 ? 0 : CMTimeGetSeconds(leftDuration) / CMTimeGetSeconds(slot.duration);
    
    NLEModel_OC *model = self.nleEditor.nleModel;
    NLETrack_OC *track = [model trackContainSlotId:slot.nle_nodeId];
    
    [slot adjustKeyFrame:[self.keyFrameEditor currentKeyframeTimeRange]];
    NLETrackSlot_OC *newSlot = [track splitFromTime:CMTimeGetSeconds(mediaContext.currentTime) * USEC_PER_SEC];
    
    newSlot.startTime = mediaContext.currentTime;
    
    [self p_updateStickerAnimationDuration:scale slot:slot];
    [self p_updateStickerAnimationDuration:1 - scale slot:newSlot];
    
    [self.actionService commitNLE:YES];
    mediaContext.selectTextSlotAtCurrentTime = newSlot;
    
    return newSlot;
}

- (NLETrackSlot_OC *)copyForSlot:(NSString *)segmentId needCommit:(BOOL)commit
{
    NLETrackSlot_OC *slot = nil;
    //当前处于封面编辑页面
    BOOL isCoverEnable = self.nleEditor.nleModel.coverModel.enable;
    if (isCoverEnable) {
        slot = [self.nleEditor.nleModel.coverModel slotOf:segmentId];
    } else {
        slot = [self.nleEditor.nleModel slotOf:segmentId];
    }
    
    if (!slot) {
        return nil;
    }
    
    NLETrack_OC *track = nil;
    if (isCoverEnable) {
        track = [self p_trackContainSlotId:slot.nle_nodeId array:self.nleEditor.nleModel.coverModel.tracks];
    } else {
        track = [self.nleEditor.nleModel trackContainSlotId:slot.nle_nodeId];

    }
    if (!track) {
        return nil;
    }
    NLEResourceType resourceType = track.nle_extraResourceType;
    
    // 轨道部分
    NLETrackSlot_OC *newSlot = [slot deepClone:YES];
    
    float offset = 0.05f;
    if (resourceType == NLEResourceTypeTextSticker || resourceType == NLEResourceTypeSticker) {
        // 向下偏移
        newSlot.transformY -= offset;
    }
    
    NLEModel_OC *model = self.nleEditor.nleModel;
    NLETrack_OC *newTrack = [[NLETrack_OC alloc] init];

    newTrack.extraTrackType = track.extraTrackType;
    newTrack.nle_extraResourceType = resourceType;
    newTrack.layer = (int)([model nle_getMaxTrackLayer:track.extraTrackType] + 1);
    [newTrack addSlot:newSlot];
    
    if (isCoverEnable) {
        [self.nleEditor.nleModel.coverModel addTrack:newTrack];
    } else {
        [model addTrack:newTrack];
    }
    [self.actionService commitNLE:(isCoverEnable ? NO : commit)];
    self.vcContext.mediaContext.selectTextSlotAtCurrentTime = newSlot;
    
    return newSlot;
}

- (BOOL)removeSlot:(NSString *)segmentId
         needCommit:(BOOL)commit
         isMainEdit:(BOOL)mainEdit
{
    NLETrackSlot_OC *slot = nil;
    if (mainEdit) {
        slot = [self.nleEditor.nleModel slotOf:segmentId];
    } else {
        slot = [self.nleEditor.nleModel.coverModel slotOf:segmentId];
    }
    
    if (!slot) {
        return NO;
    }
    
    if (mainEdit) {
        NLETrackType trackType = [self.nleEditor.nleModel trackContainSlotId:slot.nle_nodeId].extraTrackType;
        [self.nleEditor.nleModel nle_removeSlots:@[slot.nle_nodeId] inTrackType:trackType];
    } else {
        NLETrackType trackType = [self p_trackContainSlotId:slot.nle_nodeId array:self.nleEditor.nleModel.coverModel.tracks].extraTrackType;
        [self.nleEditor.nleModel.coverModel nle_removeSlots:@[slot.nle_nodeId] inTrackType:trackType];
    }
    
    [self.actionService commitNLE:commit];
    self.vcContext.mediaContext.selectTextSlot = nil;
    
    return YES;
}

// Move this function to NLEVideoFrameModel_OC later.
- (NLETrack_OC *)p_trackContainSlotId:(NSString *)slotID array:(NSArray<NLETrack_OC *> *)tracks
{
    for (NLETrack_OC *track in tracks) {
        for (NLETrackSlot_OC *slot in track.slots) {
            if ([slot.nle_nodeId isEqualToString:slotID]) {
                return track;
            }
        }
    }
    
    return nil;
}

- (void)p_updateStickerAnimationDuration:(float)scale slot:(NLETrackSlot_OC *)slot
{
    if (![slot.segment isKindOfClass:[NLESegmentSticker_OC class]]) {
        return;
    }

    NLESegmentSticker_OC *seg = (NLESegmentSticker_OC *)slot.segment;
    if (!seg.stickerAnimation) {
        return;
    }
    
    if (CMTimeGetSeconds(seg.stickerAnimation.inDuration) > 0) {
        seg.stickerAnimation.inDuration = CMTimeMakeWithSeconds(CMTimeGetSeconds(seg.stickerAnimation.inDuration) * scale, USEC_PER_SEC);
    }
    
    if (CMTimeGetSeconds(seg.stickerAnimation.outDuration) > 0) {
        seg.stickerAnimation.outDuration = CMTimeMakeWithSeconds(CMTimeGetSeconds(seg.stickerAnimation.outDuration) * scale, USEC_PER_SEC);
    }
}

@end
