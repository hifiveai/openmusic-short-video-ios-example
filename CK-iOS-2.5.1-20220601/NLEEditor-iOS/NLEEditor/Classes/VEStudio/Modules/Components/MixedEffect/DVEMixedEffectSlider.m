//
//  DVEMixedEffectSlider.m
//  NLEEditor
//
//  Created by bytedance on 2021/4/20.
//

#import "DVEMixedEffectSlider.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEMacros.h"
#import "DVELoggerImpl.h"
#import <DVETrackKit/DVECustomResourceProvider.h>

@implementation DVEMixedEffectSlider

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.slider];
        [self addSubview:self.titileLabel];
        self.slider.centerY = self.height * 0.5;
    }
    
    return self;
}

- (void)setValueRange:(DVEFloatRang)valueRange defaultProgress:(float)progress {
    _valueRange = valueRange;
    float start = _valueRange.location;
    float max = _valueRange.length;
    
    if (start > max) {
        start = max - start;
    }
    [_slider setMinimumValue:start];
    [_slider setMaximumValue:max];
    self.value = progress;
}

- (DVEStepSlider *)slider {
    if (!_slider) {
        _slider = [[DVEStepSlider alloc] initWithStep:1 defaultValue:0 frame:CGRectMake(0, 0, self.width, 30)];
        _slider.maximumTrackTintColor = colorWithHexAlpha(0x626262, 0.8);
        _slider.minimumTrackTintColor = [UIColor dve_themeColor];
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

- (void)sliderValueChanged:(UISlider *)slider {
    self.value = slider.value;
}

- (void)setValue:(float)value {
    _value = value;
    [_slider setValue:value];
    DVELogInfo(@"DVEMixedEffect sliderValue:%d", (int)self.value);
    [self.delegate sliderValueChanged:value/100.0];
}

- (void)setSliderValue:(float)value {
    _value = value;
    [_slider setValue:value];
}

@end
