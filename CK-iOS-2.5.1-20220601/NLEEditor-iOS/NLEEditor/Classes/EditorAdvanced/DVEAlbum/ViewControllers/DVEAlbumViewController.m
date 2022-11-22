//
//  DVEAlbumViewController.m
//  CameraClient
//
//  Created by bytedance on 2020/6/16.
//

#import "UIView+DVEAlbumMasonry.h"
#import "DVEAlbumViewController.h"
#import "DVEAlbumCategorylistCell.h"
#import "DVEAlbumVCNavView.h"
#import "DVEAlbumGoSettingStrip.h"
#import "DVEAlbumRequestAccessView.h"
#import "DVEAlbumDenyAccessView.h"
#import "DVEAlbumDeviceAuth.h"
#import <Masonry/Masonry.h>
#import "DVEAlbumMacros.h"
#import "DVEAlbumLanguageProtocol.h"
#import "DVEAlbumConfigProtocol.h"
#import "DVEAlbumSlidingTabbarView.h"
#import "DVEAlbumResourceUnion.h"
#import "DVEAlbumLoadingViewProtocol.h"
#import "DVEAlbumToastImpl.h"
#import "NSArray+DVEAlbumAdditions.h"
#import <KVOController/KVOController.h>
#import "UIDevice+DVEAlbumHardware.h"
//#import "DVEVideoEditViewController.h"

const static NSUInteger kAlbumTitleTabHight = 40;
const static CGFloat kAlbumSelectedAssetsViewHeight = 88.0f;
const static CGFloat kAlbumFrontBottomOffsetOffset = 1.0f;


@interface DVEAlbumViewController () <DVEAlbumSlidingViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, PHPhotoLibraryChangeObserver>

@property(nonatomic, strong, readwrite) DVEAlbumViewModel *viewModel;
@property(nonatomic, strong) DVEAlbumConfigViewModel *configViewModel;

@property(nonatomic, strong) UIView *viewWrapper;
@property(nonatomic, strong) UIView *albumTopLine;
@property(nonatomic, strong) UITableView *albumListTableView;
@property(nonatomic, strong) DVEAlbumSlidingTabbarView *slidingTabView;
@property(nonatomic, strong) DVEAlbumSlidingViewController *slidingViewController;

// photo library permission request
@property(nonatomic, strong) DVEAlbumGoSettingStrip *goSettingStrip;
@property(nonatomic, strong) DVEAlbumRequestAccessView *requestAccessView;
@property(nonatomic, strong) DVEAlbumDenyAccessView *denyAccessView;


// photos and videos mixed
@property(nonatomic, strong) DVEImportSelectView *selectedAssetsView;
@property(nonatomic, strong) DVEImportSelectBottomView *selectedAssetsBottomView;

@property(nonatomic, strong) id <DVEAlbumConfigProtocol> albumConfig;

@property(nonatomic, assign) DVEAlbumVCType vcType;
@property(nonatomic, strong) DVEAlbumTemplateModel *cutSameTemplateModel;
@property(nonatomic, strong) DVEAlbumCutSameFragmentModel *singleFragment;

@property(nonatomic, assign) BOOL hasRegisterPhotoChangeObserver;
@property(nonatomic, strong) UIView <DVEAlbumTextLoadingViewProtcol> *loadingView;

@property(nonatomic, weak) UICollectionViewCell *selectedCell;

@property (nonatomic, assign) NSInteger selectAssetsCount;

@end

@implementation DVEAlbumViewController

@synthesize  needEnablePhotoToVideo;
@synthesize topNavView = _topNavView;

//DVEAutoInject(TOCBaseServiceProvider(), albumConfig, DVEAlbumConfigProtocol)

- (instancetype)initWithAlbumViewModel:(DVEAlbumViewModel *)viewModel {
    self = [super init];
    if (self) {
        self.viewModel = viewModel;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = TOCResourceColor(TOCUIColorConstBGContainer);
    // fetch album category list
    if (!([DVEAlbumDeviceAuth isiOS14PhotoNotDetermined] && YES)) {
        [self prefetchAlbumList];
    }

    [self setupUI];
    [self bindViewModel];
    [self addPhotoLibraryChangeObserver];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}


- (void)bindViewModel {
    @weakify(self);
    [self.KVOController observe:self.viewModel.albumDataModel keyPath:@"mixedSelectAssetsModels" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id _Nullable observer, id _Nonnull object, NSDictionary<NSString *, id> *_Nonnull change) {
        @strongify(self);
        DVEAlbumListViewController *listVC = [self currentAlubmListViewController];
        [listVC reloadVisibleCell];

        [self updateNextButtonTitle];
    }];

    [self.KVOController observe:self.viewModel.albumDataModel keyPath:@"allAlbumModels" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id _Nullable observer, id _Nonnull object, NSDictionary<NSString *, id> *_Nonnull change) {
        @strongify(self);
        [self.albumListTableView reloadData];
    }];


    [self.KVOController observe:self.configViewModel keyPath:@keypath(self.configViewModel, shouldShowGoSettingStrip) options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id _Nullable observer, id _Nonnull object, NSDictionary<NSString *, id> *_Nonnull change) {
        @strongify(self);
        BOOL shouldShow = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (shouldShow && ![DVEAlbumGoSettingStrip closedByUser]) {
            self.goSettingStrip.hidden = NO;
            self.slidingViewController.view.frame = [self listViewControllerFrame];
            NSMutableDictionary *params = [@{} mutableCopy];
        } else {
            self.goSettingStrip.hidden = YES;
            self.slidingViewController.view.frame = [self listViewControllerFrame];
        }
    }];
}

