//
//  DVEAlbumPreviewAndSelectController.h
//  CameraClient
//
//  Created by bytedance on 2020/7/17.
//

#import <UIKit/UIKit.h>
#import "DVEPhotoManager.h"
#import "DVEAlbumViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class DVEAlbumAssetModel;

@interface DVEAlbumPreviewAndSelectController : UIViewController

@property (nonatomic, assign) BOOL greyMode;
@property (nonatomic, assign, readonly) NSInteger currentIndex;
//@property (nonatomic, strong, readonly) DVEAlbumAssetModel *exitAssetModel;
//@property (nonatomic, assign, readonly) BOOL currentAssetModelSelected;
@property (nonatomic, strong) NSDictionary *trackExtraDict;

@property (nonatomic, strong) NSArray<DVEAlbumAssetModel *> *selectedAssetModelArray;

@property (nonatomic, strong) NSArray<DVEAlbumAssetModel *> *originDataSource;


@property (nonatomic, copy) void(^willDismissBlock)(DVEAlbumAssetModel *currentModel);
@property (nonatomic, copy) void(^didClickedTopRightIcon)(DVEAlbumAssetModel *currentModel, BOOL isSelected);

//@property (nonatomic, assign) BOOL fromSelectedBottomView;
@property (nonatomic, assign) BOOL checkMarkSelectedStyle;

//-----由SMCheckProject工具删除-----
//- (instancetype)initWithViewModel:(DVEAlbumViewModel *)viewModel anchorAssetModel:(DVEAlbumAssetModel *)anchorAssetModel;

- (instancetype)initWithViewModel:(DVEAlbumViewModel *)viewModel anchorAssetModel:(DVEAlbumAssetModel *)anchorAssetModel fromBottomView:(BOOL)fromBottomView;

- (void)reloadSelectedStateWithGrayMode:(BOOL)greyMode;

@end

NS_ASSUME_NONNULL_END

