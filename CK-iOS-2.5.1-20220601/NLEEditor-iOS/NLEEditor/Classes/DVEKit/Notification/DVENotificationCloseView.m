//
//  DVENotificationCloseView.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/9.
//

#import "DVENotificationCloseView.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEMacros.h"
#import "NSString+VEToImage.h"
#import <Masonry/Masonry.h>

@implementation DVENotificationCloseView

- (void)setupUI {
    self.contentView.backgroundColor = HEXRGBCOLOR(0xF2F2F2);
    [super setupUI];
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.messageLabel];
    [self.contentView addSubview:self.closeButton];
    
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
        make.bottom.lessThanOrEqualTo(@-16);
    }];
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-10);
        make.top.equalTo(@10);
        make.width.height.equalTo(@16);
    }];
}
- (void)closeAction:(UIButton *)button {
    [self removeFromSuperview];
    if (_closeBlock) {
        _closeBlock(self);
    }
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = SCRegularFont(16);
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
- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:@"small_close".dve_toImage forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}
@end