- (void)dealloc {
    [self.KVOController unobserveAll];
    PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
    if (authorizationStatus == PHAuthorizationStatusAuthorized && self.hasRegisterPhotoChangeObserver) {
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    }
}

- (void)addPhotoLibraryChangeObserver {
    if (!self.hasRegisterPhotoChangeObserver) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
            if (authorizationStatus == PHAuthorizationStatusAuthorized) {
                [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
                self.hasRegisterPhotoChangeObserver = YES;
            }
        });
    }
}

- (UIViewController <DVEAlbumListViewControllerProtocol> *)currentAlbumListViewController {
    UIViewController <DVEAlbumListViewControllerProtocol> *vc = [self.slidingViewController.currentViewControllers acc_objectAtIndex:self.slidingViewController.selectedIndex];
    return vc;
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    if (self.navigationController.view.frame.origin.y < TOC_STATUS_BAR_HEIGHT && !self.viewModel.inputData.shouldApplyAlbumFront) {
        CGRect frame = self.navigationController.view.frame;
        CGFloat delta = TOC_STATUS_BAR_HEIGHT - frame.origin.y;
        frame.origin.y += delta;
        frame.size.height -= delta;
        self.navigationController.view.frame = frame;
    }

    self.viewWrapper.frame = CGRectMake(0, [self p_albumNavHeight], TOC_SCREEN_WIDTH, self.view.frame.size.height - [self p_albumNavHeight]);
    self.slidingViewController.view.frame = [self listViewControllerFrame];
    self.selectedAssetsBottomView.frame = CGRectMake(0, self.viewWrapper.frame.size.height - [self p_selectedAssetsBottomViewHeight], self.view.bounds.size.width, [self p_selectedAssetsBottomViewHeight]);
    if (self.viewModel.hasSelectedAssets) {
        self.selectedAssetsView.frame = CGRectMake(0, self.viewWrapper.frame.size.height - kAlbumSelectedAssetsViewHeight - [self p_selectedAssetsBottomViewHeight], self.view.frame.size.width, kAlbumSelectedAssetsViewHeight);
    } else {
        self.selectedAssetsView.frame = CGRectMake(0, self.viewWrapper.frame.size.height - [self p_selectedAssetsBottomViewHeight], self.view.bounds.size.width, kAlbumSelectedAssetsViewHeight);
    }

    DVEAlbumGetResourceType type = [self.viewModel.inputData.tabsInfo acc_objectAtIndex:self.viewModel.currentSelectedIndex].resourceType;
    BOOL isInMomentsTab = [self.viewModel showMomentsTab] && DVEAlbumGetResourceTypeMoments == type;
    if (self.viewModel.inputData.shouldApplyAlbumFront && !isInMomentsTab) {
        if (self.viewModel.hasSelectedAssets) {
            self.selectedAssetsView.hidden = NO;
            self.selectedAssetsBottomView.hidden = NO;
        } else {
            self.selectedAssetsView.hidden = YES;
            self.selectedAssetsBottomView.hidden = YES;
        }
    }

    if (self.vcType == DVEAlbumVCTypeForCutSame || self.vcType == DVEAlbumVCTypeForCutSameChangeMaterial) {
        [self showSelectedAssetsView];
        if (self.selectedAssetsView) {
            [self.selectedAssetsView.superview bringSubviewToFront:self.selectedAssetsView];
        }
    }

    if (_requestAccessView) {
        [self.requestAccessView.superview bringSubviewToFront:self.requestAccessView];
    }
}

#pragma mark - UI config

- (CGFloat)p_albumNavHeight {
    return self.viewModel.isFirstCreative ? 138.f : 54.f;
}

- (CGFloat)p_selectedAssetsBottomViewHeight {

    CGFloat baseViewHeight = 52.0f;
    if (self.viewModel.isFirstCreative) {
        baseViewHeight = 69.f;
    }
    return baseViewHeight + TOC_IPHONE_X_BOTTOM_OFFSET;
}

- (CGFloat)p_horizontalInset {
    if (self.viewModel.isFirstCreative) {
        return 16.f;
    }
    return 0.f;
}

#pragma mark - UI

- (void)setupUI {

    [self.view addSubview:self.topNavView];

    [self setupSlidingViewController];
    [self setupGoSettingStrip];
    [self setupViewWrapperForMixedUploading];

    [self setupRequestAccessView];
}

- (void)prefetchAlbumList {
    @weakify(self);
    [self.viewModel prefetchAlbumListWithCompletion:^{
        @strongify(self);
        [self.albumListTableView reloadData];
    }];
}

- (void)setupSlidingViewController {
    self.viewWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, [self p_albumNavHeight], TOC_SCREEN_WIDTH, self.view.frame.size.height - [self p_albumNavHeight])];
    self.viewWrapper.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.viewWrapper];

    NSMutableArray *durations;
    if ((self.viewModel.inputData.vcType == DVEAlbumVCTypeForCutSame && self.cutSameTemplateModel) ||
            (self.viewModel.inputData.vcType == DVEAlbumVCTypeForCutSameChangeMaterial && self.singleFragment)) {
        durations = [NSMutableArray array];
        if (self.vcType == DVEAlbumVCTypeForCutSame && self.cutSameTemplateModel) {
            [self.cutSameTemplateModel.extraModel.fragments enumerateObjectsUsingBlock:^(DVEAlbumCutSameFragmentModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                if (obj.duration.doubleValue > 0) {
                    [durations addObject:@(obj.duration.doubleValue / 1000.0)];
                }
            }];
        } else {
            if (self.singleFragment.duration.doubleValue > 0) {
                [durations addObject:@(self.singleFragment.duration.doubleValue / 1000.0)];
            }
        }
    }


    self.slidingViewController.view.frame = [self listViewControllerFrame];
    [self.viewWrapper addSubview:self.slidingViewController.view];
    [self addChildViewController:self.slidingViewController];
    [self.slidingViewController didMoveToParentViewController:self];
    [self.slidingViewController reloadViewControllers];
    self.slidingViewController.selectedIndex = self.viewModel.defaultSelectedIndex;
}

