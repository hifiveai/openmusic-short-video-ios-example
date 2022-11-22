//
//  DVEAlbumPhotoPreviewAndSelectCell.m
//  AWEStudio
//
//  Created by bytedance on 2020/3/15.
//
#import "DVEAlbumPhotoPreviewAndSelectCell.h"
#import "DVEAlbumLanguageProtocol.h"
#import "DVEAlbumToastImpl.h"
#import "DVEPhotoManager.h"

@interface DVEAlbumPhotoPreviewAndSelectCell()
@property (nonatomic, assign) int32_t imageRequestID;
@end

@implementation DVEAlbumPhotoPreviewAndSelectCell

- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor blackColor];

        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

- (void)configCellWithAsset:(DVEAlbumAssetModel *)assetModel withPlayFrame:(CGRect)playFrame greyMode:(BOOL)greyMode
{
    [super configCellWithAsset:assetModel withPlayFrame:playFrame greyMode:greyMode];
    self.imageView.image = assetModel.coverImage;
    int32_t imageRequestID = [DVEPhotoManager getUIImageWithPHAsset:assetModel.asset networkAccessAllowed:YES progressHandler:^(CGFloat progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
        
    } completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue]) {
            [DVEPhotoManager getOriginalPhotoDataFromICloudWithAsset:assetModel.asset progressHandler:^(CGFloat progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
                
            } completion:^(NSData * _Nonnull data, NSDictionary * _Nonnull info) {}];
            [[DVEAlbumToastImpl new] show:TOCLocalizedString(@"com_mig_syncing_the_picture_from_icloud", @"该图片正在从iCloud同步，请稍后再试")];
        } else {
            if (photo) {
                CGFloat height = [self p_resizeFromSize:photo.size toWidth:self.contentView.frame.size.width].height;
                self.imageView.frame = CGRectMake(0, (self.contentView.frame.size.height - height) / 2, self.contentView.frame.size.width, height);
                if (assetModel.coverImage == nil) {
                    self.imageView.image = photo;
                }
            } else {
                [DVEPhotoManager cancelImageRequest:self.imageRequestID];
            }
            if (!isDegraded) {
                if (photo) {
                    assetModel.coverImage = photo;
                    self.imageView.image = photo;
                }
                self.imageRequestID = 0;
            }
        }
    }];
    
    if (imageRequestID && self.imageRequestID && self.imageRequestID != imageRequestID) {
        [DVEPhotoManager cancelImageRequest:self.imageRequestID];
    }
    self.imageRequestID = imageRequestID;
}

-(void)removeCoverImageView{
    
}

- (void)setPlayerLayer:(AVPlayerLayer *)playerLayer withPlayerFrame:(CGRect)playerFrame{
    
}

- (CGSize)p_resizeFromSize:(CGSize)size toWidth:(CGFloat)width
{
    if (size.width > 0) {
        return CGSizeMake(width, size.height / size.width * width);
    } else {
        return CGSizeMake(0, 0);
    }
}


@end
