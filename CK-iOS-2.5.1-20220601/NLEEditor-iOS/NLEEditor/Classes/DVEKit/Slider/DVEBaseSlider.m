//
//  DVEBaseSlider.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "DVEBaseSlider.h"
#import "NSString+VEToImage.h"
#import "DVEMacros.h"
#import <DVETrackKit/DVEUILayout.h>
#import <DVETrackKit/UIView+VEExt.h>
#import <Masonry/Masonry.h>

@implementation DVEBaseSlider

- (instancetype)initWithStep:(float)step defaultValue:(float)defaultvalue frame:(CGRect)frame
{
    self = [self initWithFrame:frame];
    self.step = step;
    self.defaultValue = defaultvalue;
    self.horizontalInset = 0;
    self.sliderHeight = 2;
    self.imageCursor = @"btn_slidebar_gray".dve_toImage;
    self.radius = 7;
    self.strokeColor = [self strokeColor];
    self.centralLineColor = HEXRGBCOLOR(0x363636);
    self.backLayerBackgroundColor = [UIColor whiteColor];
    self.sliderHeight = 2;
    [self buildLayout];
    
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    
    return self;
}

- (void)buildLayout
{
    [self addSubview:self.label];
    [self.layer addSublayer:self.backLayer];
    [self.layer addSublayer:self.tintLayer];
    [self.layer addSublayer:self.centralLine];
    [self addSubview:self.cursorView];
    
    _backLayer.backgroundColor = _backLayerBackgroundColor.CGColor;
    
    _centralLine.backgroundColor = _centralLineColor.CGColor;
    
    _centralLine.hidden = true;
    
    _backLayer.cornerRadius = 0.5;
    _backLayer.masksToBounds = true;
    
    [_cursorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(13, 13));
        make.centerY.equalTo(self);
        make.left.equalTo(self);
    }];

    [self updateCentralLine];
    self.textOffset = 0;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat minY = self.height * 0.5;
    _backLayer.frame = CGRectMake(self.horizontalInset, minY, self.width - _horizontalInset * 2, self.sliderHeight);
    _tintLayer.frame = CGRectMake(self.horizontalInset, minY, 0, self.sliderHeight);
    _centralLine.frame = CGRectMake(self.width * 0.5 - 2, (self.height - 6) * 0.5, 2, 7);
    [self resetValueView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (self.sliderAction) {
        self.sliderAction(YES, NO, self.value);
    }
    if ([self.delegate respondsToSelector:@selector(touchesSliderBegan:)]) {
        [self.delegate touchesSliderBegan:self];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self sliderValueChangedTouches:touches.allObjects end:NO];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self sliderValueChangedTouches:touches.allObjects end:YES];
    if ([self.delegate respondsToSelector:@selector(touchesSliderEnd:)]) {
        [self.delegate touchesSliderEnd:self];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self sliderValueChangedTouches:touches.allObjects end:YES];
}

- (void)resetValueView
{
    if (self.minimumValue > self.maximumValue) {
        return;
    }
    CGFloat w = self.width - self.horizontalInset * 2 ;
    CGFloat offset =  (self.defaultValue - self.minimumValue)/(self.maximumValue - self.minimumValue) * self.backLayer.frame.size.width + self.horizontalInset - 1;
    CGFloat begin = self.minimumValue < 0 ? offset : self.horizontalInset;
    CGFloat width = (fabsf(self.minimumValue < 0 ? self.value : self.value - self.minimumValue)/(self.maximumValue - self.minimumValue)) * w;
    CGFloat start = (self.value > 0 ? begin : begin - width) - self.horizontalInset;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(start, self.sliderHeight * 0.5)];
    [path addLineToPoint:CGPointMake(start+width, self.sliderHeight * 0.5)];
    self.tintLayer.path = path.CGPath;
    self.cursorView.left = (self.value > 0 ? start + width : start) - self.radius + self.horizontalInset;
    [self updateLabelFrame];
}

- (void)updateLabelFrame
{
    self.label.centerX = self.cursorView.centerX;
    if ([DVEUILayout dve_alignmentWithName:DVEUILayoutSliderLabelPosition] == DVEUILayoutAlignmentBottom){
        self.label.top = self.cursorView.bottom + self.textOffset;
    } else{
        self.label.bottom = self.cursorView.top - self.textOffset;
    }
}

