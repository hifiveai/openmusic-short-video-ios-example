//
//  VECustomerHUD.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VECustomerHUD : NSObject

+ (void)showMessage:(NSString *)msg;
+ (void)showMessage:(NSString *)msg afterDele:(NSTimeInterval)seconds;
+ (VECustomerHUD *)showProgress;
- (void)setProgressLableWithText:(NSString *)text;
+ (void)hidProgress;

@end

NS_ASSUME_NONNULL_END
