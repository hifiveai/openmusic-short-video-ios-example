//
//   DVEEffectEditor.m
//   NLEEditor
//
//   Created  by bytedance on 2021/4/25.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEEffectEditor.h"
#import "DVEVCContext.h"

@interface DVEEffectEditor ()

@property (nonatomic, weak) id<DVECoreDraftServiceProtocol> draftService;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;

@end

@implementation DVEEffectEditor

@synthesize vcContext = _vcContext;

DVEAutoInject(self.vcContext.serviceProvider, draftService, DVECoreDraftServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if(self = [super init]) {
        self.vcContext = context;
    }
    return self;
}

///自动判断更新特效
- (void)updateNLEEffect:(NSString *)effectObjID
             resourceId:(NSString *)resourceId
                   name:(NSString*)name
                resPath:(NSString*)resPath
             needCommit:(BOOL)commit {
    if (!resPath) return;
    
    NSString *relativePath = [self.draftService copyResourceToDraft:[NSURL fileURLWithPath:resPath] resourceType:NLEResourceTypeEffect];
    NLEModel_OC *model = self.nleEditor.nleModel;
    BOOL done = NO;
    for (NLETrack_OC *track in [model getTracks]) {
        if ([track getTrackType] == NLETrackEFFECT) {
            for(NLETrackSlot_OC *slot in track.slots){///目前全局特效只有一个插槽
                NLESegmentEffect_OC* segEffect = (NLESegmentEffect_OC *)slot.segment;
                NLEResourceNode_OC *resEffect = segEffect.effectSDKEffect;
                if ([resEffect.nle_nodeId isEqualToString:effectObjID]) {
                    resEffect.resourceFile = relativePath;
                    resEffect.resourceId = resourceId;
                    segEffect.effectName = name;
                    done = YES;
                    break;
                }
            }
        }else if([track getTrackType] == NLETrackVIDEO){
            for(NLETrackSlot_OC* slot in [track getEffect]){
                
                NLESegment_OC* segment = [slot segment];
                if([segment isKindOfClass:[NLESegmentEffect_OC class]]){
                    NLESegmentEffect_OC *segEffect = (NLESegmentEffect_OC*)segment;
                    NLEResourceNode_OC *resEffect = segEffect.effectSDKEffect;
                    if ([resEffect.nle_nodeId isEqualToString:effectObjID]) {
                        resEffect.resourceFile = relativePath;
                        resEffect.resourceId = resourceId;
                        segEffect.effectName = name;
                        done = YES;
                        break;
                    }
                }
            }
        }
    }

    if(done){
        [self.actionService commitNLE:commit];
    }
}

//获取所有特效slot，并根据layer层级分组
-(NSDictionary<NSNumber*,NSArray*>*)allLayerEffectDic {
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];

    for (NLETrack_OC *track in [self.nleEditor.nleModel getTracks]) {
        for (NLETrackSlot_OC *slot in [track getEffect]) {
            NLESegment_OC* segment = [slot segment];
            if([segment isKindOfClass:[NLESegmentEffect_OC class]]){
               NSMutableArray* array = [dic objectForKey:@(slot.layer)];
                if(!array){
                    array = [NSMutableArray array];
                    [dic setObject:array forKey:@(slot.layer)];
                }
                [array addObject:slot];
            }
        }
        for (NLETrackSlot_OC *slot in [track slots]){
            NLESegment_OC* segment = [slot segment];
            if([segment isKindOfClass:[NLESegmentEffect_OC class]]){
                NSMutableArray* array = [dic objectForKey:@(slot.layer)];
                 if(!array){
                     array = [NSMutableArray array];
                     [dic setObject:array forKey:@(slot.layer)];
                 }
                 [array addObject:slot];
            }
        }
    }
    return dic;
}

