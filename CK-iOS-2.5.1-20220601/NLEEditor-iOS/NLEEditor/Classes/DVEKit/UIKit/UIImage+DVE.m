//
//  UIImage+DVE.m
//  NLEEditor-iOS
//
//  Created by bytedance on 2021/4/2.
//

#import "UIImage+DVE.h"
#import "NSBundle+DVE.h"

@implementation UIImage (DVE)

+ (UIImage *)dve_image:(NSString *)named bundleName:(NSString *)bundleName
{
    NSBundle *bundle = [NSBundle dve_bundleWithName:bundleName];
    return [UIImage imageNamed:named inBundle:bundle compatibleWithTraitCollection:nil];
}

+ (UIImage *)dev_image:(AVAsset*)asset maxSize:(CGSize)maxSize time:(CMTime)time
{
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    // 设定缩略图的方向，如果不设定，可能会在视频旋转90/180/270°时，获取到的缩略图是被旋转过的，而不是正向的。
    gen.appliesPreferredTrackTransform = YES;
    // 设置图片的最大size(分辨率)
    gen.maximumSize = maxSize;
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if (error) {
        return nil;
    }
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
}

+ (UIImage *)dev_image:(UIColor*)color size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (UIImage *)reSizeImage:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [self drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    if (!color) {
        return nil;
    }
    
    UIImage *newImage = nil;
    
    CGRect imageRect = (CGRect){CGPointZero,self.size};
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, self.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -(imageRect.size.height));
    
    CGContextClipToMask(context, imageRect, self.CGImage);//选中选区 获取不透明区域路径
    CGContextSetFillColorWithColor(context, color.CGColor);//设置颜色
    CGContextFillRect(context, imageRect);//绘制
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();//提取图片
    
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)originalImageWithColor:(UIColor *)color {
    UIImage *img = [self imageWithColor:color];
    img = [img imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)];
    return img;
}

@end
