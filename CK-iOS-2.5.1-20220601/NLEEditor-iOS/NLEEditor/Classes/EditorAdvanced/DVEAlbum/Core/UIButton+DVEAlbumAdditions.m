//
//  UIButton+ACCAdditions.m
//  CameraClient
//
//  Created by bytedance on 2019/11/17.
//

#import "UIButton+DVEAlbumAdditions.h"
#import "DVEAlbumMacros.h"
#import "NSObject+DVEAlbumSwizzle.h"
#import <objc/runtime.h>

static NSString * const DVEAlbumUIButtonBorderColorKey = @"DVEAlbumUIButtonBorderColorKey";
static NSString * const DVEAlbumUIButtonAlphaKey = @"DVEAlbumUIButtonAlphaKey";
static NSString * const DVEAlbumUIButtonAlphaTransitionTimeKey = @"DVEAlbumUIButtonAlphaTransitionTimeKey";

@implementation UIButton (DVEAlbumAdditions)

+ (void)load
{
    [self DVEAlbum_swizzleMethodsOfClass:self originSelector:@selector(pointInside:withEvent:) targetSelector:@selector(acc_pointInside:withEvent:)];
    [self DVEAlbum_swizzleMethodsOfClass:self originSelector:@selector(setAlpha:) targetSelector:@selector(acc_setAlpha:)];
}

@dynamic tap_block;
static NSString *tap_blockKey = @"tap_blockKey";


- (void)acc_centerTitleAndImageWithSpacing:(CGFloat)spacing contentEdgeInsets:(UIEdgeInsets)contentEdgeInsets
{
    CGFloat insetAmount = spacing / 2.0;
    self.imageEdgeInsets = UIEdgeInsetsMake(0, -insetAmount, 0, insetAmount);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, -insetAmount);

    contentEdgeInsets.left += insetAmount;
    contentEdgeInsets.right += insetAmount;
    self.contentEdgeInsets = contentEdgeInsets;
}

- (void)setAcc_hitTestEdgeInsets:(UIEdgeInsets)hitTestEdgeInsets
{
    NSValue *value = [NSValue valueWithUIEdgeInsets:hitTestEdgeInsets];
    objc_setAssociatedObject(self, @selector(acc_hitTestEdgeInsets), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)acc_hitTestEdgeInsets
{
    NSValue *value = objc_getAssociatedObject(self, @selector(acc_hitTestEdgeInsets));
    if (value) {
        return [value UIEdgeInsetsValue];
    } else {
        return UIEdgeInsetsZero;
    }
}

- (BOOL)acc_pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    UIEdgeInsets hitTestEdgeInsets = self.acc_hitTestEdgeInsets;
    if (UIEdgeInsetsEqualToEdgeInsets(hitTestEdgeInsets, UIEdgeInsetsZero) || !self.enabled || self.hidden || !self.alpha) {
        return [self acc_pointInside:point withEvent:event];
    }
    CGRect hitFrame = UIEdgeInsetsInsetRect(self.bounds, hitTestEdgeInsets);
    return CGRectContainsPoint(hitFrame, point);
}

- (void)setAcc_disableBlock:(void (^)(void))acc_disableBlock
{
    objc_setAssociatedObject(self, @selector(acc_disableBlock), acc_disableBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(void))acc_disableBlock
{
    return objc_getAssociatedObject(self, @selector(acc_disableBlock));
}

+ (UIImage *)acc_imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);

    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    //
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (void)acc_setBackgroundColor:(UIColor *)color forState:(UIControlState)state
{
    UIImage *imageFromColor = [UIButton acc_imageWithColor:color];
    //
    [self setBackgroundImage:imageFromColor forState:state];
}

- (void)acc_setAlpha:(CGFloat)alpha {
    NSNumber *currentKey = self.isSelected ? @(UIControlStateSelected) : (self.isHighlighted ? @(UIControlStateHighlighted) : @(UIControlStateNormal));
    NSMutableDictionary <NSNumber *, NSNumber *> *alphaSettings = objc_getAssociatedObject(self, (__bridge const void *)(DVEAlbumUIButtonAlphaKey));
    if (alphaSettings && alphaSettings[currentKey]) {
        if (self.acc_alphaTransitionTime == 0) {
            [self acc_setAlpha:alphaSettings[currentKey].floatValue];
        } else {
            [UIView animateWithDuration:self.acc_alphaTransitionTime animations:^{
                [self acc_setAlpha:alphaSettings[currentKey].floatValue];
            }];
        }
    }else {
        [self acc_setAlpha:alpha];
    }
}

- (NSTimeInterval)acc_alphaTransitionTime
{
    NSNumber *time = objc_getAssociatedObject(self, (__bridge const void *)(DVEAlbumUIButtonAlphaTransitionTimeKey));
    if (time != nil) {
        return time.floatValue;
    }
    return 0;
}
    
- (void)setTap_block:(DVEAlbumUIButtonTapBlock)tap_block
{
    objc_setAssociatedObject(self, &tap_blockKey, tap_block, OBJC_ASSOCIATION_COPY);
    [self addTarget:self action:@selector(accTap_invokeTouchUpInsideBlock:) forControlEvents:UIControlEventTouchUpInside];
}

- (DVEAlbumUIButtonTapBlock)tap_block
{
    return objc_getAssociatedObject(self, &tap_blockKey);
}

- (void)accTap_invokeTouchUpInsideBlock:(id)sender
{
    TOCBLOCK_INVOKE(self.tap_block);
}

@end





