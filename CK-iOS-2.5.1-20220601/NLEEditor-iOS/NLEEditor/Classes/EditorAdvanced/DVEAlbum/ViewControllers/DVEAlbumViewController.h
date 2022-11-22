//
//  DVEAlbumViewController.h
//  CameraClient
//
//  Created by bytedance on 2020/6/16.
//

#import <UIKit/UIKit.h>
#import "DVEPhotoAlbumDefine.h"
#import "DVEAlbumViewModel.h"
#import "DVEAlbumListViewController.h"
#import "DVEAlbumSelectAlbumAssetsProtocol.h"
#import "DVEAlbumWorksPreviewViewControllerProtocol.h"

@class DVEAlbumAssetModel, DVEAlbumViewController;

typedef void(^DVEAssetsSelectConfirmBlock) (NSMutableArray<PHAsset *> *);


@interface DVEAlbumViewController : UIViewController <DVEAlbumSelectAlbumAssetsComponetProtocol, DVEAlbumListViewControllerDelegate>

@property (nonatomic, strong, readonly) DVEAlbumViewModel *viewModel;


@property (nonatomic, copy) dispatch_block_t dismissBlock;

@property (nonatomic, copy) DVEAssetsSelectConfirmBlock confirmBlock;

/// Cut Same
@property (nonatomic, copy) DVEAlbumWorksPreviewViewControllerChangeMaterialCallback changeMaterialCallback;

/// delegate
@property (nonatomic, weak) id<DVEAlbumSelectAlbumAssetsDelegate> delegate;

- (instancetype)initWithAlbumViewModel:(DVEAlbumViewModel *)viewModel;


- (UIViewController<DVEAlbumListViewControllerProtocol> *)currentAlbumListViewController;


- (void)handleAssetsForCutSame:(NSMutableArray<DVEAlbumAssetModel *> *)models;

// tracker
- (void)trackPhotoiCloud:(NSTimeInterval)icloudFetchStart size:(NSInteger)bytes;

@end

