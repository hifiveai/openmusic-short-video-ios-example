//
//  DVEEffectEditorWrapper.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/23.
//

#import "DVEEffectEditorWrapper.h"
#import "DVEEffectEditor.h"
#import "DVELoggerImpl.h"

@interface DVEEffectEditorWrapper ()

@property (nonatomic, strong) id<DVECoreEffectProtocol> effectEditor;

@end

@implementation DVEEffectEditorWrapper

@synthesize vcContext = _vcContext;

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if (self = [super init]) {
        _vcContext = context;
        _effectEditor = [[DVEEffectEditor alloc] initWithContext:context];
    }
    return self;
}

#pragma mark - DVECoreEffectProtocol

- (void)updateNLEEffect:(NSString *)effectObjID
             resourceId:(NSString *)resourceId
                   name:(NSString*)name
                resPath:(NSString*)resPath
             needCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.effectEditor updateNLEEffect:effectObjID resourceId:resourceId name:name resPath:resPath needCommit:commit];
}

- (void)deleteNLEEffect:(NSString *)effectObjID
             needCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.effectEditor deleteNLEEffect:effectObjID needCommit:commit];
}

- (NSString *)copySelectedEffects
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.effectEditor copySelectedEffects];
}

- (NSString *)addGlobalNewEffectWithPath:(NSString *)path
                                    name:(NSString *)name
                               startTime:(CMTime)startTime
                                 endTime:(CMTime)endTime
                             resourceTag:(NLEResourceTag)resourceTag
                              resourceId:(NSString * _Nullable)resourceId
                                   layer:(NSInteger)layer
                              needCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.effectEditor addGlobalNewEffectWithPath:path name:name startTime:startTime endTime:endTime resourceTag:resourceTag resourceId:resourceId layer:layer needCommit:commit];
}

- (NSString *)addPartlyNewEffectWithPath:(NSString *)path
                                   name:(NSString *)name
                             identifier:(NSString *)identifier
                                forSlot:(NLETrackSlot_OC *)slot
                            resourceTag:(NLEResourceTag)resourceTag
                             needCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.effectEditor addPartlyNewEffectWithPath:path name:name identifier:identifier forSlot:slot resourceTag:resourceTag needCommit:commit];
}

- (NSString *)addPartlyNewEffectWithPath:(NSString *)path
                                   name:(NSString *)name
                             identifier:(NSString *)identifier
                               forTrack:(NLETrack_OC *)track
                            resourceTag:(NLEResourceTag)resourceTag
                             needCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.effectEditor addPartlyNewEffectWithPath:path name:name identifier:identifier forTrack:track resourceTag:resourceTag needCommit:commit];
}

- (NSString *)addPartlyNewEffectWithPath:(NSString *)path
                                   name:(NSString *)name
                             identifier:(NSString *)identifier
                              startTime:(CMTime)startTime
                                endTime:(CMTime)endTime
                                forNode:(NLETimeSpaceNode_OC *)timespaceNode
                            resourceTag:(NLEResourceTag)resourceTag
                             needCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.effectEditor addPartlyNewEffectWithPath:path name:name identifier:identifier startTime:startTime endTime:endTime forNode:timespaceNode resourceTag:resourceTag needCommit:commit];
}

- (void)movePartlyEffectToGlobal:(NSString *)effectObjID
                        fromSlot:(NLETrackSlot_OC *)fromSlot
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.effectEditor movePartlyEffectToGlobal:effectObjID fromSlot:fromSlot];
}

- (void)moveGlobalEffectToPartly:(NLETrackSlot_OC *)globalSlot
                      partlySlot:(NLETrackSlot_OC *)partlySlot
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.effectEditor moveGlobalEffectToPartly:globalSlot partlySlot:partlySlot];
}

- (void)movePartlyEffectToOtherPartly:(NSString *)effectObjID
                             fromSlot:(NLETrackSlot_OC *)fromSlot
                               toSlot:(NLETrackSlot_OC *)toSlot
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.effectEditor movePartlyEffectToOtherPartly:effectObjID fromSlot:fromSlot toSlot:toSlot];
}

- (NLETrackSlot_OC * _Nullable)partlySlotByeffectObjID:(NSString *)effectObjID
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.effectEditor partlySlotByeffectObjID:effectObjID];
}

- (NLETrackSlot_OC * _Nullable)globalSlotByeffectObjID:(NSString *)effectObjID
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.effectEditor globalSlotByeffectObjID:effectObjID];
}

- (NLETrackSlot_OC * _Nullable)slotByeffectObjID:(NSString *)effectObjID
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.effectEditor slotByeffectObjID:effectObjID];
}

- (BOOL)isGobalEffectBySlotID:(NSString *)slotID
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.effectEditor isGobalEffectBySlotID:slotID];
}

@end
