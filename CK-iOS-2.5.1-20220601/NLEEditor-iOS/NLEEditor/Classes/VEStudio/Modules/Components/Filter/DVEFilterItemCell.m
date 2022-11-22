//
//  DVEFilterItemCell.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEFilterItemCell.h"
#import "NSString+DVEToPinYin.h"
#import "NSString+VEToImage.h"
#import "NSString+VEIEPath.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEMacros.h"
#import <DVETrackKit/DVEUILayout.h>
#import <DVETrackKit/UIColor+DVEStyle.h>
#import <SDWebImage/SDWebImage.h>


@implementation DVEFilterItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLable];
        [self addSubview:self.iconView];
        [self addSubview:self.coverView];
        if([DVEUILayout dve_alignmentWithName:DVEUILayoutFilterItemTextPosition] == DVEUILayoutAlignmentBottom){
            self.iconView.frame = CGRectMake(0, 0, self.iconView.frame.size.width, self.iconView.frame.size.height);
            self.coverView.frame = self.iconView.frame;
            self.titleLable.frame = CGRectMake(0, self.iconView.frame.size.height, self.titleLable.frame.size.width, self.titleLable.frame.size.height);
        }
    }
    
    return self;
}


- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 24, 50, 50)];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.layer.borderWidth = 1;
        _iconView.clipsToBounds = YES;
    }
    
    return _iconView;
}

- (UILabel *)titleLable
{
    if (!_titleLable) {
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 24)];
        _titleLable.textAlignment = NSTextAlignmentCenter;
        _titleLable.font = SCRegularFont(12);
        _titleLable.textColor = [UIColor whiteColor];
    }
    
    return _titleLable;
}

- (UIView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 24, 50, 50)];
        _coverView.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
        [_coverView addSubview:self.lineView];
        [_coverView addSubview:self.hitView];
        self.lineView.center = CGPointMake(25, 25);
        self.hitView.center = CGPointMake(35, 25);
        _coverView.hidden = YES;
        
    }
    return _coverView;
}

- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 38, 1.5)];
        _lineView.backgroundColor = [UIColor whiteColor];
    }
    
    return _lineView;
}

- (UIView *)hitView
{
    if (!_hitView) {
        _hitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
        _hitView.layer.cornerRadius = 3;
        _hitView.backgroundColor = [UIColor whiteColor];
    }
    
    return _hitView;
}

- (void)setModel:(DVEEffectValue*)model
{
    [super setModel:model];
    _titleLable.text = model.name;
    [_iconView sd_setImageWithURL:model.imageURL placeholderImage:model.assetImage];
}


-(void)setStickerSelected:(BOOL)stickerSelected animated:(BOOL)animated {
    [super setStickerSelected:stickerSelected animated:animated];
    
    DVEEffectValue* m = (DVEEffectValue*)self.model;
    
    if (m.valueState != VEEffectValueStateShuntDown) {
        _coverView.hidden = !stickerSelected;
        _lineView.hidden = NO;
        _hitView.hidden = NO;
    } else {
        _coverView.hidden = !stickerSelected;
        _lineView.hidden = YES;
        _hitView.hidden = YES;
    }

    if (stickerSelected) {
        self.iconView.layer.borderColor = [UIColor dve_themeColor].CGColor;
    } else {
        self.iconView.layer.borderColor = [UIColor clearColor].CGColor;
    }
    
}

- (UIView *)downloadingView
{
    UIView* view = [super downloadingView];
    view.centerY = self.iconView.centerY;
    return view;
}

@end
