//
//  DVETextConfigShadowView.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/22.
//

#import "DVETextConfigShadowView.h"
// view controller

// model

// mgr

// view
#import "DVETextSliderView.h"
// view model

// support
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEMacros.h"


#include <math.h>
#include <stdio.h>



@interface DVETextConfigShadowView ()

@end

@implementation DVETextConfigShadowView

static const int8_t kSliderHeight = kDVETextSliderPreferHeight;

// MARK: - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.alphaSlider];
        [self addSubview:self.blurSlider];
        [self addSubview:self.distanceSlider];
        [self addSubview:self.angleSlider];
    }
    return self;
}

- (CGPoint)shadowOffset {
    return [self p_transientValueWithShadowDistance:_distanceSlider.value shadowAngle:_angleSlider.value];
}

// MARK: - Event

// MARK: - Private
/// 计算 shadowOffset
- (CGPoint)p_transientValueWithShadowDistance:(float)shadowDistance shadowAngle:(float)shadowAngle {
    double a = 0.0;
    int b = 0;
    int c = 0;
    if (shadowAngle > 0 && shadowAngle <= 90) {
        // 第一象限
        a = shadowAngle * M_PI / 180;
        b = 1;
        c = 1;
    } else if (shadowAngle > 90 && shadowAngle <= 180) {
        // 第二象限
        a = (180 - shadowAngle) * M_PI / 180;
        b = -1;
        c = 1;
    } else if (shadowAngle >= -180 && shadowAngle <= -90) {
        // 第三象限
        a = (180 + shadowAngle) * M_PI / 180;
        b = -1;
        c = -1;
    } else if (shadowAngle > -90 && shadowAngle <= 0) {
        // 第四象限
        a = (shadowAngle * -1) * M_PI / 180;
        b = 1;
        c = -1;
    }
    
    float x = (float)(cos(a) * shadowDistance / 5.55 * b);
    float y = (float)(sin(a) * shadowDistance / 5.55 * c);
    return CGPointMake(x, y);
}

// MARK: - Getters and setters

- (DVETextSliderView *)alphaSlider {
    if (!_alphaSlider) {
        _alphaSlider = [[DVETextSliderView alloc] initWithFrame:CGRectMake(0, 0, self.width, kSliderHeight)];
        _alphaSlider.textLabel.text = NLELocalizedString(@"ck_text_sticker_transparency",@"透明度");
    }
    return _alphaSlider;
}

- (DVETextSliderView *)blurSlider {
    if (!_blurSlider) {
        _blurSlider = [[DVETextSliderView alloc] initWithFrame:CGRectMake(0, kSliderHeight, self.width, kSliderHeight)];
        _blurSlider.textLabel.text = NLELocalizedString(@"ck_text_sticker_shadow_smoothing",@"模糊度");
    }
    return _blurSlider;
}

- (DVETextSliderView *)distanceSlider {
    if (!_distanceSlider) {
        _distanceSlider = [[DVETextSliderView alloc] initWithFrame:CGRectMake(0, kSliderHeight*2, self.width, kSliderHeight)];
        _distanceSlider.textLabel.text = NLELocalizedString(@"ck_text_sticker_shadow_offset",@"距离");
        _distanceSlider.minimumTrackTintColor = UIColor.whiteColor;
    }
    return _distanceSlider;
}

- (DVETextSliderView *)angleSlider {
    if (!_angleSlider) {
        _angleSlider = [[DVETextSliderView alloc] initWithFrame:CGRectMake(0, kSliderHeight*3, self.width, kSliderHeight)];
        _angleSlider.textLabel.text = NLELocalizedString(@"ck_text_sticker_shadow_angle",@"角度");
        _angleSlider.minimumTrackTintColor = UIColor.whiteColor;
    }
    return _angleSlider;
}

@end