///复制当前特效
- (NSString *)copySelectedEffects{

    NLEModel_OC *model = self.nleEditor.nleModel;
    
    NLETimeSpaceNode_OC *timespaceNode = self.vcContext.mediaContext.selectEffectSegment;
    
    NLETrackSlot_OC* slot = (NLETrackSlot_OC *)timespaceNode;
    NLESegmentEffect_OC* seg =  (NLESegmentEffect_OC*)slot.segment;
    NLEResourceNode_OC *resEffect = seg.effectSDKEffect;
    
    ///结束时间不能超过视频时长
    CGFloat endSecond = MIN((CMTimeGetSeconds(slot.endTime) + CMTimeGetSeconds(slot.duration)), CMTimeGetSeconds(self.vcContext.mediaContext.duration));
    CMTimeRange timeRange = CMTimeRangeFromTimeToTime(slot.endTime, CMTimeMake(endSecond * USEC_PER_SEC, USEC_PER_SEC));
    NSInteger targetLayer = slot.layer;
    NSDictionary<NSNumber*,NSArray*> *dic = [self allLayerEffectDic];
    NSArray* layers = [[dic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 integerValue] > [obj2 integerValue];
    }];
    for(NSNumber* layer in layers){
        if([layer integerValue] < targetLayer) continue;///过滤层级比被复制的effect小的队列
        BOOL containEffect = NO;
        for(NLETrackSlot_OC* effect in [dic objectForKey:layer]){
            CMTimeRange range = CMTimeRangeGetIntersection(timeRange, effect.nle_targetTimeRange);
            if(CMTIMERANGE_IS_VALID(range) && !CMTIMERANGE_IS_EMPTY(range)){
                containEffect = YES;break;
            }
        }
        if(containEffect){
            targetLayer++;
        }else{
            break;
        }
    }
    
    NLETrack_OC *track = [self.nleEditor.nleModel trackContainSlotId:slot.nle_nodeId];
    if (track.extraTrackType == NLETrackEFFECT) {
        return [self addGlobalNewEffectWithPath:resEffect.resourceFile
                                                                  name:seg.effectName
                                                             startTime:timeRange.start
                                                               endTime:CMTimeRangeGetEnd(timeRange)
                                                           resourceTag:resEffect.resourceTag
                                                            resourceId:resEffect.resourceId
                                                                 layer:targetLayer
                                                            needCommit:YES];
    } else {
        for(NLETrack_OC* track in [model getTracks]){//默认添加到主轨道track，与当前effect同一layer的后面
            if([track isMainTrack]){
                return [self addPartlyNewEffectWithPath:resEffect.resourceFile name:seg.effectName identifier:resEffect.resourceId startTime:timeRange.start endTime:CMTimeRangeGetEnd(timeRange) layer:(int32_t)targetLayer forNode:track resourceTag:resEffect.resourceTag needCommit:YES];
            }
        }
    }

    return nil;
    
}

///自动判断删除特效
- (void)deleteNLEEffect:(NSString *)effectObjID needCommit:(BOOL)commit {
    if (!effectObjID) return;
    
    NLEModel_OC *model = self.nleEditor.nleModel;

    for (NLETrack_OC *track in [model getTracks]) {
        if ([track getTrackType] == NLETrackEFFECT) {
            for(NLETrackSlot_OC* slot in track.slots){///目前全局特效只有一个插槽
                if ([slot.nle_nodeId isEqualToString:effectObjID]) {
                    [track removeSlot:slot];
                    break;
                }
                NLESegmentEffect_OC* segEffect = (NLESegmentEffect_OC *)slot.segment;
                NLEResourceNode_OC *resEffect = segEffect.effectSDKEffect;
                if ([resEffect.nle_nodeId isEqualToString:effectObjID]) {
                    [track removeSlot:slot];
                    break;
                }
            }
            if(track.slots.count == 0){
                [model removeTrack:track];
            }

        }else if([track getTrackType] == NLETrackVIDEO){
            for(NLETrackSlot_OC* slot in [track getEffect]){
                if ([slot.nle_nodeId isEqualToString:effectObjID]) {
                    [track removeEffect:slot];
                    break;
                }
                
                NLESegment_OC* segment = [slot segment];
                if([segment isKindOfClass:[NLESegmentEffect_OC class]]){
                    NLESegmentEffect_OC *segEffect = (NLESegmentEffect_OC*)segment;
                    NLEResourceNode_OC *resEffect = segEffect.effectSDKEffect;
                    if ([resEffect.nle_nodeId isEqualToString:effectObjID]) {
                        [track removeEffect:slot];
                        break;
                    }
                }
            }
        }
    }
    
    [self.actionService commitNLE:commit];
}

