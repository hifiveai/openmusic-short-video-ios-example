//
//  UIImage+ACCAdditions.h
//  CameraClient
//
//  Created by bytedance on 2019/12/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (DVEAlbumAdditions)

//-----由SMCheckProject工具删除-----
//- (nullable UIImage *)acc_ImageWithTintColor:(UIColor *)tintColor;

+ (nullable UIImage *)acc_imageWithColor:(UIColor *)color size:(CGSize)size;

//-----由SMCheckProject工具删除-----
//- (nullable UIImage *)acc_blurredImageWithRadius:(CGFloat)radius;

/**
 view按需求截图
 
 @param view 目标view
 @param scope 相对于目标view的需要截图的frame
 @return 目标view的截图
 */
//-----由SMCheckProject工具删除-----
//+ (instancetype)acc_captureWithView:(UIView *)view scope:(CGRect)scope;

//-----由SMCheckProject工具删除-----
//- (UIImage *)acc_imageByCropToRect:(CGRect)rect;

/*
* Fixed camera image rotation issue
*/
+ (nullable UIImage *)acc_fixImgOrientation:(nonnull UIImage *)aImage;

/*
 * Compress the image to the size of the target Size
 */
+ (nullable UIImage *)acc_compressImage:(nonnull UIImage *)sourceImage withTargetSize:(CGSize)targetSize;

/*
 * If the image given is larger than the target Size (length or width), scale in equal proportions, the length and width cannot exceed the target Size
 */
+ (nullable UIImage *)acc_tryCompressImage:(nonnull UIImage *)sourceImage ifImageSizeLargeTargetSize:(CGSize)targetSize;


/*
 有需要使用图片素材的，可以试试用下面几个方法来自行创建 UIImage
 
 属性：
 size ：尺寸小，in points，不需要乘2
 cornerRadius : 圆角
 borderWidth、borderColor : 描边
 backgroundColor : 背景色，纯色
 backgroundColors : 背景色，渐变色，现在只支持从上到下两个色值的的线性渐变
 */
//-----由SMCheckProject工具删除-----
//+ (nullable UIImage *)acc_imageWithSize:(CGSize)size
//                        backgroundColor:(nullable UIColor *)backgroundColor;

+ (nullable UIImage *)acc_imageWithSize:(CGSize)size
                           cornerRadius:(CGFloat)cornerRadius
                        backgroundColor:(nullable UIColor *)backgroundColor;

//-----由SMCheckProject工具删除-----
//+ (nullable UIImage *)acc_imageWithSize:(CGSize)size
//                            borderWidth:(CGFloat)borderWidth
//                            borderColor:(nullable UIColor *)borderColor
//                        backgroundColor:(nullable UIColor *)backgroundColor;

+ (nullable UIImage *)acc_imageWithSize:(CGSize)size
                           cornerRadius:(CGFloat)cornerRadius
                            borderWidth:(CGFloat)borderWidth
                            borderColor:(nullable UIColor *)borderColor
                        backgroundColor:(nullable UIColor *)backgroundColor;

+ (nullable UIImage *)acc_imageWithSize:(CGSize)size
                           cornerRadius:(CGFloat)cornerRadius
                            borderWidth:(CGFloat)borderWidth
                            borderColor:(nullable UIColor *)borderColor
                       backgroundColors:(nullable NSArray *)backgroundColors;

@end

NS_ASSUME_NONNULL_END






