//
//  UIView+AWEUIKit.m
//  AWEUIKit
//
//  Created by bytedance on 2019/9/26.
//

//#import "UIView+ACCMasonry.h"

#import <Masonry/View+MASAdditions.h>

@implementation UIView (DVEAlbumUIKit)

- (void)acc_removeAllSubviews
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)acc_addRotateAnimationWithDuration:(CGFloat)duration
{
    [self acc_addRotateAnimationWithDuration:duration forKey:nil];
}

- (void)acc_addRotateAnimationWithDuration:(CGFloat)duration forKey:(nullable NSString *)key
{
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
    rotationAnimation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
    rotationAnimation.duration = duration;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.removedOnCompletion = NO;
    [self.layer addAnimation:rotationAnimation forKey:key];
}

- (void)acc_addBlurEffect
{
    [self acc_addSystemBlurEffect:UIBlurEffectStyleDark];
}

- (void)acc_addSystemBlurEffect:(UIBlurEffectStyle)style
{
    //on JAILBROKEN device, maybe have no resources for blureffect
    @try {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:style];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        [self addSubview:effectView];

        [effectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    } @catch (NSException *exception) {

    }
}

- (UIImage *)acc_snapshotImage
{
    if (@available(iOS 10.0, *)) {
        UIGraphicsImageRenderer *render = [[UIGraphicsImageRenderer alloc] initWithSize:self.bounds.size];
        return [render imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            [self.layer renderInContext:rendererContext.CGContext];
        }];
    } else {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return snap;
    }
}

- (UIImage *)acc_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates
{
    if (![self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        return [self acc_snapshotImage];
    }
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:afterUpdates];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

//-----由SMCheckProject工具删除-----
//- (UIImage *)acc_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates withSize:(CGSize)size {
//    if (![self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
//        return [self acc_snapshotImage];
//    }
//    UIGraphicsBeginImageContextWithOptions(size, self.opaque, 0);
//    [self drawViewHierarchyInRect:CGRectMake(0, 0, size.width, size.height) afterScreenUpdates:afterUpdates];
//    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return snap;
//}

- (UIImageView *)acc_snapshotImageView
{
    UIImage *image = [self acc_snapshotImage];
    if (image) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = self.frame;
        return imageView;
    }
    return nil;
}

//-----由SMCheckProject工具删除-----
//- (UIImageView *)acc_snapshotImageViewAfterScreenUpdates:(BOOL)afterUpdate
//{
//    UIImage *image = [self acc_snapshotImageAfterScreenUpdates:afterUpdate];
//    if (image) {
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//        imageView.accrtl_viewType = ACCRTLViewTypeNormal;
//        imageView.frame = self.frame;
//        return imageView;
//    }
//    return nil;
//}

//-----由SMCheckProject工具删除-----
//- (UIColor *)acc_colorOfPoint:(CGPoint)point
//{
//    unsigned char pixel[4] = {0};
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
//
//    CGContextTranslateCTM(context, -point.x, -point.y);
//
//    [self.layer renderInContext:context];
//
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
//
//    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
//
//    return color;
//}

- (CGRect)acc_frameInView:(UIView *)view
{
    return [view convertRect:self.bounds fromView:self];
}

- (CGPoint)anchorOffsetWithPositive:(BOOL)positive
{
    CGPoint newPoint = CGPointMake(self.bounds.size.width * self.layer.anchorPoint.x,
                                   self.bounds.size.height * self.layer.anchorPoint.y);
    CGPoint oldPoint = CGPointMake(self.bounds.size.width * 0.5,
                                   self.bounds.size.height * 0.5);
    newPoint = CGPointApplyAffineTransform(newPoint, self.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, self.transform);
    
    if (positive) {
        return CGPointMake(oldPoint.x - newPoint.x, oldPoint.y - newPoint.y);
    } else {
        return CGPointMake(newPoint.x - oldPoint.x, newPoint.y - oldPoint.y);
    }
}

@end


@implementation UIView (DVEAlbumLayout)

- (void)setAcc_top:(CGFloat)acc_top {
    self.frame = CGRectMake(self.acc_left, acc_top, self.acc_width, self.acc_height);
}

- (CGFloat)acc_top {
    return self.frame.origin.y;
}

- (void)setAcc_bottom:(CGFloat)acc_bottom {
    self.frame = CGRectMake(self.acc_left, acc_bottom - self.acc_height, self.acc_width, self.acc_height);
}

- (CGFloat)acc_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setAcc_left:(CGFloat)acc_left {
    self.frame = CGRectMake(acc_left, self.acc_top, self.acc_width, self.acc_height);
}

- (CGFloat)acc_left {
    return self.frame.origin.x;
}

- (void)setAcc_right:(CGFloat)acc_right {
    self.frame = CGRectMake(acc_right - self.acc_width, self.acc_top, self.acc_width, self.acc_height);
}

- (CGFloat)acc_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setAcc_width:(CGFloat)acc_width {
    self.frame = CGRectMake(self.acc_left, self.acc_top, acc_width, self.acc_height);
}

- (CGFloat)acc_width {
    return self.frame.size.width;
}

- (void)setAcc_height:(CGFloat)acc_height {
    self.frame = CGRectMake(self.acc_left, self.acc_top, self.acc_width, acc_height);
}

- (CGFloat)acc_height {
    return self.frame.size.height;
}

- (CGFloat)acc_centerX {
    return self.center.x;
}

- (void)setAcc_centerX:(CGFloat)acc_centerX {
    self.center = CGPointMake(acc_centerX, self.center.y);
}

- (CGFloat)acc_centerY {
    return self.center.y;
}

- (void)setAcc_centerY:(CGFloat)acc_centerY {
    self.center = CGPointMake(self.center.x, acc_centerY);
}

- (CGSize)acc_size {
    return self.frame.size;
}

- (void)setAcc_size:(CGSize)acc_size {
    self.frame = CGRectMake(self.acc_left, self.acc_top, acc_size.width, acc_size.height);
}

- (CGPoint)acc_origin {
    return self.frame.origin;
}

- (void)setAcc_origin:(CGPoint)acc_origin {
    self.frame = CGRectMake(acc_origin.x, acc_origin.y, self.acc_width, self.acc_height);
}

@end


@implementation UIView (DVEAlbumHierarchy)

//-----由SMCheckProject工具删除-----
//- (id)acc_nearestAncestorOfClass:(Class)clazz
//{
//    if (!clazz) {
//        return nil;
//    }
//
//    UIView *ancestor = self;
//
//    while (![ancestor isKindOfClass:clazz] && ancestor.superview) {
//        ancestor = ancestor.superview;
//    }
//
//    return ancestor;
//}

@end


@implementation UIView (AWEAddGestureRecognizer)

- (UITapGestureRecognizer *)acc_addSingleTapRecognizerWithTarget:(id)target action:(SEL)sel
{
    self.userInteractionEnabled = YES;

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:sel];
    tapRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapRecognizer];

    return tapRecognizer;
}

@end


@implementation UIView (AWEViewImageMirror)

- (UIImage *)acc_imageWithView
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)acc_imageWithViewOnScreenScale
{
    CGSize s = self.bounds.size;
    if (@available(iOS 10.0, *)) {
        UIGraphicsImageRenderer *render = [[UIGraphicsImageRenderer alloc] initWithSize:self.bounds.size];
        return [render imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            [self.layer renderInContext:rendererContext.CGContext];
        }];
    } else {
        UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}

@end














