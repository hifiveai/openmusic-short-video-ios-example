//
//  DVEAnimationListCell.m
//  NLEEditor
//
//  Created by bytedance on 2021/7/1.
//

#import "DVEAnimationListCell.h"
#import "DVEMacros.h"
#import <Masonry/Masonry.h>


@implementation DVEAnimationListCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupLayout];
        [self setupStyle];
    }
    
    return self;
}
- (void)setupLayout {
    [self addSubview:self.titleLabel];
    [self addSubview:self.imageView];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@20);
    }];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(_titleLabel.mas_top);
    }];
}
- (void)setupStyle {
    
}
- (void)setSelected:(BOOL)selected {
    if (selected) {
        _imageView.layer.borderColor = HEXRGBCOLOR(0xFE6646).CGColor;
        _imageView.layer.borderWidth = 0.6;
    } else {
        _imageView.layer.borderWidth = 0;
    }
}
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 24, 50, 50)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.layer.cornerRadius = 25;
        _imageView.layer.masksToBounds = YES;
    }
    
    return _imageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 24)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = SCRegularFont(12);
        _titleLabel.textColor = [UIColor whiteColor];
    }
    
    return _titleLabel;
}
@end
