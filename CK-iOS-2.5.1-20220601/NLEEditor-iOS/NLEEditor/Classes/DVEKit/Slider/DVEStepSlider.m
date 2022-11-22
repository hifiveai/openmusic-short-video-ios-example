//
//  DVEStepSlider.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "DVEStepSlider.h"
#import "DVEBaseSlider.h"
#import "DVEMacros.h"
#import "NSString+VEToImage.h"
#import <DVETrackKit/UIColor+DVEStyle.h>
#import <DVETrackKit/UIView+VEExt.h>


@implementation DVEStepSlider

- (instancetype)initWithStep:(float)step defaultValue:(float)defaultvalue frame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initWithStep:step value:defaultvalue frame:frame];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initWithStep:1 value:0 frame:frame];
    }
    
    return self;
}

-(void)initWithStep:(float)step value:(float)value frame:(CGRect)frame
{
    _step = step;
    _minimumValue = 0.0;
    _maximumValue = 1.0;
    _value = 0.0;
    _decimal = 1;
    _sliderHeight = 2;
    _slider = [[DVEBaseSlider alloc] initWithStep:step defaultValue:value frame:frame];
    _slider.delegate = self;
    _slider.horizontalInset = 16;
    _slider.maximumValue = self.maximumValue;
    _slider.minimumValue = self.minimumValue;
    _slider.label.textColor = [UIColor whiteColor];
    _slider.silderStrokeColor = RGBCOLOR(254, 44, 85);
    _slider.backLayerBackgroundColor = [UIColor whiteColor];
    _slider.sliderHeight = 2;
    _slider.centralLineColor = HEXRGBCOLOR(0x363636);
    [self setup];
}

- (CGFloat)textOffset {
    return self.slider.textOffset;
}

- (void)setTextOffset:(CGFloat)textOffset {
    self.slider.textOffset = textOffset;
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
    self.maximumValue = max;
    self.minimumValue = start;
    self.value = progress;
}

- (void)setMinimumValue:(float)minimumValue
{
    _minimumValue = minimumValue;
    _slider.minimumValue = minimumValue;
}

- (void)setMaximumValue:(float)maximumValue
{
    _maximumValue = maximumValue;
    _slider.maximumValue = maximumValue;
}

- (void)setValue:(float)value
{
    value = MAX(_slider.minimumValue, value);
    value = MIN(_slider.maximumValue, value);
    _value = value;
    [self updateStepLabel];
    _slider.value = _value;
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor
{
    _minimumTrackTintColor = minimumTrackTintColor;
    _slider.silderStrokeColor = minimumTrackTintColor;
}

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor
{
    _maximumTrackTintColor = maximumTrackTintColor;
    _slider.backLayerBackgroundColor = maximumTrackTintColor;
}

- (void)setSliderHeight:(CGFloat)sliderHeight
{
    _sliderHeight = sliderHeight;
    _slider.sliderHeight = sliderHeight;
}

- (float)horizontalInset
{
    return _slider.horizontalInset;
}

- (void)setHorizontalInset:(float)horizontalInset
{
    _slider.horizontalInset = horizontalInset;
}

- (void)setup
{
    [self addSubview:self.slider];
    
    _slider.frame = self.bounds;

    self.maximumTrackTintColor = [UIColor dve_colorWithName:DVEUIColorSliderBackground];
    self.minimumTrackTintColor = [UIColor dve_themeColor];
    
    [self updateThumbImage];
    double decimal = log10(self.step);
    if (powf(10.0, decimal) != self.step) { decimal -= 1 ;}
    self.decimal = abs((int)(decimal));
    
        
    self.setupUI = YES;
    [self adjustLayout];
    
}

- (void)updateStepLabel
{
    NSString *valueString;
    switch (self.valueType) {
        case DVEStepSliderValueTypeNone:
            valueString = [NSString stringWithFormat:@"%d", (int)self.value];
            break;
        case DVEStepSliderValueTypePercent:
            valueString = [NSString stringWithFormat:@"%d%%", (int)self.value];
            break;
        case DVEStepSliderValueTypeSecond:
            valueString = [NSString stringWithFormat:@"%.1f", self.value];
        default:
            break;
    }
    
    _slider.label.text = valueString;
    
    [_slider.label sizeToFit];
    _slider.sliderHeight = self.sliderHeight;
}

- (void)updateThumbImage
{
    _slider.imageCursor = @"btn_slidebar_gray".dve_toImage;
}

- (void)adjustLayout
{
    
}

- (void)touchesSliderBegan:(DVEBaseSlider *)slider
{
    [self sendActionsForControlEvents:UIControlEventTouchDown];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}
- (void)touchesSliderEnd:(DVEBaseSlider *)slider
{
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}
- (void)touchesSliderValueChange:(DVEBaseSlider *)slider
{
    float v = slider.value;
    NSInteger v1 = lroundf(v * 100/ self.step);
    float newValue = v1 * self.step/100;
    BOOL changed = newValue != self.value;
    
    self.value = newValue;
    [self updateStepLabel];
    if (changed ){
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

    if(self.hidden == NO && self.alpha >= 0.01 && CGRectContainsPoint(self.bounds, point)){
        return self.slider;
    }
    return nil;
}


@end
