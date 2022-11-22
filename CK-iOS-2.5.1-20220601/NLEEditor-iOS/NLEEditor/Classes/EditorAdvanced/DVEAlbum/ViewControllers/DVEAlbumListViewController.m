//
//  DVEAlbumListViewController.m
//  CameraClient
//
//  Created by bytedance on 2020/6/16.
//

#import "UIView+DVEAlbumMasonry.h"
#import "DVEAlbumListViewController.h"
#import "DVEAlbumAssetListSectionController.h"
#import "DVEAlbumAssetListCell.h"

#import "DVENoEventView.h"
#import "DVEAllowMultiSelectBottomButton.h"

#import <Masonry/Masonry.h>
#import "DVEAlbumMacros.h"

#import "DVEAlbumLoadingViewProtocol.h"
#import "DVEAlbumToastImpl.h"
#import "DVEAlbumLanguageProtocol.h"

#import <KVOController/KVOController.h>

#import "DVEAlbumPreviewAndSelectController.h"

#import "DVEAlbumZoomTransition.h"
#import "DVEAlbumResourceUnion.h"
#import "DVEAlbumDeviceAuth.h"
#import "DVEAlbumLoadingViewDefaultImpl.h"

static NSInteger const kSCIFAlbumListColumnCount = 4;

@interface DVEAlbumListViewController ()<IGListAdapterDataSource, IGListAdapterDelegate, UIScrollViewDelegate, DVEAlbumZoomTransitionOuterContextProvider>

@property (nonatomic, strong, readonly) DVEAlbumConfigViewModel *configViewModel;

@property (nonatomic, assign) CGSize aspectRatio;

@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) IGListCollectionView *collectionView;
@property (nonatomic, strong) DVEAlbumListBlankView *blankContentView;

@property (nonatomic, assign) BOOL hasCheckedAndReload;
@property (nonatomic, strong) UIView<DVEAlbumLoadingViewProtocol> *loadingView;

// Bottom View
@property (nonatomic, strong) DVENoEventView *bottomViewForAllowMultiButton;
@property (nonatomic, strong, readwrite) DVEAllowMultiSelectBottomButton *allowMutilButton;

@property (nonatomic, assign) CGFloat beginPosition;

@property (nonatomic, strong, readonly) NSArray<DVEAlbumSectionModel *> *dataSource;

@property (nonatomic, strong) DVEAlbumZoomTransitionDelegate *transitionDelegate;

@property (nonatomic, assign) BOOL previewFromBottom;
@property (nonatomic, assign) NSInteger selectedCellIndex;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation DVEAlbumListViewController

@synthesize vcDelegate, resourceType, hasEnterCurrentVC;

- (instancetype)initWithResourceType:(DVEAlbumGetResourceType)resourceType;
{
    self = [super init];
    if (self) {
        self.resourceType = resourceType;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = TOCResourceColor(TOCUIColorConstBGContainer);
    
    self.aspectRatio = CGSizeZero;
    self.beginPosition = MAXFLOAT;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    self.adapter.scrollViewDelegate = self;
    self.adapter.collectionView = self.collectionView;
    [self.view addSubview:self.collectionView];
    DVEAlbumMasMaker(self.collectionView, {
        make.edges.equalTo(self.view);
    });
    
    [self bindViewModel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.hasEnterCurrentVC = YES;
}

- (BOOL)enableOptimizeRecordAlbum {
    return NO;
}

- (void)bindViewModel
{
    if ([self enableOptimizeRecordAlbum]) {
        [self ab_bindViewModel];
    } else {
        @weakify(self);
        [self.KVOController observe:self.viewModel.albumDataModel keyPath:@"photoSourceAssetsModels" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            @strongify(self);
            if (self.resourceType == DVEAlbumGetResourceTypeImage) {
                [self reloadDataWithScrollToBottomInMainThread];
                self.blankContentView.containerView.hidden = !TOC_isEmptyArray(self.viewModel.albumDataModel.photoSourceAssetsModels);
            }
        }];

        [self.KVOController observe:self.viewModel.albumDataModel keyPath:@"videoSourceAssetsModels" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            @strongify(self);
            if (self.resourceType == DVEAlbumGetResourceTypeVideo) {
                [self reloadDataWithScrollToBottomInMainThread];
                self.blankContentView.containerView.hidden = !TOC_isEmptyArray(self.viewModel.albumDataModel.videoSourceAssetsModels);
            }
        }];

        [self.KVOController observe:self.viewModel.albumDataModel keyPath:@"mixedSourceAssetsModels" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            @strongify(self);
            if (self.resourceType == DVEAlbumGetResourceTypeImageAndVideo) {
                [self reloadDataWithScrollToBottomInMainThread];
                self.blankContentView.containerView.hidden = !TOC_isEmptyArray(self.viewModel.albumDataModel.mixedSourceAssetsModels);
            }
        }];
    }
    @weakify(self);
    [self.KVOController observe:self.viewModel.albumDataModel keyPath:@"photoSelectAssetsModels" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        BOOL needUpdate = ![self isCurrentViewControllerVisible];
        needUpdate = needUpdate || (self.resourceType == DVEAlbumGetResourceTypeImage && self.resourceType != self.viewModel.currentResourceType);
        if (needUpdate) {
            [self adapterReloadDataInMainThread];
        }
    }];

    [self.KVOController observe:self.viewModel.albumDataModel keyPath:@"videoSelectAssetsModels" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        BOOL needUpdate = ![self isCurrentViewControllerVisible];
        needUpdate = needUpdate || (self.resourceType == DVEAlbumGetResourceTypeVideo && self.resourceType != self.viewModel.currentResourceType);
        if (needUpdate) {
            [self adapterReloadDataInMainThread];
        }
    }];

    [self.KVOController observe:self.viewModel.albumDataModel keyPath:@"mixedSelectAssetsModels" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        BOOL needUpdate = ![self isCurrentViewControllerVisible];
        needUpdate = needUpdate || (self.resourceType == DVEAlbumGetResourceTypeImageAndVideo && self.resourceType != self.viewModel.currentResourceType);
        if (needUpdate) {
            [self adapterReloadDataInMainThread];
        }
    }];
    if ([DVEAlbumDeviceAuth isiOS14PhotoNotDetermined]) {
        [self.KVOControllerNonRetaining observe:self.viewModel keyPath:@"hasRequestAuthorizationForAccessLevel" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            @strongify(self);
            BOOL hasRequestPhotoLibraryAuthorization = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
            [self p_handleSelectedPhotoLibraryAuthorization:hasRequestPhotoLibraryAuthorization];
        }];
    }
}

