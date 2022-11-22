//
//  DVEAlbumAssetListSectionController.h
//  CameraClient
//
//  Created by bytedance on 2020/6/23.
//

#import <IGListKit/IGListSectionController.h>
#import <IGListKit/IGListKit.h>
#import "DVEAlbumViewModel.h"
#import "DVEAlbumSectionModel.h"

@class DVEAlbumAssetListCell;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN CGFloat kDVEAlbumListSectionHeaderHeight;

@protocol DVEAlbumAssetListSectionControllerDelegate <NSObject>

@optional

@end

@interface DVEAlbumAssetListSectionController : IGListSectionController

@property (nonatomic, assign, readonly) CGSize itemSize;
@property (nonatomic, copy) void(^didSelectedToPreviewBlock)(DVEAlbumAssetModel *assetModel, UIImage *coverImage);
@property (nonatomic, copy) void(^didSelectedAssetBlock)(DVEAlbumAssetListCell *cell, BOOL isSelected);

@property (nonatomic, weak) id<DVEAlbumAssetListSectionControllerDelegate> delegate;


- (instancetype)initWithAlbumViewModel:(DVEAlbumViewModel *)viewModel resourceType:(DVEAlbumGetResourceType)resourceType;

@end

NS_ASSUME_NONNULL_END
