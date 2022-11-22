//
//  VEDebugCenter.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/2/3.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "VEDebugCenter.h"
#import <DoraemonKit/DoraemonKit.h>

@implementation VEDebugCenter

static VEDebugCenter *veDebugCenter = nil;

+ (instancetype)shareDebugCenter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        veDebugCenter = [[self alloc] init];
    });
    return veDebugCenter;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        veDebugCenter = [super allocWithZone:zone];
    });
    return veDebugCenter;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}


- (void)showCenter
{
    [[DoraemonManager shareInstance] install];
    [[DoraemonManager shareInstance] showDoraemon];
    self.isShow = YES;
}
- (void)dismissCenter
{
    self.isShow = NO;
    [[DoraemonManager shareInstance] hiddenDoraemon];
}

@end
