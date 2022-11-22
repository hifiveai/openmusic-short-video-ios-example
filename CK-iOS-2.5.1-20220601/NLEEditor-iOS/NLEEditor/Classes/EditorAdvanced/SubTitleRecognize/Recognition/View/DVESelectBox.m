//
//  DVESelectBox.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/18.
//

#import "DVESelectBox.h"
#import "DVEMacros.h"
#import <Masonry/Masonry.h>

@implementation DVESelectBox

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    [self updateUI];
}

- (void)setupUI
{
    _imageView = [[UIImageView alloc] init];
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = SCRegularFont(14);
    _titleLabel.textColor = colorWithHex(0x4E5969);
    
    [self addSubview:_imageView];
    [self addSubview:_titleLabel];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageView.mas_right).mas_offset(8);
        make.top.bottom.right.equalTo(self);
    }];
}

- (void)updateUI
{
    if (self.selected) {
        self.imageView.image = self.selectedImage;
    } else {
        self.imageView.image = self.normalImage;
    }
}

- (void)setNormalImage:(UIImage *)normalImage
{
    _normalImage = normalImage;
    [self updateUI];
}

- (void)setSelectedImage:(UIImage *)selectedImage
{
    _selectedImage = selectedImage;
    [self updateUI];
}

@end
