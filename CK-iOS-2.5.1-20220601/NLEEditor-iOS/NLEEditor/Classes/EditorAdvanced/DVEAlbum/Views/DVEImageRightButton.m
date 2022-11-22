//
//  DVEImageRightButton.m
//  CameraClient
//
//  Created by bytedance on 2020/6/18.
//

#import "UIView+DVEAlbumMasonry.h"
#import "DVEImageRightButton.h"
#import <Masonry/Masonry.h>

@implementation DVEImageRightButton

- (instancetype)initWithType:(DVEAlbumAnimatedButtonType)btnType
{
    if (self = [super initWithType:btnType]) {
        self.leftLabel = [[UILabel alloc] init];
        self.leftLabel.font = [UIFont boldSystemFontOfSize:17];
        
        self.rightImageView = [[UIImageView alloc] init];
        self.rightImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.rightImageView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        [self addSubview:self.leftLabel];
        [self addSubview:self.rightImageView];
        
        DVEAlbumMasMaker(self.leftLabel, {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.rightImageView.mas_left);
            make.height.lessThanOrEqualTo(self);
            make.centerY.equalTo(self.mas_centerY);
        });
        
        DVEAlbumMasMaker(self.rightImageView, {
            make.right.equalTo(self.mas_right);
            make.centerY.equalTo(self.mas_centerY);
        });
    }
    return self;
}

- (instancetype)initWithType:(DVEAlbumAnimatedButtonType)btnType titleAndImageInterval:(CGFloat)interval
{
    if (self = [super initWithType:btnType]) {
        self.leftLabel = [[UILabel alloc] init];
        self.leftLabel.font = [UIFont boldSystemFontOfSize:17];
        
        self.rightImageView = [[UIImageView alloc] init];
        self.rightImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.rightImageView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        [self addSubview:self.leftLabel];
        [self addSubview:self.rightImageView];
        
        DVEAlbumMasMaker(self.leftLabel, {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.rightImageView.mas_left).offset(-interval);
            make.height.lessThanOrEqualTo(self);
            make.centerY.equalTo(self.mas_centerY);
        });
        
        DVEAlbumMasMaker(self.rightImageView, {
            make.right.equalTo(self.mas_right);
            make.centerY.equalTo(self.mas_centerY);
        });
    }
    return self;
}

@end
