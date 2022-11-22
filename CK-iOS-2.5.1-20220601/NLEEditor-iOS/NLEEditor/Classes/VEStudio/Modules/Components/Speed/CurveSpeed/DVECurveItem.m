//
//  DVECurveItem.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVECurveItem.h"
#import "NSString+DVEToPinYin.h"
#import "NSString+VEToImage.h"
#import "DVEMacros.h"
#import <SDWebImage/SDWebImage.h>
#import <TTVideoEditor/UIColor+Utils.h>

@interface DVECurveItem()

@property (nonatomic, strong) UIImageView *maskView;

@end

@implementation DVECurveItem

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLable];
        [self addSubview:self.iconView];
        
    }
    
    return self;
}


- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.image = @"icon_vevc_transition".dve_toImage;
    }
    
    return _iconView;
}

- (UILabel *)titleLable
{
    if (!_titleLable) {
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, 50, 20)];
        _titleLable.textAlignment = NSTextAlignmentCenter;
        _titleLable.font = SCRegularFont(12);
        _titleLable.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    }
    
    return _titleLable;
}


- (void)setModel:(DVEEffectValue*)model {
    [super setModel:model];

    _titleLable.text = model.name;
    
    if(model.imageURL == nil){
        self.maskView.image = nil;
        self.maskView.backgroundColor = UIColor.clearColor;

    }else{
        self.maskView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
        self.maskView.image = @"icon_cover_edit".dve_toImage;
    }
    [self.iconView sd_setImageWithURL:model.imageURL placeholderImage:model.assetImage];
}

- (void)setStickerSelected:(BOOL)stickerSelected animated:(BOOL)animated {
    [super setStickerSelected:stickerSelected animated:animated];
    [self setSelected:stickerSelected];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        [self addSubview:self.maskView];
    } else {
        [self.maskView removeFromSuperview];
    }
}

- (UIImageView *)maskView {
    if (!_maskView) {
        _maskView = [[UIImageView alloc] initWithFrame:CGRectMake(-2.5, -2.5, 55, 55)];
        _maskView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
        _maskView.layer.borderColor = [UIColor colorWithHex:0xFE6646].CGColor;
        _maskView.layer.cornerRadius = 2.0f;
        _maskView.layer.borderWidth = 1;
        _maskView.image = @"icon_cover_edit".dve_toImage;
        _maskView.contentMode = UIViewContentModeCenter;

    }
    return _maskView;
}

@end
