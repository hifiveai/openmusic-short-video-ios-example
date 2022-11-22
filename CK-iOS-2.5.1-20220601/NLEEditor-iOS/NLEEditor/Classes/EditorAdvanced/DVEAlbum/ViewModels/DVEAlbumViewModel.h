//
//  DVEAlbumViewModel.h
//  CameraClient
//
//  Created by bytedance on 2020/6/17.
//

#import <Foundation/Foundation.h>
#import "DVEAlbumInputData.h"
#import "DVEPhotoManager.h"
#import "DVEAlbumDataModel.h"
#import "DVEAlbumSectionModel.h"
#import "DVEAlbumConfigViewModel.h"
#import "DVEAlbumViewUIConfig.h"
#import "DVEAlbumListBlankView.h"
#import "DVEAlbumSlidingViewController.h"
#import <IGListKit/IGListKit.h>
#import "DVEImportSelectView.h"
#import "DVEImportSelectBottomView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEImportMaterialSelectCollectionViewCellModel : NSObject

@property (nonatomic, strong, nullable) DVEAlbumAssetModel *assetModel;

@property (nonatomic, assign) CGFloat duration;

@property (nonatomic, assign) BOOL highlight;

@property (nonatomic, assign) BOOL shouldShowDuration;

@end

#pragma mark - DVEAlbumViewModel

FOUNDATION_EXTERN NSInteger kDVEMaxAssetCountForAIClipMode;

@interface DVEAlbumViewModel : NSObject <DVEAlbumSlidingViewControllerDelegate>

@property (nonatomic, assign) BOOL hasRequestAuthorizationForAccessLevel; // If install AwemeInhouse on iOS 14 for the first time, or already installed but upgrade from lower iOS version, we need to request for photo library authorization.

@property (nonatomic, assign, readonly) BOOL isStory;
@property (nonatomic, assign, readonly) BOOL isMV;
@property (nonatomic, assign, readonly) BOOL isCutSame;
@property (nonatomic, assign, readonly) BOOL isCutSameChangeMaterial;
@property (nonatomic, assign, readonly) BOOL isOnePhoto;
@property (nonatomic, assign, readonly) BOOL isFirstCreative;

@property (nonatomic, assign, readonly) BOOL enableMixedUploading;
@property (nonatomic, assign, readonly) BOOL showMomentsTab;
@property (nonatomic, assign, readonly) BOOL showAllTab;
@property (nonatomic, assign, readonly) BOOL hasSelectedVideo;
@property (nonatomic, assign, readonly) BOOL hasSelectedPhoto;
@property (nonatomic, assign, readonly) BOOL doNotLimitInternalSelectCount;


@property (nonatomic, assign, readonly) CGFloat choosedTotalDuration;
@property (nonatomic, assign, readonly) NSInteger defaultSelectedIndex;
@property (nonatomic, assign, readonly) NSInteger currentSelectedIndex;
@property (nonatomic, assign, readonly, getter=resourceType) DVEAlbumGetResourceType currentResourceType;
@property (nonatomic, assign, readonly) BOOL hasSelectedAssets;
@property (nonatomic, assign, readonly) BOOL hasSelectedMaxCount;
@property (nonatomic, strong, readonly) DVEAlbumDataModel *albumDataModel;
@property (nonatomic, strong, readonly) DVEAlbumInputData *inputData;
@property (nonatomic, strong, readonly) DVEAlbumConfigViewModel *configViewModel;
@property (nonatomic, strong, readonly) DVEAlbumViewUIConfig *albumViewUIConfig;

@property (nonatomic, assign, readonly) NSInteger currentSelectedAssetsCount;
@property (nonatomic, strong, readonly) NSMutableArray<DVEAlbumAssetModel *> *currentSourceAssetModels;
@property (nonatomic, strong, readonly) NSMutableArray<DVEAlbumAssetModel *> *currentSelectAssetModels;

@property (nonatomic, strong) NSMutableArray<DVEAlbumAssetModel *> *currentSelectAssets;

/// 底部框已选择的素材, importMaterialSelectView
@property (nonatomic, strong) NSMutableArray<DVEImportMaterialSelectCollectionViewCellModel *> *selectedViewModels;

@property (nonatomic, copy) dispatch_block_t nextAction;
- (void)onNext;


- (instancetype)initWithAlbumInputData:(DVEAlbumInputData *)inputData;

- (void)prefetchAlbumListWithCompletion:(void (^)(void))completion;

- (void)reloadAssetsDataWithResourceType:(DVEAlbumGetResourceType)resourceType completion:(void (^)(void))completion;

- (void)reloadAssetsDataWithAlbumCategory:(DVEAlbumModel * _Nullable)albumModel completion:(void (^)(void))completion;

- (NSArray<DVEAlbumSectionModel *> *)dataSourceWithResourceType:(DVEAlbumGetResourceType)type;

- (NSArray<DVEAlbumSectionModel *> *)ab_dataSourceWithResourceType:(DVEAlbumGetResourceType)type;

- (DVEAlbumAssetDataModel *)currentAssetDataModel;

- (DVEAlbumListBlankViewType)blankViewTypeWithResourceType:(DVEAlbumGetResourceType)type;

- (BOOL)canMutilSelectedWithResourceType:(DVEAlbumGetResourceType)type;

- (BOOL)needAllowMutilButtonWithResourceType:(DVEAlbumGetResourceType)type;

- (BOOL)isExceedMaxDurationForAIVideoClip:(NSTimeInterval)duration resourceType:(DVEAlbumGetResourceType)type;

- (void)updateAssetModel:(DVEAlbumAssetModel *)model;

- (NSUInteger)maxSelectionCount;

#pragma mark - update


- (void)updateNeedEnablePhotoToVideo:(BOOL)needEnablePhotoToVideo;

- (void)updateCurrentSelectedIndex:(NSInteger)index;

- (void)updateTimeNextButtonPress:(NSTimeInterval)time;

- (void)updateSelectedAssetsNumber;

- (void)didSelectedAsset:(DVEAlbumAssetModel *)model;

- (void)didUnselectedAsset:(DVEAlbumAssetModel *)model;

- (NSIndexPath *)indexPathForOffset:(NSInteger)offset resourceType:(DVEAlbumGetResourceType)type;

#pragma mark - handle


- (NSString *)shootWay;

@end

NS_ASSUME_NONNULL_END