- (void)ab_bindViewModel
{
    @weakify(self);
    [[self.viewModel.albumDataModel.resultSourceAssetsSubject deliverOnMainThread] subscribeNext:^(DVEAlbumAssetDataModel * _Nullable x) {
        @strongify(self);
        if (x && x.resourceType == self.resourceType) {
            [self reloadDataAndScrollToBottomWithCompltion:nil];
        }
    }];

    if (!self.hasCheckedAndReload) {
        self.hasCheckedAndReload = YES;
        [self checkAuthorizationAndReloadWithScrollToBottom:self.viewModel.inputData.scrollToBottom];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.hasCheckedAndReload) {
        self.hasCheckedAndReload = YES;
        [self checkAuthorizationAndReloadWithScrollToBottom:self.viewModel.inputData.scrollToBottom];
    } else {
        for (DVEAlbumAssetListCell *item in self.collectionView.visibleCells) {
            [item updateSelectStatus];
        }
        [self reloadVisibleCell];
    }
}

- (UICollectionViewCell *)transitionCollectionCellForItemOffset:(NSInteger)itemOffset
{
    if (self.viewModel.albumDataModel.targetIndexPath) {
        NSIndexPath *indexPath = self.viewModel.albumDataModel.targetIndexPath;
        return [self.collectionView cellForItemAtIndexPath:indexPath];
    } else {
        
    }
    NSIndexPath *indexPath = [self.viewModel indexPathForOffset:itemOffset resourceType:self.resourceType];

    if ([[self.collectionView indexPathsForVisibleItems] indexOfObject:indexPath] == NSNotFound) {
        [self.collectionView scrollToItemAtIndexPath:indexPath
                                    atScrollPosition:UICollectionViewScrollPositionTop
                                            animated:NO];
        [self reloadVisibleCell];
    }
    
    return [self.collectionView cellForItemAtIndexPath:indexPath];
}

- (void)reloadVisibleCell
{
    [self.viewModel updateSelectedAssetsNumber];
    [self p_reloadVisibleCellExcept:nil];
}

#pragma mark - Check Authorization

- (void)checkAuthorizationAndReloadWithScrollToBottom:(BOOL)scrollToBottom
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
#ifdef __IPHONE_14_0 //xcode12
    if (@available(iOS 14.0, *)) {
        status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
    }
#endif
    
    switch (status) {
        case PHAuthorizationStatusAuthorized: {
            [self p_fetchPhotoData];
        }
            break;
        case PHAuthorizationStatusNotDetermined: {
#ifdef __IPHONE_14_0 //xcode12
            if (@available(iOS 14.0, *)) {
                if (!YES) {
                    [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            switch (status) {
                                case PHAuthorizationStatusLimited:
                                case PHAuthorizationStatusAuthorized: {
                                    [self p_fetchPhotoData];
                                    break;
                                }
                                case PHAuthorizationStatusNotDetermined:
                                case PHAuthorizationStatusRestricted:
                                case PHAuthorizationStatusDenied: {
                                    [self updateBlankViewWithPermission:NO];
                                    break;
                                }
                                default:
                                    break;
                            }
                        });
                    }];
                }
            } else {
                [self p_requestAuthorizationLessTheniOS14];
            }