- (void)setupGoSettingStrip {

    // goSettingStrip
    CGFloat goSettingStripOffsetY = [self shouldShowAlbumTabView] ? 48 : 0;
    self.goSettingStrip = [[DVEAlbumGoSettingStrip alloc] initWithFrame:CGRectMake(0, goSettingStripOffsetY, self.view.frame.size.width, 40)];
    [self.viewWrapper addSubview:self.goSettingStrip];
    UITapGestureRecognizer *labelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goSettingStripLabelClicked)];
    [self.goSettingStrip.label addGestureRecognizer:labelTapGesture];
    [self.goSettingStrip.closeButton addTarget:self action:@selector(goSettingStripCloseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    // whether show goSettingStrip or not is controlled by DVEAlbumConfigViewModel.shouldShowGoSettingStrip
    self.goSettingStrip.hidden = YES;
}

- (void)setupViewWrapperForMixedUploading {
    [self setupSelectedViewForMixedUploading];
    [self setupSelectedBottomViewForMixedUploading];

    [self showSelectedAssetsView];
    if (self.selectedAssetsView) {
        [self.selectedAssetsView.superview bringSubviewToFront:self.selectedAssetsView];
    }
}

- (void)setupSelectedViewForMixedUploading {

    self.selectedAssetsView = [[DVEImportSelectView alloc] init];

    if (self.vcType == DVEAlbumVCTypeForCutSame) {
        self.selectedAssetsView = [[DVEImportSelectView alloc] init];//[DVE_SelectedAssets_Obj selectedAssetsView];

    }

    if (self.vcType == DVEAlbumVCTypeForCutSameChangeMaterial) {
        self.selectedAssetsView = [[DVEImportSelectView alloc] init];//[DVE_SelectedAssets_Obj selectedAssetsView];

    }

    self.selectedAssetsView.albumViewModel = self.viewModel;
    self.selectedAssetsView.frame = CGRectMake(0, self.view.frame.size.height - [self p_selectedAssetsBottomViewHeight], self.view.bounds.size.width, kAlbumSelectedAssetsViewHeight);
    self.selectedAssetsView.backgroundColor = TOCResourceColor(TOCUIColorConstBGContainer2);
    self.selectedAssetsView.assetModelArray = self.viewModel.currentSelectAssetModels;
    @weakify(self);
    self.selectedAssetsView.deleteAssetModelBlock = ^(DVEAlbumAssetModel *_Nonnull assetModel) {
        @strongify(self);
        [self.viewModel didUnselectedAsset:assetModel];
        [self hideSelectedAssetsBottomViewIfNeed];
        DVEAlbumListViewController *listVC = [self currentAlubmListViewController];
        [listVC reloadVisibleCell];
        [self updateNextButtonTitle];
    };

    if ([self.selectedAssetsView respondsToSelector:@selector(setTouchAssetModelBlock:)]) {
        self.selectedAssetsView.touchAssetModelBlock = ^(DVEAlbumAssetModel *_Nonnull assetModel, NSInteger index) {
            @strongify(self);
            if (DVEAlbumAssetModelMediaTypePhoto == assetModel.mediaType) {
                PHAsset *phAsset = assetModel.asset;
                CGFloat aspectRatio = (CGFloat) phAsset.pixelWidth / (CGFloat) phAsset.pixelHeight;
                if (aspectRatio >= 2.2 || aspectRatio <= 1.0 / 2.2) {
                    [[DVEAlbumToastImpl new] show:TOCLocalizedString(@"share_img_from_sys_size_error", @"暂不支持该图片尺寸")];
                    return;
                }
                [DVEPhotoManager getUIImageWithPHAsset:phAsset
                                   networkAccessAllowed:NO
                                        progressHandler:^(CGFloat progress, NSError *_Nonnull error, BOOL *_Nonnull stop, NSDictionary *_Nonnull info) {

                }                           completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    @strongify(self)
                    if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue]) {
                        NSTimeInterval icloudFetchStart = CFAbsoluteTimeGetCurrent();
                        [DVEPhotoManager getOriginalPhotoDataFromICloudWithAsset:assetModel.asset progressHandler:^(CGFloat progress, NSError *_Nonnull error, BOOL *_Nonnull stop, NSDictionary *_Nonnull info) {

                        }                                             completion:^(NSData *data, NSDictionary *info) {
                            if (data) {
                                @strongify(self);
                                [self trackPhotoiCloud:icloudFetchStart size:[data length]];
                            }
                        }];
                        [[DVEAlbumToastImpl new] show:TOCLocalizedString(@"com_mig_syncing_the_picture_from_icloud", @"该图片正在从iCloud同步，请稍后再试")];
                    } else {
                        if (!isDegraded && photo) {
                            [self p_previewWithAsset:assetModel isFromBottomView:YES resourceType:DVEAlbumGetResourceTypeImageAndVideo];
                        }
                    }
                }];
            } else if (DVEAlbumAssetModelMediaTypeVideo == assetModel.mediaType) {
                // TODO: 替换资源时候剪裁视频
                DVEAlbumCutSameFragmentModel *fragmentModel = self.cutSameTemplateModel.extraModel.fragments[index];
                if (!fragmentModel) {
                    fragmentModel = self.viewModel.inputData.singleFragment;
                }
                [self p_cropVideoWithAsseet:assetModel fragmentModel:fragmentModel];
            }
        };
    }
    //[self.viewWrapper addSubview:self.selectedAssetsView];
}