- (void)sliderValueChangedTouches:(NSArray <UITouch *>*)touches end:(BOOL)end
{
    if (touches.count == 0) {
        return;
    }
    UITouch *touch = touches.firstObject;
    
    CGFloat width = self.width - _horizontalInset * 2;
    CGFloat locationX = [touch locationInView:self].x;
    locationX = MAX(locationX, 0.0);
    locationX = MIN(locationX, self.width);
    
    CGFloat xx = MAX(0.0, MIN(width, locationX - _horizontalInset));
    CGFloat x = (xx / width)* (_maximumValue - _minimumValue);
    int v1 = ceilf(x * 100.0/self.step);
    float newValue = (v1) * self.step / 100 + self.minimumValue;
    if ((newValue != self.value) || end) {
        self.value = newValue;
        if (self.sliderAction) {
            self.sliderAction(false, end, self.value);
        }
    }
    if ([self.delegate respondsToSelector:@selector(touchesSliderValueChange:)]) {
        [self.delegate touchesSliderValueChange:self];
    }
    
}

+ (UIColor *)sliderStroke
{
    return RGBCOLOR(254, 44, 85);
}

- (UILabel *)label
{
    if (!_label) {
        _label = [UILabel new];
        _label.textColor = HEXRGBACOLOR(0xffffff, 0.8);
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = SCRegularFont(10);
    }
    
    return _label;
}

- (CALayer *)backLayer
{
    if (!_backLayer) {
        _backLayer = [CALayer layer];
    }
    
    return _backLayer;
}

- (CAShapeLayer *)tintLayer
{
    if (!_tintLayer) {
        _tintLayer = [CAShapeLayer layer];
        _tintLayer.lineWidth = 2;
        _tintLayer.cornerRadius = 0.5;
        _tintLayer.lineCap = kCALineCapRound;
    }
    
    return _tintLayer;
}

- (CALayer *)centralLine
{
    if (!_centralLine) {
        _centralLine = [CALayer layer];
    }
    
    return _centralLine;
}

- (UIImageView *)cursorView
{
    if (!_cursorView) {
        _cursorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _cursorView.image = self.imageCursor;
    }
    
    return _cursorView;
}

- (void)setMinimumValue:(float)minimumValue
{
    _minimumValue = minimumValue;
    [self updateCentralLine];
}

- (void)setMaximumValue:(float)maximumValue
{
    _maximumValue = maximumValue;
    [self updateCentralLine];
}

- (void)setSliderHeight:(CGFloat)sliderHeight
{
    _sliderHeight = sliderHeight;
    if (self.backLayer.frame.size.width > 0) {
        CGFloat minY = self.height * 0.5;
        self.backLayer.frame = CGRectMake(_horizontalInset, minY, self.width - _horizontalInset * 2, sliderHeight);
        self.tintLayer.frame = CGRectMake(_horizontalInset, minY, 0, sliderHeight);
    }
}

- (void)setSilderStrokeColor:(UIColor *)silderStrokeColor
{
    _silderStrokeColor = silderStrokeColor;
    self.tintLayer.strokeColor = silderStrokeColor.CGColor;
}

- (void)setCentralLineColor:(UIColor *)centralLineColor
{
    _centralLineColor = centralLineColor;
    self.centralLine.backgroundColor = centralLineColor.CGColor;
}

- (void)setBackLayerBackgroundColor:(UIColor *)backLayerBackgroundColor
{
    _backLayerBackgroundColor = backLayerBackgroundColor;
    self.backLayer.backgroundColor = backLayerBackgroundColor.CGColor;
}

- (void)setValue:(float)value
{
    value = MAX(self.minimumValue, value);
    value = MIN(self.maximumValue, value);
    _value = value;
    [self resetValueView];
}

- (void)setTextOffset:(CGFloat)textOffset
{
    _textOffset = textOffset;
    [self updateLabelFrame];
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    _strokeColor = strokeColor;
    self.tintLayer.strokeColor = strokeColor.CGColor;
}

- (void)updateCentralLine
{
    if (self.minimumValue > self.maximumValue) {
        return;
    }
//    CGFloat centerXOffset = ((self.defaultValue - self.minimumValue)/(self.maximumValue - self.minimumValue)) * self.backLayer.frame.size.width + _horizontalInset - 2  ;    //－2是因为一个是宽度的一半，一个是坐标是从0开始
    self.centralLine.frame = CGRectMake(0, (self.height-6)/2, 2, 7);
}

- (void)setImageCursor:(UIImage *)imageCursor
{
    _imageCursor = imageCursor;
    _cursorView.image = self.imageCursor;
}

@end
