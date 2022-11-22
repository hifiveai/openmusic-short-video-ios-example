//
//  DVEKeyFrameEditorWrapper.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/23.
//

#import "DVEKeyFrameEditorWrapper.h"
#import "DVEKeyFrameEditor.h"
#import "DVELoggerImpl.h"

@interface DVEKeyFrameEditorWrapper ()

@property (nonatomic, strong) id<DVECoreKeyFrameProtocol> keyFrameEditor;

@end

@implementation DVEKeyFrameEditorWrapper

@synthesize vcContext = _vcContext;

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if (self = [super init]) {
        _vcContext = context;
        _keyFrameEditor = [[DVEKeyFrameEditor alloc] initWithContext:context];
    }
    return self;
}

#pragma mark - DVECoreKeyFrameProtocol

-(BOOL)hasKeyframe:(NLETrackSlot_OC*)slot
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.keyFrameEditor hasKeyframe:slot];
}

-(CMTime)currentKeyframeTimeRange
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.keyFrameEditor currentKeyframeTimeRange];
}

- (void)refreshAllKeyFrameIfNeedWithSlot:(NLETrackSlot_OC *)slot {
    [self.keyFrameEditor refreshAllKeyFrameIfNeedWithSlot:slot];
}

@end