- (void)setupSelectedBottomViewForMixedUploading {
    self.selectedAssetsBottomView = [[DVEImportSelectBottomView alloc] init];
    @weakify(self)
    self.viewModel.nextAction = ^{
        @strongify(self)
        [self nextActionForCutSame:nil];
    };
    [self.selectedAssetsBottomView.nextButton addTarget:self.viewModel
                                                 action:@selector(onNext)
                                       forControlEvents:UIControlEventTouchUpInside];
    self.selectedAssetsBottomView.frame = CGRectMake(0, self.viewWrapper.frame.size.height - [self p_selectedAssetsBottomViewHeight], self.view.bounds.size.width, [self p_selectedAssetsBottomViewHeight]);
    self.selectedAssetsBottomView.backgroundColor = TOCResourceColor(TOCUIColorConstBGContainer2);
    [self.viewWrapper addSubview:self.selectedAssetsBottomView];

    [self updateNextButtonTitle];

//    NSString *title = TOCLocalizedString(@"creation_upload_docktoast", @"");
//    self.selectedAssetsBottomView.titleLabel.text = title;

    DVEAlbumVCModel *vcModel = [self.viewModel.inputData.tabsInfo acc_objectAtIndex:self.viewModel.defaultSelectedIndex];
    if ([self.viewModel showMomentsTab] && vcModel.resourceType == DVEAlbumGetResourceTypeMoments) {
        self.selectedAssetsView.hidden = YES;
        self.selectedAssetsBottomView.hidden = YES;
    }
    
    [self p_updateBottomViewWithStatus:self.viewModel.inputData.maxPictureSelectionCount <= 1];

}


- (void)setupDenyAccessView {
    if (@available(iOS 14.0, *)) {
        [self.viewWrapper addSubview:self.denyAccessView];
        [self.viewWrapper bringSubviewToFront:self.denyAccessView];
        self.denyAccessView.layer.zPosition = 1000;
    }
}

- (void)setupRequestAccessView {
    if ([DVEAlbumDeviceAuth isiOS14PhotoNotDetermined] && YES) {
        [self.viewWrapper addSubview:self.requestAccessView];
        [self.viewWrapper bringSubviewToFront:self.requestAccessView];
    }
}

- (void)updateNextButtonTitle {
    BOOL buttonEnable = NO;
    NSString *buttonTitle = @"";
    NSInteger totalSelectedAssetCount = self.viewModel.currentSelectAssetModels.count;

    if (self.viewModel.isCutSame) {
        buttonEnable = YES;
        if (self.viewModel.inputData.isFirstCreative) {
            buttonTitle = TOCLocalizedString(@"ck_start",@"开始创作");
        } else {
            buttonTitle = TOCLocalizedString(@"ck_add",@"添加");
        }
        if (totalSelectedAssetCount == self.viewModel.inputData.cutSameTemplateModel.fragmentCount) {

            self.selectedAssetsBottomView.nextButton.backgroundColor = TOCResourceColor(TOCColorPrimary);
            [self.selectedAssetsBottomView.nextButton setTitleColor:TOCResourceColor(TOCColorTextPrimary) forState:UIControlStateNormal];
        } else {
            self.selectedAssetsBottomView.nextButton.backgroundColor = TOCResourceColor(TOCColorTextReverse4);
            [self.selectedAssetsBottomView.nextButton setTitleColor:TOCResourceColor(TOCColorTextPrimary) forState:UIControlStateNormal];
        }
    } else if (self.viewModel.isCutSameChangeMaterial) {
        if (self.viewModel.inputData.isFirstCreative) {
            buttonTitle = TOCLocalizedString(@"ck_start",@"开始创作");
        } else {
            buttonTitle = TOCLocalizedString(@"ck_add",@"添加");
        }
        if (totalSelectedAssetCount == 1) {
            buttonEnable = YES;
            self.selectedAssetsBottomView.nextButton.backgroundColor = TOCResourceColor(TOCColorPrimary);
            [self.selectedAssetsBottomView.nextButton setTitleColor:TOCResourceColor(TOCColorTextPrimary) forState:UIControlStateNormal];

        } else {
            buttonEnable = NO;
            self.selectedAssetsBottomView.nextButton.backgroundColor = TOCResourceColor(TOCColorTextReverse4);
            [self.selectedAssetsBottomView.nextButton setTitleColor:TOCResourceColor(TOCColorTextPrimary) forState:UIControlStateNormal];
        }
    } else {
        buttonTitle = TOCLocalizedString(@"common_next", @"下一步");
        if (totalSelectedAssetCount > 1) {
            buttonTitle = [NSString stringWithFormat:TOCLocalizedString(@"com_mig_next_zd_07oymg",@"%@(%zd)"), @"下一步",totalSelectedAssetCount];
        }
        buttonEnable = totalSelectedAssetCount > 0;
    }

    [self.selectedAssetsBottomView.nextButton setTitle:buttonTitle forState:UIControlStateNormal];
    [self.selectedAssetsBottomView.nextButton setEnabled:buttonEnable];
    

//    CGSize sizeFits = [self.selectedAssetsBottomView.nextButton sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
//    [UIView animateWithDuration:0.35f animations:^{
//        DVEAlbumMasUpdate(self.selectedAssetsBottomView.nextButton, {
//            if (self.viewModel.isCutSame || self.viewModel.isCutSameChangeMaterial) {
//                make.width.equalTo(@(sizeFits.width + 32));
//            } else {
//                make.width.equalTo(@(sizeFits.width + 24));
//            }
//        });
//    }];
}

