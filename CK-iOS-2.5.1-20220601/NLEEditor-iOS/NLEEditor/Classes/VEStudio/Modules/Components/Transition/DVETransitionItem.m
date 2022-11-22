//
//  DVETransitionItem.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVETransitionItem.h"
#import "NSString+DVEToPinYin.h"
#import "NSString+VEToImage.h"
#import "DVEMacros.h"
#import "NSString+VEIEPath.h"
#import <DVETrackKit/UIView+VEExt.h>
#import <DVETrackKit/DVEUILayout.h>
#import <DVETrackKit/UIColor+DVEStyle.h>
#import <SDWebImage/UIImageView+WebCache.h>

@implementation DVETransitionItem

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLable];
        [self addSubview:self.iconView];
        if([DVEUILayout dve_alignmentWithName:DVEUILayoutTransitionItemTextPosition] == DVEUILayoutAlignmentBottom){
            self.iconView.frame = CGRectMake(0, 0, self.iconView.frame.size.width, self.iconView.frame.size.height);
            self.titleLable.frame = CGRectMake(0, self.iconView.frame.size.height, self.titleLable.frame.size.width, self.titleLable.frame.size.height);
        }
        self.iconView.centerX = self.width/2;
    }
    
    return self;
}


- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 24, 50, 50)];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.image = @"icon_vevc_transition".dve_toImage;
        _iconView.layer.borderWidth = 1;
        _iconView.layer.cornerRadius = [DVEUILayout dve_sizeNumberWithName:DVEUILayoutAnimationItemCornerRadius];
    }
    
    return _iconView;
}

- (UILabel *)titleLable
{
    if (!_titleLable) {
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 24)];
        _titleLable.textAlignment = NSTextAlignmentCenter;
        _titleLable.font = SCRegularFont(12);
        _titleLable.textColor = [UIColor whiteColor];
    }
    
    return _titleLable;
}

- (void)setModel:(DVEEffectValue*)model {
    [super setModel:model];

    _titleLable.text = model.name;
    
    [self.iconView sd_setImageWithURL:model.imageURL placeholderImage:model.assetImage];
}

- (UIView *)downloadView {
    UIView* view = [super downloadView];
    view.frame = CGRectMake(self.iconView.right - view.width, self.iconView.top, view.width, view.height);
    return view;
}

- (UIView *)downloadingView
{
    UIView* view = [super downloadingView];
    view.centerY = self.iconView.centerY;
    return view;
}


- (void)setStickerSelected:(BOOL)stickerSelected animated:(BOOL)animated {
    [super setStickerSelected:stickerSelected animated:animated];
    [self setSelected:stickerSelected];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        self.iconView.layer.borderColor = [UIColor dve_themeColor].CGColor;
        self.iconView.clipsToBounds = YES;
    } else {
        self.iconView.layer.borderColor = [UIColor clearColor].CGColor;
        self.iconView.clipsToBounds = NO;
    }
}

@end
