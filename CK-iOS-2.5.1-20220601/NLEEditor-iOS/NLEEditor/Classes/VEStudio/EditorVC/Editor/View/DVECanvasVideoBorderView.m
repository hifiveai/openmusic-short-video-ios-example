//
//  DVECanvasVideoBorderView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVECanvasVideoBorderView.h"
#import <DVETrackKit/DVECGUtilities.h>
#import <DVETrackKit/UIColor+DVE.h>

@interface DVECanvasVideoBorderView ()

@property (nonatomic) CAShapeLayer *borderLayer;
@end

@implementation DVECanvasVideoBorderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.lineWidth = 2.f;
        _borderLayer.strokeColor = [UIColor colorFromHex:@"#99EC3A5C"].CGColor;
        _borderLayer.fillColor = UIColor.clearColor.CGColor;
        [self.layer addSublayer:_borderLayer];
    }
    return self;
}

- (void)setVcContext:(DVEVCContext *)context
{
    _vcContext = context;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:0.f].CGPath;
    self.borderLayer.path = path;
}

- (void)updateTranslation:(CGPoint)trans {
    UIView *preview = self.superview;
    CGSize size = preview.bounds.size;
    CGPoint center = CGPointZero;
    center.x = size.width * 0.5 + (trans.x * size.width);
    center.y = size.height * 0.5 + (trans.y * size.height);
    self.center = center;
}

- (void)updateScale:(CGFloat )scale forSize:(CGSize)size {
    UIView *preview = self.superview;
    CGSize maxSize = preview.bounds.size;
    maxSize = CGSizeMake(maxSize.width * scale, maxSize.height * scale);
    CGSize ret = DVECGSizeLimitMaxSize(size, maxSize);
    ret = DVECGSizeSacleAspectFitToMaxSize(ret, maxSize);
    self.bounds = CGRectMake(0, 0, ret.width, ret.height);
}


- (void)updateRoation:(CGFloat)rotate {
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGAffineTransform targetTransform = CGAffineTransformRotate(transform, rotate / 180.f * M_PI);
    self.transform = targetTransform;
}

- (void)updateCrop:(NLEStyCrop_OC *)crop scale:(CGFloat)scale maxBounds:(CGRect)bounds
{
    NLEStyCrop_OC *newCrop = crop;
    if (!crop) {
        newCrop = [[NLEStyCrop_OC alloc] init];
    }
    CGFloat offsetX = (newCrop.upperRightX - newCrop.upperLeftX) * self.bounds.size.width;
    CGFloat offsetY = (newCrop.upperRightY - newCrop.upperLeftY) * self.bounds.size.height;
    CGFloat width = sqrt(offsetX * offsetX + offsetY * offsetY);
    
    offsetX = (newCrop.lowerLeftX - newCrop.upperLeftX) * self.bounds.size.width;
    offsetY = (newCrop.lowerLeftY - newCrop.upperLeftY) * self.bounds.size.height;
    CGFloat height = sqrt(offsetX * offsetX + offsetY * offsetY);
    
    if (isnan(width) || isnan(height)) {
        return;
    }
    CGSize cropSize = CGSizeMake(width, height);
    CGSize maxSize = CGSizeMake(bounds.size.width * scale, bounds.size.height * scale);
    
    if (CGSizeEqualToSize(CGSizeZero, cropSize) || CGSizeEqualToSize(CGSizeZero, maxSize)) {
        NSAssert(NO, @"裁剪的数据错误");
        return;
    }
    CGSize size = DVECGSizeLimitMaxSize(cropSize, maxSize);
    size = DVECGSizeSacleAspectFitToMaxSize(size, maxSize);
    self.bounds = CGRectMake(0, 0, size.width, size.height);
}

@end
