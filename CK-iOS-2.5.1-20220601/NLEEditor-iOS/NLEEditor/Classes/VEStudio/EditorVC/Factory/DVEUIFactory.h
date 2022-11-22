//
//   DVEUIFactory.h
//   NLEEditor
//
//   Created  by bytedance on 2021/5/24.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    
 
#import <Foundation/Foundation.h>
#import "DVEVCContextExternalInjectProtocol.h"
#import "DVEDraftModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEUIFactory : NSObject

/// 默认剪辑页
+ (UIViewController *)createDVEViewController;

/// 通过资源模型和能力注入构造剪辑页
/// @param resources 模型数组
/// @param injectService 外部注入能力
+ (UIViewController *)createDVEViewControllerWithResources:(NSArray<id<DVEResourcePickerModel>> *)resources
                                             injectService:(id<DVEVCContextExternalInjectProtocol>)injectService;


/// 通过草稿模型和能力注入构造剪辑页
/// @param draft 草稿模型
/// @param injectService 外部注入能力
+ (UIViewController *)createDVEViewControllerWithDraft:(DVEDraftModel *)draft
                                         injectService:(id<DVEVCContextExternalInjectProtocol>)injectService;

/// 通过NLEModel模型和能力注入构造剪辑页
///  @param model NLEModel
/// @param draftFolder 草稿目录
/// @param injectService 外部注入能力
+ (UIViewController *)createDVEViewControllerWithNLEModelString:(NSString *)nleModelString
                                              draftFolder:(NSString *)draftFolder
                                            injectService:injectService;

/// 草稿管理页
/// @param injectService 外部注入能力
+ (UIViewController *) createDVEDraftViewControllerWithInjectService:(id<DVEVCContextExternalInjectProtocol>)injectService;

@end

NS_ASSUME_NONNULL_END
