//
//   DVEGlobalExternalInjectProtocol.h
//   NLEEditor
//
//   Created  by ByteDance on 2021/9/10.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 实现该协议所注入的对象的生命周期与 APP 绑定
@protocol DVEGlobalExternalInjectProtocol <NSObject>

//草稿存放根目录
- (NSString *)draftFolderPath;

//UI配置文件和icon资源存放的bundle
- (NSBundle *)customResourceProvideBundle;

//是否启动关键帧
- (BOOL)enableKeyframeAbility;

@end

NS_ASSUME_NONNULL_END
