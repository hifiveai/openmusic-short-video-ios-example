//
//  DVERangeSlider.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/30.
//

#import "DVERangeSlider.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "NSString+VEToImage.h"
#import "DVEMacros.h"
#import <Masonry/Masonry.h>

const static CGFloat kTrackHeight = 2;
const static CGFloat kBarWidth = 40;

@interface DVERangeSliderBar()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;


@end

@implementation DVERangeSliderBar

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
    [self addSubview:self.imageView];
    [self addSubview:self.label];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@13);
        make.center.equalTo(self);
    }];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@10);
        make.top.left.right.equalTo(self);
    }];
}
- (void)setupStyle {
    
}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:@"btn_slidebar_gray".dve_toImage];
    }
    return _imageView;
}
- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = SCRegularFont(10);
        _label.textColor = [UIColor whiteColor];
        _label.hidden = YES;
    }
    return _label;
}

@end

@interface DVERangeSlider()

@property (nonatomic, strong) DVERangeSliderBar *leftBar;
@property (nonatomic, strong) DVERangeSliderBar *rightBar;
@property (nonatomic, strong) UIView *leftProgress;
@property (nonatomic, strong) UIView *rightProgress;
@property (nonatomic, strong) UIView *track;

@property (nonatomic, assign) CGFloat leftValue;
@property (nonatomic, assign) CGFloat rightValue;
@property (nonatomic, assign) BOOL leftChange;
@property (nonatomic, assign) BOOL rightChange;

@property (nonatomic, strong) DVERangeSliderBar *selectedBar;

@end


