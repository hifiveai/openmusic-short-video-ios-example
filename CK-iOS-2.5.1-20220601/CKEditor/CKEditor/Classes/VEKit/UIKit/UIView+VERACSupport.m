//
//  UIView+VERACSupport.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "UIView+VERACSupport.h"

@implementation UIView (VERACSupport)

- (RACSignal *)VEaddTapGestureSignal
{
    return [self VEaddTapGestureSignalWithDelegate:nil];
}

- (RACSignal *)VEaddLongPressGestureSignal
{
    return [self VEaddLongPressGestureSignalWithDelegate:nil];
}

- (RACSignal *)VESwipePanGestureSignal
{
    return [self VESwipePanGestureSignalWithDelegate:nil];
}

- (RACSignal *)VEaddPanGestureSignal
{
    return [self VEaddPanGestureSignalWithDelegate:nil];
}

- (RACSignal *)VEaddPinchGestureSignal
{
    return [self VEaddPinchGestureSignalWithDelegate:nil];
}

- (RACSignal *)VEaddRotationGestureSignal
{
    return [self VEaddRotationGestureSignalWithDelegate:nil];
}

- (RACSignal *)VEaddTapGestureSignalWithDelegate:(id)delegate
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] init];
    gesture.delegate = delegate;
    [self addGestureRecognizer:gesture];
    return gesture.rac_gestureSignal;
}
- (RACSignal *)VEaddLongPressGestureSignalWithDelegate:(id)delegate
{
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] init];
    gesture.delegate = delegate;
    [self addGestureRecognizer:gesture];
    return gesture.rac_gestureSignal;
}
- (RACSignal *)VESwipePanGestureSignalWithDelegate:(id)delegate
{
    self.userInteractionEnabled = YES;
    UISwipeGestureRecognizer *sgesture = [[UISwipeGestureRecognizer alloc] init];
    sgesture.delegate = delegate;
    sgesture.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    
    [self addGestureRecognizer:sgesture];
    return sgesture.rac_gestureSignal;
}

- (RACSignal *)VEaddPanGestureSignalWithDelegate:(id)delegate
{
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] init];
    gesture.delegate = delegate;
    gesture.minimumNumberOfTouches = 2;
    [self addGestureRecognizer:gesture];
    return gesture.rac_gestureSignal;
}
- (RACSignal *)VEaddPinchGestureSignalWithDelegate:(id)delegate
{
    self.userInteractionEnabled = YES;
    UIPinchGestureRecognizer *gesture = [[UIPinchGestureRecognizer alloc] init];
    gesture.delegate = delegate;
    [self addGestureRecognizer:gesture];
    return gesture.rac_gestureSignal;
}
- (RACSignal *)VEaddRotationGestureSignalWithDelegate:(id)delegate
{
    self.userInteractionEnabled = YES;
    UIRotationGestureRecognizer *gesture = [[UIRotationGestureRecognizer alloc] init];
    gesture.delegate = delegate;
    [self addGestureRecognizer:gesture];
    return gesture.rac_gestureSignal;
}




@end
