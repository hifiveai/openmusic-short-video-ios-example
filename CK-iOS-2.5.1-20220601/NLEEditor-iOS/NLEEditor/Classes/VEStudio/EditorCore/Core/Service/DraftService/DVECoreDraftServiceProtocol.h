//
//   DVECoreDraftServiceProtocol.h
//   NLEEditor
//
//   Created  by bytedance on 2021/4/26.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVECoreProtocol.h"
#import <NLEPlatform/NLENativeDefine.h>
#import "DVEDraftModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DVECoreDraftServiceProtocol <DVECoreProtocol>
////草稿根目录路径
@property (nonatomic, copy) NSString *draftRootPath;
///当前编辑草稿路径
@property (nonatomic, copy, readonly) NSString *currentDraftPath;
///当前草稿数据模型
@property (nonatomic, strong) DVEDraftModel *draftModel;

/// 保存草稿对象模型
/// @param model 草稿对象
- (void)saveDraftModel:(DVEDraftModel *)model;

/// 恢复草稿对象模型
/// @param model 草稿对象
- (void)restoreDraftModel:(DVEDraftModel *)model;

/// 获取所有草稿
- (NSArray <DVEDraftModel *>*)getAllDrafts;

///添加草稿
- (void)addOneDarftWithModel:(DVEDraftModel *)draft;

///移除草稿
- (void)removeOneDraftModel:(DVEDraftModel *)draft;

/// 创建一个空的草稿对象
- (void)createDraftModel;


/// 拷贝资源到草稿目录
/// @param resourceURL 资源绝对路径
/// @param resourceType 资源类型
- (NSString * _Nullable)copyResourceToDraft:(NSURL *)resourceURL resourceType:(NLEResourceType)resourceType;


/// 根据资源绝对路径转换草稿相对路径
/// @param resourceURL 资源绝对路径
/// @param resourceType 资源类型
- (NSString * _Nullable)convertResourceToDraftPath:(NSURL *)resourceURL resourceType:(NLEResourceType)resourceType;


@end

NS_ASSUME_NONNULL_END
