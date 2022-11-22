//
//  DVEModuleItem.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEModuleItem.h"
#import "DVEMacros.h"
#import <DVETrackKit/UIView+VEExt.h>
#import <DVETrackKit/UIFont+DVEStyle.h>
#import <DVETrackKit/DVECustomResourceProvider.h>

@interface DVEModuleItem ()



@end

@implementation DVEModuleItem

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.iconView];
        [self addSubview:self.titleLable];
    }
    
    return self;
}

- (void)setIndex:(NSIndexPath *)indexPath ForType:(VEVCModuleItemType)type
{
    self.indexPath = indexPath;
    self.type = type;
}

- (void)setType:(VEVCModuleItemType)type
{
    _type = type;
}

- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 24, 20)];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        [_iconView setTintColor:[UIColor whiteColor]];    
    }
    
    return _iconView;
}

- (UILabel *)titleLable
{
    if (!_titleLable) {
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 34, 64, 20)];
        _titleLable.font = [UIFont dve_styleWithName:DVEUIFontStyleRegular sizeName:DVEUIFontSizeBottomBarItemTitle];
        _titleLable.textAlignment = NSTextAlignmentCenter;
        _titleLable.textColor = [UIColor whiteColor];
    }
    
    return _titleLable;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.iconView.image) {
        self.titleLable.centerY = 32;
    } else {
        self.titleLable.top = 34;
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];

    if (selected && self.type != VEVCModuleItemTypeCover) {
        self.layer.borderColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.27 alpha:1.0].CGColor;
        [self.iconView setTintColor:[UIColor dve_themeColor]];
        self.titleLable.textColor = [UIColor dve_themeColor];
    } else {
        self.layer.borderColor = [UIColor clearColor].CGColor;
        [self.iconView setTintColor:[UIColor whiteColor]];
        self.titleLable.textColor = [UIColor whiteColor];
    }
}





@end
