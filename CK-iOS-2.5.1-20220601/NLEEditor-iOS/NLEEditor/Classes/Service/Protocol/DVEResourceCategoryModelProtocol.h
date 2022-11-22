//
//   DVEResourceCategoryModelProtocol.h
//   NLEEditor
//
//   Created  by bytedance on 2021/5/14.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import <Foundation/Foundation.h>
#import "DVEResourceModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DVEResourceCategoryModelProtocol <NSObject>
///分类ID 目前内部暂无使用，业务方可自由使用
@property(nonatomic,strong)NSString* categoryId;
///顺序 目前暂无使用
@property(nonatomic,assign)NSInteger order;
///分类名  分类展示使用
@property(nonatomic,strong)NSString* name;
///模型列表 
@property(nonatomic,strong)NSArray<id<DVEResourceModelProtocol>>* models;

@end

NS_ASSUME_NONNULL_END