///添加特效
- (NSString *)addGlobalNewEffectWithPath:(NSString *)path
                                   name:(NSString *)name
                              startTime:(CMTime )startTime
                                endTime:(CMTime )endTime
                            resourceTag:(NLEResourceTag)resourceTag
                             resourceId:(NSString * _Nullable)resourceId
                                  layer:(NSInteger)layer
                             needCommit:(BOOL)commit {
    NSAssert(resourceId, @"resourceId不能为空");
    NSString *relativePath = [self.draftService copyResourceToDraft:[NSURL fileURLWithPath:path] resourceType:NLEResourceTypeEffect];
    NLEModel_OC *model = self.nleEditor.nleModel;
    
    NLEResourceNode_OC *resEffect = [[NLEResourceNode_OC alloc] init];
    resEffect.resourceId = resourceId;
    resEffect.resourceFile = relativePath;
    resEffect.resourceType = NLEResourceTypeEffect;
    resEffect.resourceTag = resourceTag;
    
    NLESegmentEffect_OC *segEffect = [[NLESegmentEffect_OC alloc] init];
    [segEffect setEffectName:name];
    [segEffect setEffectSDKEffect:resEffect];
    segEffect.applyTargetType = NLESegmentEffectApplyTargetTypeGlobal;
    
    NSInteger maxLayer = [model nle_getMaxEffectLayer] + 1;
    
    NLETrackSlot_OC *effectSlot = [[NLETrackSlot_OC alloc] init];
    effectSlot.startTime = startTime;
    effectSlot.endTime = endTime;
    [effectSlot setSegmentEffect:segEffect];
    effectSlot.layer = layer < 0 ? maxLayer: layer;
 
    NLETrack_OC *effectTrack = [[NLETrack_OC alloc] init];
    [effectTrack addSlot:effectSlot];
    effectTrack.extraTrackType = NLETrackEFFECT;
    [model addTrack:effectTrack];
    
    [self.actionService commitNLE:commit];
    
    return resEffect.nle_nodeId;

}

- (NSString *)addPartlyNewEffectWithPath:(NSString *)path
                                   name:(NSString *)name
                              identifier:identifier
                              startTime:(CMTime )startTime
                                endTime:(CMTime )endTime
                                  layer:(int32_t)layer
                                forNode:(NLETimeSpaceNode_OC *)timespaceNode
                            resourceTag:(NLEResourceTag)resourceTag
                             needCommit:(BOOL)commit {
    
    if(!timespaceNode) return nil;
    NSString *relativePath = [self.draftService copyResourceToDraft:[NSURL fileURLWithPath:path] resourceType:NLEResourceTypeEffect];

    NLEResourceNode_OC *resEffect = [[NLEResourceNode_OC alloc] init];
    resEffect.resourceId = identifier;
    resEffect.resourceFile = relativePath;
    resEffect.resourceType = NLEResourceTypeEffect;
    resEffect.resourceTag = resourceTag;
    
    NLESegmentEffect_OC *segEffect = [[NLESegmentEffect_OC alloc] init];
    [segEffect setEffectName:name];
    [segEffect setEffectSDKEffect:resEffect];
    
    if ([timespaceNode isKindOfClass:NLETrackSlot_OC.class]) {
        NLEEffect_OC *effect = [[NLEEffect_OC alloc] init];
        effect.startTime = startTime;
        effect.endTime = endTime;
        effect.layer = MAX(0, layer);
        [effect setSegmentEffect:segEffect];
        [((NLETrackSlot_OC*)timespaceNode) addEffect:effect];
        
        NLETrack_OC *track = [self.nleEditor.nleModel trackContainSlotId:timespaceNode.nle_nodeId];
        if (track.isMainTrack) {
            segEffect.applyTargetType = NLESegmentEffectApplyTargetTypeMainVideo;
        } else {
            segEffect.applyTargetType = NLESegmentEffectApplyTargetTypeSubVideo;
        }
    }else if([timespaceNode isKindOfClass:NLETrack_OC.class]){
        NLETrack_OC *track = (NLETrack_OC*)timespaceNode;
        if (track.isMainTrack) {
            segEffect.applyTargetType = NLESegmentEffectApplyTargetTypeMainVideo;
        } else {
            segEffect.applyTargetType = NLESegmentEffectApplyTargetTypeSubVideo;
        }
        NLETrackSlot_OC *effectSlot = [[NLETrackSlot_OC alloc] init];
        effectSlot.startTime = startTime;
        effectSlot.endTime = endTime;
        effectSlot.layer = MAX(0, layer);
        [effectSlot setSegmentEffect:segEffect];
        [track addEffect:effectSlot];
    }else{
        return nil;
    }
    
    [self.actionService commitNLE:commit];
    
    return resEffect.nle_nodeId;
}

