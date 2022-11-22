//
//   VEResourceModel.h
//   TTVideoEditorDemo
//
//   Created  by bytedance on 2021/5/14.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    
 
#import <Foundation/Foundation.h>
#import <NLEEditor/DVEResourceCategoryModelProtocol.h>
#import <NLEEditor/DVETextTemplateDepResourceModelProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEResourceCategoryModel : NSObject<DVEResourceCategoryModelProtocol>

@end

@interface VEResourceModel : NSObject<DVEResourceModelProtocol>

@end

@interface VETextTemplateDepResourceModel : NSObject<DVETextTemplateDepResourceModelProtocol>

@end

NS_ASSUME_NONNULL_END