- (void)p_updateSlidingTabViewRedDotWithListVC:(UIViewController *)viewController index:(NSInteger)index {
    @weakify(self);
    if ([viewController conformsToProtocol:@protocol(DVEAlbumListViewControllerProtocol)] &&
            [viewController respondsToSelector:@selector(albumListShowTabDotIfNeed:)]) {
        [((UIViewController <DVEAlbumListViewControllerProtocol> *) viewController) albumListShowTabDotIfNeed:^(BOOL showDot, UIColor *_Nonnull color) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self.slidingTabView showButtonDot:showDot index:index color:color];
            });
        }];
    }
}

#pragma mark - Bottom SelectedAssetsView

- (void)showSelectedAssetsViewIfNeed {

    if (self.viewModel.isFirstCreative) {
        return;
    }

    if (self.viewModel.hasSelectedAssets) {
        self.selectedAssetsView.hidden = NO;
        [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionLayoutSubviews animations:^{
            [self showSelectedAssetsView];
        }                completion:nil];
    }
}


- (void)hideSelectedAssetsViewIfNeed {

    if (self.vcType == DVEAlbumVCTypeForCutSame || self.vcType == DVEAlbumVCTypeForCutSameChangeMaterial || self.viewModel.isFirstCreative) {
        return;
    }

    if (!self.viewModel.hasSelectedAssets) {
        self.selectedAssetsView.hidden = YES;
        [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionLayoutSubviews animations:^{
            self.slidingViewController.view.frame = [self listViewControllerFrame];
            self.selectedAssetsView.frame = CGRectMake(0, self.viewWrapper.frame.size.height - [self p_selectedAssetsBottomViewHeight], self.view.bounds.size.width, kAlbumSelectedAssetsViewHeight);
        }                completion:nil];
    }
}

- (void)showSelectedAssetsBottomViewIfNeed {
    if (self.viewModel.hasSelectedAssets && self.selectedAssetsBottomView.hidden) {
        self.selectedAssetsBottomView.hidden = NO;
    }
}

- (void)hideSelectedAssetsBottomViewIfNeed {
    if (!self.viewModel.hasSelectedAssets && self.viewModel.inputData.shouldApplyAlbumFront) {
        self.selectedAssetsBottomView.hidden = YES;
    }
}

- (void)showSelectedAssetsView {
    if (self.viewModel.isFirstCreative) {
        return;
    }

    self.selectedAssetsView.frame = CGRectMake(0, self.viewWrapper.frame.size.height - kAlbumSelectedAssetsViewHeight - [self p_selectedAssetsBottomViewHeight], self.view.frame.size.width, kAlbumSelectedAssetsViewHeight);
    self.slidingViewController.view.frame = [self listViewControllerFrame];
}

- (DVEAlbumListViewController *)currentAlubmListViewController {
    DVEAlbumListViewController *listViewController;
    UIViewController *viewController = [self.slidingViewController controllerAtIndex:self.slidingViewController.selectedIndex];
    if ([viewController isKindOfClass:[DVEAlbumListViewController class]]) {
        listViewController = (DVEAlbumListViewController *) viewController;
    }

    return listViewController;
}

#pragma mark - DVEAlbumSlidingViewControllerDelegate

- (NSInteger)numberOfControllers:(DVEAlbumSlidingViewController *)slidingController {
    return self.viewModel.inputData.tabsInfo.count;
}

- (UIViewController *)slidingViewController:(DVEAlbumSlidingViewController *)slidingViewController viewControllerAtIndex:(NSInteger)index {
    if (index >= 0 && index < self.viewModel.inputData.tabsInfo.count) {
        DVEAlbumVCModel *model = [self.viewModel.inputData.tabsInfo objectAtIndex:index];
        UIViewController *viewController = model.listViewController;
        return viewController;
    }

    return nil;
}

- (void)slidingViewController:(DVEAlbumSlidingViewController *)slidingViewController didSelectIndex:(NSInteger)index {
    [self.viewModel updateCurrentSelectedIndex:index];
}

- (void)slidingViewController:(DVEAlbumSlidingViewController *)slidingViewController willTransitionToViewController:(UIViewController *)pendingViewController {
}

- (void)slidingViewController:(DVEAlbumSlidingViewController *)slidingViewController didFinishTransitionToIndex:(NSUInteger)index {
    [self.viewModel updateCurrentSelectedIndex:index];
}

- (BOOL)albumListVC:(UIViewController *)listVC shouldSelectAsset:(DVEAlbumAssetModel *)assetModel {
    NSString *format = TOCLocalizedString(@"creation_upload_limit", @"最多选择%d个素材");
    if (self.vcType == DVEAlbumVCTypeForCutSame) {
        if (self.viewModel.currentSelectedAssetsCount >= self.cutSameTemplateModel.fragmentCount) {
            [[DVEAlbumToastImpl new] showError:[NSString stringWithFormat:format, self.cutSameTemplateModel.fragmentCount]];
            return NO;
        }
    } else if (self.vcType == DVEAlbumVCTypeForCutSameChangeMaterial) {
        if (self.viewModel.currentSelectedAssetsCount >= 1) {
            [[DVEAlbumToastImpl new] showError:[NSString stringWithFormat:format, 1]];
            return NO;
        }
    } else {
    }
    return YES;
}

