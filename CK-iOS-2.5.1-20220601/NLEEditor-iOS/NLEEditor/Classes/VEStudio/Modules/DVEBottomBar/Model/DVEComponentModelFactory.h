//
//   DVEComponentModelFactory.h
//   NLEEditor
//
//   Created  by ByteDance on 2021/6/3.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "DVEBarComponentProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEComponentModelFactory : NSObject

/// 构建节点
/// @param type 节点类型
/// @param parent 父节点
/// @param create 是否构建子节点
+ (id<DVEBarComponentProtocol>)createComponentWithType:(DVEBarComponentType)type
                                                parent:(id<DVEBarComponentProtocol> __nullable)parent
                                    createSubComponent:(BOOL)create;

@end

NS_ASSUME_NONNULL_END
