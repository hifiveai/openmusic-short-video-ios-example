//
//  DVEAlbumAssetListCell.h
//  CameraClient
//
//  Created by bytedance on 2020/6/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PHAsset, DVEAlbumAssetModel;

@interface DVEAlbumAssetListCell : UICollectionViewCell

@property (nonatomic, strong) DVEAlbumAssetModel *assetModel;
@property (nonatomic, assign) BOOL useForAmericaRecordOptim;
@property (nonatomic, assign) BOOL checkMarkSelectedStyle;

@property (nonatomic, assign) BOOL isSingleSelected;

@property (nonatomic, assign) NSInteger limitDuration;

@property (nonatomic, copy) void (^didSelectedAssetBlock)(DVEAlbumAssetListCell *selectedCell, BOOL isSelected);
@property (nonatomic, copy) void (^didFetchThumbnailBlock)(NSTimeInterval duration);


- (void)updateSelectStatus;
- (void)updateSelectStatus:(BOOL)canSelect;

//-----由SMCheckProject工具删除-----
//- (void)configureCellWithAsset:(DVEAlbumAssetModel *)assetModel greyMode:(BOOL)greyMode showRightTopIcon:(BOOL)show;
- (void)configureCellWithAsset:(DVEAlbumAssetModel *)assetModel greyMode:(BOOL)greyMode showRightTopIcon:(BOOL)show alreadySelect:(BOOL)alreadySelect;
- (void)doSelectedAnimation;
- (UIImage *)thumbnailImage;

+ (NSString *)identifier;

- (void)updateSelectedButtonWithStatus:(BOOL)singleSelected;

- (BOOL)isAssetsMatchLimitDurationWithAssetModel:(DVEAlbumAssetModel *)assetModel;

@end

NS_ASSUME_NONNULL_END

