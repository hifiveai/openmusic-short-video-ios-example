//
//  DVECropRulerView.h
//  NLEEditor
//
//  Created by bytedance on 2021/4/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DVECropRulerView;
@protocol DVECropRulerViewDelegate <NSObject>

- (void)rulerDidMove:(DVECropRulerView *)rulerView changAngle:(CGFloat)angle;
- (void)rulerDidEnd;
@end

@interface DVECropIndicatorView : UIView

- (void)updateLabelValue:(CGFloat)value;

@end

@interface DVECropRulerView : UIView

@property (nonatomic, assign, readonly) CGFloat value;
@property (nonatomic, assign, readonly) CGFloat minimumValue;
@property (nonatomic, assign, readonly) CGFloat maximumValue;
@property (nonatomic, assign, readonly) CGFloat precisonValue;
@property (nonatomic, weak) id<DVECropRulerViewDelegate> delegate;

- (instancetype)initWithDefaultValue:(CGFloat)value
                        minimumValue:(CGFloat)minimumValue
                        maximumValue:(CGFloat)maximumValue
                       precisonValue:(CGFloat)precisonValue;

- (void)updateAngle:(CGFloat)angle;

- (void)refresh:(CGFloat)angle;

- (void)reset;

- (CGFloat)inset;

@end

NS_ASSUME_NONNULL_END
