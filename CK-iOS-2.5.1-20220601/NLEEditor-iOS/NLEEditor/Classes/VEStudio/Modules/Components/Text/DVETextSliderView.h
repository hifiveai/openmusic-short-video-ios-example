//
//  DVETextSliderView.h
//  NLEEditor
//
//  Created by bytedance on 2021/6/22.
//
//  左边有个 label
#import "DVEStepSlider.h"

NS_ASSUME_NONNULL_BEGIN

static const int8_t kDVETextSliderPreferHeight = 48;

@interface DVETextSliderView : DVEStepSlider
/// 描述标题
@property (nonatomic, strong) UILabel *textLabel;
@end

NS_ASSUME_NONNULL_END
