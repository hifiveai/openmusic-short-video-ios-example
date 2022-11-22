//
//  DVEAlbumVideoPreviewAndSelectCell.m
//  AWEStudio
//
//  Created by bytedance on 2020/3/15.
//

#import "DVEAlbumVideoPreviewAndSelectCell.h"
#import "DVEAlbumToastImpl.h"
#import "DVEPhotoManager.h"
#import "DVEAlbumLanguageProtocol.h"
#import <AVFoundation/AVFoundation.h>

@interface DVEAlbumVideoPreviewAndSelectCell ()

@property (nonatomic, strong) UIImage *coverImage;
@property (nonatomic, assign) int32_t imageRequestID;

@end

@implementation DVEAlbumVideoPreviewAndSelectCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor blackColor];
        self.contentView.clipsToBounds = YES;
        self.coverImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.coverImageView];
    }
    return self;
}

- (void)configCellWithAsset:(DVEAlbumAssetModel *)assetModel withPlayFrame:(CGRect)playFrame greyMode:(BOOL)greyMode{
    [super configCellWithAsset:assetModel withPlayFrame:playFrame greyMode:greyMode];
    self.coverImageView.image = assetModel.coverImage;
    self.coverImageView.hidden = NO;
    int32_t imageRequestID = [DVEPhotoManager getUIImageWithPHAsset:assetModel.asset networkAccessAllowed:NO progressHandler:^(CGFloat progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
        
    } completion:^(UIImage * _Nonnull photo, NSDictionary * _Nonnull info, BOOL isDegraded) {
        if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue]) {
            [DVEPhotoManager getOriginalPhotoDataFromICloudWithAsset:assetModel.asset progressHandler:^(CGFloat progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
            } completion:^(NSData * _Nonnull data, NSDictionary * _Nonnull info) {
            }];
            [[DVEAlbumToastImpl new] show:TOCLocalizedString(@"com_mig_syncing_the_picture_from_icloud", @"该图片正在从iCloud同步，请稍后再试")];
        } else {
            if (photo) {
                self.coverImageView.frame = playFrame;
                self.coverImageView.image = photo;
            } else {
                [DVEPhotoManager cancelImageRequest:self.imageRequestID];
            }
            if (!isDegraded) {
                self.imageRequestID = 0;
            }
        }
    }];
    
    if (imageRequestID && self.imageRequestID && self.imageRequestID != imageRequestID) {
        [DVEPhotoManager cancelImageRequest:self.imageRequestID];
    }
    self.imageRequestID = imageRequestID;
}

- (void)setPlayerLayer:(AVPlayerLayer *)playerLayer withPlayerFrame:(CGRect)playerFrame{
    self.playerView = [[UIView alloc] initWithFrame:playerFrame];
    [self.contentView insertSubview:self.playerView belowSubview:self.coverImageView];
    playerLayer.frame = self.playerView.bounds;
    [self.playerView.layer addSublayer:playerLayer];
}

- (void)removeCoverImageView{
    self.coverImageView.hidden = YES;
}

@end
