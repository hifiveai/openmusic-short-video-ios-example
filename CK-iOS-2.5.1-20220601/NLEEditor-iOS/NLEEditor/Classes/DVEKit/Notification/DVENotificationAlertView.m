//
//  DVENotificationAlertView.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/9.
//

#import "DVENotificationAlertView.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEMacros.h"
#import <Masonry/Masonry.h>

@implementation DVENotificationAlertView

- (void)setupUI {
    [super setupUI];
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.messageLabel];
    [self.contentView addSubview:self.leftAction];
    [self.contentView addSubview:self.rightAction];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@16);
        make.left.equalTo(@16);
        make.right.equalTo(@-16);
        make.height.equalTo(@24);
    }];
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.top.equalTo(@50);
        make.right.equalTo(@-16);
        make.bottom.lessThanOrEqualTo(@-50);
    }];
    [_leftAction mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@24);
        make.bottom.equalTo(@-12);
        make.width.equalTo(@100);
        make.height.equalTo(@32);
    }];
    [_rightAction mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-24);
        make.bottom.equalTo(@-12);
        make.width.equalTo(@100);
        make.height.equalTo(@32);
    }];
}
#pragma mark - setter
- (void)setLeftActionBlock:(DVEActionBlock)leftActionBlock {
    _leftActionBlock = leftActionBlock;
    __weak typeof(self) WeakSelf = self;
    _leftAction.actionBlock = ^(UIView * _Nonnull view) {
        leftActionBlock(WeakSelf);
        [WeakSelf removeFromSuperview];
    };
}
- (void)setRightActionBlock:(DVEActionBlock)rightActionBlock {
    _rightActionBlock = rightActionBlock;
    __weak typeof(self) WeakSelf = self;
    _rightAction.actionBlock = ^(UIView * _Nonnull view) {
        rightActionBlock(WeakSelf);
        [WeakSelf removeFromSuperview];
    };
}
#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = SCSemiboldFont(16);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = HEXRGBCOLOR(0x000000);
    }
    return _titleLabel;
}
- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = SCRegularFont(14);
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        _messageLabel.textColor = HEXRGBCOLOR(0x000000);
    }
    return _messageLabel;
}
- (DVENotificationAction *)leftAction {
    if (!_leftAction) {
        _leftAction = [[DVENotificationAction alloc] init];
        _leftAction.titleLabel.textColor = HEXRGBCOLOR(0xFE6646);
        _leftAction.titleLabel.font = SCRegularFont(12);
        _leftAction.backgroundColor = UIColor.whiteColor;
        _leftAction.layer.cornerRadius = 16;
    }
    return _leftAction;
}
- (DVENotificationAction *)rightAction {
    if (!_rightAction) {
        _rightAction = [[DVENotificationAction alloc] init];
        _rightAction.titleLabel.textColor = UIColor.whiteColor;
        _rightAction.titleLabel.font = SCRegularFont(12);
        _rightAction.backgroundColor = HEXRGBCOLOR(0xFE6646);
        _rightAction.layer.cornerRadius = 16;
    }
    return _rightAction;
}
@end
