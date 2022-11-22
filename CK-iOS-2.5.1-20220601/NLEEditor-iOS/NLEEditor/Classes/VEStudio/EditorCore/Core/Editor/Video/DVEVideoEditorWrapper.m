//
//  DVEVideoEditorWrapper.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/23.
//

#import "DVEVideoEditorWrapper.h"
#import "DVEVideoEditor.h"
#import "DVELoggerImpl.h"

@interface DVEVideoEditorWrapper ()

@property (nonatomic, strong) id<DVECoreVideoProtocol> videoEditor;

@end

@implementation DVEVideoEditorWrapper

@synthesize vcContext = _vcContext;

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if (self = [super init]) {
        _vcContext = context;
        _videoEditor = [[DVEVideoEditor alloc] initWithContext:context];
    }
    return self;
}

#pragma mark - DVECoreVideoProtocol

+ (CMTime)kDefaultPhotoResourceDuration
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [DVEVideoEditor kDefaultPhotoResourceDuration];
}

- (void)videoSplitForSlot:(NLETrackSlot_OC *)slot
                   isMain:(BOOL)main
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.videoEditor videoSplitForSlot:slot isMain:main];
}

- (void)deleteVideoClip:(NLETrackSlot_OC *)slot
                 isMain:(BOOL)main
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.videoEditor deleteVideoClip:slot isMain:main];
}

- (void)changeVideoSpeed:(CGFloat)speed
                    slot:(NLETrackSlot_OC *)slot
                  isMain:(BOOL)main
          shouldKeepTone:(BOOL)isToneModify
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.videoEditor changeVideoSpeed:speed slot:slot isMain:main shouldKeepTone:isToneModify];
}

- (void)updateVideoCurveSpeedInfo:(nullable id<DVEResourceCurveSpeedModelProtocol>)curveSpeedInfo
                             slot:(NLETrackSlot_OC *)slot
                           isMain:(BOOL)main
                     shouldCommit:(BOOL)commit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.videoEditor updateVideoCurveSpeedInfo:curveSpeedInfo slot:slot isMain:main shouldCommit:commit];
}

- (NSArray *)currentCurveSpeedPoints
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return self.videoEditor.currentCurveSpeedPoints;
}

- (NSString *)currentCurveSpeedName
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return self.videoEditor.currentCurveSpeedName;
}

- (int64_t)currentSrcDuration
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return self.videoEditor.currentSrcDuration;
}

- (int64_t)srcDurationWithSlot:(NLETrackSlot_OC *)slot
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.videoEditor srcDurationWithSlot:slot];
}

- (void)changeVideoRotate:(NLETrackSlot_OC *)slot
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.videoEditor changeVideoRotate:slot];
}

- (void)changeVideoFlip:(NLETrackSlot_OC *)slot
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.videoEditor changeVideoFlip:slot];
}

- (void)changeVideoVolume:(CGFloat)volume
                     slot:(NLETrackSlot_OC *)slot
                   isMain:(BOOL)main
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.videoEditor changeVideoVolume:volume slot:slot isMain:main];
}

- (void)handleVideoReverse:(NLETrackSlot_OC *)slot
                    isMain:(BOOL)main
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.videoEditor handleVideoReverse:slot isMain:main];
}

- (void)videoFreezeForSlot:(NLETrackSlot_OC *)slot
                    isMain:(BOOL)main
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.videoEditor videoFreezeForSlot:slot isMain:main];
}

- (void)copyVideoOrImageSlot:(NLETrackSlot_OC *)slot
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.videoEditor copyVideoOrImageSlot:slot];
}

- (void)applyMixedEffectWithSlot:(NLETrackSlot_OC *)slot alpha:(CGFloat)alpha {
    [self.videoEditor applyMixedEffectWithSlot:slot alpha:alpha];
}

- (void)applyMixedEffectWithSlot:(NLETrackSlot_OC *)slot
                       blendFile:(NLEResourceNode_OC *)blendFile
                           alpha:(CGFloat)alpha {
    [self.videoEditor applyMixedEffectWithSlot:slot blendFile:blendFile alpha:alpha];
}

- (void)setKeyFrameDeleagte:(id<DVEVideoKeyFrameProtocol>)keyFrameDeleagte {
    self.videoEditor.keyFrameDeleagte = keyFrameDeleagte;
}

- (id<DVEVideoKeyFrameProtocol>)keyFrameDeleagte {
    return self.videoEditor.keyFrameDeleagte;
}

@end
