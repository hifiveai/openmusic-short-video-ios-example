//
//   DVEStickerEditor.m
//   NLEEditor
//
//   Created  by bytedance on 2021/4/26.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEStickerEditor.h"
#import "DVEVCContext.h"
#import "NSDictionary+DVE.h"
#import "DVECustomerHUD.h"
#import "NSString+DVE.h"
#import "NSString+VEIEPath.h"
#import "DVETextParm.h"
#import "DVEMacros.h"
#import "DVELoggerImpl.h"
#import "NLESegmentTextSticker_OC+Text.h"
#import <NLEPlatform/NLEStyleText+iOS.h>
#import <DVETrackKit/DVETrackConfig.h>
#import <DVETrackKit/NLETrack_OC+NLE.h>
#import <DVETrackKit/NLEModel_OC+NLE.h>
#import <DVETrackKit/NLEResourceNode_OC+Meepo.h>
#import <DVETrackKit/NLEVideoFrameModel_OC+NLE.h>
#import <NLEPlatform/NLESegmentInfoSticker+iOS.h>


@interface DVEStickerEditor() <NLEKeyFrameCallbackProtocol>

@property (nonatomic, weak) id<DVECoreDraftServiceProtocol> draftService;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVECoreSlotProtocol> slotEditor;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVECoreKeyFrameProtocol> keyFrameEditor;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@end

@implementation DVEStickerEditor

@synthesize vcContext = _vcContext;
@synthesize keyFrameDelegate = _keyFrameDelegate;

