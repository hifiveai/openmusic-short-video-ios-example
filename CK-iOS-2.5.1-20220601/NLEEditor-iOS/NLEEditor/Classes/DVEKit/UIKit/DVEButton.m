//
//  DVEButton.m
//  NLEEditor
//
//  Created by bytedance on 2021/4/8.
//

#import "DVEButton.h"
#import <objc/runtime.h>

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

@implementation DVEButton

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.imageView.image && self.dve_layoutType != DVEButtonLayoutTypeNone) {
        switch (self.dve_layoutType) {
            case DVEButtonLayoutTypeImageLeft:
                [self layoutSubviewsByTypeLeft];
                break;
            case DVEButtonLayoutTypeImageRight:
                [self layoutSubviewsByTypeRight];
                break;
            case DVEButtonLayoutTypeImageBottom:
                [self layoutSubviewsByTypeBottom];
                break;
            case DVEButtonLayoutTypeImageTop:
                [self layoutSubviewsByTypeTop];
                break;
            default:
                break;
        }
    }
}

- (void)dve_layoutWithType:(DVEButtonLayoutType)layoutType
                     space:(CGFloat)space
{
    self.dve_layoutType = layoutType;
    self.dve_space = space;
}

#pragma mark - Runtime Setter and getter

- (void)setDve_layoutType:(DVEButtonLayoutType)dve_layoutType
{
    if (self.dve_layoutType == dve_layoutType) {
        return;
    }
    
    objc_setAssociatedObject(self, @selector(dve_layoutType), [NSNumber numberWithInteger:dve_layoutType],OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self setNeedsLayout];
}

- (DVEButtonLayoutType)dve_layoutType
{
    NSNumber *result = objc_getAssociatedObject(self, @selector(dve_layoutType));
    return [result integerValue];
}

- (void)setDve_space:(CGFloat)dve_space
{
    if (self.dve_space == dve_space) {
        return;
    }
    objc_setAssociatedObject(self, @selector(dve_space),[NSNumber numberWithFloat:dve_space],OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self setNeedsLayout];
}

- (CGFloat)dve_space
{
    NSNumber *result = objc_getAssociatedObject(self, @selector(dve_space));
    return [result floatValue];
}

#pragma mark - Layout Methods

- (void)layoutSubviewsByTypeLeft
{
    CGFloat imageWidth = self.imageView.image.size.width;
    CGFloat imageHeight = self.imageView.image.size.height;
    
    CGFloat maxLabelWidth = CGRectGetWidth(self.frame) - imageWidth - self.dve_space;
    CGSize maxSize = CGSizeMake(maxLabelWidth, self.titleLabel.font.lineHeight);
    
    CGSize labelSize = VE_MULTILINE_TEXTSIZE(self.titleLabel.text, self.titleLabel.font, maxSize, NSLineBreakByWordWrapping);
    CGFloat labelX = CGRectGetMaxX(self.imageView.frame) + self.dve_space;
    
    CGFloat imageViewX = (CGRectGetWidth(self.frame) - labelSize.width - imageWidth - self.dve_space) / 2.0;
    CGFloat imageViewY = (CGRectGetHeight(self.frame) - imageHeight) / 2.0;
    
    if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft) {
        imageViewX = 0;
        labelX = CGRectGetMaxX(self.imageView.frame) + self.dve_space;
    } else if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight) {
        labelX = CGRectGetWidth(self.frame) - labelSize.width;
        imageViewX = labelX - self.dve_space - CGRectGetMaxX(self.imageView.frame);
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
    
    CGFloat maxLabelWidth = CGRectGetWidth(self.frame) - imageWidth - self.dve_space;
    CGSize maxSize = CGSizeMake(maxLabelWidth, self.titleLabel.font.lineHeight);
    
    CGSize labelSize = VE_MULTILINE_TEXTSIZE(self.titleLabel.text, self.titleLabel.font, maxSize, NSLineBreakByWordWrapping);
    CGFloat labelX = (CGRectGetWidth(self.frame) - labelSize.width - imageWidth - self.dve_space) / 2.0;
    
    CGFloat imageViewX = labelX + labelSize.width + self.dve_space;
    CGFloat imageViewY = (CGRectGetHeight(self.frame) - imageHeight) / 2.0;
    
    if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft) {
        labelX = 0;
        imageViewX = CGRectGetMaxX(self.titleLabel.frame) + self.dve_space;
    } else if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight) {
        imageViewX = CGRectGetWidth(self.frame) - imageWidth;
        labelX = imageViewX - self.dve_space - labelSize.width;
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
    CGFloat imageViewY = (CGRectGetHeight(self.frame) - labelSize.height - imageHeight - self.dve_space) / 2.0;
    CGFloat labelY = imageViewY + imageHeight + self.dve_space;
    
    if (self.contentVerticalAlignment == UIControlContentVerticalAlignmentTop) {
        imageViewY = 0;
        labelY = CGRectGetMaxY(self.imageView.frame) + self.dve_space;
    } else if (self.contentVerticalAlignment == UIControlContentVerticalAlignmentBottom) {
        labelY = CGRectGetHeight(self.frame) - labelSize.height;
        imageViewY = labelY - self.dve_space - imageWidth;
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
    CGFloat labelY =  (CGRectGetHeight(self.frame) - labelSize.height - imageHeight - self.dve_space) / 2.0;
    
    CGFloat imageViewX = (CGRectGetWidth(self.frame) - imageWidth) / 2.0;
    CGFloat imageViewY = labelY + labelSize.height + self.dve_space;
    
    if (self.contentVerticalAlignment == UIControlContentVerticalAlignmentTop) {
        labelY = 0;
        imageViewY = labelSize.height + self.dve_space;
    } else if (self.contentVerticalAlignment == UIControlContentVerticalAlignmentBottom) {
        imageViewY = CGRectGetHeight(self.frame) - imageHeight;
        labelY = imageViewY - self.dve_space - labelSize.height;
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
