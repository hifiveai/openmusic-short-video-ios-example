//
//   DVEFilterEditor.m
//   NLEEditor
//
//   Created  by bytedance on 2021/4/26.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEFilterEditor.h"
#import "DVEVCContext.h"
#import "NSDictionary+DVE.h"
#import "NSString+DVE.h"
#import <MJExtension/MJExtension.h>
#import <DVETrackKit/NLETrack_OC+NLE.h>

@interface DVEFilterEditorModel : NSObject

///绝对路径
@property (nonatomic, copy) NSString *resPath;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int order;
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) CGFloat endTime;
@property (nonatomic, assign) CGFloat intensity;

@end

@implementation DVEFilterEditorModel

@end

@interface DVEFilterEditor () <NLEKeyFrameCallbackProtocol>

@property (nonatomic, weak) id<DVECoreDraftServiceProtocol> draftService;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVECoreKeyFrameProtocol> keyFrameEditor;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@end

@implementation DVEFilterEditor

@synthesize vcContext = _vcContext;
@synthesize keyFrameDelegate = _keyFrameDelegate;

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

///适用于选择滤镜按钮，更新或者添加滤镜，会自动判断是全局还是局部滤镜
/// @param path 滤镜资源路径
/// @param name 滤镜资源名称
/// @param identifier 滤镜资源唯一标识符
/// @param intensity 滤镜强度值
/// @param resourceTag 滤镜资源类型（amazing或者是normal类型）
/// @param commit 提交NLE（提交后可以undo）
- (void)addOrUpdateFilterWithPath:(NSString *)path name:(NSString *)name identifier:(NSString *)identifier intensity:(CGFloat)intensity resourceTag:(NLEResourceTag)resourceTag needCommit:(BOOL)commit {
    // 跟TrackView交互  判断是全局还是局部滤镜
    NSAssert(identifier, @"资源唯一标识identifier为空");
    NLETrackSlot_OC *slot =  [self.vcContext.mediaContext currentBlendVideoSlot];

    if (!slot) { // //全局
        //查看当前选中slot的全局滤镜Filter
        DVEFilterEditorModel *feature = [self selectGlobalFilterFeature];
        //如果是已有的滤镜Filter，则更新强度
        if (feature && [feature.identifier isEqualToString:identifier]) {
            feature.intensity = intensity;
            [self updateGlobalNLEFilter:feature.identifier intensity:feature.intensity needCommit:commit];
        } else {
            [self addOrChangeFilterFeatureWithPath:path name:name identifier:identifier intensity:intensity forSlot:slot resourceTag:resourceTag needCommit:(BOOL)commit];
        }
    } else {
        DVEFilterEditorModel *feature = [self selectPartlyFilterFeature];
        if (feature && [feature.identifier isEqualToString:identifier]) {
            [self updatePartlyNLEFilter:identifier intensity:intensity forSlot:slot needCommit:commit];
        } else {
            [self addOrChangeFilterFeatureWithPath:path name:name identifier:identifier intensity:intensity forSlot:slot resourceTag:resourceTag needCommit:(BOOL)commit];
        }
    }
}

/// 增加或者切换滤镜，会自动判断是全局还是局部滤镜
/// @param path 资源路径
/// @param name 滤镜资源名称
/// @param identifier 滤镜资源唯一标识符
/// @param intensity 滤镜强度值
/// @param slot 视频slot
/// @param resourceTag 滤镜资源类型（amazing或者是normal类型）
/// @param commit 提交NLE（提交后可以undo）
- (void)addOrChangeFilterFeatureWithPath:(NSString *)path name:(NSString *)name identifier:(NSString *)identifier intensity:(CGFloat)intensity forSlot:(NLETrackSlot_OC *)slot resourceTag:(NLEResourceTag)resourceTag needCommit:(BOOL)commit{
    NSAssert(identifier, @"资源唯一标识符identifier为空");
    // add new one
    DVEFilterEditorModel * feature = [DVEFilterEditorModel new];
    feature.name = name;
    feature.resPath = path;
    feature.identifier = identifier;
    feature.intensity = intensity;
    if (!slot) {//全局
        if (!self.vcContext.mediaContext.selectFilterSegment) {
            [self addGlobalNLEFilter:feature name:name resourceTag:resourceTag needCommit:commit];
        } else {
            [self changeGlobalNLEFilter:feature name:name resourceTag:resourceTag needCommit:commit];
        }
    } else {

        [self addOrChangePartlyNLEFilter:feature forSlot:slot name:name resourceTag:resourceTag needCommit:commit];
    }
}

