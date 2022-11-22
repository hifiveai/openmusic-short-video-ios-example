//
//   DVECoreFilterProtocol.h
//   NLEEditor
//
//   Created  by bytedance on 2021/4/26.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVECoreProtocol.h"
#import <NLEPlatform/NLEResourceNode+iOS.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DVEFilterKeyFrameProtocol <NSObject>

- (void)filterKeyFrameDidChangedWithSlot:(NLETrackSlot_OC *)slot;

@end

@protocol DVECoreFilterProtocol <DVECoreProtocol>


@property (nonatomic, weak) id<DVEFilterKeyFrameProtocol> keyFrameDelegate;

///适用于选择滤镜按钮，更新或者添加滤镜，会自动判断是全局还是局部滤镜
/// @param path 滤镜资源路径
/// @param name 滤镜资源名称
/// @param identifier 滤镜资源唯一标识符
/// @param intensity 滤镜强度值
/// @param resourceTag 滤镜资源类型（amazing或者是normal类型）
/// @param commit 提交NLE（提交后可以undo）
- (void)addOrUpdateFilterWithPath:(NSString *)path name:(NSString *)name identifier:(NSString *)identifier intensity:(CGFloat)intensity resourceTag:(NLEResourceTag)resourceTag needCommit:(BOOL)commit;

/// 适用于取消或删除按钮，会自动判断是全局还是局部滤镜
/// @param commit 提交NLE（提交后可以undo）
- (void)deleteCurrentFilterNeedCommit:(BOOL)commit;

/// 获取一个关于当前滤镜效果的字典 "identifier" : 滤镜资源唯一标识符    "intensity" : 滤镜强度值
- (NSDictionary *)currentFilterIntensity;


@end

NS_ASSUME_NONNULL_END
