//
//  VERouteHelper.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VERouteHelper.h"
#import "VECapViewController.h"
#import <NLEEditor/DVEUIFactory.h>

NSString * const kVEVideoEditViewController = @"视频创作";
NSString * const kVECaptureEditViewController = @"视频拍摄";

static NSDictionary *VEControllerDic;

@implementation VERouteHelper

+ (NSDictionary *)VEControllerDic
{
    if (!VEControllerDic) {
        VEControllerDic = @{
            
            kVECaptureEditViewController : [VECapViewController class],
            
            kVEVideoEditViewController : [UIViewController class],
        };
    }
    
    return VEControllerDic;
}

+ (void)routeForVCWithName:(NSString *)vcName
{
    Class class = [[self VEControllerDic] valueForKey:vcName];
    if (class) {
        UIViewController *vc = [[class alloc] init];
        UINavigationController *nav  = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        UIViewController *topVC = ((UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController).topViewController;
        [topVC presentViewController:nav animated:YES completion:^{
            
        }];
    }
}

@end
