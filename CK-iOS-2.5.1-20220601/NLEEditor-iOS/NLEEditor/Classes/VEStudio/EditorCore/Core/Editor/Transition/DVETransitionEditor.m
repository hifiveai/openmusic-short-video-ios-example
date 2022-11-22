//
//   DVETransitionEditor.m
//   NLEEditor
//
//   Created  by bytedance on 2021/4/26.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVETransitionEditor.h"
#import "NSDictionary+DVE.h"
#import "DVECustomerHUD.h"
#import "NSString+DVE.h"
#import "DVEVCContext.h"
#import <DVETrackKit/NLETrack_OC+NLE.h>
#import "DVEMacros.h"

@interface DVETransitionEditor ()

@property (nonatomic, weak) id<DVECoreDraftServiceProtocol> draftService;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@end

@implementation DVETransitionEditor

@synthesize vcContext = _vcContext;

DVEAutoInject(self.vcContext.serviceProvider, draftService, DVECoreDraftServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if(self = [super init]) {
        self.vcContext = context;
    }
    return self;
}

// 添加一个转场
- (NSString*)addTransitionWithEffectResource:(NSString *)path
                             resourceId:(NSString *)resourceId
                               duration:(CGFloat)duration
                              isOverlap:(BOOL)overlap
                                forSlot:(NLETrackSlot_OC *)slot
{
    NSURL *url = [NSURL fileURLWithPath:path];
    NSString *relativePath = [self.draftService copyResourceToDraft:url resourceType:NLEResourceTypeTransition];
    
    CGFloat previewStart = 0;
    if (overlap) {
        previewStart = CMTimeGetSeconds(slot.startTime) + CMTimeGetSeconds(slot.duration) - duration;
    } else {
        previewStart = CMTimeGetSeconds(slot.startTime) + CMTimeGetSeconds(slot.duration) - duration / 2;
    }
    
    NLEResourceNode_OC *transitionResourceNode = [[NLEResourceNode_OC alloc] init];
    transitionResourceNode.resourceFile = relativePath;
    transitionResourceNode.resourceType = NLEResourceTypeTransition;
    transitionResourceNode.resourceId = resourceId;
    transitionResourceNode.duration = CMTimeMake(duration * USEC_PER_SEC, USEC_PER_SEC);
    
    NLESegmentTransition_OC *nleTransition = [[NLESegmentTransition_OC alloc] init];
    [nleTransition setOverlap:overlap];
    [nleTransition setTransitionDuration:CMTimeMake(duration * USEC_PER_SEC, USEC_PER_SEC)];
    [nleTransition setEffectSDKTransition:transitionResourceNode];
    
    [self addVideoTransition:nleTransition slot:slot autoCommit:NO];
    [self.nleEditor commit];

    @weakify(self);
    [self.vcContext.playerService updateVideoData:self.nle.videoData completeBlock:^(NSError * _Nullable error) {
        @strongify(self);
        if (!error) {
            [self.vcContext.playerService playFrom:CMTimeMake(previewStart * USEC_PER_SEC, USEC_PER_SEC)
                                        duration:duration
                                   completeBlock:nil];
        }
    }];
    return transitionResourceNode.nle_nodeId;
}

- (void)deleteCurrentTransitionForSlot:(NLETrackSlot_OC *)slot
{
    [self addVideoTransition:nil slot:slot autoCommit:NO];
    [self.nleEditor commit];
}

- (double)getMaxTranstisionTimeBySlot:(NLETrackSlot_OC *)slot {
    NLEModel_OC *model = self.nleEditor.nleModel;
    NLETrack_OC *mainTrack = [model nle_getMainVideoTrack];
    return [mainTrack nle_maxTransitionTimeForSlot:slot];
}

- (void)addVideoTransition:(NLESegmentTransition_OC * _Nullable)transition
                      slot:(NLETrackSlot_OC *)slot
                autoCommit:(BOOL)autoCommit
{
    NLETrack_OC *videoTrack = [self.nleEditor.nleModel trackContainSlotId:slot.nle_nodeId];
    if (!videoTrack.isMainTrack) {
        return;
    }
    
    NLESegmentTransition_OC *oldPayload = slot.endTransition;
    
    // 更新转场
    NLESegmentTransition_OC *transitionPayload = nil;
    if (![videoTrack.slots.lastObject.nle_nodeId isEqualToString:slot.nle_nodeId]) {
        transitionPayload = transition;
    }
    [slot nle_updateTransition:transitionPayload];
    BOOL willChangeTimeline = [self willChangeTimeline:oldPayload newTransition:transitionPayload];
    if (willChangeTimeline) {
        [videoTrack nle_rescheduleTrackForTransitionChanged];
    }
    
    // notify
    if (autoCommit) {
        [self.actionService commitNLE:autoCommit];
    }
    self.vcContext.mediaContext.changedTransitionSlot = slot.nle_nodeId;
}

- (BOOL)willChangeTimeline:(NLESegmentTransition_OC * _Nullable)oldTransition
             newTransition:(NLESegmentTransition_OC * _Nullable)newTranstion
{
    if (!oldTransition && !newTranstion) {
        return NO;
    }
    if (!oldTransition && newTranstion && newTranstion.overlap) {
        return YES;
    }
    if (oldTransition && !newTranstion && oldTransition.overlap) {
        return YES;
    }
    
    if (oldTransition && newTranstion) {
        if ((oldTransition.overlap && !newTranstion.overlap)
            || (oldTransition.overlap == newTranstion.overlap && CMTimeCompare(oldTransition.transitionDuration, newTranstion.transitionDuration) == 0)) {
            return NO;
        }
    }
    
    return YES;
}

@end
