//
//  DVECropRulerView.m
//  NLEEditor
//
//  Created by bytedance on 2021/4/8.
//

#import "DVEMacros.h"
#import "DVECropRulerView.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVELoggerImpl.h"
#import <DVETrackKit/UIColor+DVEStyle.h>
#import <Masonry/Masonry.h>

@interface DVECropIndicatorView ()

@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation DVECropIndicatorView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpLayout];
    }
    return self;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    return _line;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    return _titleLabel;
}

- (void)setUpLayout {
    [self addSubview:self.titleLabel];
    self.titleLabel.font = SCRegularFont(12);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor dve_themeColor];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.top.mas_equalTo(self.mas_top);
        make.right.mas_equalTo(self.mas_right);
    }];

//    self.titleLabel.left = self.left;
//    self.titleLabel.top = self.top;
//    self.titleLabel.right = self.right;
//
    [self addSubview:self.line];
    self.line.backgroundColor = [UIColor dve_themeColor];
    self.line.layer.cornerRadius = 1.5;
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_titleLabel.mas_bottom).offset(10);
        make.centerX.mas_equalTo(_titleLabel.mas_centerX);
        make.width.mas_equalTo(2);
        make.height.mas_equalTo(24);
    }];
//    self.line.top = self.titleLabel.bottom - 10;
//    self.line.centerX = self.titleLabel.centerX;
//    self.line.width = 3;
//    self.line.height = 18;
}

- (void)updateLabelValue:(CGFloat)value {
    int intValue = lroundf((float)value);
    self.titleLabel.text = [NSString stringWithFormat:@"%d°", intValue];
}
@end


@interface DVECropRulerView ()

@property (nonatomic, strong) UIView *container;

@property (nonatomic, strong) DVECropIndicatorView *indicatorView;

@property (nonatomic, strong) NSMutableArray<CAShapeLayer *> *unitLayers;

@property (nonatomic, assign) CGFloat minUnitOffsetValue;

@property (nonatomic, assign) BOOL isAttach;

@property (nonatomic, strong) UILabel *leftLabel;

@property (nonatomic, strong) UILabel *rightLabel;

@end

@implementation DVECropRulerView

static const CGFloat kinset = 12;

- (instancetype)initWithDefaultValue:(CGFloat)value
                        minimumValue:(CGFloat)minimumValue
                        maximumValue:(CGFloat)maximumValue
                       precisonValue:(CGFloat)precisonValue {
    if (self = [super initWithFrame:CGRectMake(0, 0, 0, 0)]) {
        _value = value;
        _minimumValue = minimumValue;
        _maximumValue = maximumValue;
        _precisonValue = precisonValue;
        
        _unitLayers = [NSMutableArray array];
        
        int unitCount = (int)((_maximumValue - _minimumValue) / _precisonValue);
        for (NSInteger i = 0; i <= unitCount; i++) {
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            BOOL isMidUnit = (i % 5 == 0);
            layer.frame = CGRectMake(0, 0, (isMidUnit ? 1.5 : 1.0), (isMidUnit ? 22.5 : 12.72));
            layer.backgroundColor = colorWithHexAlpha(0xffffff, (isMidUnit ? 0.7 : 0.5)).CGColor;
            [self.unitLayers addObject:layer];
        }
        [self setUpLayout];
        [self setUpGesture];
    }
    return self;
}

- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    return _container;
}

