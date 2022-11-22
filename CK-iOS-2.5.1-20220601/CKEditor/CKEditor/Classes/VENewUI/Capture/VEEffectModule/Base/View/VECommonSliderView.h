//
//  VECommonSliderView.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NLEEditor/DVEStepSlider.h>

NS_ASSUME_NONNULL_BEGIN

@interface VECommonSliderView : UIView

@property (nonatomic, strong) DVEStepSlider *slider;
@property (nonatomic, strong) UILabel *titileLable;

@property (nonatomic, assign) float value;

@property (nonatomic, assign) DVEFloatRang valueRange;

- (void)setValueRange:(DVEFloatRang)rang defaultProgress:(float)progress;

@end

NS_ASSUME_NONNULL_END
