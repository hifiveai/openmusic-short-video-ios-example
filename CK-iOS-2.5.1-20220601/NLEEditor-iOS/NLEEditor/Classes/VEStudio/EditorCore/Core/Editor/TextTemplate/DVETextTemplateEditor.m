//
//  DVETextTemplateEditor.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/23.
//

#import "DVETextTemplateEditor.h"
// model
// mgr
#import "DVEComponentViewManager.h"
// view

// support
#import <DVETrackKit/NLETrack_OC+NLE.h>
#import "DVEMacros.h"
#import "DVETextTemplateDepResourceModelProtocol.h"
#import <DVETrackKit/DVETrackConfig.h>

@interface DVETextTemplateEditor ()

@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@end

@implementation DVETextTemplateEditor

@synthesize vcContext = _vcContext;
@synthesize trackSlot = _trackSlot;

DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

// MARK: - Initialization

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if(self = [super init]) {
        self.vcContext = context;
    }
    return self;
}

// MARK: Public

- (void)setSticker:(NSString *)segmentId startTime:(CGFloat)startTime duration:(CGFloat)duration {
    NLETrackSlot_OC *slot =  [self.nleEditor.nleModel slotOf:segmentId];
    if (!slot) return;
    slot.startTime = CMTimeMake(startTime * USEC_PER_SEC, USEC_PER_SEC);
    slot.duration = CMTimeMake(duration * USEC_PER_SEC, USEC_PER_SEC);
    [self.actionService commitNLE:YES];
}

- (void)updateText:(NSString *)text atIndex:(NSUInteger)index isCommit:(BOOL)commit {
    NLETrackSlot_OC *slot = self.vcContext.mediaContext.selectTextSlot;
    if (!slot) return;
        
    if (![slot.segment isKindOfClass:[NLESegmentTextTemplate_OC class]]) {
        return;
    }
    
    NLESegmentTextTemplate_OC *textTemplate = (NLESegmentTextTemplate_OC *)slot.segment;
    
    [self p_updateText:text atIndex:index forTextTemplate:textTemplate];
    [self.actionService commitNLE:commit];
    // 预览模板
    [self.nle setStickerPreviewMode:slot previewMode:4];
}

- (NSString*)replaceTemplateAtSlot:(NLETrackSlot_OC *)slot
                          startTime:(Float64)startTime
                            endTime:(Float64)endTime
                               path:(NSString *)path
                        depResModels:(NSArray<DVETextTemplateDepResourceModelProtocol> *)depResModels
                            commit:(BOOL)commit
                          completion:(nullable void(^)(void))completion {
    Float64 resDuration = endTime - startTime;
    NLESegmentTextTemplate_OC *segment = [self p_makeSegmentWithPath:path
                               resDuration:resDuration
                              depResModels:depResModels];
    [slot setSegmentTextTemplate:segment];
    return [self p_addTemplateWithSlot:slot segment:segment commit:NO completion:completion];
}

- (NSString*)addTemplateWithPath:(NSString *)path
                    depResModels:(NSArray<DVETextTemplateDepResourceModelProtocol> *)depResModels
                      needCommit:(BOOL)commit
                      completion:(nullable void(^)(void))completion {
    NSInteger resDuration = 3;
    // TODO: 初始化segment部分，建议换成 p_makeSegmentWithPath
    // 资源
    NLEResourceNode_OC *resEffect = [[NLEResourceNode_OC alloc] init];
    resEffect.resourceId = [[NSUUID UUID] UUIDString];
    resEffect.resourceFile = path;
    resEffect.resourceType = NLEResourceTypeTextTemplate;
    resEffect.resourceTag = NLEResourceTagNormal;
    resEffect.duration = CMTimeMakeWithSeconds(resDuration, USEC_PER_SEC);
    
    // 添加资源依赖：字体
    NSMutableArray *mFonts = [[NSMutableArray alloc] initWithCapacity:depResModels.count];
    for (id<DVETextTemplateDepResourceModelProtocol> m in depResModels) {
        NLEResourceNode_OC *tmp = [[NLEResourceNode_OC alloc] init];
        tmp.resourceId = m.resourceId;
        tmp.resourceFile = m.path;
        [mFonts addObject:tmp];
    }
    
    // 初始化 segment
    NLESegmentTextTemplate_OC *segment = [[NLESegmentTextTemplate_OC alloc] init];
    [segment setEffectSDKFile:resEffect];
    segment.fontResList = mFonts;
    
    
    // 初始化 slot
    CMTime currentTime = self.vcContext.mediaContext.currentTime;
    CMTime startTime = CMTimeMake(CMTimeGetSeconds(currentTime) * USEC_PER_SEC, USEC_PER_SEC);
    NSInteger endSecond = MIN((CMTimeGetSeconds(currentTime) + resDuration), CMTimeGetSeconds(self.vcContext.mediaContext.duration));
    CMTime endTime = CMTimeMake(endSecond * USEC_PER_SEC, USEC_PER_SEC);
    
    int32_t layer = (int32_t)([self.nleEditor.nleModel nle_getMaxEffectLayer] + 1);
    
    NLETrackSlot_OC *textSlot = [[NLETrackSlot_OC alloc] init];
    textSlot.startTime = startTime;
    textSlot.endTime = endTime;
    textSlot.duration = CMTimeMakeWithSeconds(resDuration, USEC_PER_SEC);
    textSlot.layer = MAX(0, layer);
    [textSlot setSegmentTextTemplate:segment];
    
    return [self addTemplateWithSeg:segment
                               slot:textSlot
                         needCommit:commit
                         completion:completion];
}

