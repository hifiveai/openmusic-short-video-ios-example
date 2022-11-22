//
//  VEEStickerItem.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEEStickerItem.h"
#import <SDWebImage/SDWebImage.h>

@implementation VEEStickerItem

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.iconView];
        [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    
    return self;
}

- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [UIImageView new];
    }
    
    return _iconView;
}

- (void)setEValue:(DVEEffectValue *)evalue
{
    _eValue = evalue;
    
    if(evalue.imageURL == nil){
        _iconView.image = evalue.assetImage;
    }else{
        [_iconView sd_setImageWithURL:evalue.imageURL];
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.iconView.layer.cornerRadius = 5;
    
    self.iconView.layer.borderWidth = 1;
    self.iconView.clipsToBounds = YES;
    if (selected) {
        if (self.eValue.valueState == VEEffectValueStateInUse) {
            self.iconView.layer.borderColor = [UIColor whiteColor].CGColor;
        } else {
            self.iconView.layer.borderColor = [UIColor redColor].CGColor;
        }
        
    } else {
        self.iconView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

@end
