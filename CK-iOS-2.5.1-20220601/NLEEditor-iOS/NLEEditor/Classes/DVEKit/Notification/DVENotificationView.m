//
//  DVENotificationView.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/9.
//

#import "DVENotificationView.h"
#import "DVEMacros.h"
#import <Masonry/Masonry.h>

@implementation DVENotificationView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    [self addSubview:self.contentView];
    
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@270);
        make.height.equalTo(@140);
        make.center.equalTo(self);
    }];
}
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = HEXRGBCOLOR(0xF2F2F2);
        _contentView.layer.cornerRadius = 8;
    }
    return _contentView;
}
@end


@implementation DVENotificationAction
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    [self addSubview:self.titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint location = [touches.anyObject locationInView:self];
    if (CGRectContainsPoint(self.bounds, location) && _actionBlock) {
        _actionBlock(self);
    }
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
@end
