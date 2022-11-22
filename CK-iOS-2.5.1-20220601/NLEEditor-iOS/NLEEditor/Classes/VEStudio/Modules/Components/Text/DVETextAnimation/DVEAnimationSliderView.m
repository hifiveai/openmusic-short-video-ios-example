//
//  DVEAnimationSliderView.m
//  NLEEditor
//
//  Created by bytedance on 2021/7/2.
//

#import "DVEAnimationSliderView.h"
#import "DVEMacros.h"
#import <Masonry/Masonry.h>

@interface DVEAnimationSliderView()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;

@end


@implementation DVEAnimationSliderView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayout];
        [self setupStyle];
    }
    return self;
}
- (void)setupLayout {
    [self addSubview:self.titleLabel];
    [self addSubview:self.leftLabel];
    [self addSubview:self.slider];
    [self addSubview:self.rightLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@20);
        make.width.equalTo(@60);
        make.left.equalTo(self).offset(15);
        make.bottom.top.equalTo(self);
    }];
    [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@20);
        make.left.equalTo(_titleLabel.mas_right).offset(26);
        make.bottom.top.equalTo(self);
    }];
    [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@20);
        make.right.equalTo(self).offset(-26);
        make.bottom.top.equalTo(self);
    }];
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftLabel.mas_right);
        make.right.equalTo(_rightLabel.mas_left);
        make.bottom.top.equalTo(self);
    }];
}
- (void)setupStyle {
//    self.leftLabel.hidden = YES;
//    self.rightLabel.hidden = YES;
}
- (void)showRangeLabel {
    _leftLabel.hidden = NO;
    _rightLabel.hidden = NO;
}
- (void)hiddenRangeLabel {
    _leftLabel.hidden = YES;
    _rightLabel.hidden = YES;
}
- (DVERangeSlider *)slider {
    if (!_slider) {
        _slider = [[DVERangeSlider alloc] init];
        _slider.backgroundColor = UIColor.clearColor;
    }
    return _slider;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = SCRegularFont(12);
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = NLELocalizedString(@"ck_anim_duration", @"动画时长");
    }
    return _titleLabel;
}
- (UILabel *)leftLabel {
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.textAlignment = NSTextAlignmentCenter;
        _leftLabel.font = SCRegularFont(10);
        _leftLabel.textColor = [UIColor whiteColor];
        _leftLabel.text = NLELocalizedString(@"ck_text_anim_quick", @"快");
    }
    return _leftLabel;
}
- (UILabel *)rightLabel {
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.textAlignment = NSTextAlignmentCenter;
        _rightLabel.font = SCRegularFont(10);
        _rightLabel.textColor = [UIColor whiteColor];
        _rightLabel.text = NLELocalizedString(@"ck_text_anim_slow", @"慢");
    }
    return _rightLabel;
}
@end
