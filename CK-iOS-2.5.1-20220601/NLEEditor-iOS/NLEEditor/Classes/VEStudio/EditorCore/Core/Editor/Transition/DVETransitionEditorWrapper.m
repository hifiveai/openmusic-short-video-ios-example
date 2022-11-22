//
//  DVETransitionEditorWrapper.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/23.
//

#import "DVETransitionEditorWrapper.h"
#import "DVETransitionEditor.h"
#import "DVELoggerImpl.h"

@interface DVETransitionEditorWrapper ()

@property (nonatomic, strong) id<DVECoreTransitionProtocol> transitionEditor;

@end

@implementation DVETransitionEditorWrapper

@synthesize vcContext = _vcContext;

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if (self = [super init]) {
        _vcContext = context;
        _transitionEditor = [[DVETransitionEditor alloc] initWithContext:context];
    }
    return self;
}

#pragma mark - DVECoreTransitionProtocol

- (NSString *)addTransitionWithEffectResource:(NSString *)path
                                   resourceId:(NSString *)resourceId
                                     duration:(CGFloat)duraion
                                    isOverlap:(BOOL)overlap
                                      forSlot:(NLETrackSlot_OC *)slot
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.transitionEditor addTransitionWithEffectResource:path resourceId:resourceId duration:duraion isOverlap:overlap forSlot:slot];
}

- (void)deleteCurrentTransitionForSlot:(NLETrackSlot_OC *)slot
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.transitionEditor deleteCurrentTransitionForSlot:slot];
}

- (double)getMaxTranstisionTimeBySlot:(NLETrackSlot_OC *)slot
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.transitionEditor getMaxTranstisionTimeBySlot:slot];
}

@end
