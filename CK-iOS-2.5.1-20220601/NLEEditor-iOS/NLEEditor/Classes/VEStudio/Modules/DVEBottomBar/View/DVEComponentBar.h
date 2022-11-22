//
//   DVEComponentBar.h
//   NLEEditor
//
//   Created  by ByteDance on 2021/6/1.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEBaseBar.h"
#import "DVEBarComponentProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEComponentBar : DVEBaseBar


/// backComponent字典一般存储两个返回节点，key值为DVEBarSubComponentGroup的两个枚举值转化成的NSNumber对象
@property(nonatomic,strong) NSMutableDictionary<NSNumber *, id<DVEBarComponentProtocol>> * backComponentDic;

@property(nonatomic,strong) id<DVEBarComponentProtocol> component;

@property (nonatomic, assign, readonly) DVEBarComponentType panelType;

@end

NS_ASSUME_NONNULL_END
