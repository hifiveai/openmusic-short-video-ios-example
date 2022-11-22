//
//   VEVCCoreEffectProtocol.h
//   NLEEditor
//
//   Created  by bytedance on 2021/4/25.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVECoreProtocol.h"
#import <AVKit/AVKit.h>
#import <NLEPlatform/NLEResourceNode+iOS.h>

NS_ASSUME_NONNULL_BEGIN

@class NLETimeSpaceNode_OC;


@protocol DVECoreEffectProtocol <DVECoreProtocol>

/// 更新特效
/// @param effectObjID 特效唯一ID（effect对象生成的标示ID,通过effectObjID在track和effect数组中找到对应的slot对象）
/// @param resourceId 后台的资源id
/// @param resPath 资源路径
/// @param name 特效名称
/// @param commit 提交NLE（提交后可undo）
- (void)updateNLEEffect:(NSString *)effectObjID
             resourceId:(NSString *)resourceId
                   name:(NSString*)name
                resPath:(NSString*)resPath
             needCommit:(BOOL)commit;

// 删除特效
/// @param effectObjID 特效唯一ID（effect对象生成的标示ID,通过effectObjID在track和effect数组中找到对应的slot对象）
/// @param commit 提交NLE（提交后可undo）
- (void)deleteNLEEffect:(NSString *)effectObjID needCommit:(BOOL)commit;

///复制当前特效
- (NSString*)copySelectedEffects;

///添加全局特效
/// @param path 资源路径
/// @param name 特效名称
/// @param startTime 特效开始时间
/// @param endTime 特效结束时间
/// @param resourceTag 资源类型
/// @param resourceId 资源Id
/// @param commit 提交NLE（提交后可undo）
- (NSString *)addGlobalNewEffectWithPath:(NSString *)path
                                    name:(NSString *)name
                               startTime:(CMTime )startTime
                                 endTime:(CMTime )endTime
                             resourceTag:(NLEResourceTag)resourceTag
                              resourceId:(NSString * _Nullable)resourceId
                                   layer:(NSInteger)layer
                              needCommit:(BOOL)commit;

///添加局部特效(默认特效时间起点为当前时间尺，结束点为后3秒)
/// @param path 资源路径
/// @param name 特效名称
/// @param slot 指定SLot（主轨道/副轨道的VideoSlot）
/// @param resourceTag 资源类型
/// @param commit 提交NLE（提交后可undo）
- (NSString*)addPartlyNewEffectWithPath:(NSString *)path name:(NSString *)name identifier:(NSString *)identifier forSlot:(NLETrackSlot_OC *)slot resourceTag:(NLEResourceTag)resourceTag needCommit:(BOOL)commit;


///添加局部特效(默认特效时间起点为当前时间尺，结束点为后3秒)
/// @param path 资源路径
/// @param name 特效名称
/// @param track 指定Track（主轨道/副轨道）
/// @param resourceTag 资源类型
/// @param commit 提交NLE（提交后可undo）
- (NSString*)addPartlyNewEffectWithPath:(NSString *)path name:(NSString *)name identifier:(NSString *)identifier forTrack:(NLETrack_OC *)track resourceTag:(NLEResourceTag)resourceTag needCommit:(BOOL)commit;


///添加局部特效
/// @param path 资源路径
/// @param name 特效名称
/// @param identifier 资源唯一标识符
/// @param startTime 特效开始时间
/// @param endTime 特效结束时间
/// @param timespaceNode 指定Slot/Track
/// @param resourceTag 资源类型
/// @param commit 提交NLE（提交后可undo）
- (NSString*)addPartlyNewEffectWithPath:(NSString *)path name:(NSString *)name identifier:(NSString *)identifier startTime:(CMTime)startTime endTime:(CMTime)endTime forNode:(NLETimeSpaceNode_OC *)timespaceNode resourceTag:(NLEResourceTag)resourceTag needCommit:(BOOL)commit;

///把局部特效移动到全局特效
/// @param effectObjID 特效唯一ID（effect对象生成的标示ID,通过effectObjID在fromSlot找到对应的effect对象）
/// @param fromSlot 局部特效
- (void)movePartlyEffectToGlobal:(NSString*)effectObjID fromSlot:(NLETrackSlot_OC *)fromSlot;


///把全局特效移动到局部特效
/// @param globalSlot 全局特效Slot
/// @param partlySlot 局部特效Slot （主轨道/副轨道的VideoSlot）
- (void)moveGlobalEffectToPartly:(NLETrackSlot_OC *)globalSlot partlySlot:(NLETrackSlot_OC *)partlySlot;


///把局部特效移动到另外局部特效
/// @param effectObjID 特效唯一ID（effect对象生成的标示ID,通过effectObjID在fromSlot找到对应的effect对象）
/// @param fromSlot 局部特效Slot （主轨道/副轨道的VideoSlot）
/// @param toSlot 局部特效Slot （主轨道/副轨道的VideoSlot）
- (void)movePartlyEffectToOtherPartly:(NSString*)effectObjID fromSlot:(NLETrackSlot_OC *)fromSlot toSlot:(NLETrackSlot_OC *)toSlot;

///通过唯一特效ID反查局部特效所属slot
/// @param effectObjID 特效唯一ID（effect对象生成的标示ID,通过effectObjID在track的effect数组找到对应的slot对象）
- (NLETrackSlot_OC * _Nullable)partlySlotByeffectObjID:(NSString*)effectObjID;

///通过唯一特效ID反查全局特效所属slot
/// @param effectObjID 特效唯一ID（effect对象生成的标示ID,通过effectObjID在track中找到对应的slot对象）
- (NLETrackSlot_OC * _Nullable)globalSlotByeffectObjID:(NSString*)effectObjID;

///通过唯一特效ID特效所属slot
/// @param effectObjID 特效唯一ID（effect对象生成的标示ID,通过effectObjID在track和effect数组中找到对应的slot对象）
- (NLETrackSlot_OC * _Nullable)slotByeffectObjID:(NSString*)effectObjID;


/// 通过SlotID判断是否全局特效
/// @param slotID slotID
- (BOOL)isGobalEffectBySlotID:(NSString*)slotID;

@end

NS_ASSUME_NONNULL_END
