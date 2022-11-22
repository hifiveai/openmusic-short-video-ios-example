//
//  DVEAlbumListViewController.h
//  CameraClient
//
//  Created by bytedance on 2020/6/16.
//

#import <UIKit/UIKit.h>
#import "DVEAlbumViewModel.h"
#import "DVEAlbumViewControllerProtocol.h"

@class DVEAlbumListViewController, DVEAllowMultiSelectBottomButton;

@interface DVEAlbumListViewController : UIViewController <DVEAlbumListViewControllerProtocol>

@property (nonatomic, strong, readonly) DVEAllowMultiSelectBottomButton *allowMutilButton;
@property (nonatomic, weak) DVEAlbumViewModel *viewModel;

- (instancetype)initWithResourceType:(DVEAlbumGetResourceType)resourceType;

- (UICollectionViewCell *)transitionCollectionCellForItemOffset:(NSInteger)itemOffset;

- (void)reloadVisibleCell;

- (void)didSelectedToPreview:(DVEAlbumAssetModel *)model coverImage:(UIImage *)coverImage fromBottomView:(BOOL)fromBottomView;

@end
