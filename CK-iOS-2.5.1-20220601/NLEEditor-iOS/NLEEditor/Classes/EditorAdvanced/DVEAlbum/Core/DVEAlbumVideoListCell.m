//
//  AWEVideoListCell.m
//  AWEStudio
//
//  Created by bytedance on 2018/5/22.
//  Copyright © 2018年 bytedance. All rights reserved.
//

#import "UIView+DVEAlbumMasonry.h"
#import "DVEAlbumVideoListCell.h"
#import "DVEAlbumResourceUnion.h"
#import <Masonry/View+MASAdditions.h>

static NSString * const DVEAlbumVideoListCellCoverImageFadeAnimationKey = @"DVEAlbumVideoListCellCoverImageFadeAnimationKey";

@interface DVEAlbumVideoListCell ()

@property (nonatomic, strong) UIImageView *coverImageView;

@end

@implementation DVEAlbumVideoListCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.coverImageView];
        [self.contentView addSubview:self.timeLabel];
        
        DVEAlbumMasMaker(self.coverImageView, {
            make.edges.equalTo(self.contentView);
        });
        DVEAlbumMasMaker(self.timeLabel, {
            make.right.equalTo(self).inset(4);
            make.bottom.equalTo(self).inset(2);
//            make.centerX.equalTo(self.contentView.mas_centerX);
//            make.centerY.equalTo(self.contentView.mas_centerY);
        });
    }
    return self;
}

- (UIImageView *)coverImageView
{
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
        _coverImageView.layer.cornerRadius = 2;
        _coverImageView.alpha = 1.0;
    }
    return _coverImageView;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:10];
        _timeLabel.textColor = TOCResourceColor(TOCColorTextPrimary);
//        _timeLabel.layer.shadowColor = TOCResourceColor(TOCColorSDSecondary).CGColor;
//        _timeLabel.layer.shadowOffset = CGSizeMake(0, 2);
//        _timeLabel.layer.shadowOpacity = 1.0;
//        _timeLabel.layer.shadowRadius = 1.5f;
    }
    return _timeLabel;
}

- (void)setCoverImage:(UIImage *)coverImage animated:(BOOL)animated
{
    self.coverImage = coverImage;
    if (animated) {
        [self.coverImageView.layer removeAnimationForKey:DVEAlbumVideoListCellCoverImageFadeAnimationKey];

        CATransition *transition = [CATransition animation];
        transition.duration = 0.3;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        [self.coverImageView.layer addAnimation:transition forKey:DVEAlbumVideoListCellCoverImageFadeAnimationKey];
        self.coverImageView.image = coverImage;
    } else {
        self.coverImageView.image = coverImage;
    }
}

@end
