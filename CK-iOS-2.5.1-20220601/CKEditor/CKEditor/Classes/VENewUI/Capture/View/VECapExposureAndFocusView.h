//
//  VECapExposureAndFocusView.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^exposureChangeBlock)(CGFloat exposureValue);

@interface VECapExposureAndFocusView : UIView

@property (nonatomic, assign) CGFloat exposure;

+ (void)showInView:(UIView *)view
minValue:(CGFloat)min
maxValue:(CGFloat)max
curValue:(CGFloat)curValue
point:(CGPoint)point
exposureChangeBlock:(exposureChangeBlock)block;

+ (void)hideInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
