//
//   DVEAnimationEditor.m
//   NLEEditor
//
//   Created  by bytedance on 2021/4/26.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//

#import "DVEAnimationEditor.h"
#import "NSDictionary+DVE.h"
#import "DVECustomerHUD.h"
#import "NSString+DVE.h"
#import "DVEVCContext.h"
#import "NSString+VEIEPath.h"
#import <DVETrackKit/NLETrack_OC+NLE.h>
#import <TTVideoEditor/VEVideoAnimation.h>

@interface DVEAnimationEditor ()

@property (nonatomic, weak) id<DVECoreDraftServiceProtocol> draftService;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;

@end

@implementation DVEAnimationEditor

@synthesize vcContext = _vcContext;

DVEAutoInject(self.vcContext.serviceProvider, draftService, DVECoreDraftServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if(self = [super init]) {
        self.vcContext = context;
    }
    return self;
}

- (void)addAnimation:(NSString *)inAnimationPath
          identifier:(NSString *)identifier
            withType:(DVEModuleCutSubTypeAnimationType)type
            duration:(CGFloat)duration {
    NSString *relativePath = [self.draftService copyResourceToDraft:[NSURL fileURLWithPath:inAnimationPath] resourceType:NLEResourceTypeAnimationVideo];
    NLETrackSlot_OC *selectSlot = [self.vcContext.mediaContext currentBlendVideoSlot];

    CMTime start = kCMTimeZero;
    NLEVideoAnimationType animationType = NLEVideoAnimationTypeNone;
    switch (type) {
        case DVEModuleCutSubTypeAnimationTypeAdmission: {
            animationType = NLEVideoAnimationTypeIn;
        }
            break;
        case DVEModuleCutSubTypeAnimationTypeCombination: {
            animationType = NLEVideoAnimationTypeCombination;
        }
            break;
        case DVEModuleCutSubTypeAnimationTypeDisappear: {
            start = CMTimeSubtract(selectSlot.duration, CMTimeMake(duration * USEC_PER_SEC, USEC_PER_SEC));
            animationType = NLEVideoAnimationTypeOut;
        }
            break;
    }

    // NLE
    CMTime cmDuration = CMTimeMake(duration * USEC_PER_SEC, USEC_PER_SEC);

    NLEResourceNode_OC *resource = [[NLEResourceNode_OC alloc] init];
    resource.resourceFile = relativePath;
    resource.resourceId = identifier;
    resource.duration = cmDuration;
    resource.resourceType = NLEResourceTypeAnimationVideo;

    NLESegmentVideoAnimation_OC *segmentVideoAnimation = [[NLESegmentVideoAnimation_OC alloc] init];
    segmentVideoAnimation.animationDuration = cmDuration;
    segmentVideoAnimation.effectSDKVideoAnimation = resource;

    NLEVideoAnimation_OC *animation = [[NLEVideoAnimation_OC alloc] init];
    animation.segmentVideoAnimation = segmentVideoAnimation;
    // 相对于素材本身的时间
    animation.startTime = start;
    [selectSlot clearVideoAnim];
    [selectSlot addVideoAnim:animation];
    animation.nle_animationType = animationType;

    [self.actionService commitNLE:NO];
}

- (void)deleteVideoAnimation
{
    NLETrackSlot_OC *selectSlot = [self.vcContext.mediaContext currentBlendVideoSlot];

    [selectSlot clearVideoAnim];

    [self.actionService commitNLE:NO];
}

- (NSDictionary *)currentAnimationDuration:(NLEVideoAnimationType)type
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NLETrackSlot_OC *selectSlot = [self.vcContext.mediaContext currentBlendVideoSlot];

    if (selectSlot) {
        NSArray<NLEVideoAnimation_OC*>* array= [selectSlot getVideoAnims];
        for (NLEVideoAnimation_OC *animation in array) {
            if (type == animation.nle_animationType) {
                NLEResourceNode_OC *resAnimation = animation.segmentVideoAnimation.effectSDKVideoAnimation;
                CGFloat duration = resAnimation.duration.value / (resAnimation.duration.timescale * 1.0);
                [dic setObject:resAnimation.resourceId forKey:@"identifier"];
                [dic setObject:@(duration) forKey:resAnimation.resourceId];
                return dic;
            }
        }
    }
    return dic;
}

@end
