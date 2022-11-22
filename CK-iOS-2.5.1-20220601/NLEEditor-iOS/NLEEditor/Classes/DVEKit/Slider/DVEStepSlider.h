//
//  DVEStepSlider.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVEBaseSlider.h"

typedef struct DVEFloatRang {
    CGFloat location;
    CGFloat length;
} DVEFloatRang;

CG_INLINE DVEFloatRang DVEMakeFloatRang (CGFloat location,CGFloat length)
{
    DVEFloatRang veRang;
    veRang.location = location;
    veRang.length = length;
    
    return veRang;
}

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DVEStepSliderType) {
    DVEStepSliderTypeRed = 0,
    DVEStepSliderTypeBlack,
    DVEStepSliderTypeCustom,
    DVEStepSliderTypeAnulus,
   
};

typedef NS_ENUM(NSUInteger, DVEStepSliderValueType) {
    DVEStepSliderValueTypeNone, //整数，无单位
    DVEStepSliderValueTypePercent, //整数，百分比
    DVEStepSliderValueTypeSecond, //小数，单位s
};


@interface DVEStepSlider : UIControl<DVESBaseSliderProtocol>

///数值类型
@property (nonatomic, assign) DVEStepSliderValueType valueType;

@property (nonatomic, assign) float minimumValue;
@property (nonatomic, assign) float maximumValue;
@property (nonatomic, assign) DVEStepSliderType type;
@property (nonatomic, assign) float value;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) CGFloat textOffset;
@property (nonatomic, strong) UIColor *minimumTrackTintColor;
@property (nonatomic, strong) UIColor *maximumTrackTintColor;
@property (nonatomic, copy) NSString *(^currentTextProvider)(float value,NSString *formatString,DVEStepSlider *slider);
@property (nonatomic, assign) BOOL showTitleWhenSliding;
@property (nonatomic, assign) float step;
@property (nonatomic, assign) CGFloat sliderHeight;
@property (nonatomic, assign) BOOL isShowingSliderValue;
@property (nonatomic, strong) UILabel *minTitleLabel;
@property (nonatomic, strong) UILabel *maxTitleLabel;
@property (nonatomic, strong) UIColor *minmaxLableTextColor;
@property (nonatomic, strong) UIFont *minmaxLableTextFont;
@property (nonatomic, assign) CGFloat minmaxLableTextOffset;
@property (nonatomic, assign) BOOL defaultMarkShow;
@property (nonatomic, strong) UIColor *defaultMarkColor;
@property (nonatomic, assign) BOOL setupUI;
@property (nonatomic, assign) NSInteger decimal;
@property (nonatomic, strong) DVEBaseSlider *slider;
@property (nonatomic, assign) DVEFloatRang valueRange;
@property (nonatomic, assign) float horizontalInset;

- (instancetype)initWithStep:(float)step defaultValue:(float)defaultvalue frame:(CGRect)frame;

- (void)setValueRange:(DVEFloatRang)rang defaultProgress:(float)progress;



@end

NS_ASSUME_NONNULL_END
