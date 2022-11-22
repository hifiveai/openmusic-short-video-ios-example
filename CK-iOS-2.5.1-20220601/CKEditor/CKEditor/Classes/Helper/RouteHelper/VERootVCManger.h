//
//  VERootVCManger.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define VETOPVC ((UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController).topViewController

@interface VERootVCManger : NSObject

+ (instancetype)shareManager;
- (void)swichRootVC;

@end

NS_ASSUME_NONNULL_END
