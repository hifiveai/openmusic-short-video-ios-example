//
//  UIButton+layout.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "UIButton+layout.h"
#import <objc/runtime.h>

static inline float pixel(float num) {
    float unit = 1.0 / [UIScreen mainScreen].scale;
    double remain = fmod(num, unit);
    return num - remain + (remain >= unit / 2.0? unit: 0);
}

static inline CGSize VE_MULTILINE_TEXTSIZE(NSString *text, UIFont *font, CGSize maxSize, NSLineBreakMode mode)
{
    if ([text length] > 0) {
        CGSize size = [text boundingRectWithSize:maxSize
                                         options: NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                      attributes:@{NSFontAttributeName:font} context:nil].size;
        return CGSizeMake(ceilf(size.width), ceilf(size.height));
    } else {
        return CGSizeZero;
    }
}

@implementation UIButton (layout)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method ovr_method = class_getInstanceMethod([self class], @selector(layoutSubviews));
        Method swz_method = class_getInstanceMethod([self class], @selector(VECustomLayoutSubviews));
        method_exchangeImplementations(ovr_method, swz_method);
    });
}

- (void)VECustomLayoutSubviews
{
    [self VECustomLayoutSubviews];
    
    if (self.imageView.image && self.layoutType != VEButtonLayoutTypeNone) {
        switch (self.layoutType) {
            case VEButtonLayoutTypeImageLeft:
                [self layoutSubviewsByTypeLeft];
                break;
            case VEButtonLayoutTypeImageRight:
                [self layoutSubviewsByTypeRight];
                break;
            case VEButtonLayoutTypeImageBottom:
                [self layoutSubviewsByTypeBottom];
                break;
            case VEButtonLayoutTypeImageTop:
                [self layoutSubviewsByTypeTop];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Public method

- (void)VElayoutWithType:(VEButtonLayoutType)layoutType space:(CGFloat)space
{
    self.layoutType = layoutType;
    self.space = space;
}

#pragma mark - Runtime Setter and getter

- (void)setLayoutType:(VEButtonLayoutType)layoutType
{
    if (self.layoutType == layoutType) {
        return;
    }
    
    objc_setAssociatedObject(self, @selector(layoutType), [NSNumber numberWithInteger:layoutType],OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self setNeedsLayout];
}

- (VEButtonLayoutType)layoutType
{
    NSNumber *result = objc_getAssociatedObject(self, @selector(layoutType));
    return [result integerValue];
}

- (void)setSpace:(CGFloat)space
{
    if (self.space == space) {
        return;
    }
    objc_setAssociatedObject(self, @selector(space),[NSNumber numberWithFloat:space],OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self setNeedsLayout];
}

- (CGFloat)space
{
    NSNumber *result = objc_getAssociatedObject(self, @selector(space));
    return [result floatValue];
}

- (void)setIndex:(NSInteger)index
{
    if (self.index == index) {
        return;
    }
    objc_setAssociatedObject(self, @selector(index), [NSNumber numberWithInteger:index], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)index
{
    NSNumber *result = objc_getAssociatedObject(self, @selector(index));
    return [result integerValue];
}

#pragma mark - Layout Methods

- (void)layoutSubviewsByTypeLeft
{
    CGFloat imageWidth = self.imageView.image.size.width;
    CGFloat imageHeight = self.imageView.image.size.height;
    
    CGFloat maxLabelWidth = CGRectGetWidth(self.frame) - imageWidth - self.space;
    CGSize maxSize = CGSizeMake(maxLabelWidth, self.titleLabel.font.lineHeight);
    
    CGSize labelSize = VE_MULTILINE_TEXTSIZE(self.titleLabel.text, self.titleLabel.font, maxSize, NSLineBreakByWordWrapping);
    CGFloat labelX = CGRectGetMaxX(self.imageView.frame) + self.space;
    
    CGFloat imageViewX = (CGRectGetWidth(self.frame) - labelSize.width - imageWidth - self.space) / 2.0;
    CGFloat imageViewY = (CGRectGetHeight(self.frame) - imageHeight) / 2.0;
    
    if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft) {
        imageViewX = 0;
        labelX = CGRectGetMaxX(self.imageView.frame) + self.space;
    } else if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight) {
        labelX = CGRectGetWidth(self.frame) - labelSize.width;
        imageViewX = labelX - self.space - CGRectGetMaxX(self.imageView.frame);
    }
    
    if (self.contentVerticalAlignment == UIControlContentVerticalAlignmentTop) {
        imageViewY = 0;
    } else if (self.contentVerticalAlignment == UIControlContentVerticalAlignmentBottom) {
        imageViewY = CGRectGetHeight(self.frame) - imageHeight;
    }
    
    self.imageView.frame = CGRectMake(imageViewX, imageViewY, imageWidth, imageHeight);
    self.titleLabel.frame = CGRectMake(labelX, 0, labelSize.width, labelSize.height);
    self.titleLabel.center = CGPointMake(self.titleLabel.center.x, self.imageView.center.y);
}

- (void) layoutSubviewsByTypeRight
{
    CGFloat imageHeight = self.imageView.image.size.height;
    CGFloat imageWidth =self.imageView.image.size.width;
    
    CGFloat maxLabelWidth = CGRectGetWidth(self.frame) - imageWidth - self.space;
    CGSize maxSize = CGSizeMake(maxLabelWidth, self.titleLabel.font.lineHeight);
    
    CGSize labelSize = VE_MULTILINE_TEXTSIZE(self.titleLabel.text, self.titleLabel.font, maxSize, NSLineBreakByWordWrapping);
    CGFloat labelX = (CGRectGetWidth(self.frame) - labelSize.width - imageWidth - self.space) / 2.0;
    
    CGFloat imageViewX = labelX + labelSize.width + self.space;
    CGFloat imageViewY = (CGRectGetHeight(self.frame) - imageHeight) / 2.0;
    
    if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft) {
        labelX = 0;
        imageViewX = CGRectGetMaxX(self.titleLabel.frame) + self.space;
    } else if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight) {
        imageViewX = CGRectGetWidth(self.frame) - imageWidth;
        labelX = imageViewX - self.space - labelSize.width;
    }
    
    if (self.contentVerticalAlignment == UIControlContentVerticalAlignmentTop) {
        imageViewY = 0;
    } else if (self.contentVerticalAlignment == UIControlContentVerticalAlignmentBottom) {
        imageViewY = CGRectGetHeight(self.frame) - imageHeight;
    }
    
    self.titleLabel.frame = CGRectMake(labelX, 0, labelSize.width, labelSize.height);
    self.imageView.frame = CGRectMake(imageViewX, imageViewY, imageWidth, imageHeight);
    self.titleLabel.center = CGPointMake(self.titleLabel.center.x, self.imageView.center.y);
}

