//
//  HFConfigModel.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/14.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "HFConfigModel.h"

@implementation HFConfigModel


+ (UIColor *)mainTitleColor {
    return [UIColor whiteColor];
}
+ (UIColor *)headLineColor {
    return [UIColor whiteColor];
}
+ (UIColor *)bodyColor {
    return [UIColor whiteColor];
}
+ (UIColor *)subodyColor {
    return [UIColor colorWithWhite:1 alpha:0.6];
}

+ (UIColor *)timeColor {
    return [UIColor colorWithWhite:1 alpha:0.3];
}

+ (UIColor *)usingBackColor {
    return [UIColor colorWithRed:255/255.0 green:214/255.0 blue:0/255.0 alpha:1.0];
}

+ (UIFont *)mainTitleFont {
    return [UIFont systemFontOfSize:22];
}
+ (UIFont *)bodyFont {
    return [UIFont systemFontOfSize:15];
}
+ (UIFont *)subBodyFont {
    return [UIFont systemFontOfSize:13];
}
+ (UIFont *)timeFont {
    return [UIFont systemFontOfSize:11];
}
+ (UIFont *)palyViewNameFont {
    return [UIFont systemFontOfSize:17];
}
@end
