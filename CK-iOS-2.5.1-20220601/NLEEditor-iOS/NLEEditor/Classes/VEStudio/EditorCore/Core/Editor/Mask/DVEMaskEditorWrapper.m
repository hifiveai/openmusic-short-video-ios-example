//
//  DVEMaskEditorWrapper.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/23.
//

#import "DVEMaskEditorWrapper.h"
#import "DVEMaskEditor.h"
#import "DVELoggerImpl.h"

@interface DVEMaskEditorWrapper ()

@property (nonatomic, strong) id<DVECoreMaskProtocol> maskEditor;

@end

@implementation DVEMaskEditorWrapper

@synthesize vcContext = _vcContext;

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if (self = [super init]) {
        _vcContext = context;
        _maskEditor = [[DVEMaskEditor alloc] initWithContext:context];
    }
    return self;
}

#pragma mark - DVECoreMaskProtocol

- (void)addOrChangeMaskWithEffectValue:(DVEMaskConfigModel *)eValue
                       needCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.maskEditor addOrChangeMaskWithEffectValue:eValue needCommit:commit];
}

- (void)updateOneMaskWithEffectValue:(DVEMaskConfigModel *)eValue
                          needCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.maskEditor updateOneMaskWithEffectValue:eValue needCommit:commit];
}

- (void)deletCurMaskEffectValueNeedCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.maskEditor deletCurMaskEffectValueNeedCommit:commit];
}

- (NSDictionary *)currentMaskInfo
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return self.maskEditor.currentMaskInfo;
}

- (void)setKeyFrameDelegate:(id<DVEMaskKeyFrameProtocol>)keyFrameDelegate
{
    self.maskEditor.keyFrameDelegate = keyFrameDelegate;
}

- (id<DVEMaskKeyFrameProtocol>)keyFrameDelegate
{
    return self.maskEditor.keyFrameDelegate;
}

@end
