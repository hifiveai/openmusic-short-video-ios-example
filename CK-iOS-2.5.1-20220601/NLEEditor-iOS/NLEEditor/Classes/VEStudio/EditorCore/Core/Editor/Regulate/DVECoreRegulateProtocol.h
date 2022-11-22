//
//   DVECoreRegulateProtocol.h
//   NLEEditor
//
//   Created  by bytedance on 2021/5/10.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVECoreProtocol.h"
#import <NLEPlatform/NLEResourceNode+iOS.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DVERegulateKeyFrameProtocol <NSObject>

- (void)regulateKeyFrameDidChangedWithSlot:(NLETrackSlot_OC *)slot;

@end


@protocol DVECoreRegulateProtocol <DVECoreProtocol>


@property (nonatomic, weak) id<DVERegulateKeyFrameProtocol> keyFrameDelegate;

/// 适用于选择调节按钮，更新或者添加调节，会自动判断是全局还是局部调节
/// @param path 调节资源路径
/// @param name 调节资源名称
/// @param identifier 调节资源唯一标识符
/// @param intensity 调节强度值
/// @param resourceTag 调节资源类型（amazing或者是normal类型）
/// @param commit 提交NLE（提交后可以undo）
- (void)addOrUpdateAjustFeatureWithPath:(NSString *)path name:(NSString *)name identifier:identifier intensity:(CGFloat)intensity resourceTag:(NLEResourceTag)resourceTag needCommit:(BOOL)commit;

/// 重置当前全部的调节参数
/// @param commit 提交NLE（提交后可以undo）
- (void)resetAllRegulateNeedCommit:(BOOL)commit;

/// 删除选中的调节slot
- (void)deleteSelectRegulateSegment;

- (NSDictionary *)currentAdjustIntensity;

@end

NS_ASSUME_NONNULL_END
