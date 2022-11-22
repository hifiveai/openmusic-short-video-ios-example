//
//  UIView+VERACSupport.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface UIView (VERACSupport)<UIGestureRecognizerDelegate>

- (RACSignal *)VEaddTapGestureSignal;
- (RACSignal *)VEaddLongPressGestureSignal;
- (RACSignal *)VESwipePanGestureSignal;
- (RACSignal *)VEaddPanGestureSignal;
- (RACSignal *)VEaddPinchGestureSignal;
- (RACSignal *)VEaddRotationGestureSignal;

- (RACSignal *)VEaddTapGestureSignalWithDelegate:(id)delegate;
- (RACSignal *)VEaddLongPressGestureSignalWithDelegate:(id)delegate;
- (RACSignal *)VESwipePanGestureSignalWithDelegate:(id)delegate;
- (RACSignal *)VEaddPanGestureSignalWithDelegate:(id)delegate;
- (RACSignal *)VEaddPinchGestureSignalWithDelegate:(id)delegate;
- (RACSignal *)VEaddRotationGestureSignalWithDelegate:(id)delegate;

@end