DVEAutoInject(self.vcContext.serviceProvider, slotEditor, DVECoreSlotProtocol)
DVEAutoInject(self.vcContext.serviceProvider, draftService, DVECoreDraftServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEAutoInject(self.vcContext.serviceProvider, keyFrameEditor, DVECoreKeyFrameProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if(self = [super init]) {
        self.vcContext = context;
        [self.nle addKeyFrameListener:self];
    }
    
    return self;
}



- (NLETrackSlot_OC *)addNewRandomPositionImageSitckerWithPath:(NSString *)path {
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    NSString *relativePath = [self copyImage:image fromPath:path];
    
    uint32_t randomX = arc4random_uniform(300);
    int32_t aRandom =  randomX - 150;
    CGFloat x = aRandom / 200.f;
    UInt32 randomY = arc4random_uniform(200);
    aRandom = randomY - 100;
    CGFloat y = aRandom / 300.f;
    
    CMTime duration = CMTimeMake(3.0f * USEC_PER_SEC, USEC_PER_SEC);
    
    NLEResourceNode_OC *node = [[NLEResourceNode_OC alloc] init];
    [node setResourceFile:relativePath];
    [node setResourceType:NLEResourceTypeImage];
    [node setResourceId:@"0"];
    NSString *destPath = [self.draftService.currentDraftPath stringByAppendingPathComponent:relativePath];
    node.mp_iconUrlStr = destPath;
    
    NLESegmentImageSticker_OC *segment = [[NLESegmentImageSticker_OC alloc] init];
    [segment setImageFile:node];
    
    NLETrackSlot_OC *stickerSlot = [self.slotEditor addSlot:NLETrackSTICKER
                                               resourceType:NLEResourceTypeSticker
                                                    segment:segment
                                                  startTime:self.vcContext.mediaContext.currentTime
                                                   duration:duration];
    stickerSlot.transformX = x;
    stickerSlot.transformY = y;
    //图片贴纸的scale默认要取小一些
    stickerSlot.scale = 0.4;
    
    @weakify(self);
    [self.actionService commitNLE:YES completion:^(NSError * _Nullable error) {
        @strongify(self);
        CMTime seekTime = CMTimeAdd(self.vcContext.mediaContext.currentTime, DVETrackConfig.timePerFrame);
        [self.vcContext.playerService seekToTime:seekTime isSmooth:NO];;
    }];
    
    return stickerSlot;
}

- (NLETrackSlot_OC *)addStickerWithPath:(NSString *)path
                             identifier:(NSString *)identifier
                                iconURL:(NSString *)iconURL
{
    NSAssert(identifier, @"资源唯一标识identifier为空");
    NSString *relativePath = [self copyPathToDraft:path];
    NSString *relativeIconPath = iconURL;
    if (![iconURL hasPrefix:@"http"]) {
        [self copyPathToDraft:iconURL];
    }
    
    CMTime duration = CMTimeMake(3.0f * USEC_PER_SEC, USEC_PER_SEC);
    
    NLEResourceNode_OC *node = [[NLEResourceNode_OC alloc] init];
    [node setResourceFile:relativePath];
    [node setResourceType:NLEResourceTypeSticker];
    [node setResourceId:identifier];
    node.mp_iconUrlStr = relativeIconPath;
    
    NLESegmentInfoSticker_OC *segment = [[NLESegmentInfoSticker_OC alloc] init];
    [segment setEffectSDKFile:node];
    
    NLETrackSlot_OC *stickerSlot = [self.slotEditor addSlot:NLETrackSTICKER
                                               resourceType:NLEResourceTypeSticker
                                                    segment:segment
                                                  startTime:self.vcContext.mediaContext.currentTime
                                                   duration:duration];
    
    @weakify(self);
    [self.actionService commitNLE:YES completion:^(NSError * _Nullable error) {
        @strongify(self);
        CMTime seekTime = CMTimeAdd(self.vcContext.mediaContext.currentTime, DVETrackConfig.timePerFrame);
        [self.vcContext.playerService seekToTime:seekTime isSmooth:NO];;
    }];
    
    self.vcContext.mediaContext.selectTextSlotAtCurrentTime = stickerSlot;
    
    return stickerSlot;
}

// 编辑一个贴纸transform
- (void)setSticker:(NSString *)segmentId
           offsetX:(CGFloat)x
           offsetY:(CGFloat)y
             angle:(CGFloat)angle
             scale:(CGFloat)scale
       isCommitNLE:(BOOL)iscommit
{
    NLETrackSlot_OC *slot =  [self.nleEditor.nleModel slotOf:segmentId];
    if (!slot) {
        slot = [self.nleEditor.nleModel.coverModel slotOf:segmentId];
    }
    if (!slot) {
        return;
    }
    slot.transformX = x;
    slot.transformY = y;
    slot.scale = scale;
    slot.rotation = -angle;
    
    [slot addOrUpdateKeyframe:CMTimeMake(self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC, USEC_PER_SEC)
                   timeRange:[self.keyFrameEditor currentKeyframeTimeRange] forceAdd:NO];
    [self.actionService commitNLE:iscommit];
}

- (void)setStickerFilpX:(NSString *)segmentId  {
    
    NLETrackSlot_OC *slot =  [self.nleEditor.nleModel slotOf:segmentId];
    if (!slot) {
        slot = [self.nleEditor.nleModel.coverModel slotOf:segmentId];
    }
    if (!slot) {
        return;
    }
    
    BOOL flipX = slot.Mirror_X ? NO : YES;
    BOOL flipY = NO;
    
    slot.Mirror_X = flipX ? 1 : 0;
    slot.Mirror_Y = flipY ? 1 : 0;
    [self.actionService commitNLE:YES];
}

- (void)setSticker:(NSString *)segmentId startTime:(CGFloat)startTime duration:(CGFloat)duration {
    
    NLETrackSlot_OC *slot =  [self.nleEditor.nleModel slotOf:segmentId];
    if (!slot) {
        slot = [self.nleEditor.nleModel.coverModel slotOf:segmentId];
    }
    if (!slot) {
        return;
    }
    slot.startTime = CMTimeMake(startTime * USEC_PER_SEC, USEC_PER_SEC);
    slot.duration = CMTimeMake(duration * USEC_PER_SEC, USEC_PER_SEC);
    [self.actionService commitNLE:YES];
}

- (NLETrack_OC *)textTrackForTextStickerWithStartTime:(CGFloat)startTime
                                             duration:(CGFloat)duration {
    NSString *text = NLELocalizedString(@"ck_enter_text", @"输入文字");
    NSDictionary *params = @{
        @"version": @"1",
        @"text": text,
        @"background": @YES,
        @"fontSize": @15,
        @"fontPath": @"", // 字体路径
        @"effectPath": @"", // 花字路径
        @"useEffectDefaultColor": @YES,
        @"shapePath": @"", // 气泡路径
        @"textColor": @[@1,@1,@1,@1],
        @"backgroundColor": @[@0,@0,@0,@0],
        @"outlineColor":@[@0,@0,@0,@0],
        @"shadowColor":@[@0,@0,@0,@0],
        @"underlineWidth":@(0.05),
        @"lineMaxWidth":@(-1),
        @"lineGap": @(0.1),
        @"boldWidth":@(0),
        @"italicDegree":@(0),
        @"underlineOffset": @(0.22),
        @"innerPadding":@(0.18),
        @"alignType":@(1),
        @"shadow":@(YES),
        @"charSpacing":@(0),
        @"outline":@(YES),
        @"underline":@(NO),
        @"typeSettingKind":@(0)
    };
    
    CGFloat endTime = startTime + duration;
    
    NLETrack_OC *textTrack = [[NLETrack_OC alloc] init];
    textTrack.extraTrackType = NLETrackSTICKER;
    textTrack.nle_extraResourceType = NLEResourceTypeTextSticker;
    
    NLEStyleText_OC *styleText = [NLEStyleText_OC textStyleWithJSONString:params.dve_toJsonString];
    NLESegmentTextSticker_OC *segment = [[NLESegmentTextSticker_OC alloc] init];;
    segment.style = styleText;
    segment.content = params[@"text"];
    
    NLETrackSlot_OC *textSlot = [[NLETrackSlot_OC alloc] init];
    textSlot.startTime = CMTimeMake(startTime * USEC_PER_SEC, USEC_PER_SEC);
    textSlot.endTime = CMTimeMake(endTime * USEC_PER_SEC, USEC_PER_SEC);
    textSlot.duration = CMTimeMake(duration * USEC_PER_SEC, USEC_PER_SEC);
    textSlot.segment = segment;
    
    [textTrack addSlot:textSlot];
    return textTrack;
}

// 添加一个随机位置的文字贴纸
- (NSString *)addNewRandomPositonTextSticker
{
    CGFloat startTime = CMTimeGetSeconds(self.vcContext.mediaContext.currentTime);
    NLETrack_OC *textTrack = [self textTrackForTextStickerWithStartTime:startTime duration:3];
    
    NLEModel_OC *model = self.nleEditor.nleModel;
    textTrack.layer = (int)([model nle_getMaxTrackLayer:NLETrackSTICKER] + 1);
    [model addTrack:textTrack];
    
    @weakify(self);
    [self.actionService commitNLE:NO completion:^(NSError * _Nullable error) {
        @strongify(self);
        CMTime seekTime = CMTimeAdd(self.vcContext.mediaContext.currentTime, DVETrackConfig.timePerFrame);
        [self.vcContext.playerService seekToTime:seekTime isSmooth:NO];;
    }];
    
    NLETrackSlot_OC *textSlot = [[textTrack slots] firstObject];
    self.vcContext.mediaContext.selectTextSlotAtCurrentTime = textSlot;

    return [textSlot nle_nodeId];
}

- (NSString *)addNewRandomPositionTextStickerForVideoCover:(NLEVideoFrameModel_OC *)coverModel
                                                 startTime:(CGFloat)startTime
                                                  duration:(CGFloat)duration {
    NLETrack_OC *textTrack = [self textTrackForTextStickerWithStartTime:startTime duration:duration];
    NLETrackSlot_OC *textSlot = [[textTrack slots] firstObject];
    
    textTrack.layer = (int)([coverModel nle_getMaxTrackLayer:NLETrackSTICKER] + 1);
    [coverModel addTrack:textTrack];
    
    @weakify(self);
    [self.actionService commitNLE:NO completion:^(NSError * _Nullable error) {
        @strongify(self);
        CMTime seekTime = CMTimeAdd(self.vcContext.mediaContext.currentTime, DVETrackConfig.timePerFrame);
        [self.vcContext.playerService seekToTime:seekTime isSmooth:NO];;
    }];
    return [textSlot nle_nodeId];
}

- (void)updateTextStickerWithParm:(DVETextParm *)parm
                        segmentID:(NSString *)segId
                         isCommit:(BOOL)commit
                       isMainEdit:(BOOL)mainEdit {
    NLETrackSlot_OC *slot = nil;
    if (mainEdit) {
        slot = [self.nleEditor.nleModel slotOf:segId];
    } else {
        slot = [self.nleEditor.nleModel.coverModel slotOf:segId];
    }
    
    if (!slot) {
        return;
    }
    
    NSDictionary *params = [self convertTextParamToDic:parm slot:slot];
    
    // 记录到NLE
    NSString *text = [params valueForKey:@"text"];

    NLEStyleText_OC *styleText = [NLEStyleText_OC textStyleWithJSONString:params.dve_toJsonString];
    
    if (styleText.flower.resourceFile.length > 0) {
        NSString *relativePath = [self.draftService copyResourceToDraft:[NSURL fileURLWithPath:styleText.flower.resourceFile] resourceType:NLEResourceTypeFlower];
        styleText.flower.resourceFile = relativePath;
    }
    if (styleText.font.resourceFile.length > 0) {
        NSString *str = styleText.font.resourceFile;
        // 可能经过url编码，所以使用stringByRemovingPercentEncoding去掉
        NSURL *url = [NSURL fileURLWithPath:str.stringByRemovingPercentEncoding];
        NSString *relativePath = [self.draftService copyResourceToDraft:url resourceType:NLEResourceTypeFont];
        styleText.font.resourceFile = relativePath;
    }
    
    //设置了花字同时字体颜色还是默认的
    if (styleText.flower.resourceFile.length > 0 && [self p_isTextColorChangedWithParam:params]) {
        styleText.useFlowerDefaultColor = YES;
    } else {
        styleText.useFlowerDefaultColor = NO;
    }
    
    NLESegmentTextSticker_OC *segment = (NLESegmentTextSticker_OC *)slot.segment;
    segment.alpha = parm.alpha;
    segment.style = styleText;
    segment.content = VEOptionsStringValue(text, @"");
    
    [slot addOrUpdateKeyframe:CMTimeMake(self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC, USEC_PER_SEC)
                   timeRange:[self.keyFrameEditor currentKeyframeTimeRange] forceAdd:NO];
    [self.actionService commitNLE:commit];
}


- (BOOL)p_isTextColorChangedWithParam:(NSDictionary *)params {
    NSArray *textColor = [params objectForKey:@"textColor"];
    NSArray *backgroundColor = [params objectForKey:@"backgroundColor"];
    NSArray *outlineColor = [params objectForKey:@"outlineColor"];
    NSArray *shadowColor = [params objectForKey:@"shadowColor"];
    
    NSArray *defaultTextColor = @[@1, @1, @1, @1];
    NSArray *defaultParamColor = @[@0, @0, @0, @0];
    
    return [textColor isEqualToArray:defaultTextColor] && [backgroundColor isEqualToArray:defaultParamColor] && [outlineColor isEqualToArray:defaultParamColor] && [shadowColor isEqualToArray:defaultParamColor];
}

- (void)changeTextSitckerHorOrVer:(NSString *)segId {
    NLETrackSlot_OC *slot = [self.nleEditor.nleModel slotOf:segId];
    if (!slot) {
        slot = [self.nleEditor.nleModel.coverModel slotOf:segId];
    }
    if (!slot) {
        return;
    }
    NLESegmentTextSticker_OC *textSeg = (NLESegmentTextSticker_OC *)slot.segment;
    NLEStyleText_OC *style =  textSeg.style;
    
    style.typeSettingKind = style.typeSettingKind ? 0 : 1;
    [self.actionService commitNLE:YES];
}
/// 翻转气泡
- (void)changeTextBubbleHorOrVer:(NSString *)segId {
    NLETrackSlot_OC *slot =  [self.nleEditor.nleModel slotOf:segId];
    if (!slot) {
        slot = [self.nleEditor.nleModel.coverModel slotOf:segId];
    }
    if (!slot) {
        return;
    }
    NLESegmentTextSticker_OC *textSeg = (NLESegmentTextSticker_OC *)slot.segment;
    NLEStyleText_OC *style =  textSeg.style;
    // 气泡如何翻转，好像每次只改一个变量
//    style.shapeFlipX = true;
//    style.shapeFlipY = true;
    [self.actionService commitNLE:YES];
}


- (NSDictionary *)convertTextParamToDic:(DVETextParm *)parm
                                   slot:(NLETrackSlot_OC *)slot;
{
    NLESegmentTextSticker_OC *textSeg = (NLESegmentTextSticker_OC *) slot.segment;
    NLEStyleText_OC *style = textSeg.style;
    
    
    if (!style) {
        return nil;
    }
    NSString *fontPath = parm.font.sourcePath;
    if(!fontPath){
        fontPath = @"";
    }
    NSString *text = nil;
    if (parm.text ) {
        text = parm.text.length ? parm.text : NLELocalizedString(@"ck_enter_text", @"输入文字") ;
    } else if (textSeg.content) {
        text = textSeg.content;
    } else {
        text = NLELocalizedString(@"ck_enter_text", @"输入文字");
    }
    NSArray *textColor = nil;
    if (parm.textColor) {
        textColor = parm.textColor;
    } else if (style.textColor) {
        textColor = [style getTextColors];
    } else {
        textColor = @[@1,@1,@1,@1];
    }
    NSArray *outlineColor = nil;
    if (parm.outlineColor) {
        outlineColor = parm.outlineColor;
    } else if (style.outlineColor) {
        outlineColor = [style getOutlineColors];;
    } else {
        outlineColor = @[@0,@0,@0,@0];
    }
    
    NSArray *backgroundColor = nil;
    if (parm.backgroundColor) {
        backgroundColor = parm.backgroundColor;
    } else if (style.backgroundColor) {
        backgroundColor = [style getBackgourndColors];
    } else {
        backgroundColor = @[@0,@0,@0,@0];
    }
    
    NSInteger alignType = [parm.alignment.alignType intValue];
    
//    if (style.typeSettingKind == 0) {
//        if (parm.alignment.alignType) {
//            alignType = parm.alignment.alignType.integerValue;
//        } else if (style.alignType) {
//            alignType = style.alignType;
//        } else {
//            alignType = 1;
//        }
//
//    } else {
//        if (parm.alignment.alignType) {
//            alignType = parm.alignment.alignType.integerValue;
//        } else if (style.alignType) {
//            alignType = style.alignType;
//        } else {
//            alignType = 1;
//        }
//
//        if (alignType == 0) {
//            alignType = 3;
//        }
//
//        if (alignType == 2) {
//            alignType = 4;
//        }
//    }
    
    NSMutableDictionary *params = [@{
        @"version": @"1",
        @"text": text,
        @"background": parm.backgroundColor.count > 0 ? @YES : @NO,
        @"fontSize": @(style.fontSize),
        @"fontPath": fontPath ?: @"", // 字体路径
        @"effectPath": style.flower.resourceFile ?: @"", // 花字路径
        @"useEffectDefaultColor": @(parm.useEffectDefaultColor),
        @"shapePath": style.shape.resourceFile ?: @"", // 气泡路径
        @"textColor": textColor,
        @"backgroundColor": backgroundColor,
        @"outlineColor":outlineColor,
        @"underlineWidth":@(0.05),
        @"lineMaxWidth":@(-1),
        @"lineGap": parm.lineGap > 0 ? @(parm.lineGap) : @(0.1),
        @"boldWidth":@(parm.boldWidth),
        @"italicDegree":@(parm.italicDegree),
        @"underlineOffset": @(0.22),
        @"innerPadding":@(0.18),
        @"charSpacing":parm.charSpacing > 0 ? @(parm.charSpacing) : @(0),
        @"alignType":@(alignType),
        @"outline":parm.outlineColor.count > 0 ? @YES : @NO,
        @"outlineWidth" : @(parm.outlineWidth),
        @"underline":@(parm.underline),
        @"typeSettingKind":@(parm.typeSettingKind),
        
    } mutableCopy];
    
    // 阴影
    params[@"shadow"] = @(YES);
    params[@"shadowSmoothing"] = @(parm.shadowSmoothing);
    if (parm.shadowOffset.count > 0) {
        params[@"shadowOffset"] = parm.shadowOffset;
    }
    BOOL hasShadowColor = parm.shadowColor.count > 0;
    if (hasShadowColor) {
        params[@"shadowColor"] = parm.shadowColor;
    } else {
        params[@"shadowColor"] = @[@(0), @(0), @(0), @(0)];
    }
    
    return [params copy];
}

- (void)deleteCurrentSelectText
{
    if (self.vcContext.mediaContext.selectTextSlot) {
        [self.nleEditor.nleModel nle_removeSlots:@[self.vcContext.mediaContext.selectTextSlot.nle_nodeId] inTrackType:NLETrackSTICKER];
        [self.actionService commitNLE:YES];
    }
}

-(NSArray<NLETrackSlot_OC *> *)stickerSlots{
    NSMutableArray<NLETrackSlot_OC *> *stickerSlots = [NSMutableArray array];
    NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel nle_allTracksOfType:NLETrackSTICKER];
    for (NLETrack_OC *track in tracks) {
        NSArray<NLETrackSlot_OC *> *slots = track.slots;
        for (NLETrackSlot_OC *slot in slots) {
            if ([slot.segment isKindOfClass:NLESegmentInfoSticker_OC.class] || [slot.segment isKindOfClass:[NLESegmentImageSticker_OC class]]) {
                [stickerSlots addObject:slot];
            }
        }
    }
    
    return [stickerSlots copy];
}

