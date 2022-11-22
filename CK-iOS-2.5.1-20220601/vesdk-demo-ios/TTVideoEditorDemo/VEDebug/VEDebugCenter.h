//
//  VEDebugCenter.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/2/3.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEDebugCenter : NSObject

@property (nonatomic, assign) BOOL isShow;

+ (instancetype)shareDebugCenter;

- (void)showCenter;
- (void)dismissCenter;

@end

NS_ASSUME_NONNULL_END
