//
//  DVEAlbumResponder.m
//  Essay
//
//  Created by bytedance on 15/11/5.
//  Copyright © 2015年 Bytedance. All rights reserved.
//

#import "DVEAlbumResponder.h"

@implementation DVEAlbumResponder

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wincompatible-pointer-types"
#pragma clang diagnostic pop

+ (UINavigationController *)topNavigationControllerForResponder:(UIResponder *)responder
{
    UIViewController *topViewController = [self topViewControllerForResponder:responder];
    if ([topViewController isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)topViewController;
    } else if (topViewController.navigationController) {
        return topViewController.navigationController;
    } else {
        return nil;
    }
}

+ (UIViewController *)topViewController
{
    return [self topViewControllerForController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIView *)topView
{
    return [self topViewController].view;
}

+ (UIViewController *)topViewControllerForController:(UIViewController *)rootViewController
{
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self topViewControllerForController:[navigationController.viewControllers lastObject]];
    }
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabController = (UITabBarController *)rootViewController;
        return [self topViewControllerForController:tabController.selectedViewController];
    }
    if (rootViewController.presentedViewController) {
        return [self topViewControllerForController:rootViewController.presentedViewController];
    }
    return rootViewController;
}

+ (UIViewController *)topViewControllerForView:(UIView *)view
{
    UIResponder *responder = view;
    while(responder && ![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
    }
    
    if(!responder) {
        responder = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    
    return [self topViewControllerForController:(UIViewController *)responder];
}

+ (UIViewController *)topViewControllerForResponder:(UIResponder *)responder
{
    if ([responder isKindOfClass:[UIView class]]) {
        return [self topViewControllerForView:(UIView *)responder];
    } else if ([responder isKindOfClass:[UIViewController class]]) {
        return [self topViewControllerForController:(UIViewController *)responder];
    } else {
        return [self topViewController];
    }
}


@end

//@implementation UIViewController (ACC_Close)
//
//
//@end