-(NSArray<NLETrackSlot_OC *> *)textSlots {
    NSMutableArray<NLETrackSlot_OC *> *textStickerSlots = [NSMutableArray array];
    NSMutableArray<NLETrack_OC *> *tracks = [NSMutableArray array];
    //当前处于视频编辑页面
    if (self.nleEditor.nleModel.coverModel.enable) {
        [tracks addObjectsFromArray:[self.nleEditor.nleModel.coverModel nle_allTracksOfType:NLETrackSTICKER]];
    } else {
        [tracks addObjectsFromArray:[self.nleEditor.nleModel nle_allTracksOfType:NLETrackSTICKER]];
    }

    for (NLETrack_OC *track in tracks) {
        NSArray<NLETrackSlot_OC *> *slots = track.slots;
        for (NLETrackSlot_OC *slot in slots) {
            if ([slot.segment isKindOfClass:NLESegmentTextSticker_OC.class]) {
                [textStickerSlots addObject:slot];
            }
        }
    }
    
    return [textStickerSlots copy];
}

#if ENABLE_SUBTITLERECOGNIZE
- (void)insertAutoSubtitle:(DVESubtitleQueryModel *)subtitleQueryModel coverOldSubtitle:(BOOL)coverOldSubtitle
{
    if (subtitleQueryModel.captions.count == 0) {
        return;
    }
    NLEModel_OC *model = self.nleEditor.nleModel;
    // 如果覆盖，则先删除所有之前添加的自动字幕
    if (coverOldSubtitle) {
        NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel nle_allTracksOfType:NLETrackSTICKER];
        for (NLETrack_OC *track in tracks) {
            NSArray<NLETrackSlot_OC *> *slots = track.slots;
            for (NLETrackSlot_OC *slot in slots) {
                NSString *resourceStr = [slot.segment getExtraForKey:@"isAutoSubtitle"];
                if ([resourceStr isEqualToString:@"1"]) {
                    [track removeSlot:slot];
                }
            }
        }
        [self.nleEditor.nleModel nle_removeLastEmptyTracksForType:NLETrackSTICKER];
    }
    
    // 寻找已存在的自动字幕轨道
    NLETrack_OC *textTrack = nil;
    NSArray<NLETrack_OC *> *tracks = [model nle_allTracksOfType:NLETrackSTICKER];
    for (NLETrack_OC *track in tracks) {
        NSString *isAutoSubtitle = [track getExtraForKey:@"isAutoSubtitle"];
        if ([isAutoSubtitle isEqualToString:@"1"]) {
            textTrack = track;
        }
    }
    
    if (!textTrack) {
        textTrack = [[NLETrack_OC alloc] init];
        textTrack.extraTrackType = NLETrackSTICKER;
        textTrack.nle_extraResourceType = NLEResourceTypeTextSticker;
        textTrack.layer = (int)([model nle_getMaxTrackLayer:NLETrackSTICKER] + 1);
        [textTrack setExtra:@"1" forKey:@"isAutoSubtitle"];
        [model addTrack:textTrack];
    }
    
    for (DVESubtitleSentenceModel *sentence in subtitleQueryModel.captions) {
        CMTime startTime = CMTimeMake(sentence.startTime, NSEC_PER_USEC);
        CMTime duration = CMTimeMake(sentence.endTime - sentence.startTime, NSEC_PER_USEC);
        CMTimeRange targetTimeRange = CMTimeRangeMake(startTime, duration);
        BOOL canInsert = YES;
        
        // 如果轨道上对应时间区间内有了贴纸，则不插入新的
        for (NLETrackSlot_OC *slot in textTrack.slots) {
            if (!CMTIMERANGE_IS_EMPTY(CMTimeRangeGetIntersection(targetTimeRange, slot.nle_targetTimeRange))) {
                canInsert = NO;
                break;
            }
        }
        
        if (canInsert) {
            NLEStyleText_OC *styleText = [[NLEStyleText_OC alloc] init];
            //默认15pt 白色字 黑色描边
            styleText.fontSize = 15;
            styleText.textColor = 0xffffffff;
            styleText.outline = 0xff000000;
            NLESegmentTextSticker_OC *segment = [[NLESegmentTextSticker_OC alloc] init];;
            segment.style = styleText;
            segment.content = sentence.text;
            
            if(self.nleEditor.nleModel.canvasRatio > 1)
            {///横屏画布比例，一行最多18个字，插入换行符
                segment.content = [segment adjustContent:18];
            }
            else{///竖画布比例，一行最多10个字，插入换行符
                segment.content = [segment adjustContent:10];
            }
            
            [segment setExtra:@"1" forKey:@"isAutoSubtitle"];
            
            NLETrackSlot_OC *textSlot = [[NLETrackSlot_OC alloc] init];
            textSlot.startTime = startTime;
            textSlot.endTime = CMTimeMake(sentence.endTime, NSEC_PER_USEC);
            textSlot.segment = segment;
            textSlot.transformY = 2.0 * 0.22 - 1.0;
            
            [textTrack addSlot:textSlot];
        }
    }
    
    [self.actionService commitNLE:YES];
}