/// 将 segment 与 slot 联系起来，并调用 NLE 接口
- (NSString *)addTemplateWithSeg:(NLESegmentTextTemplate_OC *)segment
                            slot:(NLETrackSlot_OC *)slot
                      needCommit:(BOOL)commit
                      completion:(nullable void(^)(void))completion {
    if (!segment || !slot) {
        return nil;
    }

    NLEModel_OC *model = self.nleEditor.nleModel;
    NLETrack_OC *textTrack = [[NLETrack_OC alloc] init];
    textTrack.extraTrackType = NLETrackSTICKER;
    textTrack.nle_extraResourceType = NLEResourceTypeTextTemplate;
    textTrack.layer = (int)([model nle_getMaxTrackLayer:NLETrackSTICKER] + 1);
    [model addTrack:textTrack];
    
    self.trackSlot = slot;
    [textTrack addSlot:slot];
    
    return [self p_addTemplateWithSlot:slot segment:segment commit:commit completion:completion];

}

- (void)removeSelectedTextTemplateWithIsCommit:(BOOL)commit {
    NLETrackSlot_OC *slot = self.vcContext.mediaContext.selectTextSlot;
    if (!slot) {
        return;
    }
    [self removeTextTemplate:slot.nle_nodeId isCommit:commit];
}

- (void)removeTextTemplate:(NSString * )segmentId isCommit:(BOOL)commit {
    if (segmentId.length == 0) {
        return;
    }

    [self.nleEditor.nleModel nle_removeSlots:@[segmentId] inTrackType:NLETrackSTICKER];
    
    [self.actionService commitNLE:commit];
    self.vcContext.mediaContext.selectTextSlot = nil;
}

- (NSString *)copyTextTemplateWithIsCommit:(BOOL)commit {
    NLETrackSlot_OC* slot = self.vcContext.mediaContext.selectTextSlot;
    if (!slot) {
        return nil;
    }
    if (![slot.segment isKindOfClass:[NLESegmentTextTemplate_OC class]]) {
        return nil;
    }
    
    // 轨道部分逻辑
    NLETrackSlot_OC *textSlot = [slot deepClone:YES];
    // 向下偏移
    float offset = 0.1f;
    textSlot.transformY = slot.transformY - offset;
    
    NSString *newSegId = [self addTemplateWithSeg:(NLESegmentTextTemplate_OC*)textSlot.segment
                                             slot:textSlot
                                       needCommit:commit
                                       completion:nil];
    // 取消预览
    [self.nle setStickerPreviewMode:textSlot previewMode:0];
    return newSegId;
}

-(NSArray<NLETrackSlot_OC *> *)textTemplatestickerSlots {
    NSMutableArray<NLETrackSlot_OC *> *textStickerSlots = [NSMutableArray array];
    NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel nle_allTracksOfType:NLETrackSTICKER];
    for (NLETrack_OC *track in tracks) {
        NSArray<NLETrackSlot_OC *> *slots = track.slots;
        for (NLETrackSlot_OC *slot in slots) {
            if ([slot.segment isKindOfClass:NLESegmentTextTemplate_OC.class]) {
                [textStickerSlots addObject:slot];
            }
        }
    }
    
    return [textStickerSlots copy];
}


- (NSArray *)selectedTexts {
    NLETrackSlot_OC *slot = self.vcContext.mediaContext.selectTextSlot;
    if (![slot.segment isKindOfClass:[NLESegmentTextTemplate_OC class]]) {
        return nil;
    }
    NLESegmentTextTemplate_OC *seg = (NLESegmentTextTemplate_OC *)slot.segment;
    
    NSArray *clips = seg.textClips;
    if (clips.count == 0) {
        return nil;
    }
    
    clips = [seg.textClips sortedArrayUsingComparator:^NSComparisonResult(NLETextTemplateClip_OC *obj1, NLETextTemplateClip_OC *obj2) {
        return obj1.index - obj2.index;
    }];
    
    NSMutableArray *mList = [NSMutableArray new];
    for (NLETextTemplateClip_OC *clip in clips) {
        [mList addObject:clip.content];
    }
    
    return [mList copy];
}