- (void)albumListVC:(UIViewController *)listVC didSelectedVideo:(DVEAlbumAssetModel *)assetModel {

    if (self.viewModel.hasSelectedAssets) {
        [self showSelectedAssetsViewIfNeed];
        [self showSelectedAssetsBottomViewIfNeed];
    } else {
        [self hideSelectedAssetsViewIfNeed];
        [self hideSelectedAssetsBottomViewIfNeed];
    }
    
    if (assetModel.isSelected) {
        self.selectAssetsCount += 1;
        [self.viewModel.currentSelectAssets addObject:assetModel];
    } else {
        self.selectAssetsCount -= 1;
        if ([self.viewModel.currentSelectAssets containsObject:assetModel]) {
            [self.viewModel.currentSelectAssets removeObject:assetModel];
        }
    }
    
    if (self.selectAssetsCount > 0) {
        NSString *format = NLELocalizedString(@"ck_selector_select_count", @"已选择%s个素材");
        self.selectedAssetsBottomView.titleLabel.text = [NSString stringWithFormat:format,[@(self.selectAssetsCount).stringValue cStringUsingEncoding:kCFStringEncodingUTF8]];
    } else {
        self.selectedAssetsBottomView.titleLabel.text = nil;
    }
    [self.selectedAssetsBottomView updateNextButtonWithStatus:self.selectAssetsCount > 0];
}

- (BOOL)checkVideoValidForCutSame:(DVEAlbumAssetModel *)assetModel {
    BOOL flag = YES;
    if ([self.selectedAssetsView respondsToSelector:@selector(checkVideoValidForCutSameTemplate:)]) {
        flag = [self.selectedAssetsView checkVideoValidForCutSameTemplate:assetModel];
    }
    return flag;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.albumDataModel.allAlbumModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DVEAlbumCategorylistCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DVEAlbumCategorylistCell"];
    if (indexPath.row < self.viewModel.albumDataModel.allAlbumModels.count) {
        DVEAlbumModel *albumModel = [self.viewModel.albumDataModel.allAlbumModels objectAtIndex:indexPath.row];
        [cell configCellWithAlbumModel:albumModel];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *uploadType = @"";
    NSString *contentType = @"";

    if (self.viewModel.currentResourceType == DVEAlbumGetResourceTypeImage &&
            self.viewModel.albumDataModel.photoSelectAssetsModels.count > 0) {
        uploadType = @"slideshow";
    }

    if (self.viewModel.currentResourceType == DVEAlbumGetResourceTypeImage) {
        contentType = @"photo";
    } else {
        contentType = @"video";
    }

    DVEAlbumModel *albumModel = [self.viewModel.albumDataModel.allAlbumModels objectAtIndex:indexPath.row];
    if (albumModel.localIdentifier) {
        [self.viewModel reloadAssetsDataWithAlbumCategory:albumModel completion:^{
        }];
    } else {
        [self.viewModel reloadAssetsDataWithAlbumCategory:nil completion:^{
        }];
    }

    [self didAlbumChanged:albumModel];
    [self dismissAlbumMenuViewAnimated:YES];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self prefetchAlbumList];
    });
}


#pragma mark - Preview

- (void)p_previewWithAsset:(DVEAlbumAssetModel *)model isFromBottomView:(BOOL)isFromBottomView resourceType:(DVEAlbumGetResourceType)resourceType {
    UIViewController *viewController = [self currentAlbumListViewController];
    if ([viewController isKindOfClass:[DVEAlbumListViewController class]]) {
        [((DVEAlbumListViewController *) viewController) didSelectedToPreview:model coverImage:model.coverImage fromBottomView:isFromBottomView];
    }
}

- (void)p_cropVideoWithAsseet:(DVEAlbumAssetModel *)assetModel fragmentModel:(DVEAlbumCutSameFragmentModel *)fragmentModel {
//    DVEVideoEditViewController *editViewController = [[DVEVideoEditViewController alloc] init];
//    editViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
//    editViewController.assetModel = assetModel;
//    editViewController.fragmentModel = fragmentModel;
//    [self presentViewController:editViewController animated:YES completion:nil];
}

#pragma mark - Action
#pragma mark -  goSettingStrip

- (void)goSettingStripCloseButtonClicked:(id)sender {
    [DVEAlbumGoSettingStrip setClosedByUser];
    self.configViewModel.shouldShowGoSettingStrip = NO;
}

- (void)goSettingStripLabelClicked {
    NSMutableDictionary *params = [@{} mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    });
}

#pragma mark - Button Action

- (void)clickGoToSettingsButton:(id)sender {
    NSMutableDictionary *params = [@{} mutableCopy];
    params[@"click_type"] = @"go_to_settings";
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    });
}