@implementation DVERangeSlider

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayout];
        [self setupStyle];
        _maxValue = 1.0;
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_leftChange) {
        [self setLeftValue:_leftValue];
    }
    if (_rightChange) {
        [self setRightValue:_rightValue];
    }
}
- (void)setupLayout {
    [self addSubview:self.track];
    [self addSubview:self.leftProgress];
    [self addSubview:self.rightProgress];
    [self addSubview:self.leftBar];
    [self addSubview:self.rightBar];
    
    CGFloat halfHeight = kBarWidth * 0.5;
    
    [_track mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(halfHeight);
        make.right.equalTo(self).offset(-halfHeight);
        make.height.equalTo(@(kTrackHeight));
        make.centerY.equalTo(self);
    }];
    [_leftProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_track);
        make.width.equalTo(@(0));
        make.height.equalTo(@(kTrackHeight));
        make.centerY.equalTo(_track);
    }];
    [_rightProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_track);
        make.width.equalTo(@(0));
        make.height.equalTo(@(kTrackHeight));
        make.centerY.equalTo(_track);
    }];
    [_leftBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_leftProgress.mas_right);
        make.width.equalTo(@(kBarWidth));
        make.height.equalTo(self);
        make.centerY.equalTo(_track);
    }];
    [_rightBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_rightProgress.mas_left);
        make.width.equalTo(@(kBarWidth));
        make.height.equalTo(self);
        make.centerY.equalTo(_track);
    }];
}
- (void)setupStyle {
    
}
- (void)showLeftSlider {
    _leftBar.hidden = NO;
    _leftProgress.hidden = NO;
}
- (void)showRightSlider {
    _rightBar.hidden = NO;
    _rightProgress.hidden = NO;
}
- (void)hiddenLeftSlider {
    _leftBar.hidden = YES;
    _leftProgress.hidden = YES;
}
- (void)hiddenRightSlider {
    _rightBar.hidden = YES;
    _rightProgress.hidden = YES;
}
- (void)setLeftValue:(CGFloat)leftValue {
    _leftChange = leftValue != _leftValue;
    _leftValue = leftValue;
    
    CGFloat rangeDistance = self.width - kBarWidth;
    [_leftProgress mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(rangeDistance * leftValue/_maxValue));
    }];
    
    _leftBar.label.text = [NSString stringWithFormat:@"%0.1fs", MIN(leftValue, _maxValue)];
    if (_leftChange) {
        _leftBar.label.hidden = NO;
    }
}
- (void)setRightValue:(CGFloat)rightValue {
    _rightChange = rightValue != _rightValue;
    _rightValue = rightValue;
    
    CGFloat rangeDistance = self.width - kBarWidth;

    [_rightProgress mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(rangeDistance * rightValue/_maxValue));
    }];
    
    _rightBar.label.text = [NSString stringWithFormat:@"%0.1fs", MIN(rightValue, _maxValue)];
    if (_rightChange) {
        _rightBar.label.hidden = NO;
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint position = [touches.anyObject locationInView:self];
    //如果两个bar重叠在一起，选择上面的那个
    if (CGRectContainsPoint(_rightBar.frame, position) && CGRectContainsPoint(_leftBar.frame, position)) {
        if ([self.subviews indexOfObject:_leftBar] > [self.subviews indexOfObject:_rightBar]) {
            _selectedBar = _leftBar;
        }
        if ([self.subviews indexOfObject:_leftBar] < [self.subviews indexOfObject:_rightBar]) {
            _selectedBar = _rightBar;
        }
    } else {
        if (CGRectContainsPoint(_leftBar.frame, position)) {
            _selectedBar = _leftBar;
        }
        if (CGRectContainsPoint(_rightBar.frame, position)) {
            _selectedBar = _rightBar;
        }
    }
    _selectedBar.label.hidden = NO;
    [self bringSubviewToFront:_selectedBar];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint position = [touches.anyObject locationInView:self];
    CGFloat offset = position.x;
    CGFloat minOffset = 0;
    CGFloat maxOffset = _track.width;
    CGFloat rangeDistance = self.width - kBarWidth;
    
    if (offset < minOffset) {
        offset = minOffset;
    }
    if (offset > maxOffset) {
        offset = maxOffset;
    }
    if (_selectedBar == _leftBar) {
        if (offset > (rangeDistance - _rightProgress.width) && !_rightProgress.isHidden) {
            offset = (rangeDistance - _rightProgress.width);
        }
        [_leftProgress mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(offset));
        }];
        
        _selectedBar.label.text = [NSString stringWithFormat:@"%0.1fs", _leftProgress.width/rangeDistance * _maxValue];
    }
    if (_selectedBar == _rightBar) {
        if (offset < _leftProgress.width && !_leftProgress.isHidden) {
            offset = _leftProgress.width;
        }
        [_rightProgress mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(rangeDistance - offset));
        }];
        _selectedBar.label.text = [NSString stringWithFormat:@"%0.1fs", _rightProgress.width/rangeDistance * _maxValue];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGFloat rangeDistance = self.width - kBarWidth;
    CGFloat offet;
    if (_selectedBar == _leftBar) {
        offet = _leftProgress.width;
        [_delegate slider:self leftValueChange:offet/rangeDistance * _maxValue];
    }
    if (_selectedBar == _rightBar) {
        offet = _rightProgress.width;
        [_delegate slider:self rightValueChange:offet/rangeDistance * _maxValue];
    }
}
- (DVERangeSliderBar *)leftBar {
    if (!_leftBar) {
        _leftBar = [[DVERangeSliderBar alloc] init];
    }
    return _leftBar;
}
- (DVERangeSliderBar *)rightBar {
    if (!_rightBar) {
        _rightBar = [[DVERangeSliderBar alloc] init];
    }
    return _rightBar;
}
- (UIView *)leftProgress {
    if (!_leftProgress) {
        _leftProgress = [[UIView alloc] init];
        _leftProgress.layer.cornerRadius = kTrackHeight * 0.5;
        _leftProgress.backgroundColor = HEXRGBCOLOR(0xFE6646);
    }
    return _leftProgress;
}
- (UIView *)rightProgress {
    if (!_rightProgress) {
        _rightProgress = [[UIView alloc] init];
        _rightProgress.layer.cornerRadius = kTrackHeight * 0.5;
        _rightProgress.backgroundColor = HEXRGBCOLOR(0xF5E76EE);
    }
    return _rightProgress;
}
- (UIView *)track {
    if (!_track) {
        _track = [[UIView alloc] init];
        _track.layer.cornerRadius = kTrackHeight * 0.5;
        _track.layer.masksToBounds = YES;
        _track.backgroundColor = HEXRGBCOLOR(0x626262);
    }
    return _track;
}
@end
