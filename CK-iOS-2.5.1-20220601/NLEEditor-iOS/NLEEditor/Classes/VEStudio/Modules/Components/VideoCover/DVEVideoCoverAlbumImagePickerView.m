//
//  DVEVideoCoverAlbumImagePickerView.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/28.
//

#import "DVEVideoCoverAlbumImagePickerView.h"
#import "NSString+VEToImage.h"
#import "DVEMacros.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>

@interface DVEVideoCoverAlbumImagePickerView ()

@property (nonatomic, strong) UIButton *imageSelectedButton;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *label;

@end

@implementation DVEVideoCoverAlbumImagePickerView

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage;
    [self.imageSelectedButton setImage:selectedImage forState:UIControlStateNormal];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        return;
    }
    
    [self addSubview:self.imageSelectedButton];
    [self addSubview:self.iconView];
    [self addSubview:self.label];
    
    self.imageSelectedButton.alpha = 0.5;
    [self.imageSelectedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 80));
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.mas_top);
    }];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.left.mas_equalTo(self.imageSelectedButton.mas_left).offset(30);
        make.top.mas_equalTo(self.imageSelectedButton.mas_top).offset(22);
    }];
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(42, 24));
        make.left.mas_equalTo(self.imageSelectedButton.mas_left).offset(19);
        make.top.mas_equalTo(self.imageSelectedButton.mas_top).offset(44);
    }];
    
    @weakify(self);
    [[[self.imageSelectedButton rac_signalForControlEvents:UIControlEventTouchUpInside] deliverOnMainThread] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self.delegate updateSelectedAlbumImageWithCompletion:^(UIImage * _Nullable image) {
            if (!image) {
                return;
            }
            @strongify(self);
            [self.delegate showAlbumImageCropViewWithImage:image];
        }];
    }];
}


- (UIButton *)imageSelectedButton {
    if (!_imageSelectedButton) {
        _imageSelectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _imageSelectedButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageSelectedButton.imageView.clipsToBounds = YES;
    }
    return _imageSelectedButton;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        [_iconView setImage:[@"icon_cover_edit" dve_toImage]];
    }
    return _iconView;
}


- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.text = NLELocalizedString(@"ck_edit_image_cover", @"点击编辑");
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = SCRegularFont(10);
    }
    return _label;
}

@end