- (void)layoutSubviewsByTypeTop
{
    CGFloat imageWidth = self.imageView.image.size.width;
    CGFloat imageHeight = self.imageView.image.size.height;
    
    CGSize labelSize = VE_MULTILINE_TEXTSIZE(self.titleLabel.text, self.titleLabel.font, CGSizeMake(CGRectGetWidth(self.frame), self.titleLabel.font.lineHeight), NSLineBreakByWordWrapping);
    CGFloat labelX = (CGRectGetWidth(self.frame) - labelSize.width) / 2.0;
    
    CGFloat imageViewX = (CGRectGetWidth(self.frame) - imageWidth) / 2.0;
    CGFloat imageViewY = (CGRectGetHeight(self.frame) - labelSize.height - imageHeight - self.space) / 2.0;
    CGFloat labelY = imageViewY + imageHeight + self.space;
    
    if (self.contentVerticalAlignment == UIControlContentVerticalAlignmentTop) {
        imageViewY = 0;
        labelY = CGRectGetMaxY(self.imageView.frame) + self.space;
    } else if (self.contentVerticalAlignment == UIControlContentVerticalAlignmentBottom) {
        labelY = CGRectGetHeight(self.frame) - labelSize.height;
        imageViewY = labelY - self.space - imageWidth;
    }
    
    if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft) {
        imageViewX = 0;
        labelX = 0;
    } else if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight) {
        imageViewX = CGRectGetWidth(self.frame) - imageWidth;
        labelX = CGRectGetWidth(self.frame) - labelSize.width;
    }
    
    self.imageView.frame = CGRectMake(imageViewX, imageViewY, imageWidth, imageHeight);
    self.titleLabel.frame = CGRectMake(labelX, labelY, labelSize.width, labelSize.height);
}

- (void)layoutSubviewsByTypeBottom
{
    CGFloat imageWidth = self.imageView.image.size.width;
    CGFloat imageHeight = self.imageView.image.size.height;
    
    CGSize labelSize = VE_MULTILINE_TEXTSIZE(self.titleLabel.text, self.titleLabel.font, CGSizeMake(CGRectGetWidth(self.frame), self.titleLabel.font.lineHeight), NSLineBreakByWordWrapping);
    CGFloat labelX = (CGRectGetWidth(self.frame) - labelSize.width) / 2.0;
    CGFloat labelY =  (CGRectGetHeight(self.frame) - labelSize.height - imageHeight - self.space) / 2.0;
    
    CGFloat imageViewX = (CGRectGetWidth(self.frame) - imageWidth) / 2.0;
    CGFloat imageViewY = labelY + labelSize.height + self.space;
    
    if (self.contentVerticalAlignment == UIControlContentVerticalAlignmentTop) {
        labelY = 0;
        imageViewY = labelSize.height + self.space;
    } else if (self.contentVerticalAlignment == UIControlContentVerticalAlignmentBottom) {
        imageViewY = CGRectGetHeight(self.frame) - imageHeight;
        labelY = imageViewY - self.space - labelSize.height;
    }
    
    if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft) {
        imageViewX = 0;
        labelX = 0;
    } else if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight) {
        imageViewX = CGRectGetWidth(self.frame) - imageWidth;
        labelX = CGRectGetWidth(self.frame) - labelSize.width;
    }
    
    self.titleLabel.frame = CGRectMake(labelX, labelY, labelSize.width, labelSize.height);
    self.imageView.frame = CGRectMake(imageViewX, imageViewY, imageWidth, imageHeight);
}

@end

