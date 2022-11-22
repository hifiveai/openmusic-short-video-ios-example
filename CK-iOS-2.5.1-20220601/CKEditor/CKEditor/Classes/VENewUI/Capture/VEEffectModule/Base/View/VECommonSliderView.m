//
//  VECommonSliderView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECommonSliderView.h"

@interface VECommonSliderView ()



@end

@implementation VECommonSliderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
        [self addSubview:self.slider];
        [self addSubview:self.titileLable];
        _slider.centerY = self.height * 0.5;
        self.titileLable.top = _slider.centerY + 5;
        self.titileLable.centerX = _slider.left + 0.8 * _slider.width;
        self.titileLable.text = @"0.8";
    }
    
    return self;
}

- (void)setValueRange:(DVEFloatRang)valueRange
{
    _valueRange = valueRange;
    
}

- (void)setValueRange:(DVEFloatRang)rang defaultProgress:(float)progress
{
    _valueRange = rang;
    float start = _valueRange.location;
    float max = _valueRange.length;
    
    if (start > max) {
        start = max - start;
    }
    [_slider setMinimumValue:start];
    [_slider setMaximumValue:max];
    self.value = progress;
}

- (DVEStepSlider *)slider
{
    if (!_slider) {
        _slider = [[DVEStepSlider alloc] initWithStep:1 defaultValue:0 frame:CGRectMake(50, 0, self.width - 100, 30)];
        _slider.maximumTrackTintColor = RGBACOLOR(255, 255, 255, 100);
        _slider.minimumTrackTintColor = HEXRGBCOLOR(0xFE6646);
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _slider.value = 0.8;
    }
    
    return _slider;
}

- (UILabel *)titileLable
{
    if (!_titileLable) {
        _titileLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
        _titileLable.font = SCRegularFont(10);
        _titileLable.textColor = [UIColor whiteColor];
        _titileLable.textAlignment = NSTextAlignmentCenter;
        _titileLable.hidden = YES;
    }
    
    return _titileLable;
}

- (void)sliderValueChanged:(UISlider *)slider
{
    self.value = slider.value;
    
}

- (void)setValue:(float)value
{
    _value = value;
    [_slider setValue:value];
    self.titileLable.centerX = (VE_SCREEN_WIDTH - _slider.width) * 0.5 + ((self.value - self.slider.minimumValue)/(self.slider.maximumValue - self.slider.minimumValue)) * _slider.width;
    self.titileLable.text = [NSString stringWithFormat:@"%0.1f",self.value];
}


@end
