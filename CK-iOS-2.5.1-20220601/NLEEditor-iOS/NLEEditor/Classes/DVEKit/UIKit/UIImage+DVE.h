//
//  UIImage+DVE.h
//  NLEEditor-iOS
//
//  Created by bytedance on 2021/4/2.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (DVE)

+ (UIImage *)dev_image:(AVAsset*)asset maxSize:(CGSize)maxSize time:(CMTime)time;

+ (UIImage *)dev_image:(UIColor*)color size:(CGSize)size;

- (UIImage *)reSizeImage:(CGSize)reSize;

- (UIImage*)imageWithColor:(UIColor*)color;

- (UIImage *)originalImageWithColor:(UIColor *)color;
@end

NS_ASSUME_NONNULL_END