- (NSString*)addPartlyNewEffectWithPath:(NSString *)path name:(NSString *)name identifier:(NSString *)identifier startTime:(CMTime )startTime endTime:(CMTime )endTime forNode:(NLETimeSpaceNode_OC *)timespaceNode resourceTag:(NLEResourceTag)resourceTag needCommit:(BOOL)commit  {
    return [self addPartlyNewEffectWithPath:path name:name identifier:identifier startTime:startTime endTime:endTime layer:[self.nleEditor.nleModel nle_getMaxEffectLayer] + 1 forNode:timespaceNode resourceTag:resourceTag needCommit:commit];
}

- (NSString*)addPartlyNewEffectWithPath:(NSString *)path name:(NSString *)name identifier:(NSString *)identifier forTrack:(NLETrackSlot_OC *)track resourceTag:(NLEResourceTag)resourceTag needCommit:(BOOL)commit  {
    NSInteger endSecond = MIN((CMTimeGetSeconds(self.vcContext.mediaContext.currentTime) + 3), CMTimeGetSeconds(self.vcContext.mediaContext.duration));
    return [self addPartlyNewEffectWithPath:path name:name identifier:identifier startTime:CMTimeMake(CMTimeGetSeconds(self.vcContext.mediaContext.currentTime) * USEC_PER_SEC, USEC_PER_SEC) endTime:CMTimeMake(endSecond * USEC_PER_SEC, USEC_PER_SEC) forNode:track resourceTag:resourceTag  needCommit:commit];
}

- (NSString*)addPartlyNewEffectWithPath:(NSString *)path name:(NSString *)name identifier:(NSString *)identifier forSlot:(NLETrackSlot_OC *)slot resourceTag:(NLEResourceTag)resourceTag needCommit:(BOOL)commit  {
    NSInteger endSecond = MIN((CMTimeGetSeconds(self.vcContext.mediaContext.currentTime) + 3), CMTimeGetSeconds(self.vcContext.mediaContext.duration));
    return [self addPartlyNewEffectWithPath:path name:name identifier:identifier startTime:CMTimeMake(CMTimeGetSeconds(self.vcContext.mediaContext.currentTime) * USEC_PER_SEC, USEC_PER_SEC) endTime:CMTimeMake(endSecond * USEC_PER_SEC, USEC_PER_SEC) forNode:slot  resourceTag:(NLEResourceTag)resourceTag needCommit:commit];
}

