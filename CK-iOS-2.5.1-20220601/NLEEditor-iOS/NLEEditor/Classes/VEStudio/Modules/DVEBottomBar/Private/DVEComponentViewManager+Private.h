//
//   DVEComponentViewManager+Private.h
//   NLEEditor
//
//   Created  by ByteDance on 2021/6/10.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEComponentViewManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEComponentViewManager (Private)

/// 展示历史路径上一个bar
/// @param animation 展示动画
-(DVEComponentBar*)popToParentComponent:(BOOL)animation;

/// 展示历史路径上一个bar，不展示动画
-(DVEComponentBar*)popToParentComponent;

/// 指定展示bar
/// @param type 展示节点类型
/// @param animation 动画
-(DVEComponentBar*)showComponent:(id<DVEBarComponentProtocol>)type animation:(BOOL)animation;

/// 指定展示bar
/// @param type 展示节点类型 ，不展示动画
-(DVEComponentBar*)showComponent:(id<DVEBarComponentProtocol>)type;

@end

NS_ASSUME_NONNULL_END
