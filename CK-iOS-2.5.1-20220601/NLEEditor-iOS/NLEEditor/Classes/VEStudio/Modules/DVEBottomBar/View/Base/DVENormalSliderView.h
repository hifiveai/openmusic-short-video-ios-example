//
//  DVENormalSliderView.h
//  NLEEditor
//
//  Created by bytedance on 2021/6/28.
//

#import <UIKit/UIKit.h>
#import "DVEStepSlider.h"

NS_ASSUME_NONNULL_BEGIN



@interface DVENormalSliderView : UIView

@property (nonatomic, strong) DVEStepSlider *slider;

/// 显示 value 值
@property (nonatomic, strong) UILabel *titileLable;

@property (nonatomic, assign) float value;

@property (nonatomic, assign) DVEFloatRang valueRange;

- (void)setValueRange:(DVEFloatRang)rang defaultProgress:(float)progress;

@end

NS_ASSUME_NONNULL_END
