//
//  DVEImportSelectView.h
//  CutSameIF
//
//  Created by bytedance on 2020/3/5.
//

#import <UIKit/UIKit.h>
#import "DVESelectedAssetsViewProtocol.h"
#import "DVEAlbumViewModel.h"

NS_ASSUME_NONNULL_BEGIN
@class DVEAlbumViewModel;
typedef void(^DVESelectedAssetsDidDeleteAssetModel)(DVEAlbumAssetModel *assetModel); // 删除回调
//typedef void(^ACCSelectedAssetsDidChangeOrder)(void); // 调整顺序回调
typedef void(^DVESelectedAssetsDidTouchAssetModel)(DVEAlbumAssetModel *assetModel, NSInteger index); // 点击预览回调

// <ACCSelectedAssetsViewProtocol>

@interface DVEImportSelectView : UIView
/// ACCSelectedAssetsViewProtocol
@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray<DVEAlbumAssetModel *> *assetModelArray;

@property (nonatomic, strong) DVEAlbumCutSameFragmentModel *singleFragmentModel;

@property (nonatomic, assign) BOOL isVideoAndPicMixed;

@property (nonatomic, strong) DVEAlbumTemplateModel *templateModel;

@property (nonatomic, copy) DVESelectedAssetsDidDeleteAssetModel deleteAssetModelBlock;

@property (nonatomic, copy) DVESelectedAssetsDidTouchAssetModel touchAssetModelBlock;

@property (nonatomic, strong) DVEAlbumViewModel *albumViewModel;

- (NSMutableArray<DVEAlbumAssetModel *> *)currentAssetModelArray;

- (void)reloadSelectView;

- (BOOL)checkVideoValidForCutSameTemplate:(DVEAlbumAssetModel *)assetModel;

- (void)scrollToNextSelectCell;

@end

@interface DVEImportMaterialSelectView: DVEImportSelectView

@end

NS_ASSUME_NONNULL_END
