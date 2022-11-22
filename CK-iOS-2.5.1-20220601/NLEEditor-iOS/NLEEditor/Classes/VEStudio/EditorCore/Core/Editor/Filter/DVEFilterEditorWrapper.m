//
//  DVEFilterEditorWrapper.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/23.
//

#import "DVEFilterEditorWrapper.h"
#import "DVEFilterEditor.h"
#import "DVELoggerImpl.h"

@interface DVEFilterEditorWrapper ()

@property (nonatomic, strong) id<DVECoreFilterProtocol> filterEditor;

@end

@implementation DVEFilterEditorWrapper

@synthesize vcContext = _vcContext;

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if (self = [super init]) {
        _vcContext = context;
        _filterEditor = [[DVEFilterEditor alloc] initWithContext:context];
    }
    return self;
}

#pragma mark - DVECoreFilterProtocol

- (void)addOrUpdateFilterWithPath:(NSString *)path
                             name:(NSString *)name
                       identifier:(NSString *)identifier
                        intensity:(CGFloat)intensity
                      resourceTag:(NLEResourceTag)resourceTag
                       needCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.filterEditor addOrUpdateFilterWithPath:path name:name identifier:identifier intensity:intensity resourceTag:resourceTag needCommit:commit];
}

- (void)deleteCurrentFilterNeedCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.filterEditor deleteCurrentFilterNeedCommit:commit];
}

- (NSDictionary *)currentFilterIntensity
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return self.filterEditor.currentFilterIntensity;
}

- (void)setKeyFrameDelegate:(id<DVEFilterKeyFrameProtocol>)keyFrameDelegate {
    self.filterEditor.keyFrameDelegate = keyFrameDelegate;
}

- (id<DVEFilterKeyFrameProtocol>)keyFrameDelegate {
    return self.filterEditor.keyFrameDelegate;
}

@end
