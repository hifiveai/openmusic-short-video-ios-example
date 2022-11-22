//
//  DVECustomerHUD.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVECustomerHUD : NSObject

+ (void)showMessage:(NSString *)msg;
+ (void)showMessage:(NSString *)msg afterDele:(NSTimeInterval)seconds;
+ (void)showProgress;
+ (void)setProgressLableWithText:(NSString *)text;
+ (void)hidProgress;
+ (void)showProgressInView:(UIView*)view;
+ (void)hidProgressInView:(UIView*)view;
@end

NS_ASSUME_NONNULL_END