#else //xcode11
            [self p_requestAuthorizationLessTheniOS14];
#endif
        }
            break;
        case PHAuthorizationStatusRestricted: {
            [self updateBlankViewWithPermission:NO];
        }
            break;
        case PHAuthorizationStatusDenied: {
            [self updateBlankViewWithPermission:NO];
        }
            break;
        default:
        {
#ifdef __IPHONE_14_0 //xcode12
            if (@available(iOS 14.0, *)) {
                if (status == PHAuthorizationStatusLimited) {
                    [self p_fetchPhotoData];
                }
            }
#endif
        }
            break;
    }
}

//ios14-
- (void)p_requestAuthorizationLessTheniOS14
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusAuthorized: {
                    [self p_fetchPhotoData];
                    break;
                }
                case PHAuthorizationStatusNotDetermined:
                case PHAuthorizationStatusRestricted:
                case PHAuthorizationStatusDenied: {
                    [self updateBlankViewWithPermission:NO];
                    break;
                }
                default:
                    break;
            }
        });
    }];
}
    
- (void)p_handleSelectedPhotoLibraryAuthorization:(BOOL)hasRequestPhotoLibraryAuthorization
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (hasRequestPhotoLibraryAuthorization) {
            [self p_fetchPhotoData];
        } else {
            [self updateBlankViewWithPermission:NO];
        }
    });
}

- (void)p_fetchPhotoData
{
    self.blankContentView.containerView.hidden = YES;
    self.loadingView = [DVEAlbumLoadingViewDefaultImpl showTextLoadingOnView:self.view title:@"" animated:YES];
    @weakify(self);
    [self.viewModel reloadAssetsDataWithResourceType:self.resourceType completion:^{
        @strongify(self);
        [self reloadDataAndScrollToBottomWithCompltion:^{
            @strongify(self);
            [self.loadingView dismissWithAnimated:YES];
        }];
    }];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - Reload Data

- (void)reloadDataWithScrollToBottomInMainThread
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadDataAndScrollToBottomWithCompltion:^{
        }];
    });
}

- (void)adapterReloadDataInMainThread
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.adapter performUpdatesAnimated:NO completion:^(BOOL finished) {
            if ([self enableOptimizeRecordAlbum]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self p_reloadVisibleCellExcept:nil];
                });
            }
        }];
    });
}

- (void)reloadDataAndScrollToBottomWithCompltion:(void(^)(void))compltion
{
    BOOL scrollToBottom = self.viewModel.inputData.scrollToBottom;
    self.collectionView.hidden = YES;
    
    @weakify(self);
    [self.adapter performUpdatesAnimated:NO completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            CGFloat contentHeight = self.collectionView.contentSize.height;
            CGFloat frameHeight = self.collectionView.frame.size.height;

            if(scrollToBottom && contentHeight > frameHeight) {
                [self.collectionView setContentOffset:CGPointMake(0, contentHeight - frameHeight) animated:NO];
                [self reloadVisibleCell];
            }
            
            TOCBLOCK_INVOKE(compltion);
            self.collectionView.hidden = NO;
            [self updateBlankViewWithPermission:YES];
        });
    }];
    
    self.bottomViewForAllowMultiButton.hidden = NO;
    
}

- (void)albumListScrollToAssetModel:(DVEAlbumAssetModel *)assetModel{
    if ([self enableOptimizeRecordAlbum]) {
        [self ab_albumListScrollToAssetModel:assetModel];
        return;
    }
    self.viewModel.albumDataModel.targetIndexPath = nil;
    
    NSArray<NSIndexPath *> *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];

    [self.dataSource enumerateObjectsUsingBlock:^(DVEAlbumSectionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.assetsModels enumerateObjectsUsingBlock:^(DVEAlbumAssetModel * _Nonnull obj, NSUInteger idy, BOOL * _Nonnull stop) {
            if ([obj isEqual:assetModel]) {
                NSIndexPath *targetIndexPath = [NSIndexPath indexPathForRow:idy inSection:idx];
                self.viewModel.albumDataModel.targetIndexPath = targetIndexPath;
                //1. if this cell is not within visibleIndexPath, scroll it to center
                //2. if this cell in visibleIndexPath and partly exceed at top of current visible view,scroll it to top
                //3. if this cell in visibleIndexPath and partly exceed at bottom of current visible view,then scroll it to bottom
                if (![visibleIndexPaths containsObject:targetIndexPath]) {
                    if (visibleIndexPaths.count > 0) {
                        [self.collectionView scrollToItemAtIndexPath:targetIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                    }
                } else {
                    UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:targetIndexPath];
                    if (cell){
                        CGRect rect = [self.collectionView convertRect:cell.frame toView:self.view];
                        if (rect.origin.y < 0) {
                            [self.collectionView scrollToItemAtIndexPath:targetIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
                        } else if (CGRectGetMaxY(rect) > self.collectionView.frame.size.height) {
                            [self.collectionView scrollToItemAtIndexPath:targetIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
                        }
                    }

                }
                *stop = YES;
            }
        }];
        if ([obj.assetsModels containsObject:assetModel]){
            *stop = YES;
        }
    }];
}

