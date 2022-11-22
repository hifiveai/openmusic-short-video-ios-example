//
//  DVEStickerItem.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEStickerItem.h"
#import "NSString+VEToImage.h"
#import <DVETrackKit/DVEUILayout.h>
#import <DVETrackKit/UIColor+DVEStyle.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@implementation DVEStickerItem

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildLayout];
    }
    
    return self;
}

- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:self.bounds];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.image = @"icon_aixinxin".dve_toImage;
        _iconView.layer.masksToBounds = YES;
        _iconView.layer.cornerRadius = [DVEUILayout dve_sizeNumberWithName:DVEUILayoutStickerItemCornerRadius];
        _iconView.backgroundColor = [UIColor dve_colorWithName:DVEUIColorStickerItemBackground];
        _iconView.layer.borderWidth = 1;
    }
    
    return _iconView;
}

- (void)buildLayout
{
    [self addSubview:self.iconView];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setModel:(DVEEffectValue*)model
{
    [super setModel:model];
    [self updateStickerIconImage];
}

- (void)updateStickerIconImage
{
    [self.iconView sd_setImageWithURL:self.model.imageURL placeholderImage:self.model.assetImage];
}

- (void)setStickerSelected:(BOOL)stickerSelected animated:(BOOL)animated {
    [super setStickerSelected:stickerSelected animated:animated];

    if (stickerSelected) {
        self.iconView.layer.borderColor = [UIColor dve_themeColor].CGColor;
    } else {
        self.iconView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

@end
