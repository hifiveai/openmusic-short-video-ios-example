//
//  DVETextConfigShadowView.h
//  NLEEditor
//
//  Created by bytedance on 2021/6/22.
//
//  阴影配置
#import <UIKit/UIKit.h>
#import "DVETextSliderView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVETextConfigShadowView : UIView
@property (nonatomic, strong) DVETextSliderView *alphaSlider;
@property (nonatomic, strong) DVETextSliderView *blurSlider;
@property (nonatomic, strong) DVETextSliderView *distanceSlider;
/// 角度
@property (nonatomic, strong) DVETextSliderView *angleSlider;
/// 根据角度、距离计算 shadowOffset
- (CGPoint)shadowOffset;
@end

NS_ASSUME_NONNULL_END
