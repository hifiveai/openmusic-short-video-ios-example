//
//  DVESlotEditorWrapper.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/23.
//

#import "DVESlotEditorWrapper.h"
#import "DVESlotEditor.h"
#import "DVELoggerImpl.h"

@interface DVESlotEditorWrapper ()

@property (nonatomic, strong) id<DVECoreSlotProtocol> slotEditor;

@end

@implementation DVESlotEditorWrapper

@synthesize vcContext = _vcContext;

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if (self = [super init]) {
        _vcContext = context;
        _slotEditor = [[DVESlotEditor alloc] initWithContext:context];
    }
    return self;
}

#pragma mark - DVECoreSlotProtocol

- (NLETrackSlot_OC *)splitForSlot:(NLETrackSlot_OC *)slot
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.slotEditor splitForSlot:slot];
}

- (NLETrackSlot_OC *)copyForSlot:(NSString *)segmentId
                      needCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.slotEditor copyForSlot:segmentId needCommit:commit];
}

- (BOOL)removeSlot:(NSString *)segmentId
        needCommit:(BOOL)commit
        isMainEdit:(BOOL)mainEdit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.slotEditor removeSlot:segmentId needCommit:commit isMainEdit:mainEdit];
}

- (NLETrackSlot_OC *)addSlot:(NLETrackType)trackType
                resourceType:(NLEResourceType)resourceType
                     segment:(NLESegment_OC *)segment
                   startTime:(CMTime)startTime
                    duration:(CMTime)duration
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.slotEditor addSlot:trackType resourceType:resourceType segment:segment startTime:startTime duration:duration];
}

@end
