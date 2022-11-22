//
//  VEUIHelper.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEUIHelper.h"

@interface VEUIHelper ()

@property (nonatomic, strong) UINavigationController *vc;

@end

@implementation VEUIHelper

static VEUIHelper *instance = nil;

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
        if (@available(iOS 11.0, *)) {
            self.bottomBarMargn = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
        } else {
            self.bottomBarMargn = 0;
        }
        self.topBarMargn = self.vc.navigationBar.height + [UIApplication sharedApplication].statusBarFrame.size.height - 64;
    }
    return self;
}

- (UINavigationController *)vc
{
    if (!_vc) {
        _vc = [[UINavigationController alloc] initWithRootViewController:[UIViewController new]];
    }
    
    return _vc;
}


@end
