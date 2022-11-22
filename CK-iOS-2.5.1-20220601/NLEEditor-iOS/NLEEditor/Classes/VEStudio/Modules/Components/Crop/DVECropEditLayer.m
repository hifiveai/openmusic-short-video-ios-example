//
//  DVECropEditLayer.m
//  NLEEditor
//
//  Created by bytedance on 2021/4/12.
//

#import "DVEMacros.h"
#import "DVECropEditLayer.h"

@implementation DVECropEditLayer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor].CGColor;
        self.fillColor = colorWithHexAlpha(0x101010, 0.7).CGColor;
        self.fillRule = kCAFillRuleEvenOdd;
    }
    return self;
}

#pragma mark - Override

- (instancetype)initWithLayer:(id)layer {
    self = [super initWithLayer:layer];
    return self;
}

- (void)hollowOutWithRect:(CGRect)rect duration:(NSTimeInterval)duration {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cropPath = [UIBezierPath bezierPathWithRect:rect];
    [path appendPath:cropPath];
    path.usesEvenOddFillRule = YES;
    
    if (duration <= 0.0) {
        self.path = path.CGPath;
    } else {
        [self animateWithPath:path.CGPath duration:duration];
    }
}

- (void)animateWithPath:(CGPathRef)path duration:(NSTimeInterval)duration {
    CABasicAnimation *animate = [CABasicAnimation animationWithKeyPath:@"path"];
    animate.duration = duration;
    animate.fromValue = (__bridge id)self.path;
    animate.toValue = (__bridge id)path;
    animate.fillMode = kCAFillModeForwards;
    animate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [self addAnimation:animate forKey:@"path"];
    self.path = path;
}


@end
