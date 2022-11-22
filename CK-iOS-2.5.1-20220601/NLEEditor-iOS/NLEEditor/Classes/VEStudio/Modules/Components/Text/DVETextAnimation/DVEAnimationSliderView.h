//
//  DVEAnimationSliderView.h
//  NLEEditor
//
//  Created by bytedance on 2021/7/2.
//

#import <UIKit/UIKit.h>
#import "DVERangeSlider.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEAnimationSliderView : UIView

@property (nonatomic, strong) DVERangeSlider *slider;

- (void)showRangeLabel;
- (void)hiddenRangeLabel;

@end

NS_ASSUME_NONNULL_END
