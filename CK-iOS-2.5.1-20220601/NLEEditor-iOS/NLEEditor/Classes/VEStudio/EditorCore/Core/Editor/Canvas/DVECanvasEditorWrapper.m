//
//  DVECanvasEditorWrapper.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/23.
//

#import "DVECanvasEditorWrapper.h"
#import "DVECanvasEditor.h"
#import "DVELoggerImpl.h"

@interface DVECanvasEditorWrapper ()

@property (nonatomic, strong) id<DVECoreCanvasProtocol> canvasEditor;

@end

@implementation DVECanvasEditorWrapper

@synthesize vcContext = _vcContext;

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if (self = [super init]) {
        _vcContext = context;
        _canvasEditor = [[DVECanvasEditor alloc] initWithContext:context];
    }
    return self;
}

#pragma mark - DVECoreCanvasProtocol

- (DVECanvasRatio)ratio
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return self.canvasEditor.ratio;
}

- (CGSize)canvasSize
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return self.canvasEditor.canvasSize;
}

- (CGSize)originRatioSize
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return self.canvasEditor.originRatioSize;
}

- (void)initCanvasWithResource:(id<DVEResourcePickerModel>)resourceModel
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.canvasEditor initCanvasWithResource:resourceModel];
}

- (void)saveCanvasSize
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.canvasEditor saveCanvasSize];
}

- (void)restoreCanvasSize
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.canvasEditor restoreCanvasSize];
}

- (CGSize)fitMaxSizeForResolution:(CGFloat)resolution
                       originSize:(CGSize)originSize
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.canvasEditor fitMaxSizeForResolution:resolution originSize:originSize];
}

- (CGSize)exportSizeForResolution:(DVEExportResolution)resolution
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.canvasEditor exportSizeForResolution:resolution];
}

- (void)updateCanvasRatio:(NSInteger)ratio
                     size:(CGSize)size
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.canvasEditor updateCanvasRatio:ratio size:size];
}

- (CGRect)subViewScaleAspectFit:(CGRect)rect
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.canvasEditor subViewScaleAspectFit:rect];
}

- (CGSize)canvasSizeScaleAspectFitInRect:(CGRect)rect
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.canvasEditor canvasSizeScaleAspectFitInRect:rect];
}

- (void)setCanvasRatio:(DVECanvasRatio)ratio
         inPreviewView:(UIView *)view
            needCommit:(BOOL)isneed
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.canvasEditor setCanvasRatio:ratio inPreviewView:view needCommit:isneed];
}

- (void)updateVideoClipTranslation:(CGPoint)translation
                           forSlot:(NLETrackSlot_OC *)slot
                          isCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.canvasEditor updateVideoClipTranslation:translation forSlot:slot isCommit:commit];
}

- (void)updateVideoClipScale:(CGFloat)scale
                     forSlot:(NLETrackSlot_OC *)slot
                    isCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.canvasEditor updateVideoClipScale:scale forSlot:slot isCommit:commit];
}

- (void)updateVideoClipRotation:(CGFloat)rotation
                        forSlot:(NLETrackSlot_OC *)slot
                       isCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.canvasEditor updateVideoClipRotation:rotation forSlot:slot isCommit:commit];
}

- (void)setKeyFrameDelegate:(id<DVECanvasKeyFrameProtocol>)keyFrameDelegate {
    [self.canvasEditor setKeyFrameDelegate:keyFrameDelegate];
}

- (id<DVECanvasKeyFrameProtocol>)keyFrameDelegate {
    return self.canvasEditor.keyFrameDelegate;
}

@end
