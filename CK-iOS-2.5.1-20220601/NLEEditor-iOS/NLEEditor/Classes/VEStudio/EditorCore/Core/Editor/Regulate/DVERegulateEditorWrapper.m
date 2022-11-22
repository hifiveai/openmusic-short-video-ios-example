//
//  DVERegulateEditorWrapper.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/23.
//

#import "DVERegulateEditorWrapper.h"
#import "DVERegulateEditor.h"
#import "DVELoggerImpl.h"

@interface DVERegulateEditorWrapper ()

@property (nonatomic, strong) id<DVECoreRegulateProtocol> regulateEditor;

@end

@implementation DVERegulateEditorWrapper

@synthesize vcContext = _vcContext;

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if (self = [super init]) {
        _vcContext = context;
        _regulateEditor = [[DVERegulateEditor alloc] initWithContext:context];
    }
    return self;
}

#pragma mark - DVECoreRegulateProtocol

- (void)addOrUpdateAjustFeatureWithPath:(NSString *)path
                                   name:(NSString *)name
                             identifier:identifier
                              intensity:(CGFloat)intensity
                            resourceTag:(NLEResourceTag)resourceTag
                             needCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.regulateEditor addOrUpdateAjustFeatureWithPath:path name:name identifier:identifier intensity:intensity resourceTag:resourceTag needCommit:commit];
}

- (void)resetAllRegulateNeedCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.regulateEditor resetAllRegulateNeedCommit:commit];
}

- (void)deleteSelectRegulateSegment
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.regulateEditor deleteSelectRegulateSegment];
}

- (NSDictionary *)currentAdjustIntensity
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return self.regulateEditor.currentAdjustIntensity;
}

- (void)setKeyFrameDelegate:(id<DVERegulateKeyFrameProtocol>)keyFrameDelegate {
    self.regulateEditor.keyFrameDelegate = keyFrameDelegate;
}

- (id<DVERegulateKeyFrameProtocol>)keyFrameDelegate {
    return self.regulateEditor.keyFrameDelegate;
}

@end
