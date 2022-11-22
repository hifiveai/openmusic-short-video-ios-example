//
//  UIDevice+VECamera.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "UIDevice+VECamera.h"
#include <sys/sysctl.h>

@implementation UIDevice (VECamera)

- (NSArray<NSNumber *> *)systemCameraZoomFactors {
    static NSArray *factors;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *model;
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        model = [NSString stringWithUTF8String:machine];
        free(machine);
              
    });
    return  factors;
}
@end
