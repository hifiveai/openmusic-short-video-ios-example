//
//  DVEMaskItem.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/3/31.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "DVEMaskItem.h"
#import "NSString+DVEToPinYin.h"
#import "NSString+VEToImage.h"
#import "NSString+VEIEPath.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEMacros.h"
#import "DVELoadingView.h"
#import <DVETrackKit/UIColor+DVEStyle.h>
#import <DVETrackKit/DVEUILayout.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface DVEMaskItem()
@property(nonatomic,strong) UIImageView* downloadView;
@property (nonatomic, strong) UIView *downloadingView;
@end

@implementation DVEMaskItem
@synthesize model = _model;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.iconView];
        [self.iconView addSubview:self.coverView];
    }
    return self;
}


- (UIImageView *)iconView
{
    if (!_iconView) {
        if ([DVEUILayout dve_alignmentWithName:DVEUILayoutMasktemTextPosition] == DVEUILayoutAlignmentBottom) {
            _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        } else {
            _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 24, 50, 50)];
        }
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.layer.cornerRadius = [DVEUILayout dve_sizeNumberWithName:DVEUILayoutMaskItemCornerRadius];
        _iconView.layer.borderWidth = 1;
    }
    return _iconView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        if ([DVEUILayout dve_alignmentWithName:DVEUILayoutMasktemTextPosition] == DVEUILayoutAlignmentBottom) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 50, 24)];
        } else {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 24)];
        }
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = SCRegularFont(12);
        _titleLabel.textColor = [UIColor whiteColor];
    }
    
    return _titleLabel;
}

- (UIView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _coverView.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
        [_coverView addSubview:self.lineView];
        [_coverView addSubview:self.hitView];
//        self.lineView.center = CGPointMake(25, 25);
//        self.hitView.center = CGPointMake(35, 25);
        _coverView.hidden = YES;
    }
    return _coverView;
}

//- (UIView *)lineView
//{
//    if (!_lineView) {
//        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 38, 2)];
//        _lineView.backgroundColor = [UIColor whiteColor];
//    }
//    return _lineView;
//}

//- (UIView *)hitView
//{
//    if (!_hitView) {
//        _hitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
//        _hitView.layer.cornerRadius = 3;
//        _hitView.clipsToBounds  = YES;
//        _hitView.backgroundColor = [UIColor whiteColor];
//    }
//    return _hitView;
//}

- (void)setSelected:(BOOL)selected
{
    if(self.model.status == DVEResourceModelStatusDefault){
        [super setSelected:selected];
        _coverView.hidden = !selected;
        if (selected) {
            self.iconView.layer.borderColor = [UIColor dve_themeColor].CGColor;
            self.iconView.clipsToBounds = YES;
        } else {
            self.iconView.layer.borderColor = [UIColor clearColor].CGColor;
            self.iconView.clipsToBounds = NO;
        }
    }
}


- (void)setModel:(DVEEffectValue*)model {
    _model = model;
    _titleLabel.text = model.name;
    
//    if(_model.valueState == VEEffectValueStateShuntDown){
//        self.hitView.hidden = YES;
//        self.lineView.hidden = YES;
//    }else{
//        self.hitView.hidden = NO;
//        self.lineView.hidden = NO;
//    }
        
    [_iconView sd_setImageWithURL:model.imageURL placeholderImage:model.assetImage];
}

- (UIView *)downloadView {
    if(!_downloadView) {
        _downloadView = [[UIImageView alloc] initWithImage:@"icon_effects_download".dve_toImage];
        CGFloat w = CGRectGetWidth(self.frame);
        _downloadView.frame = CGRectMake(w - 9, self.iconView.frame.origin.y, 9, 9);
    }
    return _downloadView;
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

@end