- (void)ab_albumListScrollToAssetModel:(DVEAlbumAssetModel *)assetModel{
    self.viewModel.albumDataModel.targetIndexPath = nil;

    NSArray<NSIndexPath *> *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];

    [self.dataSource enumerateObjectsUsingBlock:^(DVEAlbumSectionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.assetDataModel containsObject:assetModel]) {
            NSInteger idy = [obj.assetDataModel indexOfObject:assetModel];
            NSIndexPath *targetIndexPath = [NSIndexPath indexPathForRow:idy inSection:idx];
            self.viewModel.albumDataModel.targetIndexPath = targetIndexPath;
            //1. if this cell is not within visibleIndexPath, scroll it to center
            //2. if this cell in visibleIndexPath and partly exceed at top of current visible view,scroll it to top
            //3. if this cell in visibleIndexPath and partly exceed at bottom of current visible view,then scroll it to bottom
            if (![visibleIndexPaths containsObject:targetIndexPath]) {
                if (visibleIndexPaths.count > 0) {
                    [self.collectionView scrollToItemAtIndexPath:targetIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                }
            } else {
                UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:targetIndexPath];
                if (cell){
                    CGRect rect = [self.collectionView convertRect:cell.frame toView:self.view];
                    if (rect.origin.y < 0) {
                        [self.collectionView scrollToItemAtIndexPath:targetIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
                    } else if (CGRectGetMaxY(rect) > self.collectionView.frame.size.height) {
                        [self.collectionView scrollToItemAtIndexPath:targetIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
                    }
                }

            }
            *stop = YES;
        }
    }];
}


#pragma mark - IGListAdapterDataSource

