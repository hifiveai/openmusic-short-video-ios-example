//
//  HFConfigModel.h
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/14.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HFConfigModel : NSObject
/// 颜色
+ (UIColor *)mainTitleColor;
+ (UIColor *)headLineColor;
+ (UIColor *)bodyColor;
+ (UIColor *)subodyColor;
+ (UIColor *)timeColor;
+ (UIColor *)usingBackColor;


//字号
+ (UIFont *)mainTitleFont;
+ (UIFont *)bodyFont;
+ (UIFont *)subBodyFont;
+ (UIFont *)timeFont;
+ (UIFont *)palyViewNameFont;
@end

NS_ASSUME_NONNULL_END
