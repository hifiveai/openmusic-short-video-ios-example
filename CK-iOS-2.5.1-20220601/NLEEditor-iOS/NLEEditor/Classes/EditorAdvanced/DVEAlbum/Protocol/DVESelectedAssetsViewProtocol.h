//
//  ACCSelectedAssetsViewProtocol.h
//  CutSameIF
//
//  Created by bytedance on 2020/3/9.
//

#import <Foundation/Foundation.h>
//#import <CutSameIF/DVEAlbumAssetModel.h>
//#import <CutSameIF/DVEServiceLocator.h>
////#import "LVTemplateModel.h"
//#import "DVESelectedAssetsBottomViewProtocol.h"
//#import <CutSameIF/DVEAlbumCutSameFragmentModel.h>

//#define ACC_SelectedAssets_Obj  (id<ACCSelectedAssetsProtocol>)DVEAutoInline(DVEUIInnerServiceProvider(),ACCSelectedAssetsProtocol)

NS_ASSUME_NONNULL_BEGIN

//typedef void(^DVESelectedAssetsDidDeleteAssetModel)(DVEAlbumAssetModel *assetModel); // 删除回调
////typedef void(^ACCSelectedAssetsDidChangeOrder)(void); // 调整顺序回调
//typedef void(^DVESelectedAssetsDidTouchAssetModel)(DVEAlbumAssetModel *assetModel); // 点击预览回调

//@protocol ACCSelectedAssetsViewProtocol <NSObject>
//
//@required
//@property (nonatomic, strong, readonly) UICollectionView *collectionView;
//@property (nonatomic, strong) NSMutableArray<DVEAlbumAssetModel *> *assetModelArray;
//@property (nonatomic, copy) DVESelectedAssetsDidDeleteAssetModel deleteAssetModelBlock;
//
//@optional
////@property (nonatomic, copy) ACCSelectedAssetsDidChangeOrder changeOrderBlock;
//@property (nonatomic, copy) DVESelectedAssetsDidTouchAssetModel touchAssetModelBlock;
//
//@property (nonatomic, strong) LVTemplateModel *templateModel;
//@property (nonatomic, strong) LVCutSameFragmentModel *singleFragmentModel;
//@property (nonatomic, assign) BOOL isVideoAndPicMixed;
//
//- (void)reloadSelectView;
//
////-----由SMCheckProject工具删除-----
////- (BOOL)checkAssetModelValid:(DVEAlbumAssetModel *)assetModel previewing:(BOOL)isPreviewing;
//
//- (BOOL)checkVideoValidForCutSameTemplate:(DVEAlbumAssetModel *)assetModel;
//
//- (NSMutableArray<DVEAlbumAssetModel *> *)currentAssetModelArray;
//
//- (void)scrollToNextSelectCell;
//
//@end


//@protocol ACCSelectedAssetsProtocol <NSObject>
//
//- (UIView<ACCSelectedAssetsViewProtocol> *)selectedAssetsView;
//
//- (UIView<DVESelectedAssetsBottomViewProtocol> *)selectedAssetsBottomView;
//
//@end

NS_ASSUME_NONNULL_END

