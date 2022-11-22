//
//  DVENoEventView.m
//  CameraClient
//
//  Created by bytedance on 2020/7/16.
//

#import "DVENoEventView.h"

@implementation DVENoEventView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result = [super hitTest:point withEvent:event];
    if (result == self) {
        return nil;
    }
    return result;
}

@end
