//
//  NSString+DVEAlbum.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/8/23.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "NSString+DVEAlbum.h"

@implementation NSString (DVEAlbum)

- (UIColor *)dve_album_colorFromARGBHexString {
    unsigned argbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setScanLocation:1]; // pass '#' character
    [scanner scanHexInt:&argbValue];
    unsigned alphaValue = (argbValue & 0xFF000000) >> 24;
    CGFloat alpha = alphaValue > 0 ? alphaValue/255.0 : 1;
    return [UIColor colorWithRed:((argbValue & 0xFF0000) >> 16)/255.0 green:((argbValue & 0xFF00) >> 8)/255.0 blue:(argbValue & 0xFF)/255.0 alpha:alpha];
}

- (UIColor *)dve_album_colorFromRGBHexStringWithAlpha:(CGFloat)alpha
{
    unsigned argbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setScanLocation:1]; // pass '#' character
    [scanner scanHexInt:&argbValue];
    
    return [UIColor colorWithRed:((argbValue & 0xFF0000) >> 16)/255.0 green:((argbValue & 0xFF00) >> 8)/255.0 blue:(argbValue & 0xFF)/255.0 alpha:alpha];
}


@end
