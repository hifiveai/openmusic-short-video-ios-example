//
//  DVENormalSliderView.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/28.
//

#import "DVENormalSliderView.h"
#import "DVEMacros.h"
#import <DVETrackKit/UIView+VEExt.h>

@implementation DVENormalSliderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = HEXRGBCOLOR(0x181718);
        [self addSubview:self.slider];
        _slider.centerY = self.height * 0.5;
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
        _slider = [[DVEStepSlider alloc] initWithStep:1 defaultValue:0 frame:CGRectMake(0, 0, self.width, 30)];
        _slider.maximumTrackTintColor = RGBACOLOR(255, 255, 255, 100);
        _slider.minimumTrackTintColor = HEXRGBCOLOR(0xFE6646);
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _slider.value = 0.8;
        _slider.valueType = DVEStepSliderValueTypeSecond;
    }
    
    return _slider;
}


- (void)sliderValueChanged:(UISlider *)slider
{
    self.value = slider.value;
    
}

- (void)setValue:(float)value
{
    _value = value;
    [_slider setValue:value];
}


@end