/// 适用于取消或删除按钮，会自动判断是全局还是局部滤镜
/// @param commit 提交NLE（提交后可以undo）
- (void)deleteCurrentFilterNeedCommit:(BOOL)commit {
    // 1. 跟TrackView交互  判断是全局还是局部滤镜
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentBlendVideoSlot];

    // 2. 先删除以前的滤镜
    if (!slot) { // 全局
        if ([self selectGlobalFilterFeature]) {
            DVEFilterEditorModel *feature = [self selectGlobalFilterFeature];
            [self deleteGlobalNLEFilter:feature.identifier needCommit:commit];
        };
    } else {
        if ([self selectPartlyFilterFeature]){
            DVEFilterEditorModel *feature = [self selectPartlyFilterFeature];
            [self deletePartlyNLEFilter:feature.identifier forSlot:slot needCommit:commit];
        };
    }
}

- (void)addPartlyNLEFilter:(DVEFilterEditorModel*)info
                   forSlot:(NLETrackSlot_OC *)selectSlot
                      name:(NSString *)name
               resourceTag:(NLEResourceTag)resourceTag
                needCommit:(BOOL)commit{

    if (!selectSlot) return;
    
    NSString *relativePath = [self.draftService copyResourceToDraft:[NSURL fileURLWithPath:info.resPath] resourceType:NLEResourceTypeFilter];
    
    NLEResourceNode_OC *resFilter = [[NLEResourceNode_OC alloc] init];
    resFilter.resourceId = info.identifier;
    resFilter.resourceFile = relativePath;
    resFilter.resourceType = NLEResourceTypeFilter;
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

/// 新增/切换成另一种局部滤镜
/// @param info 构建滤镜信息Model
/// @param name 滤镜名称
/// @param resourceTag 滤镜资源类型（amazing或者是normal类型）
/// @param commit 提交NLE（提交后可以undo）
- (void)addOrChangePartlyNLEFilter:(DVEFilterEditorModel*)info forSlot:(NLETrackSlot_OC *)selectSlot name:(NSString *)name resourceTag:(NLEResourceTag)resourceTag needCommit:(BOOL)commit{
    if (!selectSlot) return;
    
    NLESegmentFilter_OC *segFilter = nil;

    for(NLEFilter_OC* filter in [selectSlot getFilter]){
        if(filter.segmentFilter.getResNode.resourceType == NLEResourceTypeFilter){
            segFilter = filter.segmentFilter;
            break;
        }
    }

    if(segFilter == nil){
        [self addPartlyNLEFilter:info forSlot:selectSlot name:name resourceTag:resourceTag needCommit:commit];
    }else{
        NSString *relativePath = [self.draftService copyResourceToDraft:[NSURL fileURLWithPath:info.resPath] resourceType:NLEResourceTypeFilter];
        
        NLEResourceNode_OC *resFilter = [[NLEResourceNode_OC alloc] init];
        resFilter.resourceId = info.identifier;
        resFilter.resourceFile = relativePath;
        resFilter.resourceType = NLEResourceTypeFilter;
        resFilter.resourceTag = resourceTag;

        [segFilter setFilterName:name];
        [segFilter setIntensity:info.intensity];
        [segFilter setEffectSDKFilter:resFilter];

        [self.actionService commitNLE:commit];
        [self.vcContext.mediaContext seekToCurrentTime];
    }
}

/// 给全局滤镜slot增加一个滤镜
/// @param info 构建滤镜信息Model
/// @param name 滤镜名称
/// @param resourceTag 滤镜资源类型（amazing或者是normal类型）
/// @param commit 提交NLE（提交后可以undo）
- (void)addGlobalNLEFilter:(DVEFilterEditorModel*)info name:(NSString *)name resourceTag:(NLEResourceTag)resourceTag needCommit:(BOOL)commit{
    
    NSString *relativePath = [self.draftService copyResourceToDraft:[NSURL fileURLWithPath:info.resPath] resourceType:NLEResourceTypeFilter];
    
    NLEModel_OC *model = self.nleEditor.nleModel;

    NLEResourceNode_OC *resource = [[NLEResourceNode_OC alloc] init];
    resource.resourceId = info.identifier;
    resource.resourceFile = relativePath;
    resource.resourceType = NLEResourceTypeFilter;
    resource.resourceTag = resourceTag;
    
    NLESegmentFilter_OC *segFilter = [[NLESegmentFilter_OC alloc] init];
    [segFilter setEffectSDKFilter:resource];
    [segFilter setFilterName:name];
    [segFilter setIntensity:info.intensity];
    
    NLEFilter_OC *filter = [[NLEFilter_OC alloc] init];
    filter.segmentFilter = segFilter;
    
    NLESegmentFilter_OC *mainSegFilter = [[NLESegmentFilter_OC alloc] init];
    mainSegFilter.filterName = name;

    NLETrackSlot_OC *trackSlot = [[NLETrackSlot_OC alloc] init];
    [trackSlot setSegment:mainSegFilter];
    [trackSlot addFilter:filter];
    trackSlot.startTime = self.vcContext.mediaContext.currentTime;
    trackSlot.duration = CMTimeMake(3 * USEC_PER_SEC, USEC_PER_SEC);///默认按时长3s去找空隙
    //查找有空位可以插入新slot的滤镜轨道
    NLETrack_OC *filterTrack = nil;
    NSArray<NLETrack_OC *> *trackArray = [model nle_allTracksOfType:NLETrackFILTER resourceType:NLEResourceTypeFilter];
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
    
    //如果没有能插入slot的轨道，则创建新的轨道
    if (!filterTrack) {
        filterTrack = [[NLETrack_OC alloc] init];
        filterTrack.extraTrackType = NLETrackFILTER;
        filterTrack.nle_extraResourceType = NLEResourceTypeFilter;
        [model addTrack:filterTrack];
    }
    [filterTrack addSlot:trackSlot];
    [self.actionService commitNLE:commit];
    self.vcContext.mediaContext.selectFilterSegment = trackSlot;
    [self.vcContext.mediaContext seekToCurrentTime];
}

/// 切换成另一种全局滤镜
/// @param info 构建滤镜信息Model
/// @param name 滤镜名称
/// @param resourceTag 滤镜资源类型（amazing或者是normal类型）
/// @param commit 提交NLE（提交后可以undo）
- (void)changeGlobalNLEFilter:(DVEFilterEditorModel*)info name:(NSString *)name resourceTag:(NLEResourceTag)resourceTag needCommit:(BOOL)commit{
    NLETrackSlot_OC *selectSlot = self.vcContext.mediaContext.selectFilterSegment;
    if (!selectSlot) return;
    
    NSString *relativePath = [self.draftService copyResourceToDraft:[NSURL fileURLWithPath:info.resPath] resourceType:NLEResourceTypeFilter];

    NLEResourceNode_OC *resource = [[NLEResourceNode_OC alloc] init];
    resource.resourceId = info.identifier;
    resource.resourceFile = relativePath;
    resource.resourceType = NLEResourceTypeFilter;
    resource.resourceTag = resourceTag;
    
    NLESegmentFilter_OC *segFilter = [[NLESegmentFilter_OC alloc] init];
    [segFilter setEffectSDKFilter:resource];
    [segFilter setFilterName:name];
    [segFilter setIntensity:info.intensity];
    
    NLEFilter_OC *filter = [[NLEFilter_OC alloc] init];
    filter.segmentFilter = segFilter;
    
    NLESegmentFilter_OC *mainSegment = (NLESegmentFilter_OC *)selectSlot.segment;
    mainSegment.filterName = name;

    //清除原有的滤镜Filter(这里注意别清了调节)filter，设置新的滤镜效果
    for(NLEFilter_OC* filter in [selectSlot getFilter]){
        if(filter.segmentFilter.getResNode.resourceType == NLEResourceTypeFilter){
            [selectSlot removeFilter:filter];
        }
    }
    [selectSlot addFilter:filter];
    
    [self.actionService commitNLE:commit];
}

/// 删除全局的滤镜Filter
/// @param identifier 滤镜资源唯一的标识符
/// @param commit 提交NLE（提交后可以undo）
- (void)deleteGlobalNLEFilter:(NSString *)identifier needCommit:(BOOL)commit {
    if (!identifier) return;
    NLETrackSlot_OC *slot = self.vcContext.mediaContext.selectFilterSegment;
    if (!slot) return;

    NLEModel_OC *model = self.nleEditor.nleModel;
    NLETrack_OC *filterTrack = [model trackContainSlotId:slot.nle_nodeId];
    if (!filterTrack) return;
    
    [filterTrack removeSlot:slot];
    if (filterTrack.slots.count == 0) {
        [model removeTrack:filterTrack];
    }
    [self.actionService commitNLE:commit];
}

- (void)deletePartlyNLEFilter:(NSString *)identifier forSlot:(NLETrackSlot_OC *)slot  needCommit:(BOOL)commit {
    if (!slot) return;
    NLEFilter_OC *findFilter = nil;
    NSMutableArray<NLEFilter_OC*>* filters = [slot getFilter];
    for (NLEFilter_OC *filter in filters) {
        NLESegmentFilter_OC *segFilter = filter.segmentFilter;
        NLEResourceNode_OC *resFilter = segFilter.effectSDKFilter;
        if ([resFilter.resourceId isEqualToString:identifier]) {
            findFilter = filter;
            break;
        }
    }
    if (findFilter) {
        [slot removeFilter:findFilter];
    }
    [self.actionService commitNLE:commit];
}

- (void)updatePartlyNLEFilter:(NSString *)identifier intensity:(CGFloat)intensity forSlot:(NLETrackSlot_OC *)slot needCommit:(BOOL)commit {
    if (!slot) return;
    NLEFilter_OC *findFilter = nil;
    NSMutableArray<NLEFilter_OC*>* filters = [slot getFilter];
    for (NLEFilter_OC *filter in filters) {
        NLESegmentFilter_OC *segFilter = filter.segmentFilter;
        NLEResourceNode_OC *resFilter = segFilter.effectSDKFilter;
        if ([resFilter.resourceId isEqualToString:identifier]) {
            findFilter = filter;
            [segFilter setIntensity:intensity];
            break;
        }
    }
    
    [slot addOrUpdateKeyframe:CMTimeMake(self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC, USEC_PER_SEC)
                   timeRange:[self.keyFrameEditor currentKeyframeTimeRange] forceAdd:NO];
    
    [self.actionService commitNLE:commit];
}

/// 更新全局滤镜的强度
/// @param identifier 滤镜资源的唯一标识符
/// @param intensity 滤镜强度值
/// @param commit 提交NLE（提交后可以undo）
- (void)updateGlobalNLEFilter:(NSString *)identifier intensity:(CGFloat)intensity needCommit:(BOOL)commit {
    if (!identifier) return;

    NLEModel_OC *model = self.nleEditor.nleModel;
    if(model.getTracks.count == 0) return;
    
    NSMutableArray<NLETrack_OC *> *filterTracks = [[NSMutableArray alloc] init];
    for (NLETrack_OC *track in [model getTracks]) {
        if ([track getTrackType] == NLETrackFILTER && [track nle_extraResourceType] == NLEResourceTypeFilter) {
            [filterTracks addObject:track];
        }
    }
    
    if (!filterTracks.count) return;
    
    for (NLETrack_OC *filterTrack in filterTracks) {
        for (NLETrackSlot_OC *slot in filterTrack.slots) {
            NLESegmentFilter_OC *segFilter = [slot getFilter].firstObject.segmentFilter;
            NLEResourceNode_OC *resFilter = [segFilter getResNode];
            if ([resFilter.resourceId isEqualToString:identifier]) {
                [segFilter setIntensity:intensity];
                [slot addOrUpdateKeyframe:CMTimeMake(self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC, USEC_PER_SEC)
                               timeRange:[self.keyFrameEditor currentKeyframeTimeRange] forceAdd:NO];
                break;
            }
        }
    }
    [self.actionService commitNLE:commit];
}

- (NSDictionary *)currentFilterIntensity
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSString *identifier = nil;
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentBlendVideoSlot];

    if(slot) {
        DVEFilterEditorModel *model = [self selectPartlyFilterFeature];
        identifier = model.identifier;
        if (identifier) {
            [dic setValue:identifier forKey:@"identifier"];
            NSNumber *intensity = @(model.intensity);
            [dic setValue:intensity forKey:@"intensity"];
        }
        return dic;
    }
    //如果是全局滤镜
    slot = self.vcContext.mediaContext.selectFilterSegment;
    if(slot) {
        DVEFilterEditorModel *model = [self selectGlobalFilterFeature];
        identifier = model.identifier;
        if (identifier) {
            [dic setValue:identifier forKey:@"identifier"];
            NSNumber *intensity = @(model.intensity);
            [dic setValue:intensity forKey:@"intensity"];
        }
    }
    return dic;
}

