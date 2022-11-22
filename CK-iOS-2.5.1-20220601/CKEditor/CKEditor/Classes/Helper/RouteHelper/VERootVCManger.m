//
//  VERootVCManger.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VERootVCManger.h"
#import "VEHomeViewController.h"

@interface VERootVCManger ()

@property (nonatomic, strong) VEHomeViewController *homeVC;
@property (nonatomic, weak) UIViewController *curVC;

@end

@implementation VERootVCManger

static VERootVCManger *instance = nil;

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {

    }
    return self;
}

- (void)swichRootVC
{
    UIViewController *vc = nil;
    vc = self.homeVC;
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    if (!window) {
        [UIApplication sharedApplication].delegate.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window = [UIApplication sharedApplication].delegate.window;
    }
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    window.rootViewController = nav;
    [window makeKeyAndVisible];
    [UIApplication  sharedApplication].keyWindow.backgroundColor = [UIColor whiteColor];
        
}
#pragma UIView实现动画
- (void)animationWithView: (UIView *)view WithAnimationTransition:(UIViewAnimationTransition) transition complet:(void (^)(void))complet
{
    [UIView animateWithDuration:0.75 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:transition forView:view cache:YES];
        
    } completion:^(BOOL finished) {
        if (complet) {
            complet();
        }
    }];
}

#pragma mark - getter

- (VEHomeViewController *)homeVC
{
    if (!_homeVC) {
        _homeVC = [VEHomeViewController new];
    }
    
    return _homeVC;
}


@end
