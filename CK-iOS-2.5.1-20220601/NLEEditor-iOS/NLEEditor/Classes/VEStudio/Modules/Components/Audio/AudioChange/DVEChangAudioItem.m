//
//  DVEChangAudioItem.m
//  NLEEditor
//
//  Created by bytedance on 2021/7/6.
//

#import "DVEChangAudioItem.h"
#import "NSString+DVEToPinYin.h"
#import "NSString+VEToImage.h"
#import "NSString+VEIEPath.h"
#import "DVEMacros.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation DVEChangAudioItem

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.iconView];
        [self addSubview:self.coverView];
    }
    
    return self;
}


- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 27, 50, 50)];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.layer.cornerRadius = 25;
        _iconView.layer.borderWidth = 1;
        _iconView.clipsToBounds = YES;
    }
    
    return _iconView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 24)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = SCRegularFont(12);
        _titleLabel.textColor = [UIColor whiteColor];
    }
    
    return _titleLabel;
}

- (UIView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 27, 50, 50)];
        _coverView.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
        _coverView.layer.cornerRadius = 25;
        _coverView.layer.borderWidth = 0;
        _coverView.clipsToBounds = YES;
        _coverView.hidden = YES;
        
    }
    
    return _coverView;
}


- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];

    _coverView.hidden = !selected;
    if (selected) {
        self.iconView.layer.borderColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.27 alpha:1.0].CGColor;
    } else {
        self.iconView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}


- (void)setModel:(DVEEffectValue*)model {
    [super setModel:model];
    _titleLabel.text = model.name;
    [_iconView sd_setImageWithURL:model.imageURL placeholderImage:model.assetImage];
}

- (void)setStickerSelected:(BOOL)stickerSelected animated:(BOOL)animated {
    [super setStickerSelected:stickerSelected animated:animated];
    [self setSelected:stickerSelected];
}

@end
