//
//  DVEBaseSlider.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/MASConstraint.h>

NS_ASSUME_NONNULL_BEGIN
@class DVEBaseSlider;
@protocol DVESBaseSliderProtocol <NSObject>

- (void)touchesSliderBegan:(DVEBaseSlider *)slider;
- (void)touchesSliderEnd:(DVEBaseSlider *)slider;
- (void)touchesSliderValueChange:(DVEBaseSlider *)slider;

@end

@interface DVEBaseSlider : UIView
@property (nonatomic, assign) float step;
@property (nonatomic, assign) float minimumValue;
@property (nonatomic, assign) float maximumValue;
@property (nonatomic, assign) float horizontalInset;
@property (nonatomic, strong) CALayer *centralLine;
@property (nonatomic, assign) CGFloat sliderHeight;
@property (nonatomic, assign) BOOL showTitleWhenSliding;
@property (nonatomic, weak) id<DVESBaseSliderProtocol> delegate;
@property (nonatomic, strong) UIImage *imageCursor;
@property (nonatomic, assign) float defaultValue;
@property (nonatomic, strong) UIColor *silderStrokeColor;
@property (nonatomic, strong) UIColor *centralLineColor;
@property (nonatomic, strong) UIColor *backLayerBackgroundColor;
@property (nonatomic, assign) float value;
@property (nonatomic, assign) CGFloat textOffset;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) CAShapeLayer *tintLayer;
@property (nonatomic, strong) CALayer *backLayer;
@property (nonatomic, strong) UIImageView *cursorView;
@property (nonatomic, copy) void(^sliderAction)(BOOL a,BOOL b,float c);
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) MASConstraint *cursorLeftConstraint;

- (instancetype)initWithStep:(float)step defaultValue:(float)defaultvalue frame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
