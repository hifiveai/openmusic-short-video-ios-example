//
//  DVEStickerEditorWrapper.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/23.
//

#import "DVEStickerEditorWrapper.h"
#import "DVEStickerEditor.h"
#import "DVELoggerImpl.h"

@interface DVEStickerEditorWrapper ()

@property (nonatomic, strong) id<DVECoreStickerProtocol> stickerEditor;

@end

@implementation DVEStickerEditorWrapper

@synthesize vcContext = _vcContext;

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if (self = [super init]) {
        _vcContext = context;
        _stickerEditor = [[DVEStickerEditor alloc] initWithContext:context];
    }
    return self;
}

#pragma mark - DVECoreStickerProtocol

- (NLETrackSlot_OC *)addNewRandomPositionImageSitckerWithPath:(NSString *)path
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.stickerEditor addNewRandomPositionImageSitckerWithPath:path];
}

- (NLETrackSlot_OC *)addStickerWithPath:(NSString *)path
                             identifier:(NSString *)identifier
                                iconURL:(NSString *)iconURL
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.stickerEditor addStickerWithPath:path identifier:identifier iconURL:iconURL];
}

- (void)setSticker:(NSString *)segmentId
           offsetX:(CGFloat)x
           offsetY:(CGFloat)y
             angle:(CGFloat)angle
             scale:(CGFloat)scale
       isCommitNLE:(BOOL)iscommit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.stickerEditor setSticker:segmentId offsetX:x offsetY:y angle:angle scale:scale isCommitNLE:iscommit];
}

- (void)setSticker:(NSString *)segmentId startTime:(CGFloat)startTime duration:(CGFloat)duration
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.stickerEditor setSticker:segmentId startTime:startTime duration:duration];
}

- (void)setStickerFilpX:(NSString *)segmentId
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.stickerEditor setStickerFilpX:segmentId];
}

- (NSArray<NLETrackSlot_OC *> *)stickerSlots
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.stickerEditor stickerSlots];
}

- (NSArray<NLETrackSlot_OC *> *)textSlots
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.stickerEditor textSlots];
}

- (NSString *)addNewRandomPositonTextSticker
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.stickerEditor addNewRandomPositonTextSticker];
}

- (NSString *)addNewRandomPositionTextStickerForVideoCover:(NLEVideoFrameModel_OC *)coverModel
                                                 startTime:(CGFloat)startTime
                                                  duration:(CGFloat)duration
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.stickerEditor addNewRandomPositionTextStickerForVideoCover:coverModel startTime:startTime duration:duration];
}

- (void)changeTextSitckerHorOrVer:(NSString *)segId
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.stickerEditor changeTextSitckerHorOrVer:segId];
}

- (void)changeTextBubbleHorOrVer:(NSString *)segId
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.stickerEditor changeTextBubbleHorOrVer:segId];
}

- (void)updateTextStickerWithParm:(DVETextParm *)parm
                        segmentID:(NSString *)segId
                         isCommit:(BOOL)commit
                       isMainEdit:(BOOL)mainEdit
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.stickerEditor updateTextStickerWithParm:parm segmentID:segId isCommit:commit isMainEdit:mainEdit];
}

- (NSDictionary *)convertTextParamToDic:(DVETextParm *)parm
                                   slot:(NLETrackSlot_OC *)slot
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return [self.stickerEditor convertTextParamToDic:parm slot:slot];
}

/// 当前样式
- (NLEStyleText_OC *)currentStyle
{
    DVELogReport(@"EditorCoreFunctionCalled");
    return self.stickerEditor.currentStyle;
}

#if ENABLE_SUBTITLERECOGNIZE
- (void)insertAutoSubtitle:(DVESubtitleQueryModel *)subtitleQueryModel
          coverOldSubtitle:(BOOL)coverOldSubtitle
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.stickerEditor insertAutoSubtitle:subtitleQueryModel coverOldSubtitle:coverOldSubtitle];
}
#endif

- (void)setKeyFrameDelegate:(id<DVEStickerKeyFrameProtocol>)keyFrameDelegate {
    self.stickerEditor.keyFrameDelegate = keyFrameDelegate;
}

- (id<DVEStickerKeyFrameProtocol>)keyFrameDelegate {
    return self.stickerEditor.keyFrameDelegate;
}

@end
