//
//  DVECircularProgressView.h
//  Pods
//
//  Created by bytedance on 2019/5/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVECircularProgressView : UIView

// 进度
@property (nonatomic, assign) CGFloat progress;

// 进度条的颜色
@property (nonatomic, strong) UIColor *progressTintColor;

// 进度条的背景色
@property (nonatomic, strong) UIColor *progressBackgroundColor;

// 线宽
@property (nonatomic, assign) CGFloat lineWidth;

// 背景宽
@property (nonatomic, assign) CGFloat backgroundWidth;

// 进度条半径
@property (nonatomic, assign) CGFloat progressRadius;
// 背景半径
@property (nonatomic, assign) CGFloat backgroundRadius;

- (void)unobserveAll;

@end

NS_ASSUME_NONNULL_END