- (void)updateAllTextTemplateSlotPreviewMode:(int)previewMode {
    NLEModel_OC *model = self.nleEditor.nleModel;
    for (NLETrack_OC *track in [model getTracks]) {
        for (NLETrackSlot_OC *slot in [track slots]) {
            if (![slot.segment isKindOfClass:NLESegmentTextTemplate_OC.class]) {
                continue;
            }
            [self.nle setStickerPreviewMode:slot previewMode:previewMode];
        }
    }
}
// MARK: - Event

// MARK: - Private
/// 微调时间
/// 修复（非起始位置）添加模板时，无法预览问题，原因是：VE与NLE的时间线有偏差，需要加一帧左右时间
- (void)p_seekTime {
    // TODO: 仍偶尔会有，可能还有其他seek地方需要处理
    CMTime time = CMTimeAdd(self.vcContext.mediaContext.currentTime, [DVETrackConfig timelineErrorOffsetTime]);
    [self.vcContext.mediaContext.playerDelegate mediaDelegateSeekToTime:time isSmooth:NO];
}

- (void)p_addText:(NLETextTemplateSubInfo *)textInfo
   toTextTemplate:(NLESegmentTextTemplate_OC *)textTemplate {
    NLETextTemplateClip_OC *clip_oc = [[NLETextTemplateClip_OC alloc] init];
    clip_oc.content = textInfo.text;
    clip_oc.index = textInfo.index;
    [textTemplate addTextClip:clip_oc];
}

- (void)p_updateText:(NSString *)text
             atIndex:(NSUInteger)index
     forTextTemplate:(NLESegmentTextTemplate_OC *)textTemplate {
    NSArray *clips = [textTemplate textClips];
    for (NLETextTemplateClip_OC *textClip in clips) {
        if (textClip.index == index) {
            textClip.content = text;
            break;
        }
    }
}

- (NLESegmentTextTemplate_OC *)p_makeSegmentWithPath:(NSString *)path
                                         resDuration:(Float64)resDuration
                                        depResModels:(NSArray<DVETextTemplateDepResourceModelProtocol> *)depResModels {
    // 资源
    NLEResourceNode_OC *resEffect = [[NLEResourceNode_OC alloc] init];
    resEffect.resourceId = [[NSUUID UUID] UUIDString];
    resEffect.resourceFile = path;
    resEffect.resourceType = NLEResourceTypeTextTemplate;
    resEffect.resourceTag = NLEResourceTagNormal;
    resEffect.duration = CMTimeMakeWithSeconds(resDuration, USEC_PER_SEC);
    
    // 添加资源依赖：字体
    NSMutableArray *mFonts = [[NSMutableArray alloc] initWithCapacity:depResModels.count];
    for (id<DVETextTemplateDepResourceModelProtocol> m in depResModels) {
        NLEResourceNode_OC *tmp = [[NLEResourceNode_OC alloc] init];
        tmp.resourceId = m.resourceId;
        tmp.resourceFile = m.path;
        [mFonts addObject:tmp];
    }
    
    // 初始化 segment
    NLESegmentTextTemplate_OC *segment = [[NLESegmentTextTemplate_OC alloc] init];
    [segment setEffectSDKFile:resEffect];
    segment.fontResList = mFonts;
    
    return segment;
}

- (NSString *)p_addTemplateWithSlot:(NLETrackSlot_OC *)slot segment:(NLESegmentTextTemplate_OC*)segment commit:(BOOL)commit completion:(nullable void(^)(void))completion {
    [self.actionService commitNLE:NO];
    
    // 设置 enable 是为了只展示预览框，不关闭模板面板
    [DVEComponentViewManager sharedManager].enable = NO;
    self.vcContext.mediaContext.selectTextSlotAtCurrentTime = slot;
    [DVEComponentViewManager sharedManager].enable = YES;
    // 预览模板
    [self.nle setStickerPreviewMode:slot previewMode:4];
    
    /*
     添加的文字模板，超过了主轨视频时长，会触发update videodata，ve 内部会修
     改infosticker 的id，内部的sticker id 变化会通过 stickerRecoverEvent
     这个block来通知我们，但是这个是在updatevideoData完成后回调的。
     所以commit之后，立刻获取文字模板信息就会获取不到
     */
    @weakify(self);
    [self.vcContext.playerService updateCurVideoDataWithCompleteBlock:^(NSError * _Nullable error) {
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            // 获取到实时的数据
            NLETextTemplateInfo *info = [self.nle textTemplateInfoForSlot:slot];
            segment.textClips = nil; // clear
            for (NLETextTemplateSubInfo *sub in info.textInfos) {
                [self p_addText:sub toTextTemplate:segment];
            }
            
            [self.actionService commitNLE:commit];
            [self p_seekTime];
            if (completion) {
                completion();
            }
        });
    }];
    
    return slot.name;
}

// MARK: - Getters and setters

@end

