//
//  VEDebugWindow.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/2/3.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "VEDebugWindow.h"
#import "VEDebugCenter.h"

@implementation VEDebugWindow

#pragma mark UIResponder

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (self.detectsShake) {
        if (event.type == UIEventTypeMotion && motion == UIEventSubtypeMotionShake) {
            [self detectWindowShake];
        }
    }
    else {
        //
        // NOTE:
        // By calling super-class method, default shaking method
        // e.g. UITextView's undo/redo will be safely performed.
        //
        [super motionEnded:motion withEvent:event];
    }
}

- (void)detectWindowShake
{
    VEDebugCenter *center = [VEDebugCenter shareDebugCenter];
    if (center.isShow) {
        [center dismissCenter];
    } else {
        [center showCenter];
    }
}


@end
