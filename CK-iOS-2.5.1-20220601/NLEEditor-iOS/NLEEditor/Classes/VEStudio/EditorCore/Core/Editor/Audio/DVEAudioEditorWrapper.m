//
//  DVEAudioEditorWrapper.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/23.
//

#import "DVEAudioEditorWrapper.h"
#import "DVEAudioEditor.h"
#import "DVELoggerImpl.h"

@interface DVEAudioEditorWrapper ()

@property (nonatomic, strong) id<DVECoreAudioProtocol> audioEditor;

@end

@implementation DVEAudioEditorWrapper

@synthesize vcContext = _vcContext;

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if (self = [super init]) {
        _vcContext = context;
        _audioEditor = [[DVEAudioEditor alloc] initWithContext:context];
    }
    return self;
}

#pragma mark - DVECoreAudioProtocol

- (NLETrackSlot_OC *)addAudioResource:(NSURL *)audioUrl
                            audioName:(NSString *)audioName
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.audioEditor addAudioResource:audioUrl audioName:audioName];
}

- (NLETrackSlot_OC *)addAudioEffectResource:(NSURL *)audioUrl
                                 audioName:(NSString *)audioName
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.audioEditor addAudioEffectResource:audioUrl audioName:audioName];
}

- (NLETrackSlot_OC *)copyAudioSlot:(NLETrackSlot_OC*)audioSlot
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.audioEditor copyAudioSlot:audioSlot];
}

- (NSString *)recordDefaultName
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.audioEditor recordDefaultName];
}

- (NSInteger)numberOfRecoderSlot
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.audioEditor numberOfRecoderSlot];
}

- (NSInteger)maxRecoderNumberSlot
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.audioEditor maxRecoderNumberSlot];
}

- (void)removeAudioSegment:(NSString * )segmentId
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.audioEditor removeAudioSegment:segmentId];
}

- (void)audioSplitForSlot:(NLETrackSlot_OC *)slot
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.audioEditor audioSplitForSlot:slot];
}

- (void)audioSplitForSlot:(NLETrackSlot_OC *)slot
              newSlotName:(NSString*)newSlotName
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.audioEditor audioSplitForSlot:slot newSlotName:newSlotName];
}

- (void)addText2AudioResource:(NSURL *)audioUrl
                    audioName:(NSString *)audioName
                    startTime:(CMTime)startTime
                   replaceOld:(BOOL)repalceOld
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.audioEditor addText2AudioResource:audioUrl audioName:audioName startTime:startTime replaceOld:repalceOld];
}

- (void)changeAudioSpeed:(CGFloat)speed
                    slot:(NLETrackSlot_OC *)slot
          shouldKeepTone:(BOOL)shouldKeepTone
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.audioEditor changeAudioSpeed:speed slot:slot shouldKeepTone:shouldKeepTone];
}

- (NSString *)audioChangeForSlot:(NLETrackSlot_OC *)slot
                     sourcePath:(NSString*)sourcePath
                     sourceName:(NSString*)sourceName
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.audioEditor audioChangeForSlot:slot sourcePath:sourcePath sourceName:sourceName];
}

- (void)removeAudioChangeForSlot:(NLETrackSlot_OC *)slot
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.audioEditor removeAudioChangeForSlot:slot];
}

@end