- (void)movePartlyEffectToGlobal:(NSString*)effectObjID fromSlot:(NLETrackSlot_OC *)fromSlot{
    if (!fromSlot) return;

    NLEModel_OC *model = self.nleEditor.nleModel;
    NLETrack_OC* fromTrack = [self trackBySlotID:fromSlot.nle_nodeId];
    
    for(NLETrackSlot_OC* slot in [fromTrack getEffect]){
        
        NLESegment_OC* segment = [slot segment];
        if([segment isKindOfClass:[NLESegmentEffect_OC class]]){
            NLESegmentEffect_OC *segEffect = (NLESegmentEffect_OC*)segment;
            NLEResourceNode_OC *resEffect = segEffect.effectSDKEffect;
            if ([resEffect.nle_nodeId isEqualToString:effectObjID]) {
                [fromTrack removeEffect:slot];
                
                NLETrack_OC *effectTrack = [[NLETrack_OC alloc] init];
                
                NLETrackSlot_OC *effectSlot = [[NLETrackSlot_OC alloc] init];
                effectSlot.startTime = slot.startTime;
                effectSlot.endTime = slot.endTime;
                segEffect.applyTargetType = NLESegmentEffectApplyTargetTypeGlobal;
                [effectSlot setSegmentEffect:segEffect];
                effectSlot.layer = slot.layer;
                
                [effectTrack addSlot:effectSlot];
                [model addTrack:effectTrack];
                
                [self.actionService commitNLE:YES];
                
                return;
            }
        }

    }

}

- (void)moveGlobalEffectToPartly:(NLETrackSlot_OC *)globalSlot partlySlot:(NLETrackSlot_OC *)partlySlot{
    
    NLEModel_OC* model = self.nleEditor.nleModel;
    NLETrack_OC* globalTrack = [self trackBySlotID:globalSlot.nle_nodeId];
    
    if(!globalTrack){
        return;
    }

    NLETrack_OC* partlyTrack = [self trackBySlotID:partlySlot.nle_nodeId];
    [partlyTrack addEffect:globalSlot];
    [globalTrack removeSlot:globalSlot];
    
    if ([globalSlot.segment isKindOfClass:NLESegmentEffect_OC.class]) {
        NLESegmentEffect_OC *segEffect = (NLESegmentEffect_OC *)globalSlot.segment;
        if (partlyTrack.isMainTrack) {
            segEffect.applyTargetType = NLESegmentEffectApplyTargetTypeMainVideo;
        } else {
            segEffect.applyTargetType = NLESegmentEffectApplyTargetTypeSubVideo;
        }
    }
    
    if(globalTrack.slots.count == 0){
        [model removeTrack:globalTrack];
    }

    [self.actionService commitNLE:YES];
}

- (void)movePartlyEffectToOtherPartly:(NSString*)effectObjID fromSlot:(NLETrackSlot_OC *)fromSlot toSlot:(NLETrackSlot_OC *)toSlot{
    if (!fromSlot || !toSlot) return;
    
    NLETrack_OC* fromTrack = [self trackBySlotID:fromSlot.nle_nodeId];
    NLETrack_OC* toTrack = [self trackBySlotID:toSlot.nle_nodeId];
    
    for(NLETrackSlot_OC* slot in [fromTrack getEffect]){
        
        NLESegment_OC* segment = [slot segment];
        if([segment isKindOfClass:[NLESegmentEffect_OC class]]){
            NLESegmentEffect_OC *segEffect = (NLESegmentEffect_OC*)segment;
            NLEResourceNode_OC *resEffect = segEffect.effectSDKEffect;
            if ([resEffect.nle_nodeId isEqualToString:effectObjID]) {
                [fromTrack removeEffect:slot];
                
                NLETrackSlot_OC *effectSlot = [[NLETrackSlot_OC alloc] init];
                effectSlot.startTime = slot.startTime;
                effectSlot.endTime = slot.endTime;
                if (toTrack.isMainTrack) {
                    segEffect.applyTargetType = NLESegmentEffectApplyTargetTypeMainVideo;
                } else {
                    segEffect.applyTargetType = NLESegmentEffectApplyTargetTypeSubVideo;
                }
                [effectSlot setSegmentEffect:segEffect];
                effectSlot.layer = slot.layer;

                [toTrack addEffect:effectSlot];
                
                [self.actionService commitNLE:YES];
                
                return;;
            }
        }
    }
    
}

