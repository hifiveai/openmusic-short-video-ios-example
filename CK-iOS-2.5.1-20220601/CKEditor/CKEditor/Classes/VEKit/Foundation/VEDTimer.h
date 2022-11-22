//
//  VEDTimer.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/2/7.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEDTimer : NSObject

+ (VEDTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo;
+ (VEDTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo;

- (id)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:(id)ui repeats:(BOOL)rep;

- (void)fire;

- (NSDate *)fireDate;
- (void)setFireDate:(NSDate *)date;

- (NSTimeInterval)timeInterval;

- (void)invalidate;
- (void)finallyInvalidate;

- (BOOL)isValid;

- (id)userInfo;

- (void)addToRunloop:(NSRunLoop *)runloop forMode:(NSString *)mode;

@end

NS_ASSUME_NONNULL_END
