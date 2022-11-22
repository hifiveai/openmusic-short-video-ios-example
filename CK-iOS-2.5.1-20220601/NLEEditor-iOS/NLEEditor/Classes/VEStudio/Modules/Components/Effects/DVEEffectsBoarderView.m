//
//   DVEEffectsBoarderView.m
//   NLEEditor
//
//   Created  by bytedance on 2021/4/11.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEEffectsBoarderView.h"
#import "DVEMacros.h"
#import <DVETrackKit/UIColor+DVEStyle.h>
#import <Masonry/Masonry.h>

@interface DVEEffectsBoarderView()
@property (nonatomic, strong) UIButton *imageButton;
@end

@implementation DVEEffectsBoarderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.layer.borderWidth = SINGLE_LINE_WIDTH;
        
        [self addSubview:self.imageButton];
        [self.imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self).offset(4);
            make.right.bottom.equalTo(self).offset(-4);
        }];

    }
    
    return self;
}

#pragma mark layz Method


- (UIButton *)imageButton
{
    if (!_imageButton) {
        _imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _imageButton.userInteractionEnabled = NO;
        _imageButton.clipsToBounds = YES;
    }
    
    return _imageButton;
}

#pragma mark public Method

- (void)setUnSelected
{
    self.layer.borderColor = [UIColor clearColor].CGColor;
}

- (void)setInUse
{
    self.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)setSelected
{
    self.layer.borderColor = [UIColor dve_themeColor].CGColor;
}

-(void)setImage:(UIImage *)image
{
    [self.imageButton setImage:image forState:UIControlStateNormal];
}

-(UIImage*)image
{
    return self.imageButton.imageView.image;
}

- (UIViewContentMode)imageMode
{
    return self.imageButton.imageView.contentMode;
}

- (void)setImageMode:(UIViewContentMode)imageMode
{
    self.imageButton.imageView.contentMode = imageMode;
}

- (void)setEnable:(BOOL)enable
{
    self.imageButton.enabled = enable;
}

@end
