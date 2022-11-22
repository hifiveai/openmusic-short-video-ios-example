//
//  VEEFliteItem.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEEFliteItem.h"
#import "NSString+VEToPinYin.h"
#import <SDWebImage/SDWebImage.h>

@interface VEEFliteItem ()

@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *hitView;

@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation VEEFliteItem

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLable];
        [self addSubview:self.iconView];
        [self addSubview:self.coverView];
    }
    
    return self;
}


- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 24, 50, 50)];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
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
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 38, 2)];
        _lineView.backgroundColor = [UIColor whiteColor];
    }
    
    return _lineView;
}

- (UIView *)hitView
{
    if (!_hitView) {
        _hitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
        _hitView.layer.cornerRadius = 3;
        _hitView.clipsToBounds  = YES;
        _hitView.backgroundColor = [UIColor whiteColor];
    }
    
    return _hitView;
}

- (void)setEValue:(DVEEffectValue *)eValue
{
    _eValue = eValue;
    _titleLable.text = eValue.name;
    if(eValue.imageURL == nil){
        _iconView.image = eValue.assetImage;
    }else{
        [_iconView sd_setImageWithURL:eValue.imageURL];
    }
    
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (self.eValue.valueState != VEEffectValueStateShuntDown) {
        _coverView.hidden = !selected;
    }
    
    self.layer.cornerRadius = 5;
    
    self.layer.borderWidth = 1;
    self.clipsToBounds = YES;
    if (selected) {
        self.layer.borderColor = [UIColor redColor].CGColor;
        
    } else {
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

@end
