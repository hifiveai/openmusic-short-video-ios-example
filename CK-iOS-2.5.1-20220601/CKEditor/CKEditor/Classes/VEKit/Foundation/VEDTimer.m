//
//  VEDTimer.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/2/7.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "VEDTimer.h"
#import <objc/runtime.h>

@interface VEDTimer ()

@property (nonatomic) NSTimer *innerTimer;
@property (nonatomic, weak) id target;
@property (nonatomic) SEL selector;

@end

@implementation VEDTimer

+ (VEDTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo
{
    VEDTimer *timer = [[self alloc] init];
    timer.innerTimer = [NSTimer timerWithTimeInterval:ti target:timer selector:@selector(innerTimerTick_:)  userInfo:userInfo repeats:yesOrNo];
    timer.target = aTarget;
    timer.selector = aSelector;
    [[NSRunLoop currentRunLoop] addTimer:timer.innerTimer forMode:NSDefaultRunLoopMode];
    return timer;
}

+ (VEDTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo
{
    VEDTimer *timer = [[self alloc] init];
    timer.innerTimer = [NSTimer scheduledTimerWithTimeInterval:ti target:timer selector:@selector(innerTimerTick_:) userInfo:userInfo repeats:yesOrNo];
    timer.target = aTarget;
    timer.selector = aSelector;
    return timer;
}

- (id)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:(id)ui repeats:(BOOL)rep
{
    self = [super init];
    if (self) {
        self.innerTimer = [[NSTimer alloc] initWithFireDate:date interval:ti target:self selector:@selector(innerTimerTick_:) userInfo:ui repeats:rep];
        self.target = t;
        self.selector = s;
    }
    return self;
}

- (void)innerTimerTick_:(NSTimer *)timer
{
    if (self.target && self.selector) {
        Method m = class_getInstanceMethod([self.target class], self.selector);
        NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(m)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        if (methodSignature.numberOfArguments > 2) {
            [invocation setArgument:&timer atIndex:2];
        }
        [invocation setTarget:self.target];
        [invocation setSelector:self.selector];
        [invocation invoke];
    } else {
        [self finallyInvalidate];
    }
}

- (void)fire
{
    [self.innerTimer fire];
}

- (NSDate *)fireDate
{
    return self.innerTimer.fireDate;
}

- (void)setFireDate:(NSDate *)date
{
    [self.innerTimer setFireDate:date];
}

- (NSTimeInterval)timeInterval
{
    return self.innerTimer.timeInterval;
}

- (void)invalidate
{
    [self.innerTimer invalidate];
}

- (void)finallyInvalidate
{
    [self invalidate];
    self.innerTimer = nil;
}

- (BOOL)isValid
{
    return [self.innerTimer isValid];
}

- (id)userInfo
{
    return [self.innerTimer userInfo];
}

- (void)addToRunloop:(NSRunLoop *)runloop forMode:(NSString *)mode
{
    [runloop addTimer:self.innerTimer forMode:mode];
}


@end
