//
//   DVERegulateEditor.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/10.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVERegulateEditor.h"
#import "DVEVCContext.h"
#import "NSDictionary+DVE.h"
#import "NSString+DVE.h"
#import <DVETrackKit/NLETrack_OC+NLE.h>

@interface DVERegulateEditModel : NSObject

@property (nonatomic, copy) NSString *resPath;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) int order;
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) CGFloat endTime;
@property (nonatomic, assign) CGFloat intensity;
@property (nonatomic, copy) NSString *name;

@end

@implementation DVERegulateEditModel

@end

@interface DVERegulateEditor () <NLEKeyFrameCallbackProtocol>

@property (nonatomic, weak) id<DVECoreDraftServiceProtocol> draftService;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVECoreKeyFrameProtocol> keyFrameEditor;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@end

@implementation DVERegulateEditor

@synthesize vcContext = _vcContext;
@synthesize keyFrameDelegate = _keyFrameDelegate;

DVEAutoInject(self.vcContext.serviceProvider, draftService, DVECoreDraftServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, keyFrameEditor, DVECoreKeyFrameProtocol)

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if (self = [super init]) {
        _vcContext = context;
        [self.nle addKeyFrameListener:self];
    }
    return self;
}

- (void)addOrUpdateAjustFeatureWithPath:(NSString *)path
                                   name:(NSString *)name
                             identifier:identifier
                              intensity:(CGFloat)intensity
                            resourceTag:(NLEResourceTag)resourceTag
                             needCommit:(BOOL)commit {
    NSAssert(identifier, @"资源唯一标识identifier为空");
    // 1. 跟TrackView交互  判断是全局还是局部滤镜
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentBlendVideoSlot];
    
    DVERegulateEditModel *needUpdateFeature = nil;
    if (!slot) { // 全局
        //遍历选中全局slot的所有调节feature，查找是否是已有的调节效果
        for (DVERegulateEditModel *feature in [self currentGlobalAdjustFeatures]) {
            if ([feature.identifier isEqualToString:identifier]) {
                needUpdateFeature = feature;
                break;
            }
        }
        //如果是已有的调节效果，则更新
        if (needUpdateFeature) {
            [self updateGlobalNLEFilter:identifier intensity:intensity needCommit:commit];
        } else {
            DVERegulateEditModel *newFeature = [DVERegulateEditModel new];
            newFeature.resPath = path;
            newFeature.identifier = identifier;
            newFeature.intensity = intensity;
            [self addGlobalNLEFilter:newFeature name:name resourceTag:resourceTag needCommit:commit];
        }
    } else { // 局部
        NSArray <DVERegulateEditModel *> *features = [self currentPartlyAdjustFeatures];
        for (DVERegulateEditModel *feature in features) {
            if ([feature.identifier isEqualToString:identifier]) {
                needUpdateFeature = feature;
                break;
            }
        }
        if (needUpdateFeature) {
            [self updatePartlyNLEFilter:needUpdateFeature.resPath intensity:intensity forSlot:slot needCommit:commit];
        } else {
            DVERegulateEditModel *newFeature = [DVERegulateEditModel new];
            newFeature.resPath = path;
            newFeature.identifier = identifier;
            newFeature.intensity = intensity;
            // 添加VE&NLE&缓存
            [self addPartlyNLEFilter:newFeature forSlot:slot name:name resourceTag:resourceTag needCommit:commit];
        }

    }
}

- (void)addPartlyNLEFilter:(DVERegulateEditModel*)info
                   forSlot:(NLETrackSlot_OC *)selectSlot
                      name:(NSString *)name
               resourceTag:(NLEResourceTag)resourceTag
                needCommit:(BOOL)commit{
    if (!selectSlot) return;
    
    NSString *relativePath = [self.draftService copyResourceToDraft:[NSURL fileURLWithPath:info.resPath] resourceType:NLEResourceTypeAdjust];
    
    NLEResourceNode_OC *resFilter = [[NLEResourceNode_OC alloc] init];
    resFilter.resourceId = info.identifier;
    resFilter.resourceFile = relativePath;
    resFilter.resourceType = NLEResourceTypeAdjust;
    resFilter.resourceTag = resourceTag;
    
    NLESegmentFilter_OC *segFilter = [[NLESegmentFilter_OC alloc] init];
    [segFilter setEffectSDKFilter:resFilter];
    [segFilter setFilterName:name];
    [segFilter setIntensity:info.intensity];
    
    NLEFilter_OC *filter = [[NLEFilter_OC alloc] init];
    [filter setSegmentFilter:segFilter];
    
    [selectSlot addFilter:filter];

    [self.actionService commitNLE:commit];
    [self.vcContext.mediaContext seekToCurrentTime];

}

