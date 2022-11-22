//
//  DVEAlbumPreviewAndSelectCell.h
//  AWEStudio-Pods-Aweme
//
//  Created by bytedance on 2020/3/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//@class DVEAlbumAssetModel, AVPlayerLayer, DVEAlbumPreviewAndSelectCell;
@class DVEAlbumAssetModel, AVPlayerLayer, DVEAlbumPreviewAndSelectCell;

@interface DVEAlbumPreviewAndSelectCell : UICollectionViewCell

@property (nonatomic, strong) DVEAlbumAssetModel *assetModel;

- (void)configCellWithAsset:(DVEAlbumAssetModel *)assetModel withPlayFrame:(CGRect)playFrame greyMode:(BOOL)greyMode;

/// just set hidden property
- (void)removeCoverImageView;
- (void)setPlayerLayer:(AVPlayerLayer *)playerLayer withPlayerFrame:(CGRect)playerFrame;

@end

NS_ASSUME_NONNULL_END
