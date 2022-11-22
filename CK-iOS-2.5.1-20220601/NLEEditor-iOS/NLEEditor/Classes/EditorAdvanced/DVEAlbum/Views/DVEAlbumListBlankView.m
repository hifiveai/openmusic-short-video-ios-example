//
//  DVEAlbumListBlankView.m
//  AWEStudio
//
//  Created by bytedance on 2018/2/8.
//  Copyright © 2018年 bytedance. All rights reserved.
//
#import "UIView+DVEAlbumMasonry.h"
#import "DVEAlbumListBlankView.h"
#import "DVEAlbumResourceUnion.h"
#import "DVEAlbumMacros.h"
#import "DVEAlbumLanguageProtocol.h"
#import <Masonry/Masonry.h>

@interface DVEAlbumListBlankView ()

@property (nonatomic, strong) UILabel *mainTitleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) DVEAlbumAnimatedButton *toSetupButton;

@end

@implementation DVEAlbumListBlankView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.containerView = [[UIView alloc] initWithFrame:frame];
        self.containerView.hidden = YES;
        [self addSubview:self.containerView];

        UILabel *mainTitleLabel = [[UILabel alloc] init];
        mainTitleLabel.font = [UIFont systemFontOfSize:17];
        mainTitleLabel.text = TOCLocalizedString(@"com_mig_allow_access_to_photos_and_videos_from_your_device_in_your_settings", @"未授权访问系统相册");
        mainTitleLabel.textColor = TOCResourceColor(TOCUIColorConstTextPrimary);
        mainTitleLabel.textAlignment = NSTextAlignmentCenter;
        mainTitleLabel.numberOfLines = 0;
        self.mainTitleLabel = mainTitleLabel;
        [self.containerView addSubview:mainTitleLabel];

        UILabel *subtitleLabel = [[UILabel alloc] init];
        subtitleLabel.font = [UIFont systemFontOfSize:15];
        subtitleLabel.text = TOCLocalizedString(@"com_mig_to_grant_musically_photo_access_go_to_system_settings_privacy_photos_and_find_musically", @"系统设置找到抖音并设置照片项为读取和写入");
        subtitleLabel.textColor = TOCResourceColor(TOCUIColorConstTextTertiary);
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        subtitleLabel.numberOfLines = 0;
        self.subtitleLabel = subtitleLabel;
        [self.containerView addSubview:subtitleLabel];

        DVEAlbumAnimatedButton *toSetupButton = [[DVEAlbumAnimatedButton alloc] initWithType:SCIFAnimatedButtonTypeAlpha];
        toSetupButton.backgroundColor = TOCResourceColor(TOCUIColorConstTextPrimary);
        toSetupButton.layer.cornerRadius = 2;
        toSetupButton.layer.masksToBounds = YES;
        [toSetupButton setTitle:TOCLocalizedString(@"com_mig_allow_access_to_photos_and_videos_from_your_device", @"去打开相册权限") forState:UIControlStateNormal];
        toSetupButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [toSetupButton setTitleColor:TOCResourceColor(TOCUIColorConstBGContainer) forState:UIControlStateNormal];
        toSetupButton.titleLabel.font = [UIFont systemFontOfSize:15];
        toSetupButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        toSetupButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        toSetupButton.titleLabel.minimumScaleFactor = 11.0 / 15;
        self.toSetupButton = toSetupButton;
        [self.containerView addSubview:toSetupButton];

        DVEAlbumMasMaker(mainTitleLabel, {
            make.bottom.equalTo(subtitleLabel.mas_top).offset(-6);
            make.width.equalTo(@(TOC_SCREEN_WIDTH - 64));
            make.centerX.equalTo(self.mas_centerX);
        });

        DVEAlbumMasMaker(subtitleLabel, {
            make.bottom.equalTo(self.mas_centerY).offset(-13.5);
            make.width.equalTo(@(TOC_SCREEN_WIDTH - 64));
            make.centerX.equalTo(mainTitleLabel.mas_centerX);
        });
        [toSetupButton setContentCompressionResistancePriority:UILayoutPriorityRequired - 1 forAxis:UILayoutConstraintAxisHorizontal];
        DVEAlbumMasMaker(toSetupButton, {
            make.leading.greaterThanOrEqualTo(self).offset(32);
            make.trailing.lessThanOrEqualTo(self).offset(-32);
            make.centerX.equalTo(self.mas_centerX);
            make.height.equalTo(@(44));
            make.top.equalTo(self.mas_centerY).offset(46.5);
        });
    }
    return self;
}

- (void)setType:(DVEAlbumListBlankViewType)type
{
    switch (type) {
        case DVEAlbumListBlankViewTypeNoPermissions: {
            self.mainTitleLabel.hidden = NO;
            self.subtitleLabel.hidden = NO;
            self.toSetupButton.hidden = NO;
            self.mainTitleLabel.text = TOCLocalizedString(@"com_mig_allow_access_to_photos_and_videos_from_your_device_in_your_settings", @"未授权访问系统相册");

        }
            break;
        case DVEAlbumListBlankViewTypeNoPhoto: {
            self.mainTitleLabel.hidden = NO;
            self.subtitleLabel.hidden = YES;
            self.toSetupButton.hidden = YES;
            self.mainTitleLabel.text = TOCLocalizedString(@"com_mig_no_photos_available", @"相册中没有图片");
        }
            break;
        case DVEAlbumListBlankViewTypeNoVideo: {
            self.mainTitleLabel.hidden = NO;
            self.subtitleLabel.hidden = YES;
            self.toSetupButton.hidden = YES;
            self.mainTitleLabel.text = TOCLocalizedString(@"com_mig_cannot_find_videos_in_gallery", @"相册中没有视频");
        }
            break;
        case DVEAlbumListBlankViewTypeNoVideoAndPhoto: {
            self.mainTitleLabel.hidden = NO;
            self.subtitleLabel.hidden = YES;
            self.toSetupButton.hidden = YES;
            self.mainTitleLabel.text = TOCLocalizedString(@"com_mig_no_photos_or_videos_available", @"相册中没有视频和照片");
        }
            break;
    }
}

@end