- (NSArray<id <IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter
{
    if ([self enableOptimizeRecordAlbum]) {
        return [self.viewModel ab_dataSourceWithResourceType:self.resourceType];
    } else {
        NSArray *array = [self.viewModel dataSourceWithResourceType:self.resourceType];
        return array;
    }
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object
{
    DVEAlbumAssetListSectionController *sectionController = [[DVEAlbumAssetListSectionController alloc] initWithAlbumViewModel:self.viewModel resourceType:self.resourceType];
    @weakify(self);
    sectionController.didSelectedAssetBlock = ^(DVEAlbumAssetListCell * _Nonnull cell, BOOL isSelected) {
        @strongify(self);
        [self p_didSelectedAssetWithCell:cell isSelected:isSelected];
    };
    
    sectionController.didSelectedToPreviewBlock = ^(DVEAlbumAssetModel * _Nonnull assetModel, UIImage * _Nonnull coverImage) {
        @strongify(self);
        [self p_didSelectedToPreview:assetModel coverImage:coverImage fromBottomView:NO];
    };
    
    return sectionController;
}

- (nullable UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter
{
    self.blankContentView.bounds = self.view.bounds;
    return self.blankContentView;
}


#pragma mark - Select

- (void)didSelectedToPreview:(DVEAlbumAssetModel *)model coverImage:(UIImage *)coverImage fromBottomView:(BOOL)fromBottomView
{
    if (!coverImage) {
        coverImage = model.coverImage;
    }
    [self p_didSelectedToPreview:model coverImage:coverImage fromBottomView:fromBottomView];
}

- (void)p_didSelectedToPreview:(DVEAlbumAssetModel *)model coverImage:(UIImage *)coverImage fromBottomView:(BOOL)fromBottomView
{
    if (![self.viewModel canMutilSelectedWithResourceType:self.resourceType] && [self.vcDelegate respondsToSelector:@selector(albumListVC:didClickedCell:)]) {
        [self.viewModel didSelectedAsset:model];
        [self.vcDelegate albumListVC:self didClickedCell:model];
        return;
    }
    
    self.previewFromBottom = fromBottomView;
    if (DVEAlbumGetResourceTypeImage == self.resourceType || DVEAlbumAssetModelMediaTypePhoto == model.mediaType) {
        [self p_didSelectedPhotoToPreview:model fromBottomView:fromBottomView];
    }
    
    if (DVEAlbumGetResourceTypeVideo == self.resourceType || DVEAlbumAssetModelMediaTypeVideo == model.mediaType) {
        [self p_didSelectedVideoToPreview:model coverImage:coverImage fromBottomView:fromBottomView];
    }
}

- (void)p_didSelectedPhotoToPreview:(DVEAlbumAssetModel *)model fromBottomView:(BOOL)fromBottomView
{
    if (self.viewModel.isStory) {
        return;
    }
    
    self.selectedCellIndex = model.cellIndex;
    @weakify(self);
    void (^fetchAlbumPhotoCompleion)(UIImage *photo) = ^(UIImage *photo) {
        DVEAlbumPreviewAndSelectController *preview = [[DVEAlbumPreviewAndSelectController alloc] initWithViewModel:self.viewModel anchorAssetModel:model fromBottomView:fromBottomView];
        preview.willDismissBlock = ^(DVEAlbumAssetModel * _Nonnull currentModel) {
            @strongify(self);
            [self albumListScrollToAssetModel:currentModel];
        };
        preview.didClickedTopRightIcon = ^(DVEAlbumAssetModel * _Nonnull currentModel, BOOL isSelected) {
            @strongify(self);
            [self p_didSelectedAsset:currentModel isSelected:isSelected fromPreivew:YES];
        };
        preview.modalPresentationStyle = UIModalPresentationCustom;
        preview.modalPresentationCapturesStatusBarAppearance = YES;
        preview.transitioningDelegate = self.transitionDelegate;
        self.transitioningDelegate = self.transitionDelegate;
        [self presentViewController:preview animated:YES completion:nil];
    };
    
    PHAsset *phAsset = model.asset;
    [DVEPhotoManager getUIImageWithPHAsset:phAsset networkAccessAllowed:NO progressHandler:^(CGFloat progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
    } completion:^(UIImage * _Nonnull photo, NSDictionary * _Nonnull info, BOOL isDegraded) {
        @strongify(self)
        if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue]) {
            NSTimeInterval icloudFetchStart = CFAbsoluteTimeGetCurrent();
            [DVEPhotoManager getOriginalPhotoDataFromICloudWithAsset:phAsset progressHandler:^(CGFloat progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
            } completion:^(NSData * _Nonnull data, NSDictionary * _Nonnull info) {
                @strongify(self);
                if (data) {
                    [self p_trackPhotoiCloud:icloudFetchStart size:data.length];
                }
            }];
            
            [[DVEAlbumToastImpl new] show:TOCLocalizedString(@"com_mig_syncing_the_picture_from_icloud", @"该图片正在从iCloud同步，请稍后再试")];
        } else if (!isDegraded && photo) {
            if (![self.viewModel.currentSelectAssets containsObject:model]) {
                [self.viewModel.currentSelectAssets addObject:model];
            }
            if (self.viewModel.inputData.maxPictureSelectionCount > 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    TOCBLOCK_INVOKE(fetchAlbumPhotoCompleion, photo);
                });
            } else {
                [self.viewModel onNext];
            }
        }
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (void)p_didSelectedVideoToPreview:(DVEAlbumAssetModel *)model coverImage:(UIImage *)coverImage fromBottomView:(BOOL)fromBottomView
{
    self.selectedCellIndex = model.cellIndex;
    if (![self.viewModel.currentSelectAssets containsObject:model]) {
        [self.viewModel.currentSelectAssets addObject:model];
    }
    
    if (self.viewModel.inputData.maxPictureSelectionCount <= 1) {
        [self.viewModel onNext];
        return;
    }
    
    DVEAlbumPreviewAndSelectController *preview = [[DVEAlbumPreviewAndSelectController alloc] initWithViewModel:self.viewModel anchorAssetModel:model fromBottomView:fromBottomView];
    @weakify(self);
    preview.willDismissBlock = ^(DVEAlbumAssetModel * _Nonnull currentModel) {
        @strongify(self);
        [self albumListScrollToAssetModel:currentModel];
    };
    preview.didClickedTopRightIcon = ^(DVEAlbumAssetModel * _Nonnull currentModel, BOOL isSelected) {
        @strongify(self);
        [self p_didSelectedAsset:currentModel isSelected:isSelected fromPreivew:YES];
    };
    preview.modalPresentationStyle = UIModalPresentationCustom;
    preview.modalPresentationCapturesStatusBarAppearance = YES;
    preview.transitioningDelegate = self.transitionDelegate;
    self.transitioningDelegate = self.transitionDelegate;
    [self presentViewController:preview animated:YES completion:nil];
}

- (void)p_didSelectedAssetWithCell:(DVEAlbumAssetListCell *)cell isSelected:(BOOL)isSelected
{
    DVEAlbumAssetModel *model = cell.assetModel;
    
    if (![self p_didSelectedAsset:model isSelected:isSelected fromPreivew:NO]) {
        return;
    }
    
    // Synchronize the number in the upper right corner of the cell, need to call the delegate method first,
    // and then reload the visible cell to prevent the number of visible cells from being incorrect.
    [self p_reloadVisibleCellExcept:cell];
    [cell doSelectedAnimation];
}

- (BOOL)p_didSelectedAsset:(DVEAlbumAssetModel *)model isSelected:(BOOL)isSelected fromPreivew:(BOOL)fromPreview
{
        // Should Select the assetModel.
        if ([self.vcDelegate respondsToSelector:@selector(albumListVC:shouldSelectAsset:)]) {
            if (![self.vcDelegate albumListVC:self shouldSelectAsset:model]) {
                return NO;
            }
        }
        
        if (![self p_checkValidForAssetModel:model]) {
            return NO;
        }

        [self.viewModel didSelectedAsset:model];
//    }
    
    if ([self.vcDelegate respondsToSelector:@selector(albumListVC:didSelectedVideo:)]) {
        [self.vcDelegate albumListVC:self didSelectedVideo:model];
    }
    
    return YES;
}

- (void)p_reloadVisibleCellExcept:(DVEAlbumAssetListCell *)cell
{
    NSMutableArray *visibleIndexPaths = [[self.collectionView indexPathsForVisibleItems] mutableCopy];
    if (!cell) {
        [UIView performWithoutAnimation:^{
            [self.collectionView reloadItemsAtIndexPaths:visibleIndexPaths];
        }];
        return;
    }
    
    NSIndexPath *currentIndexPath = [self.collectionView indexPathForCell:cell];
    for (NSIndexPath *path in visibleIndexPaths) {
        if (path.row == currentIndexPath.row && path.section == currentIndexPath.section){
            [visibleIndexPaths removeObject:path];
            break;
        }
    }
    [UIView performWithoutAnimation:^{
        [self.collectionView reloadItemsAtIndexPaths:visibleIndexPaths];
    }];
}

#pragma mark - DVEAlbumListViewControllerProtocol

- (void)albumListShowTabDotIfNeed:(void (^)(BOOL showDot, UIColor *color))showDotBlock
{
    TOCBLOCK_INVOKE(showDotBlock, NO, [UIColor clearColor]);
}

#pragma mark - DVEAlbumZoomTransitionOuterContextProvider

- (NSInteger)zoomTransitionItemOffset
{
    return self.selectedCellIndex;
}

- (UIView *_Nullable)zoomTransitionStartViewForOffset:(NSInteger)offset
{
    if (self.viewModel.currentSelectedIndex < 0 || self.viewModel.currentSelectedIndex >= self.viewModel.inputData.tabsInfo.count) {
        return nil;
    }
    
    if (self.previewFromBottom) {
        return nil;
    }

    DVEAlbumVCModel *model = [self.viewModel.inputData.tabsInfo objectAtIndex:self.viewModel.currentSelectedIndex];
    UIViewController *viewController = model.listViewController;
    if ([viewController isKindOfClass:[DVEAlbumListViewController class]]) {
        UICollectionViewCell *cell = [((DVEAlbumListViewController *)viewController) transitionCollectionCellForItemOffset:offset];
        return cell;
    }
    
    return nil;
}

#pragma mark - IGListAdapterDelegate

- (void)listAdapter:(IGListAdapter *)listAdapter willDisplayObject:(id)object atIndex:(NSInteger)index
{

}

- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingObject:(id)object atIndex:(NSInteger)index
{
    
}

#pragma mark - Blank View

- (void)updateBlankViewWithPermission:(BOOL)permission
{
    if (!permission) {
        self.blankContentView.type = DVEAlbumListBlankViewTypeNoPermissions;
        return;
    }
    self.blankContentView.type = [self.viewModel blankViewTypeWithResourceType:self.resourceType];
}

#pragma mark - Valid

- (BOOL)p_checkValidForAssetModel:(DVEAlbumAssetModel *)assetModel
{
    if (self.viewModel.hasSelectedMaxCount) {
        if (assetModel.mediaType == DVEAlbumAssetModelMediaTypePhoto) {
            if (self.viewModel.isMV) {
                [[DVEAlbumToastImpl new] show:[NSString stringWithFormat:TOCLocalizedString(@"com_mig_select_up_to_photos_1ln6mp",@"此影集最多选择%@个素材"), @([self.viewModel maxSelectionCount])]];
            } else {
                [[DVEAlbumToastImpl new] show:[NSString stringWithFormat:TOCLocalizedString(@"com_mig_select_up_to_photos",@"此影集最多选择%@个素材"), @([self.viewModel maxSelectionCount])]];
            }
        } else if (assetModel.mediaType == DVEAlbumAssetModelMediaTypeVideo) {
            [[DVEAlbumToastImpl new] show:[NSString stringWithFormat:TOCLocalizedString(@"com_mig_you_can_select_up_to_videos",@"最多选择%@个视频"), @([self.viewModel maxSelectionCount])]];
        }
        
        return NO;
    }
    
//    if (assetModel.mediaType == DVEAlbumAssetModelMediaTypePhoto && ![self p_validAssetModelForPhoto:assetModel]) {
//        return NO;
//    }
//
//    if (assetModel.mediaType == DVEAlbumAssetModelMediaTypeVideo && ![self p_validAssetModelForVideo:assetModel]) {
//        return NO;
//    }
        
    return YES;
}

- (BOOL)p_validAssetModelForPhoto:(DVEAlbumAssetModel *)assetModel
{
    CGFloat scale = (CGFloat)assetModel.asset.pixelWidth / (CGFloat)assetModel.asset.pixelHeight;
    if (scale >= 2.2 || scale <= 1.0 / 2.2) {
        [[DVEAlbumToastImpl new] show:TOCLocalizedString(@"share_img_from_sys_size_error", @"暂不支持该图片尺寸")];
        [self p_trackInValidAssetWithCode:0 assetTypeVideo:NO];
        return NO;
    }
    
    return YES;
}


+ (CMVideoCodecType)videoCodecTypeForAsset:(PHAsset *)phAsset {
    // 同步获取AVAsset
    dispatch_semaphore_t    semaphore = dispatch_semaphore_create(0);
    __block AVAsset *resultAsset;
    [PHCachingImageManager.defaultManager requestAVAssetForVideo:phAsset options:nil resultHandler:^(AVAsset * _Nullable videoAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        resultAsset = videoAsset;
        dispatch_semaphore_signal(semaphore);
        
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSArray *videoAssetTracks = [resultAsset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *videoAssetTrack = videoAssetTracks.firstObject;
    
    CMFormatDescriptionRef desc = (__bridge CMFormatDescriptionRef)videoAssetTrack.formatDescriptions.firstObject;
    CMVideoCodecType codec = CMVideoFormatDescriptionGetCodecType(desc);
    return codec;
}

+ (AVAsset *)avAssetWith:(PHAsset *)phAsset {
    dispatch_semaphore_t    semaphore = dispatch_semaphore_create(0);
    __block AVAsset *resultAsset;
    [PHCachingImageManager.defaultManager requestAVAssetForVideo:phAsset options:nil resultHandler:^(AVAsset * _Nullable videoAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        resultAsset = videoAsset;
        dispatch_semaphore_signal(semaphore);
        
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return resultAsset;
}

- (BOOL)p_validAssetModelForVideo:(DVEAlbumAssetModel *)assetModel
{
    PHAsset *phAsset = assetModel.asset;
    
    // 编码检测
//    CMVideoCodecType code = [self.class videoCodecTypeForAsset:phAsset];
//    if (code == kCMVideoCodecType_HEVC || code == kCMVideoCodecType_HEVCWithAlpha) {
//        [[DVEAlbumToastImpl new] show:@"暂不支持该视频格式"];
//        return NO;
//    }
    // check if avurlasset
    if (![[self.class avAssetWith:phAsset] isKindOfClass:AVURLAsset.class]) {
        [[DVEAlbumToastImpl new] show:@"暂不支持该视频格式"];
        return NO;
    }
    
    // 时长检测
    CGFloat duration = phAsset.duration;

    if (duration < self.configViewModel.videoMinSeconds) {
        NSString *minTimeTipDes = [NSString stringWithFormat:TOCLocalizedString(@"com_mig_cannot_select_video_shorter_than_0f_s",@"视频时长不能小于%.0fs"), self.configViewModel.videoMinSeconds];
        [[DVEAlbumToastImpl new] showError:minTimeTipDes];
        [self p_trackInValidAssetWithCode:1 assetTypeVideo:YES];
        return NO;
    }

    if ([self.viewModel isExceedMaxDurationForAIVideoClip:duration resourceType:self.resourceType]) {
        return NO;
    }
    
    if (duration > self.configViewModel.videoSelectableMaxSeconds) {
        [[DVEAlbumToastImpl new] show:TOCLocalizedString(@"com_mig_video_is_too_long_try_another_one", @"视频太长，请重新选择")];
        [self p_trackInValidAssetWithCode:2 assetTypeVideo:YES];
        return NO;
    }
    
    CGSize naturalSize = CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight);
    CGFloat tolerance = 0.01;
    CGFloat factor = naturalSize.width / naturalSize.height;
    
    BOOL resolutionIsUpported = (factor > 9. / 20 - tolerance) && (factor < 20. / 9 + tolerance);
    
//    hmd_MemoryBytes memoryBytes = hmd_getMemoryBytes();

//    if (naturalSize.height * naturalSize.width > 1080 * 1920 && memoryBytes.totalMemory <= HMD_MEMORY_GB) {
//        resolutionIsUpported = NO;
//    }

//    NSInteger resolution = 2160 * 3840;//1080 * 1920;
//    if (naturalSize.height * naturalSize.width >= resolution) {// || memoryBytes.totalMemory <= HMD_MEMORY_GB) {
//        resolutionIsUpported = NO;
//    }
//
//    if (!resolutionIsUpported) {
//        [[DVEAlbumToastImpl new] show:TOCLocalizedString(@"com_mig_video_resolution_not_supported_at_this_time", @"暂不支持该分辨率的视频")];
//        [self p_trackInValidAssetWithCode:0 assetTypeVideo:YES];
//        return NO;
//    }
    
    if (self.viewModel.isCutSame || self.viewModel.isCutSameChangeMaterial) {
            BOOL validFlag = [self p_checkVideoValidForCutSame:assetModel];
            if (!validFlag) {
                return NO;
            }
        }
    return YES;
}

- (BOOL)p_checkVideoValidForCutSame:(DVEAlbumAssetModel *)assetModel
{
    BOOL flag = YES;
    if ([self.vcDelegate respondsToSelector:@selector(checkVideoValidForCutSame:)])
    {
        flag = [self.vcDelegate checkVideoValidForCutSame:assetModel];
    }
    return flag;
}

#pragma mark - Utils

- (BOOL)isCurrentViewControllerVisible
{
    return (self.isViewLoaded && self.view.window);
}

#pragma mark - Tracker

- (void)p_trackInValidAssetWithCode:(NSInteger)code assetTypeVideo:(BOOL)isVideo
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"type"] = @(isVideo ? 0:1); //0-video，1-photo，2-other
    params[@"code"] = @(code);          //0-size,1-length too short,2-over length
    [params addEntriesFromDictionary:self.viewModel.inputData.trackExtraDic?:@{}];
}

- (void)p_trackPhotoiCloud:(NSTimeInterval)icloudFetchStart size:(NSInteger)bytes
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"duration"] = @((NSInteger)((CFAbsoluteTimeGetCurrent() - icloudFetchStart) * 1000));
    params[@"type"] = @(1);
    params[@"size"] = @(bytes);
    [params addEntriesFromDictionary:self.viewModel.inputData.trackExtraDic?:@{}];
}

#pragma mark - Getter

- (NSArray<DVEAlbumSectionModel *> *)dataSource
{
    if ([self enableOptimizeRecordAlbum]) {
        return [self.viewModel ab_dataSourceWithResourceType:self.resourceType];
    } else {
        return [self.viewModel dataSourceWithResourceType:self.resourceType];
    }
}

- (IGListCollectionView *)collectionView
{
    if (!_collectionView) {
        IGListCollectionViewLayout *layout = [[IGListCollectionViewLayout alloc] initWithStickyHeaders:NO
                                                                                       topContentInset:0.0f
                                                                                         stretchToEdge:NO];
        
        _collectionView = [[IGListCollectionView alloc] initWithFrame:self.view.bounds listCollectionViewLayout:layout];
        _collectionView.backgroundColor = TOCResourceColor(TOCUIColorConstBGContainer);
    }
    
    return _collectionView;
}

- (IGListAdapter *)adapter
{
    if (!_adapter) {
        IGListAdapterUpdater *updater = [[IGListAdapterUpdater alloc] init];
        _adapter = [[IGListAdapter alloc] initWithUpdater:updater viewController:self workingRangeSize:0];
        _adapter.delegate = self;
        _adapter.dataSource = self;
    }
    
    return _adapter;
}

- (DVEAlbumListBlankView *)blankContentView
{
    if (!_blankContentView) {
        _blankContentView = [[DVEAlbumListBlankView alloc] initWithFrame:self.view.bounds];
        _blankContentView.backgroundColor = TOCResourceColor(TOCUIColorConstBGContainer);
    }
    return _blankContentView;
}

- (DVEAlbumConfigViewModel *)configViewModel
{
    return self.viewModel.configViewModel;
}

- (DVEAlbumZoomTransitionDelegate *)transitionDelegate
{
    if (!_transitionDelegate) {
        _transitionDelegate = [DVEAlbumZoomTransitionDelegate new];
    }
    return _transitionDelegate;
}

@end
