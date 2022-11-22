//
//  VEEBeautyItem.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEEBeautyItem.h"
#import <SDWebImage/SDWebImage.h>

@interface VEEBeautyItem ()

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *titleLable;

@end

@implementation VEEBeautyItem

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.icon];
        [self addSubview:self.titleLable];
    }
    
    return self;
}


- (UIImageView *)icon
{
    if (!_icon) {
        _icon = [[UIImageView alloc] initWithFrame:CGRectMake(30, 5, 24, 22)];
        _icon.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _icon;
}

- (UILabel *)titleLable
{
    if (!_titleLable) {
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.width, 20)];
        _titleLable.textColor = [UIColor whiteColor];
        _titleLable.font = SCRegularFont(12);
        _titleLable.textAlignment = NSTextAlignmentCenter;
    }
    
    return _titleLable;
}

- (void)setEValue:(DVEEffectValue *)eValue
{
    _eValue = eValue;
    
    if(eValue.imageURL == nil){
        self.icon.image = eValue.assetImage;
    }else{
//        @weakify(self);
//        [[SDWebImageManager sharedManager] loadImageWithURL:eValue.imageURL options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
//            @strongify(self);
//            if(image != nil){
//                self.icon.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//            }
//        }];
        [self.icon sd_setImageWithURL:eValue.imageURL];
    }
    
    
    self.titleLable.text = eValue.name;
    
    if (self.selected) {
        self.layer.borderColor = [UIColor redColor].CGColor;
        [self.icon setTintColor:[UIColor orangeColor]];
        self.titleLable.textColor = [UIColor orangeColor];
    } else {
        self.layer.borderColor = [UIColor clearColor].CGColor;
        [self.icon setTintColor:[UIColor whiteColor]];
        self.titleLable.textColor = [UIColor whiteColor];
    }
//    self.layer.borderColor = [UIColor clearColor].CGColor;
//    [self.icon setTintColor:[UIColor whiteColor]];
//    self.titleLable.textColor = [UIColor whiteColor];
    
    self.icon.centerX = self.width * 0.5;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.layer.borderWidth = 1;
    self.clipsToBounds = YES;
    if (selected) {
        self.layer.borderColor = [UIColor redColor].CGColor;
        [self.icon setTintColor:[UIColor orangeColor]];
        self.titleLable.textColor = [UIColor orangeColor];
    } else {
        self.layer.borderColor = [UIColor clearColor].CGColor;
        [self.icon setTintColor:[UIColor whiteColor]];
        self.titleLable.textColor = [UIColor whiteColor];
    }
}



@end