- (void)clickStartSettingsButton:(id)sender {
#ifdef __IPHONE_14_0 //xcode12
    NSMutableDictionary *params = [@{} mutableCopy];
    params[@"click_type"] = @"allow_access";
    if (@available(iOS 14.0, *)) {
        if ([DVEAlbumDeviceAuth isiOS14PhotoNotDetermined]) {
            [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    switch (status) {
                        case PHAuthorizationStatusLimited: {
                            [self p_handleAuthWithShowGoSettingStrip:YES];
                            params[@"click_type"] = @"select_photo";
                            break;
                        }
                        case PHAuthorizationStatusAuthorized: {
                            [self p_handleAuthWithShowGoSettingStrip:NO];
                            params[@"click_type"] = @"allow_all_photo";
                            break;
                        }
                        case PHAuthorizationStatusNotDetermined:
                        case PHAuthorizationStatusRestricted: {
                            break;
                        }

                        case PHAuthorizationStatusDenied: {
                            [self.requestAccessView removeFromSuperview];
                            [self setupDenyAccessView];
                            [self.viewWrapper layoutIfNeeded];
                            self.viewModel.hasRequestAuthorizationForAccessLevel = NO;
                            params[@"click_type"] = @"not_allow";
                            break;
                        }
                        default:
                            break;
                    }
                });
            }];
        } else if ([DVEAlbumDeviceAuth isiOS14PhotoLimited]) {
            /** When we request for photo library access authorization (with a callback handler), the system will show a toast with three options. If the user chooses `select photos` (`选择照片` in CN), a PHPicker will be presented for photo selection.
             * The user may select any (or none) photos on PHPicker and perform three actions afterwards:
             * 1. Click complete button (on the top right corner).
             * 2. Click cancel button (on the top left corner).
             * 3. Directly swipe down to dismiss the PHPicker.
             * For action 3, our callback will not be executed, even though the user did grant us with Limited Photo Access permission, and we are handling this situation here.
             */
            [self p_handleAuthWithShowGoSettingStrip:YES];
            params[@"click_type"] = @"select_photo";
        }
    }
#endif
}

- (void)p_handleAuthWithShowGoSettingStrip:(BOOL)needShow {
    [self.requestAccessView removeFromSuperview];
    [self addPhotoLibraryChangeObserver];
    [self prefetchAlbumList];
    if ([self.currentAlbumListViewController respondsToSelector:@selector(requestAuthorizationCompleted)]) {
        [self.currentAlbumListViewController requestAuthorizationCompleted];
    }
    if ([self.delegate respondsToSelector:@selector(albumViewControllerDidRequestPhotoAuthorization)]) {
        [self.delegate albumViewControllerDidRequestPhotoAuthorization];
    }
    [self.viewWrapper layoutIfNeeded];
    self.viewModel.hasRequestAuthorizationForAccessLevel = YES;
    self.configViewModel.shouldShowGoSettingStrip = needShow;
}


#pragma mark - Cancel Button

- (void)cancelBtnClicked:(UIButton *)button {
    TOCBLOCK_INVOKE(self.dismissBlock);

    if ([[self.navigationController viewControllers] firstObject] == self || !self.navigationController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Next Button

- (void)nextActionForCutSame:(id)sender {
    [self.viewModel updateTimeNextButtonPress:CFAbsoluteTimeGetCurrent()];
//    if (self.cutSameTemplateModel && self.viewModel.currentSelectedAssetsCount < self.cutSameTemplateModel.fragmentCount) {
//        return;
//    }

    [self handleAssetsForCutSame:self.viewModel.currentSelectAssets];
}

#pragma mark - Album List TableView

- (BOOL)isAlbumMenuViewVisible {
    return nil != self.albumListTableView;
}

- (void)showAlbumMenuViewOnView:(UIView *)view frame:(CGRect)frame animated:(BOOL)animated animationWillBeginBlock:(void (^)(BOOL success))beginBlock {
    if (self.albumListTableView) {
        TOCBLOCK_INVOKE(beginBlock, NO);
        return;
    }
    self.albumListTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.albumListTableView.backgroundColor = TOCResourceColor(TOCUIColorConstBGContainer);
    [self.albumListTableView registerClass:[DVEAlbumCategorylistCell class] forCellReuseIdentifier:@"DVEAlbumCategorylistCell"];
    self.albumListTableView.delegate = self;
    self.albumListTableView.dataSource = self;
    self.albumListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.albumListTableView.tableFooterView = [UIView new];
    self.albumListTableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, frame.origin.y, TOC_SCREEN_WIDTH, 1.0 / TOC_SCREEN_SCALE)];
    line.backgroundColor = TOCResourceColor(TOCUIColorLineSecondary2);
    self.albumTopLine = line;

    [view addSubview:self.albumListTableView];
    [view addSubview:line];
    if (beginBlock) {
        beginBlock(YES);
    }
    self.albumListTableView.transform = CGAffineTransformMakeTranslation(0, -self.view.bounds.size.height);
    [UIView animateWithDuration:0.25f animations:^{
        self.albumListTableView.transform = CGAffineTransformIdentity;
        self.topNavView.leftCancelButton.alpha = 0.0f;
    }];
}

- (void)dismissAlbumMenuViewAnimated:(BOOL)animated {
    if (self.albumListTableView) {
        [UIView animateWithDuration:0.25f animations:^{
            self.albumListTableView.transform = CGAffineTransformMakeTranslation(0, -self.view.bounds.size.height);
            self.topNavView.leftCancelButton.alpha = 1.0f;
        }                completion:^(BOOL finished) {
            [self.albumListTableView removeFromSuperview];
            self.albumListTableView = nil;
        }];
    }
    if (self.albumTopLine) {
        [self.albumTopLine removeFromSuperview];
    }
}

