//
//  VEVCRegulateItem.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "DVERegulateItem.h"
#import "NSString+DVEToPinYin.h"
#import "NSString+VEIEPath.h"
#import "NSString+VEToImage.h"
#import <DVETrackKit/UIView+VEExt.h>
#import <DVETrackKit/UIColor+DVEStyle.h>
#import "DVEMacros.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>

@implementation DVERegulateItem

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.iconView];
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self).offset(-5);
            make.height.mas_equalTo(20);
        }];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(15);
            make.left.equalTo(self).offset(12);
            make.right.equalTo(self).offset(-12);
            make.bottom.equalTo(self.titleLabel.mas_top).offset(-5);
        }];

    }
    
    return self;
}

- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [UIImageView new];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        [_iconView setTintColor:[UIColor whiteColor]];
    }
    
    return _iconView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = SCRegularFont(12);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
    }
    
    return _titleLabel;
}

- (void)setModel:(DVEEffectValue*)model {
    [super setModel:model];

    _titleLabel.text = model.name;
    
    @weakify(self);
    [_iconView sd_setImageWithURL:model.imageURL placeholderImage:[model.assetImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if(image != nil){
            @strongify(self);
            self.iconView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }];
}

- (void)setStickerSelected:(BOOL)stickerSelected animated:(BOOL)animated {
    [super setStickerSelected:stickerSelected animated:animated];
    [self setSelected:stickerSelected];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.layer.borderColor = [UIColor redColor].CGColor;
        [self.iconView setTintColor:[UIColor dve_themeColor]];
        self.titleLabel.textColor = [UIColor dve_themeColor];
    } else {
        self.layer.borderColor = [UIColor clearColor].CGColor;
        [self.iconView setTintColor:[UIColor whiteColor]];
        self.titleLabel.textColor = [UIColor whiteColor];
    }
}

@end
