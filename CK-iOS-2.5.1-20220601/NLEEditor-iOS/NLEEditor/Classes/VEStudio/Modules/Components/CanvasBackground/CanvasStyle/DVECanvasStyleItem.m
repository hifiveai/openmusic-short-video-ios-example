//
//  DVECanvasStyleItem.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/1.
//

#import "DVECanvasStyleItem.h"
#import "DVEMacros.h"
#import <DVETrackKit/UIView+VEExt.h>
#import <SDWebImage/SDWebImage.h>

NSNotificationName const DVECanvasStyleItemDeSelectLocalImageNotification = @"DVECanvasStyleItemDeSelectLocalImageNotification";

@interface DVECanvasStyleItem ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIImageView *downloadIconView;

@end

@implementation DVECanvasStyleItem

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.iconView];
        [self addSubview:self.coverView];
        [self addSubview:self.closeButton];
        [self addSubview:self.downloadIconView];
    }
    return self;
}

- (void)setUpLayout {
    self.iconView.backgroundColor = [UIColor colorWithRed:0.188 green:0.2 blue:0.212 alpha:1];
    
    self.closeButton.size = CGSizeMake(20, 20);
    self.closeButton.top = self.iconView.top - 8;
    self.closeButton.right = self.iconView.right + 8;
    self.closeButton.hidden = YES;
    [self.closeButton addTarget:self action:@selector(cancelSelectedCanvasStyleImage) forControlEvents:UIControlEventTouchUpInside];
    
    self.downloadIconView.size = CGSizeMake(15, 15);
    self.downloadIconView.top = self.iconView.top - 5;
    self.downloadIconView.right = self.iconView.right + 5;
    self.downloadIconView.hidden = YES;
    
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 50, 50)];
        _iconView.contentMode = UIViewContentModeScaleToFill;
        _iconView.clipsToBounds = YES;
    }
    return _iconView;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 56, 56)];
        _coverView.layer.cornerRadius = 2.0;
        _coverView.layer.borderWidth = 1;
        _coverView.clipsToBounds = YES;
        _coverView.layer.borderColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.27 alpha:1.0].CGColor;
        _coverView.hidden = YES;
    }
    return _coverView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:[@"icon_vevc_delete_pic" dve_toImage] forState:UIControlStateNormal];
    }
    return _closeButton;
}

- (UIImageView *)downloadIconView {
    if (!_downloadIconView) {
        _downloadIconView = [[UIImageView alloc] init];
        _downloadIconView.image = [@"effectIcDownloadN" dve_toImage];
    }
    return _downloadIconView;
}

- (void)cancelSelectedCanvasStyleImage {
    self.model.sourcePath = nil;
    self.iconView.image = self.model.assetImage;
    self.closeButton.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DVECanvasStyleItemDeSelectLocalImageNotification
                                                        object:nil];
}

- (void)setStickerSelected:(BOOL)stickerSelected animated:(BOOL)animated {
    [super setStickerSelected:stickerSelected animated:animated];
    self.coverView.hidden = !stickerSelected;
    
    [self setUpLayout];
    
    switch (self.model.valueType) {
        case VEEffectValueTypeCanvasStyleLocal: {
            if (self.model.sourcePath.length > 0) {
                [self.iconView sd_setImageWithURL:[NSURL URLWithString:self.model.sourcePath]];
                self.closeButton.hidden = NO;
            } else {
                self.iconView.image = self.model.assetImage;
            }
            self.coverView.hidden = YES;
            break;
        }
        case VEEffectValueTypeCanvasStyleNetwork: {
            self.downloadIconView.hidden = NO;
            if (self.model.sourcePath.length > 0) {
                self.downloadIconView.hidden = YES;
            }
            break;
        }
        default:
            break;
    }
}

- (void)setModel:(DVEEffectValue *)model {
    [super setModel:model];
    [self.iconView sd_setImageWithURL:model.imageURL placeholderImage:model.assetImage];
}


@end