- (void)didAlbumChanged:(DVEAlbumModel *)albumModel {
    if (albumModel) {
        //do alp_disableLocalizations
        self.topNavView.selectAlbumButton.leftLabel.text = albumModel.name;
    } else {
        //do alp_disableLocalizations
        self.topNavView.selectAlbumButton.leftLabel.text = @"im_all_photos";
    }
    self.topNavView.selectAlbumButton.rightImageView.layer.transform = CATransform3DIdentity;
}

#pragma mark - Utils

- (CGFloat)albumSlidingOffsetY {
    CGFloat offsetY = 5;
    return offsetY;
}

- (CGRect)listViewControllerFrame {

    CGFloat offset = [self p_selectedAssetsBottomViewHeight] + kAlbumSelectedAssetsViewHeight - 60;
    CGFloat height = self.viewModel.inputData.maxPictureSelectionCount > 1 ? self.viewWrapper.frame.size.height - [self albumSlidingOffsetY] - offset : self.viewWrapper.frame.size.height;
    return CGRectMake(0, [self albumSlidingOffsetY], TOC_SCREEN_WIDTH, height);
}

- (BOOL)shouldShowAlbumTabView {
    if (self.viewModel.inputData.albumTabViewHidden || self.viewModel.inputData.tabsInfo.count == 1) {
        return NO;
    }
    return YES;
}

#pragma mark - Setter

- (void)setNeedEnablePhotoToVideo:(BOOL)needEnablePhotoToVideo {
    [self.viewModel updateNeedEnablePhotoToVideo:needEnablePhotoToVideo];
}

#pragma mark - Getter

- (DVEAlbumSlidingViewController *)slidingViewController {
    if (!_slidingViewController) {
        _slidingViewController = [[DVEAlbumSlidingViewController alloc] init];
        _slidingViewController.automaticallyAdjustsScrollViewInsets = NO;
        _slidingViewController.slideEnabled = YES;
        _slidingViewController.delegate = self;
        _slidingViewController.tabbarView = self.slidingTabView;
    }
    return _slidingViewController;
}

- (DVEAlbumSlidingTabbarView *)slidingTabView {
    if (!_slidingTabView) {
        NSArray *titlesArray = self.viewModel.inputData.titles;

        _slidingTabView = [[DVEAlbumSlidingTabbarView alloc] initWithFrame:CGRectMake(0, 0, TOC_SCREEN_WIDTH-120, 60) buttonStyle:SCIFSlidingTabButtonStyleText dataArray:titlesArray.copy selectedDataArray:titlesArray.copy];
        _slidingTabView.shouldShowTopLine = NO;
        _slidingTabView.backgroundColor = TOCResourceColor(TOCUIColorConstBGContainer);
        [_slidingTabView configureButtonTextColor:TOCResourceColor(TOCUIColorConstTextTertiary) selectedTextColor:TOCResourceColor(TOCUIColorConstTextPrimary)];
        _slidingTabView.shouldShowSelectionLine = NO;
    }
    return _slidingTabView;
}

- (DVEAlbumVCNavView *)topNavView {
    if (!_topNavView) {
        _topNavView = [[DVEAlbumVCNavView alloc] initWithVCType:self.viewModel.inputData.vcType];
        _topNavView.frame = CGRectMake(0, 0, self.view.frame.size.width, [self p_albumNavHeight]);
        [_topNavView.selectAlbumButton setHidden:YES];
        [_topNavView.leftCancelButton addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.slidingTabView.frame = CGRectInset(_topNavView.bounds, 60, 0);
        [_topNavView addSubview:self.slidingTabView];
    }
    if (self.viewModel.isFirstCreative) {
        _topNavView.hidden = YES;
    }
    return _topNavView;
}

- (DVEAlbumVCType)vcType {
    return self.viewModel.inputData.vcType;
}

- (DVEAlbumTemplateModel *)cutSameTemplateModel {
    return self.viewModel.inputData.cutSameTemplateModel;
}

- (DVEAlbumCutSameFragmentModel *)singleFragment {
    return self.viewModel.inputData.singleFragment;
}

- (DVEAlbumConfigViewModel *)configViewModel {
    return self.viewModel.configViewModel;
}

- (DVEAlbumRequestAccessView *)requestAccessView {
    if (!_requestAccessView) {
        CGRect frame = CGRectMake(0, self.slidingTabView.frame.size.height, TOC_SCREEN_WIDTH, self.viewWrapper.frame.size.height - kAlbumTitleTabHight);
        _requestAccessView = [[DVEAlbumRequestAccessView alloc] initWithFrame:frame];
        [_requestAccessView.startSettingButton addTarget:self action:@selector(clickStartSettingsButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _requestAccessView;
}

- (DVEAlbumDenyAccessView *)denyAccessView {
    if (!_denyAccessView) {
        _denyAccessView = [[DVEAlbumDenyAccessView alloc] initWithFrame:self.requestAccessView.frame];
        [_denyAccessView.startSettingButton addTarget:self action:@selector(clickGoToSettingsButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _denyAccessView;
}

#pragma mark - Button Action

- (void)handleAssetsForCutSame:(NSMutableArray<DVEAlbumAssetModel *> *)models {
    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
    [models enumerateObjectsUsingBlock:^(DVEAlbumAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [assets addObject:obj.asset];
    }];
    
    if (self.confirmBlock) {
        self.confirmBlock(assets);
    }
}


#pragma mark - Private

- (void)p_updateBottomViewWithStatus:(BOOL)singleSelected {
    if (singleSelected) {
        [self.selectedAssetsBottomView removeFromSuperview];
    }
}

@end