- (NLETrackSlot_OC * _Nullable)partlySlotByeffectObjID:(NSString*)effectObjID
{
    for (NLETrack_OC *track in [self.nleEditor.nleModel getTracks]) {
        if ([track getTrackType] != NLETrackEFFECT) {//查找非特效的track
            for (NLETrackSlot_OC *slot in [track getEffect]) {
                
                NLESegment_OC* segment = [slot segment];
                if([segment isKindOfClass:[NLESegmentEffect_OC class]]){
                    NLESegmentEffect_OC *segEffect = (NLESegmentEffect_OC*)segment;
                    NLEResourceNode_OC *resEffect = segEffect.effectSDKEffect;
                    if ([resEffect.nle_nodeId isEqualToString:effectObjID]) {
                        return slot;
                    }
                }
            }
        }
    }
    return nil;
}

- (NLETrackSlot_OC * _Nullable)globalSlotByeffectObjID:(NSString*)effectObjID
{
    for (NLETrack_OC *track in [self.nleEditor.nleModel getTracks]) {
        if ([track getTrackType] == NLETrackEFFECT) {//查找特效的track
            for (NLETrackSlot_OC *slot in [track slots]){
                NLESegment_OC* segment = [slot segment];
                if([segment isKindOfClass:[NLESegmentEffect_OC class]]){
                    NLESegmentEffect_OC *segEffect = (NLESegmentEffect_OC*)segment;
                    NLEResourceNode_OC *resEffect = segEffect.effectSDKEffect;
                    if ([resEffect.nle_nodeId isEqualToString:effectObjID]) {
                        return slot;
                    }
                }
            }
        }
    }
    return nil;
}

- (NLETrackSlot_OC * _Nullable)slotByeffectObjID:(NSString*)effectObjID
{
    for (NLETrack_OC *track in [self.nleEditor.nleModel getTracks]) {
        for (NLETrackSlot_OC *slot in [track getEffect]) {
            NLESegment_OC* segment = [slot segment];
            if([segment isKindOfClass:[NLESegmentEffect_OC class]]){
                NLESegmentEffect_OC *segEffect = (NLESegmentEffect_OC*)segment;
                NLEResourceNode_OC *resEffect = segEffect.effectSDKEffect;
                if ([resEffect.nle_nodeId isEqualToString:effectObjID]) {
                    return slot;
                }
            }
        }
        for (NLETrackSlot_OC *slot in [track slots]) {
            NLESegment_OC* segment = [slot segment];
            if([segment isKindOfClass:[NLESegmentEffect_OC class]]){
                NLESegmentEffect_OC *segEffect = (NLESegmentEffect_OC*)segment;
                NLEResourceNode_OC *resEffect = segEffect.effectSDKEffect;
                if ([resEffect.nle_nodeId isEqualToString:effectObjID]) {
                    return slot;
                }
            }
        }
    }
    return nil;
}

- (NLETrack_OC * _Nullable)trackBySlotID:(NSString*)slotID
{
    NLEModel_OC *model = self.nleEditor.nleModel;
    NLETrack_OC* track = [model trackContainSlotId:slotID];
    if(track == nil){
        for (NLETrack_OC *t in [model getTracks]) {
            for (NLETrackSlot_OC *slot in [t getEffect]) {
                if([[slot nle_nodeId] isEqualToString:slotID]){
                    return t;
                }
            }
        }
    }
    return track;
}

- (BOOL)isGobalEffectBySlotID:(NSString*)slotID
{
    NLEModel_OC *model = self.nleEditor.nleModel;
    NLETrack_OC* track = [model trackContainSlotId:slotID];
    if(track != nil){
        return YES;
    }
    return NO;
}

@end
