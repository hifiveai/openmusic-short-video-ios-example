//
//  DVEAnimationEditorWrapper.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/23.
//

#import "DVEAnimationEditorWrapper.h"
#import "DVEAnimationEditor.h"
#import "DVELoggerImpl.h"

@interface DVEAnimationEditorWrapper ()

@property (nonatomic, strong) id<DVECoreAnimationProtocol> animationEditor;

@end

@implementation DVEAnimationEditorWrapper

@synthesize vcContext = _vcContext;

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if (self = [super init]) {
        _vcContext = context;
        _animationEditor = [[DVEAnimationEditor alloc] initWithContext:context];
    }
    return self;
}

#pragma mark - DVECoreAnimationProtocol

- (void)addAnimation:(NSString *)inAnimationPath
          identifier:(NSString *)identifier
            withType:(DVEModuleCutSubTypeAnimationType)type
            duration:(CGFloat)duration
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.animationEditor addAnimation:inAnimationPath identifier:identifier withType:type duration:duration];
}

- (void)deleteVideoAnimation
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.animationEditor deleteVideoAnimation];
}

- (NSDictionary *)currentAnimationDuration:(NLEVideoAnimationType)type
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.animationEditor currentAnimationDuration:type];
}

@end