/// 判断是创建一个调节slot，还是给已有的调节slot，增加一个调节效果。
/// @param info 构建调节信息Model
/// @param name 调节资源名称
/// @param resourceTag 调节资源类型（amazing或者是normal类型）
/// @param commit 提交NLE（提交后可以undo）
- (void)addGlobalNLEFilter:(DVERegulateEditModel*)info
                      name:(NSString *)name
               resourceTag:(NLEResourceTag)resourceTag
                needCommit:(BOOL)commit{
    NLETrackSlot_OC *trackSlot = self.vcContext.mediaContext.selectFilterSegment;
    if (trackSlot) {
        [self addGlobalNLEFilterForExistSlot:info name:name resourceTag:resourceTag forSelectSlot:trackSlot needCommit:commit];
    } else {
        [self addGlobalNLEFilterForNewSlot:info name:name resourceTag:resourceTag needCommit:commit];
    }
}

/// 新建一个调节slot，并设置调节效果。
/// @param info 调节信息Model
/// @param name 调节资源名称
/// @param resourceTag 调节资源类型（amazing或者是normal类型）
/// @param commit 提交NLE（提交后可以undo）
- (void)addGlobalNLEFilterForNewSlot:(DVERegulateEditModel*)info
                                name:(NSString *)name
                         resourceTag:(NLEResourceTag)resourceTag
                          needCommit:(BOOL)commit{
    NSString *relativePath = [self.draftService copyResourceToDraft:[NSURL fileURLWithPath:info.resPath] resourceType:NLEResourceTypeAdjust];
    NLEModel_OC *model = self.nleEditor.nleModel;

    NLEResourceNode_OC *resource = [[NLEResourceNode_OC alloc] init];
    resource.resourceId = info.identifier;
    resource.resourceFile = relativePath;
    resource.resourceType = NLEResourceTypeAdjust;
    resource.resourceTag = resourceTag;
    
    NLESegmentFilter_OC *segFilter = [[NLESegmentFilter_OC alloc] init];
    [segFilter setEffectSDKFilter:resource];
    [segFilter setFilterName:name];
    [segFilter setIntensity:info.intensity];
    
    NLEFilter_OC *filter = [[NLEFilter_OC alloc] init];
    [filter setSegmentFilter:segFilter];
    
    NLESegmentFilter_OC *mainSegFilter = [[NLESegmentFilter_OC alloc] init];
    mainSegFilter.filterName = [self newNameForAdjustSlot];
    
    NLETrackSlot_OC *trackSlot = [[NLETrackSlot_OC alloc] init];
    trackSlot = [[NLETrackSlot_OC alloc] init];
    trackSlot.startTime = self.vcContext.mediaContext.currentTime;
    trackSlot.duration = CMTimeMake(3 * USEC_PER_SEC, USEC_PER_SEC);///默认按时长3s去找空隙
    [trackSlot addFilter:filter];
    [trackSlot setSegment:mainSegFilter];
    
    //查找有空位可以插入新slot的滤镜轨道
    NLETrack_OC *filterTrack = nil;
    NSArray<NLETrack_OC *> *trackArray = [model nle_allTracksOfType:NLETrackFILTER resourceType:NLEResourceTypeAdjust];
    for (NLETrack_OC *track in trackArray) {
        BOOL isContainSlot = YES;
        for (NLETrackSlot_OC *slot in track.slots) {
            //如果与该轨道上的slot有交叠部分，则isContainSlot设置为NO
            if (CMTimeRangeContainsTime(trackSlot.nle_targetTimeRange, slot.startTime) || CMTimeRangeContainsTime(trackSlot.nle_targetTimeRange, slot.endTime) ||
                CMTimeRangeContainsTime(slot.nle_targetTimeRange, trackSlot.startTime) ||
                CMTimeRangeContainsTime(slot.nle_targetTimeRange, trackSlot.endTime)) {
                isContainSlot = NO;
                break;
            }
        }
        if (isContainSlot == YES) {
            filterTrack = track;
            break;
        }
    }
    
    
    ///最后滤镜时长不能超过总时长
    CGFloat endSecond = MIN(CMTimeGetSeconds(trackSlot.endTime), CMTimeGetSeconds(self.vcContext.mediaContext.duration));
    trackSlot.endTime = CMTimeMakeWithSeconds(endSecond, USEC_PER_SEC);
    
    //如果没有找到可以插入slot的轨道，则新建一个轨道
    if (!filterTrack) {
        filterTrack = [[NLETrack_OC alloc] init];
        filterTrack.extraTrackType = NLETrackFILTER;
        filterTrack.nle_extraResourceType = NLEResourceTypeAdjust;
        [model addTrack:filterTrack];
    }
    [filterTrack addSlot:trackSlot];
    
    [self.actionService commitNLE:commit];
    self.vcContext.mediaContext.selectFilterSegment = trackSlot;
    [self.vcContext.mediaContext seekToCurrentTime];
}

