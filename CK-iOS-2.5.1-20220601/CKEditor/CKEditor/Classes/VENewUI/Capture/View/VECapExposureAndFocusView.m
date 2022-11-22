//
//  VECapExposureAndFocusView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECapExposureAndFocusView.h"
#import "UIImage+VEAdd.h"

@interface VECapExposureAndFocusView ()

@property (nonatomic, strong) UIView *focusView;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *desLable;

@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat curValue;

@property (nonatomic, copy) exposureChangeBlock exposureBlock;

@end

@implementation VECapExposureAndFocusView

+ (void)hideInView:(UIView *)view
{
    UIView *tview = [view viewWithTag:989898];
    if (tview) {
        [tview removeFromSuperview];
    }
}

+ (void)showInView:(UIView *)view
minValue:(CGFloat)min
maxValue:(CGFloat)max
curValue:(CGFloat)curValue
point:(CGPoint)point
exposureChangeBlock:(exposureChangeBlock)block
{
    VECapExposureAndFocusView *eView = [[VECapExposureAndFocusView alloc] initWithFrame:CGRectMake(0, 0, 106, 88) minValue:min maxValue:max curValue:curValue];
    eView.exposureBlock = block;
    eView.tag = 989898;
    
    UIView *tview = [view viewWithTag:eView.tag];
    if (tview) {
        [tview removeFromSuperview];
    }
    
    [view addSubview:eView];
    eView.center = CGPointMake(point.x + 28, point.y);
    eView.userInteractionEnabled = YES;
    [eView performSelector:@selector(hide) withObject:nil afterDelay:3];
}

- (void)hide
{
    [self removeFromSuperview];
}

- (instancetype)initWithFrame:(CGRect)frame minValue:(CGFloat)min maxValue:(CGFloat)max curValue:(CGFloat)curValue
{
    if (self = [self initWithFrame:frame]) {
        self.minValue = min;
        self.maxValue = max;
        self.curValue = curValue;
        [self buildLayout];
    }
    
    return self;
}

- (void)buildLayout
{
    [self addSubview:self.focusView];
    [self addSubview:self.slider];
    [self addSubview:self.desLable];
}



- (UIView *)focusView
{
    if (!_focusView) {
        _focusView = [[UIView alloc] initWithFrame:CGRectMake(0, 19, 50, 50)];
        _focusView.layer.borderColor = [UIColor whiteColor].CGColor;
        _focusView.layer.borderWidth = 0.5;
        
    }
    
    return _focusView;
}

- (UISlider *)slider
{
    if (!_slider) {
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(18, 44 - 15, 88, 30)];
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _slider.maximumValue = self.maxValue;
        _slider.minimumValue = self.minValue;
        _slider.tintColor = HEXRGBCOLOR(0xFE6646);
        _slider.value = self.curValue;
        _slider.transform = CGAffineTransformMakeRotation(-M_PI_2);
        _slider.userInteractionEnabled = YES;
        [_slider setMaximumTrackImage:[UIImage VE_imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_slider setMinimumTrackImage:[UIImage VE_imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_slider setThumbImage:@"icon_slider_sun".UI_VEToImage forState:UIControlStateNormal];
        
    }
    
    return _slider;
}

- (UILabel *)desLable
{
    if (!_desLable) {
        _desLable = [[UILabel alloc] initWithFrame:CGRectMake(67, 14, 20, 60)];
        _desLable.textAlignment = NSTextAlignmentCenter;
        _desLable.font = SCRegularFont(12);
        _desLable.text = @"0";
    }
    
    return _desLable;
}

- (void)sliderValueChanged:(UISlider *)slider
{
    NSLog(@"qqqqqqqqqqqq-------%0.2f",slider.value);
    
    if (self.exposureBlock) {
        self.exposureBlock(slider.value);
    }
    
    _desLable.text = [NSString stringWithFormat:@"%0.0f",slider.value];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    [self performSelector:@selector(hide) withObject:nil afterDelay:3];
}

@end