//返回当前局部滤镜feature信息
- (DVEFilterEditorModel *)selectPartlyFilterFeature
{
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentBlendVideoSlot];
    DVEFilterEditorModel *partlyFeature = nil;
    
    if(slot) {
        NSMutableArray<NLEFilter_OC*>* filters = [slot getFilter].copy;
        for (NLEFilter_OC *filter in filters) {
            
            if([filter.segmentFilter getType] == NLEResourceTypeAdjust) continue;///过滤调节资源
            
            NLESegmentFilter_OC *segFilter = filter.segmentFilter;
            NLEResourceNode_OC *resFilter = segFilter.effectSDKFilter;
            DVEFilterEditorModel *model = [[DVEFilterEditorModel alloc] init];
            model.name = segFilter.name;
            model.identifier = resFilter.resourceId;
            model.intensity = segFilter.intensity;
            model.resPath = resFilter.resourceFile;
            partlyFeature = model;
        }
        return partlyFeature;
    }
    return partlyFeature;
}
//返回当前选中的全局滤镜feature信息
- (DVEFilterEditorModel *)selectGlobalFilterFeature
{
    DVEFilterEditorModel *globalFeature = nil;
    NLETrackSlot_OC *slot = self.vcContext.mediaContext.selectFilterSegment;
    if (!slot) return globalFeature;

    NLESegmentFilter_OC *segFilter = (NLESegmentFilter_OC *)slot.segment;
    NLEResourceNode_OC* res = [segFilter getResNode];
    ///老逻辑全局滤镜存放在mainSegment，如果资源为空，则为新逻辑放在filter数组里
    if(res == nil){
        segFilter = [slot getFilter].firstObject.segmentFilter;
    }
    
    NLEResourceNode_OC *resFilter = segFilter.effectSDKFilter;
    if (resFilter.resourceType == NLEResourceTypeFilter) {
        DVEFilterEditorModel *model = [[DVEFilterEditorModel alloc] init];
        model.name = segFilter.name;
        model.identifier = resFilter.resourceId;
        model.intensity = segFilter.intensity;
        model.resPath = resFilter.resourceFile;
        globalFeature = model;
    }

    return globalFeature;
}

- (void)nleDidChangedWithPTS:(CMTime)time keyFrameInfo:(NLEAllKeyFrameInfo *)info {
    
    
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentBlendVideoSlotWithFilter];
    if(!slot) return;
    
    slot = [self.nle refreshAllKeyFrameInfo:info pts:self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC inSlot:slot];
    if (self.keyFrameDelegate &&
        [self.keyFrameDelegate respondsToSelector:@selector(filterKeyFrameDidChangedWithSlot:)]) {
        [self.keyFrameDelegate filterKeyFrameDidChangedWithSlot:slot];
    }
}

@end
