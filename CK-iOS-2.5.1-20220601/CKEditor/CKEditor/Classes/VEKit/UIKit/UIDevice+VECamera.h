//
//  UIDevice+VECamera.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (VECamera)

- (NSArray<NSNumber *> *)systemCameraZoomFactors;

@end

NS_ASSUME_NONNULL_END
