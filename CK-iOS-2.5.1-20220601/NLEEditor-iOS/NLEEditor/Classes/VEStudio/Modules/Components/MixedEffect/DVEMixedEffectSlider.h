//
//  DVEMixedEffectSlider.h
//  NLEEditor
//
//  Created by bytedance on 2021/4/20.
//

#import <UIKit/UIKit.h>
#import "DVEStepSlider.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DVEMixedEffectSliderDelegate <NSObject>

- (void)sliderValueChanged:(float)value;
@end

@interface DVEMixedEffectSlider : UIView

@property (nonatomic, weak) id<DVEMixedEffectSliderDelegate> delegate;
@property (nonatomic, strong) DVEStepSlider *slider;
@property (nonatomic, strong) UILabel *titileLabel;
@property (nonatomic, assign) float value;
@property (nonatomic, assign) DVEFloatRang valueRange;

- (void)setValueRange:(DVEFloatRang)valueRange defaultProgress:(float)progress;

- (void)setSliderValue:(float)value;

@end

NS_ASSUME_NONNULL_END
