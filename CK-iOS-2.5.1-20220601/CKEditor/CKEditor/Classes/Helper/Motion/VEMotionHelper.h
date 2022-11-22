//
//  VEMotionHelper.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VEMotionHelperProtocol <NSObject>

@optional

- (void)directionChange:(UIDeviceOrientation)direction;

@end

NS_ASSUME_NONNULL_BEGIN

@interface VEMotionHelper : NSObject

+ (instancetype)shareManager;

- (void)startWithDelegate:(id<VEMotionHelperProtocol>)delegate;
- (void)stopWithDelegate:(id<VEMotionHelperProtocol>)delegate;

@end

NS_ASSUME_NONNULL_END
