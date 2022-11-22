//
//  UIImage+VEAdd.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/2/4.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "UIImage+VEAdd.h"

@implementation UIImage (VEAdd)

+ (UIImage *)VE_imageWithColor:(UIColor *)color

{
    CGRect rect = CGRectMake(0.0f, 0.0f, 50.0f, 0.5f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