/// 给已有的调节slot，增加一个调节效果。
/// @param info 调节信息Model
/// @param name 调节资源名称
/// @param resourceTag 调节资源类型（amazing或者是normal类型）
/// @param slot 选中的调节Slot
/// @param commit 提交NLE（提交后可以undo）
- (void)addGlobalNLEFilterForExistSlot:(DVERegulateEditModel*)info
                                  name:(NSString *)name
                           resourceTag:(NLEResourceTag)resourceTag
                         forSelectSlot:(NLETrackSlot_OC *)slot
                            needCommit:(BOOL)commit{
    
    NSString *relativePath = [self.draftService copyResourceToDraft:[NSURL fileURLWithPath:info.resPath] resourceType:NLEResourceTypeAdjust];
    NLEResourceNode_OC *resource = [[NLEResourceNode_OC alloc] init];
    resource.resourceId = info.identifier;
    resource.resourceFile = relativePath;
    resource.resourceType = NLEResourceTypeAdjust;
    resource.resourceTag = resourceTag;
    
    NLESegmentFilter_OC *segFilter = [[NLESegmentFilter_OC alloc] init];
    [segFilter setEffectSDKFilter:resource];
    [segFilter setFilterName:name];
    [segFilter setIntensity:info.intensity];
    
    NLEFilter_OC *filter = [[NLEFilter_OC alloc] init];
    [filter setSegmentFilter:segFilter];
    
    //给已有的调节slot增加调节效果
    [slot addFilter:filter];
    
    [self.actionService commitNLE:commit];
    self.vcContext.mediaContext.selectFilterSegment = slot;
    [self.vcContext.mediaContext seekToCurrentTime];
}


- (void)updatePartlyNLEFilter:(NSString *)resPath
                    intensity:(CGFloat)intensity
                      forSlot:(NLETrackSlot_OC *)slot
                   needCommit:(BOOL)commit
{
    if (!slot) return;
    NLEFilter_OC *findFilter = nil;
    NSMutableArray<NLEFilter_OC*>* filters = [slot getFilter];
    for (NLEFilter_OC *filter in filters) {
        NLESegmentFilter_OC *segFilter = filter.segmentFilter;
        NLEResourceNode_OC *resFilter = segFilter.effectSDKFilter;
        if ([resFilter.resourceFile isEqualToString:resPath]) {
            findFilter = filter;
            [segFilter setIntensity:intensity];
            break;
        }
    }
    
    [slot addOrUpdateKeyframe:CMTimeMake(self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC, USEC_PER_SEC)
                   timeRange:[self.keyFrameEditor currentKeyframeTimeRange] forceAdd:NO];
    
    [self.actionService commitNLE:commit];
}

/// 更新已有的调节slot的效果强度。
/// @param identifier 调节资源唯一标识符
/// @param intensity 调节资源强度
/// @param commit 提交NLE（提交后可以undo）
- (void)updateGlobalNLEFilter:(NSString *)identifier
                    intensity:(CGFloat)intensity
                   needCommit:(BOOL)commit
{
    if (!identifier) return;
    NLETrackSlot_OC *slot = self.vcContext.mediaContext.selectFilterSegment;
    if (!slot) return;
    for (NLEFilter_OC *filter in [slot getFilter]) {
        NLESegmentFilter_OC *segFilter = filter.segmentFilter;
        NLEResourceNode_OC *resFilter = [segFilter getResNode];
        //找到对应的调节Filter，并更新它的强度intensity
        if ([resFilter.resourceId isEqualToString:identifier]) {
            [segFilter setIntensity:intensity];
        }
    }
    
    [slot addOrUpdateKeyframe:CMTimeMake(self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC, USEC_PER_SEC)
                   timeRange:[self.keyFrameEditor currentKeyframeTimeRange] forceAdd:NO];
    
    [self.actionService commitNLE:commit];
}

- (void)resetAllRegulateNeedCommit:(BOOL)commit
{
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentBlendVideoSlotWithFilter];
    
    BOOL change = NO;
    if (slot) {
        NSArray<NLEFilter_OC*>* filters = [slot getFilter];
        for (NLEFilter_OC *filter in filters) {
            if([filter.segmentFilter getType] == NLEResourceTypeFilter) continue;///过滤滤镜资源
            NLESegmentFilter_OC *segFilter = filter.segmentFilter;
            [segFilter setIntensity:0];
            change = YES;
        }
    }
    if(change){
        [slot addOrUpdateKeyframe:CMTimeMake(self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC, USEC_PER_SEC)
                       timeRange:[self.keyFrameEditor currentKeyframeTimeRange] forceAdd:NO];
        [self.actionService commitNLE:commit];
    }

}

