//
//  DVEAlbumResponder.h
//
//  Created by bytedance on 15/11/5.
//  Copyright © 2015年 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DVEAlbumResponder : NSObject

/**
 * @brief 寻找responder的NavigationController
 *
 * @param responder View或者ViewController
 */
+ (nullable UINavigationController *)topNavigationControllerForResponder:(nullable UIResponder *)responder;

/**
 * @brief 当前ViewController栈上，寻找top rootViewController
 */
+ (nullable UIViewController *)topViewController;


/**
 * @brief 当前ViewController栈上，寻找top rootViewController，返回其root view
 */
+ (nullable UIView *)topView;

/**
 * @brief 从指定ViewController开始的ViewController栈上，寻找top rootViewController
 *
 * @param rootViewController 寻找的起点ViewController
 */
+ (nullable UIViewController *)topViewControllerForController:(nonnull UIViewController *)rootViewController;

/**
 * @brief 从指定View开始的ViewController栈上，寻找top rootViewController
 *
 * @param view 寻找的起点View
 */
+ (nullable UIViewController *)topViewControllerForView:(nonnull UIView *)view;

/**
 * @brief 从指定responder开始的ViewController栈上，寻找top rootViewController
 *
 * @param responder View或者ViewController
 */
+ (nullable UIViewController *)topViewControllerForResponder:(nonnull UIResponder *)responder;

@end

///////////////////////////////////////////////////////////////////////////////////

//@interface UIViewController (ACC_Close)
//
//@end