#endif
- (NSString *)copyImage:(UIImage *)image fromPath:(NSString *)fromPath
{
    NSString *relativePath = [self getTargetDraftRelativePathForResourcePath:fromPath];
    if (relativePath.pathExtension.length <= 0) {
        relativePath = [relativePath stringByAppendingString:@".jpeg"];
    }
    NSString *destPath = [self.draftService.currentDraftPath stringByAppendingPathComponent:relativePath];
    [UIImageJPEGRepresentation(image, 1) writeToFile:destPath atomically:YES];
    return relativePath;
}

- (NSString *)getTargetDraftRelativePathForResourcePath:(NSString *)path
{
    // copy resource
    NSError *error = nil;
    NSString *relativePath = [@"sticker" stringByAppendingPathComponent:path.lastPathComponent];
    NSString *stickerPath = [self.draftService.currentDraftPath stringByAppendingPathComponent:@"sticker"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:stickerPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:stickerPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    if (error) {
        DVELogError(@"create file directory error:%@", error);
    }
    
    return relativePath;
}

- (NSString *)copyPathToDraft:(NSString *)path
{
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    NSAssert(isFileExist, @"sticker resource path is invaild!!!");
    
    // copy resource
    NSError *error = nil;
    NSString *relativePath = [@"sticker" stringByAppendingPathComponent:path.lastPathComponent];
    NSString *stickerPath = [self.draftService.currentDraftPath stringByAppendingPathComponent:@"sticker"];
    NSString *destPath = [self.draftService.currentDraftPath stringByAppendingPathComponent:relativePath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:stickerPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:stickerPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    if (error) {
        DVELogError(@"create file directory error:%@", error);
    }
    
    [[NSFileManager defaultManager] copyItemAtPath:path toPath:destPath error:&error];
    if (error) {
        DVELogError(@"copy resource error:%@", error);
    }
    return relativePath;
}

- (NLEStyleText_OC *)currentStyle {
    NLESegment_OC *seg = self.vcContext.mediaContext.selectTextSlot.segment;
    if (![seg isKindOfClass:NLESegmentTextSticker_OC.class]) {
        return nil;
    }
    return [(NLESegmentTextSticker_OC *)seg style];
}

#pragma mark - KeyFrame Private

- (BOOL)isStyleTextChangedForKeyFrame:(NLEStyleText_OC *)style
                            prevStyle:(NLEStyleText_OC *)prevStyle {
    //以下关键帧属性改变时才addOrUpdate关键帧
    return (style.outlineWidth != prevStyle.outlineWidth ||
            style.shadowSmoothing != prevStyle.shadowSmoothing ||
            style.shadowOffsetX != prevStyle.shadowOffsetX ||
            style.shadowOffsetY != prevStyle.shadowOffsetY ||
            style.textColor != prevStyle.textColor ||
            style.backgroundColor != prevStyle.backgroundColor ||
            style.shadowColor != prevStyle.shadowColor ||
            style.outlineColor != prevStyle.outlineColor);
}

#pragma mark - NLEKeyFrameCallbackProtocol

- (void)nleDidChangedWithPTS:(CMTime)time keyFrameInfo:(NLEAllKeyFrameInfo *)info {
    
    if (!self.vcContext.mediaContext.selectTextSlot) {
        return;
    }

    NLETrackSlot_OC *stickerSlot = [self.nle refreshAllKeyFrameInfo:info pts:self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC inSlot:self.vcContext.mediaContext.selectTextSlot];
    
    if (self.keyFrameDelegate &&
        [self.keyFrameDelegate respondsToSelector:@selector(stickerKeyFrameDidChangedWithSlot:)]) {
        [self.keyFrameDelegate stickerKeyFrameDidChangedWithSlot:stickerSlot];
    }
}

@end
