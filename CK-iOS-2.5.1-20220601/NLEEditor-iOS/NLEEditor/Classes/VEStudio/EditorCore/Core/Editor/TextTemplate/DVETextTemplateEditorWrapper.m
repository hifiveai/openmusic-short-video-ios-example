//
//  DVETextTemplateEditorWrapper.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/23.
//

#import "DVETextTemplateEditorWrapper.h"
#import "DVETextTemplateEditor.h"
#import "DVELoggerImpl.h"

@interface DVETextTemplateEditorWrapper ()

@property (nonatomic, strong) id<DVECoreTextTemplateProtocol> textTemplateEditor;

@end

@implementation DVETextTemplateEditorWrapper

@synthesize vcContext = _vcContext;

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if (self = [super init]) {
        _vcContext = context;
        _textTemplateEditor = [[DVETextTemplateEditor alloc] initWithContext:context];
    }
    return self;
}

#pragma mark - DVECoreTextTemplateProtocol

- (NLETrackSlot_OC *)trackSlot
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return self.textTemplateEditor.trackSlot;
}

- (NSString *)addTemplateWithPath:(NSString *)path
                     depResModels:(NSArray<DVETextTemplateDepResourceModelProtocol> *)depResModels
                       needCommit:(BOOL)commit
                       completion:(nullable void(^)(void))completion
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.textTemplateEditor addTemplateWithPath:path depResModels:depResModels needCommit:commit completion:completion];
}

- (void)setSticker:(NSString *)segmentId startTime:(CGFloat)startTime duration:(CGFloat)duration
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.textTemplateEditor setSticker:segmentId startTime:startTime duration:duration];
}

- (void)updateText:(NSString *)text atIndex:(NSUInteger)index isCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.textTemplateEditor updateText:text atIndex:index isCommit:commit];
}

- (void)removeSelectedTextTemplateWithIsCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.textTemplateEditor removeSelectedTextTemplateWithIsCommit:commit];
}

- (void)removeTextTemplate:(NSString * )segmentId isCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.textTemplateEditor removeTextTemplate:segmentId isCommit:commit];
}

- (NSString *)copyTextTemplateWithIsCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.textTemplateEditor copyTextTemplateWithIsCommit:commit];
}

- (NLETrackSlot_OC * _Nullable)slotByeffectObjID:(NSString*)effectObjID
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.textTemplateEditor slotByeffectObjID:effectObjID];
}

- (NSArray<NLETrackSlot_OC *> *)textTemplatestickerSlots
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.textTemplateEditor textTemplatestickerSlots];
}

- (NSArray *)selectedTexts
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.textTemplateEditor selectedTexts];
}

- (void)updateAllTextTemplateSlotPreviewMode:(int)previewMode
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.textTemplateEditor updateAllTextTemplateSlotPreviewMode:previewMode];
}

- (NSString *)replaceTemplateAtSlot:(NLETrackSlot_OC *)slot
                          startTime:(Float64)startTime
                            endTime:(Float64)endTime
                               path:(NSString *)path
                       depResModels:(NSArray<DVETextTemplateDepResourceModelProtocol> *)depResModels
                             commit:(BOOL)commit
                         completion:(nullable void(^)(void))completion
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.textTemplateEditor replaceTemplateAtSlot:slot startTime:startTime endTime:endTime path:path depResModels:depResModels commit:commit completion:completion];
}

@end
