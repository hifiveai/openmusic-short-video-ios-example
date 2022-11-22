//
//  DVEAlbumDenyAccessView.m
//  CutSameIF
//
//  Created by bytedance on 2020/9/9.
//

#import "DVEAlbumDenyAccessView.h"
#import "DVEAlbumResourceUnion.h"
#import "UIView+DVEAlbumMasonry.h"
#import "DVEAlbumLanguageProtocol.h"
#import <Masonry/View+MASAdditions.h>

@interface DVEAlbumDenyAccessView ()

@property (nonatomic, strong) UIImageView *displayImageView;
@property (nonatomic, strong) UILabel *accessAlbumLabel;
@property (nonatomic, strong) UILabel *accessAllPhotoLabel;

@end

@implementation DVEAlbumDenyAccessView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.backgroundColor = TOCResourceColor(TOCUIColorConstBGContainer);
    
    CGFloat verticalSpacingFactor = self.frame.size.height / 553;
    CGSize imageSize = CGSizeMake(240, 160);
    CGSize accessAlbumSize = CGSizeMake(311, 24);
    CGSize startSettingSize = CGSizeMake(280, 44);
    
    [self addSubview:self.displayImageView];
    DVEAlbumMasMaker(self.displayImageView, {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.mas_top).offset(62 * verticalSpacingFactor);
        make.size.equalTo(@(imageSize));
    });

    [self addSubview:self.accessAlbumLabel];
    DVEAlbumMasMaker(self.accessAlbumLabel, {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.displayImageView.mas_bottom).offset(20 * verticalSpacingFactor);
        make.size.mas_equalTo(@(accessAlbumSize));
    });
    
    [self addSubview:self.accessAllPhotoLabel];
    DVEAlbumMasMaker(self.accessAllPhotoLabel, {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.accessAlbumLabel.mas_bottom).offset(12 * verticalSpacingFactor);
        make.width.mas_equalTo(311);
    });
    
    [self addSubview:self.startSettingButton];
    DVEAlbumMasMaker(self.startSettingButton, {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.accessAllPhotoLabel.mas_bottom).offset(64 * verticalSpacingFactor);
        make.size.mas_equalTo(@(startSettingSize));
    });
}


#pragma mark - getter

- (UIImageView *)displayImageView
{
    if (!_displayImageView) {
        _displayImageView = [[UIImageView alloc] init];
        _displayImageView.image = TOCResourceImage(@"image_deny_access_album");
    }
    return _displayImageView;
}

- (UILabel *)accessAlbumLabel
{
    if (!_accessAlbumLabel) {
        _accessAlbumLabel = [[UILabel alloc] init];
        _accessAlbumLabel.text = TOCLocalizedString(@"authorization_album_noaccess_title", @"开启相册权限");
        _accessAlbumLabel.textColor = TOCResourceColor(TOCColorTextReverse);
        _accessAlbumLabel.textAlignment = NSTextAlignmentCenter;
        _accessAlbumLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:17];
    }
    return _accessAlbumLabel;
}

- (UILabel *)accessAllPhotoLabel
{
    if (!_accessAllPhotoLabel) {
        _accessAllPhotoLabel = [[UILabel alloc] init];
        _accessAllPhotoLabel.text = TOCLocalizedString(@"authorization_album_noaccess_body", @"当前设置是“不允许访问照片”，请到设置中授予抖音相册访问权限。");
        _accessAllPhotoLabel.textColor = TOCResourceColor(TOCColorTextReverse3);
        _accessAllPhotoLabel.numberOfLines = 0;
        _accessAllPhotoLabel.textAlignment = NSTextAlignmentCenter;
        _accessAllPhotoLabel.font = [UIFont systemFontOfSize:14];
        [_accessAllPhotoLabel sizeToFit];
    }
    return _accessAllPhotoLabel;
}

- (UIButton *)startSettingButton
{
    if (!_startSettingButton) {
        _startSettingButton = [[UIButton alloc] init];
        _startSettingButton.backgroundColor = TOCResourceColor(TOCColorPrimary);
        [_startSettingButton setTitle:TOCLocalizedString(@"authorization_gotosetting", @"去设置") forState:UIControlStateNormal];
        [_startSettingButton setTitleColor:TOCResourceColor(TOCUIColorConstTextInverse) forState:UIControlStateNormal];
        _startSettingButton.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    return _startSettingButton;
}

@end