- (DVECropIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[DVECropIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    return _indicatorView;
}

- (UILabel *)leftLabel {
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    return _leftLabel;
}

- (UILabel *)rightLabel {
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    return _rightLabel;
}

- (void)setUpLayout {
    [self addSubview:self.container];
    
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(-18);
        make.left.mas_equalTo(self.mas_left).inset(kinset);
        make.right.mas_equalTo(self.mas_right).inset(kinset);
        make.height.mas_equalTo(12);
    }];
    
    for (CAShapeLayer *layer in self.unitLayers) {
        [self.container.layer addSublayer:layer];
    }
    DVELogInfo(@"container:%.10f %.10f %.10f %.10f", self.container.frame.origin.x, self.container.frame.origin.y, self.container.frame.size.width, self.container.frame.size.height);
    
    [self addSubview:self.indicatorView];
    [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(50);
        make.top.mas_equalTo(self.mas_top).offset(15);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-20);
    }];
    
    [self addSubview:self.leftLabel];
    self.leftLabel.font = SCRegularFont(14);
    self.leftLabel.textAlignment = NSTextAlignmentCenter;
    self.leftLabel.textColor = [UIColor whiteColor];
    self.leftLabel.text = [NSString stringWithFormat:@"%d°", (int)self.minimumValue];
    [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_container.mas_bottom).offset(10);
        make.left.mas_equalTo(self.mas_left);
    }];
    
    [self addSubview:self.rightLabel];
    self.rightLabel.font = SCRegularFont(14);
    self.rightLabel.textAlignment = NSTextAlignmentCenter;
    self.rightLabel.textColor = [UIColor whiteColor];
    self.rightLabel.text = [NSString stringWithFormat:@"%d°", (int)self.maximumValue];
    [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_container.mas_bottom).offset(10);
        make.right.mas_equalTo(self.mas_right);
    }];
    
    [self.indicatorView updateLabelValue:self.value];
    
}

- (void)setUpGesture {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(hanleGesture:)];
    [self.indicatorView addGestureRecognizer:panGesture];
}

- (void)hanleGesture:(UIPanGestureRecognizer *)panGesture {
    CGPoint pos = [panGesture locationInView:self.container];
    if (pos.x < kinset) {
        pos.x = kinset;
    } else if (pos.x > self.container.frame.size.width + kinset) {
        pos.x = self.container.frame.size.width + kinset;
    }
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat offset = pos.x - kinset;
            CGFloat angle = (self.container.frame.size.width / 2.0 - offset) / self.container.frame.size.width * ((CGFloat)(_maximumValue - _minimumValue));
            if (fabs(angle) < 1.0) {
                if (_isAttach) {
                    return;
                }
                if (@available(iOS 10.0, *)) {
                    UISelectionFeedbackGenerator * selection = [[UISelectionFeedbackGenerator alloc] init];
                    [selection selectionChanged];
                }
                angle = 0;
                _isAttach = YES;
            } else {
                _isAttach = NO;
            }
            [self updateAngle:angle];
            [self.delegate rulerDidMove:self changAngle:angle];
            DVELogInfo(@"delegate rulerDidMove:%.10f", angle);
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self panGestureEnded:panGesture];
            break;
        default:
            break;
    }
}

//滑杆响应旋转
- (void)panGestureEnded:(UIPanGestureRecognizer *)recognizer {
    [self.delegate rulerDidEnd];
}

#pragma mark Override

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect rect = CGRectInset(self.indicatorView.frame, -10, -10);
    return CGRectContainsPoint(rect, point);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.unitLayers.count > 1) {
        _minUnitOffsetValue = self.container.frame.size.width / ((CGFloat)(self.unitLayers.count - 1));
        NSInteger count = self.unitLayers.count;
        for (NSInteger i = 0; i < count; i++) {
            self.unitLayers[i].position = CGPointMake(_minUnitOffsetValue * ((CGFloat)i), (i % 5 == 0 ? 6 : 10));
            DVELogInfo(@"unitLayer's x:%.10f", _minUnitOffsetValue * ((CGFloat)i));
        }
        [self updateAngle:_value];
    }
}

- (void)updateAngle:(CGFloat)angle {
    CGFloat posAngle = angle;
    if (posAngle < _minimumValue) {
        posAngle = _minimumValue;
    }
    if (posAngle > _maximumValue) {
        posAngle = _maximumValue;
    }

    _value = posAngle;
    [self.indicatorView updateLabelValue:-_value];
    CGFloat dist = posAngle / (CGFloat)_precisonValue * _minUnitOffsetValue;
    if (isnan(dist) || !isfinite(dist)) {
        dist = 0;
    }
    DVELogInfo(@"dist:%.10f", dist);
    [_indicatorView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX).offset(-dist);
    }];
//    self.indicatorView.centerX = self.centerX - dist;
}

- (void)refresh:(CGFloat)angle {
    [self updateAngle:angle];
    _isAttach = (angle < 1.0);
}

- (CGFloat)inset {
    return kinset;
}

@end
