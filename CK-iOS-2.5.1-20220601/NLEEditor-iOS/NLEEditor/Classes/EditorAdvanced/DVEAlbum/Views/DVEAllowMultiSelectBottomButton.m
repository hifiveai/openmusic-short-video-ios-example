//
//  DVEAllowMultiSelectBottomButton.m
//  AWEStudio
//
//  Created by bytedance on 2018/11/19.
//  Copyright © 2018 bytedance. All rights reserved.
//

#import "UIView+DVEAlbumMasonry.h"
#import "DVEAllowMultiSelectBottomButton.h"
#import "DVEAlbumResourceUnion.h"
#import <Masonry/Masonry.h>

@interface DVEAllowMultiSelectBottomButton ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) MASConstraint *labelRightToSelfConstraint;

@end

@implementation DVEAllowMultiSelectBottomButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
        self.layer.cornerRadius = 22;
        self.layer.shadowColor = TOCResourceColor(TOCUIColorConstLineSecondary).CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowRadius = 8;
        self.layer.shadowOpacity = 1.0f;
    }
    return self;
}

- (void)addSubviews
{
    [self addSubview:self.iconImageView];
    DVEAlbumMasReMaker(self.iconImageView, {
        make.width.height.equalTo(@(44));
        make.left.equalTo(self);
        make.top.bottom.equalTo(self);
    });
    [self addSubview:self.label];
    DVEAlbumMasReMaker(self.label, {
        make.left.equalTo(self.iconImageView.mas_right);
        make.centerY.equalTo(self.iconImageView);
        self.labelRightToSelfConstraint = make.right.equalTo(self).offset(-16);
    });
}

#pragma mark - subviews

- (UIImageView *)iconImageView
{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithImage:TOCResourceImage(@"icMultipleBlack")];
        _iconImageView.tintColor = TOCResourceColor(TOCUIColorConstBGContainer);
    }
    return _iconImageView;
}

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.text = @"multi_select_video";
        _label.font = [UIFont boldSystemFontOfSize:15];
        _label.textColor = TOCResourceColor(TOCUIColorConstTextPrimary);
    }
    return _label;
}

#pragma mark - setter

- (void)setSelected:(BOOL)selected
{
    [self markSelected:selected animated:YES];
}

- (void)markSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected];

    [self.labelRightToSelfConstraint uninstall];
    
    if (selected) {
        DVEAlbumMasReMaker(self.iconImageView, {
            make.width.height.equalTo(@(44));
            make.left.equalTo(self);
            make.top.bottom.equalTo(self);
            make.right.equalTo(self);
        });
        DVEAlbumMasReMaker(self.label, {
            make.left.equalTo(self.iconImageView.mas_right);
            make.centerY.equalTo(self.iconImageView);
        });
    } else {
        DVEAlbumMasReMaker(self.iconImageView, {
            make.width.height.equalTo(@(44));
            make.left.equalTo(self);
            make.top.bottom.equalTo(self);
        });
        DVEAlbumMasReMaker(self.label, {
            make.left.equalTo(self.iconImageView.mas_right);
            make.centerY.equalTo(self.iconImageView);
            self.labelRightToSelfConstraint = make.right.equalTo(self).offset(-16);
        });
    }
    
    UIColor *backgroundColor = self.selected ? TOCResourceColor(TOCUIColorConstPrimary) : TOCResourceColor(TOCUIColorConstBGContainer2);
    UIColor *tintColor = self.selected ? TOCResourceColor(TOCUIColorConstTextInverse) : TOCResourceColor(TOCUIColorConstTextPrimary);
    if (animated) {
        [UIView animateWithDuration:0.15 delay:0 options:0 animations:^{
            self.iconImageView.tintColor = tintColor;
            self.backgroundColor = backgroundColor;
            [self.superview layoutIfNeeded];
            self.label.alpha = selected ? 0.0f : 1.0f;
        } completion:nil];
    } else {
        self.iconImageView.tintColor = tintColor;
        self.backgroundColor = backgroundColor;
        [self.superview layoutIfNeeded];
    }
}

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

@end