- (void)deleteSelectRegulateSegment
{
    if (self.vcContext.mediaContext.selectFilterSegment) {
        NLETrackSlot_OC *regulateSlot = self.vcContext.mediaContext.selectFilterSegment;
        NLEModel_OC *model = self.nleEditor.nleModel;
        NLETrack_OC *regulateTrack = [model trackContainSlotId:regulateSlot.nle_nodeId];
        [regulateTrack removeSlot:regulateSlot];
        //删除slot后，如果该轨道没有slot了，则删除该轨道
        if (regulateTrack.slots.count == 0) {
            [model removeTrack:regulateTrack];
        }
        [self.actionService commitNLE:YES];
    }
    [self.vcContext.playerService seekToTime:self.vcContext.mediaContext.currentTime isSmooth:NO];
}

- (NSString*)adjustDefaultName {
    return NLELocalizedString(@"ck_adjust", @"调节");
}

- (NSString *)newNameForAdjustSlot
{
    NSInteger number = 0;
    NLEModel_OC *model = self.nleEditor.nleModel;
    NSArray<NLETrack_OC *> *filterTrackArray = [model nle_allTracksOfType:NLETrackFILTER resourceType:NLEResourceTypeAdjust];
    for (NLETrack_OC *track in filterTrackArray) {
        for (NLETrackSlot_OC *slot in track.slots) {
            NLESegmentFilter_OC *segFilter = (NLESegmentFilter_OC *)(slot.segment);
            NSString* str = [segFilter.filterName stringByReplacingOccurrencesOfString:[self adjustDefaultName] withString:@""];
            number = MAX([str integerValue], number);
        }
    }
    return [NSString stringWithFormat:@"%@%ld",[self adjustDefaultName], number+1];
}


- (NSDictionary *)currentAdjustIntensity
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentBlendVideoSlot];
    NSArray<DVERegulateEditModel *> *models = nil;
    if(slot) {
        models = [self currentPartlyAdjustFeatures];
    } else if(self.vcContext.mediaContext.selectFilterSegment) {
        models = [self currentGlobalAdjustFeatures];
    }
    
    for(DVERegulateEditModel* model in models){
        [dic setValue:@(model.intensity) forKey:model.identifier];
    }
    
    return dic;
}

- (NSArray<DVERegulateEditModel *> *)currentPartlyAdjustFeatures
{
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentBlendVideoSlot];
    NSMutableArray<DVERegulateEditModel *> *partlyFeatures = [[NSMutableArray alloc] init];
    
    if(slot) {
        NSMutableArray<NLEFilter_OC*>* filters = [slot getFilter].copy;
        for (NLEFilter_OC *filter in filters) {
            
            if([filter.segmentFilter getType] == NLEResourceTypeFilter) continue;///过滤滤镜资源
            
            NLESegmentFilter_OC *segFilter = filter.segmentFilter;
            NLEResourceNode_OC *resFilter = segFilter.effectSDKFilter;
            DVERegulateEditModel *model = [[DVERegulateEditModel alloc]  init];
            model.identifier = resFilter.resourceId;
            model.name = segFilter.filterName;
            model.intensity = segFilter.intensity;
            model.resPath = resFilter.resourceFile;
            [partlyFeatures addObject:model];
        }
        return partlyFeatures;
    }
    return partlyFeatures;
}

- (NSArray<DVERegulateEditModel *> *)currentGlobalAdjustFeatures
{
    NSMutableArray<DVERegulateEditModel *> *globalFeatures = [[NSMutableArray alloc] init];
    NLETrackSlot_OC *slot = self.vcContext.mediaContext.selectFilterSegment;
    if (!slot) return globalFeatures;
    
    for (NLEFilter_OC *filter in [slot getFilter]) {
        
        NLESegmentFilter_OC *segFilter = filter.segmentFilter;
        NLEResourceNode_OC *resFilter = [segFilter getResNode];
        DVERegulateEditModel *model = [[DVERegulateEditModel alloc] init];
        model.identifier = resFilter.resourceId;
        model.name = segFilter.filterName;
        model.intensity = segFilter.intensity;
        model.resPath = resFilter.resourceFile;
        [globalFeatures addObject:model];
    }
    return globalFeatures;
}

#pragma mark - NLEKeyFrameCallbackProtocol

- (void)nleDidChangedWithPTS:(CMTime)time keyFrameInfo:(NLEAllKeyFrameInfo *)info {
    
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentBlendVideoSlotWithFilter];
    
    if (!slot) {
        return;
    }
    
    slot = [self.nle refreshAllKeyFrameInfo:info pts:self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC inSlot:slot];
    
    if (self.keyFrameDelegate &&
        [self.keyFrameDelegate respondsToSelector:@selector(regulateKeyFrameDidChangedWithSlot:)]) {
        [self.keyFrameDelegate regulateKeyFrameDidChangedWithSlot:slot];
    }
}

@end
