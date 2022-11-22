//
//  UIColor+ACCMIX.h
//  CameraClient
//
//  Created by bytedance on 2019/11/18.
//
#import <UIKit/UIKit.h>

@interface UIColor (DVEAlbumAdditions)

+ (instancetype)acc_mixColor1:(UIColor *)color1 withColor2:(UIColor *)color2;

+ (NSString *)acc_hexStringFromColor:(UIColor *)color;

+ (UIColor *)acc_colorWithHexString:(NSString *)hexString;

@end
