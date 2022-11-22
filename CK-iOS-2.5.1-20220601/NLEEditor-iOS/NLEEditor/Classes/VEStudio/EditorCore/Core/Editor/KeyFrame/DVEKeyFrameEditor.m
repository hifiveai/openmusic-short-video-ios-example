//
//   DVEKeyFrameEditor.m
//   NLEEditor
//
//   Created  by ByteDance on 2021/8/18.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEKeyFrameEditor.h"
#import "DVEVCContext.h"
#import <NLEPlatform/NLEStyleText+iOS.h>
#import <NLEPlatform/NLETrackSlot+iOS.h>


// 默认关键帧左右覆盖时间范围各100ms,共200ms
NSInteger const NLEKeyframeRange = 200 * 1000;

@interface DVEKeyFrameEditor ()

@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;

@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@end

@implementation DVEKeyFrameEditor

@synthesize vcContext = _vcContext;

DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if(self = [super init]) {
        self.vcContext = context;
    }
    return self;
}

-(BOOL)hasKeyframe:(NLETrackSlot_OC*)slot
{
    return slot.getKeyframe.count > 0;
}

-(CMTime)currentKeyframeTimeRange
{
    return CMTimeMake(NLEKeyframeRange / (self.vcContext.mediaContext.timeScale > 0 ? self.vcContext.mediaContext.timeScale : 1), USEC_PER_SEC);
}

- (void)refreshAllKeyFrameIfNeedWithSlot:(NLETrackSlot_OC *)slot {
    if (!slot) {
        return;
    }
    
    NLEAllKeyFrameInfo *info = [self.nle keyFrameInfoAtTime:self.vcContext.mediaContext.currentTime];
    slot = [self.nle refreshAllKeyFrameInfo:info pts:self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC inSlot:slot];
}

@end
