//
//  DVEAlbumPreviewAndSelectController.m
//  CameraClient
//
//  Created by bytedance on 2020/7/17.
//

#import "UIView+DVEAlbumMasonry.h"
#import "DVEAlbumPreviewAndSelectController.h"
#import "DVEAlbumPhotoPreviewAndSelectCell.h"
#import "DVEAlbumVideoPreviewAndSelectCell.h"
#import "DVEAlbumZoomTransition.h"
#import "DVEAlbumMacros.h"
#import "DVEAlbumGradientView.h"
#import "UIDevice+DVEAlbumHardware.h"
#import "DVEAlbumLoadingViewProtocol.h"
#import "DVEAlbumToastImpl.h"
#import "DVEAlbumLanguageProtocol.h"
#import "DVEAlbumResourceUnion.h"
//#import "TOCMonitorProtocol.h"
#import "DVEAlbumResponder.h"
#import "UIImage+DVEAlbumAdditions.h"
#import <KVOController/KVOController.h>
#import <Masonry/Masonry.h>
#import "DVEAlbumLoadingViewDefaultImpl.h"

@interface DVEAlbumPreviewAndSelectController () <UICollectionViewDelegate, UICollectionViewDataSource, DVEAlbumZoomTransitionInnerContextProvider>

@property (nonatomic, strong) NSValue *videoSize;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign, readwrite) NSInteger currentIndex;
@property (nonatomic, strong, readwrite) DVEAlbumAssetModel *currentAssetModel;
//@property (nonatomic, strong, readwrite) DVEAlbumAssetModel *exitAssetModel;
//@property (nonatomic, assign, readwrite) BOOL currentAssetModelSelected;

@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) BOOL showLeftToast;
@property (nonatomic, assign) BOOL showRightToast;
//@property (nonatomic, assign) BOOL fromBottomView;

@property (nonatomic, assign) DVEAlbumGetResourceType resourceType;

@property (nonatomic, strong) UIView<DVEAlbumTextLoadingViewProtcol> *loadingView;

@property (nonatomic, strong) UIView *selectPhotoView;
@property (nonatomic, strong) DVEAlbumGradientView *selectedGradientView;
@property (nonatomic, strong) UIImageView *unCheckImageView;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UIImageView *numberBackGroundImageView;
@property (nonatomic, strong) UILabel *selectHintLabel;

@property (nonatomic, assign) BOOL selectPhotoUserInteractive;

//monitor
@property (nonatomic, assign) BOOL couldTrack;
@property (nonatomic, assign) BOOL errorOccur;

@property (nonatomic, weak) DVEAlbumViewModel *viewModel;

@property (nonatomic, strong) DVEAlbumAssetDataModel *assetDataModel;

// 底部状态栏
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) DVEImportMaterialSelectBottomView *selectedAssetsBottomView;
@property(nonatomic, strong) DVEImportMaterialSelectView *selectedAssetsView;

@end

@implementation DVEAlbumPreviewAndSelectController

//-----由SMCheckProject工具删除-----
//- (instancetype)initWithViewModel:(DVEAlbumViewModel *)viewModel anchorAssetModel:(DVEAlbumAssetModel *)anchorAssetModel
//{
//    self = [super init];
//    if (self) {
//        [self setupWithViewModel:viewModel anchorAssetModel:anchorAssetModel fromBottomView:NO];
//    }
//    
//    return self;
//}

- (instancetype)initWithViewModel:(DVEAlbumViewModel *)viewModel anchorAssetModel:(DVEAlbumAssetModel *)anchorAssetModel fromBottomView:(BOOL)fromBottomView
{
    self = [super init];
    if (self) {
//        self.fromBottomView = fromBottomView;
        [self setupWithViewModel:viewModel anchorAssetModel:anchorAssetModel fromBottomView:fromBottomView];
    }
    
    return self;
}

- (BOOL)enableOptimizeRecordAlbum
{
    return NO;
}

- (void)setupWithViewModel:(DVEAlbumViewModel *)viewModel anchorAssetModel:(DVEAlbumAssetModel *)anchorAssetModel fromBottomView:(BOOL)fromBottomView
{
    self.checkMarkSelectedStyle = viewModel.isCutSame || viewModel.isCutSameChangeMaterial;
    self.originDataSource = viewModel.currentSourceAssetModels;
    if (fromBottomView) {
        self.originDataSource = [viewModel.currentSelectAssetModels mutableCopy];
    }
    
    self.selectedAssetModelArray = viewModel.currentSelectAssetModels;
    self.currentAssetModel = anchorAssetModel;
    if ([self enableOptimizeRecordAlbum]) {
        self.assetDataModel = [viewModel currentAssetDataModel];
        [self.assetDataModel configDataWithPreviewFilterBlock:^BOOL(PHAsset *asset) {
            PHAsset *phAsset = asset;
            CGFloat aspectRatio = (CGFloat)phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
            if (PHAssetMediaTypeImage == phAsset.mediaType && (aspectRatio >= 2.2 || aspectRatio <= 1.0 / 2.2)) {
                return NO;
            }
            return YES;
        }];
        self.currentIndex = [self.assetDataModel previewIndexOfObject:self.currentAssetModel];
        if ([self.assetDataModel removePreviewInvalidAssetForPostion:self.currentIndex]) {
            self.currentIndex = [self.assetDataModel previewIndexOfObject:self.currentAssetModel];
        }
    } else {
        self.currentIndex = [self.originDataSource indexOfObject:self.currentAssetModel];
    }
    if (self.currentIndex == NSNotFound) {
        self.currentIndex = 0;
    }
    self.viewModel = viewModel;
    self.resourceType = viewModel.currentResourceType;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
//    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
//    [self.view addGestureRecognizer:tapGes];
    
    [self.view addSubview:self.collectionView];
    self.backButton = [[UIButton alloc] init];
    [self.view addSubview:self.backButton];
    DVEAlbumMasMaker(self.backButton, {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(15);
        } else {
            make.top.equalTo(self.view).offset(16);
        }
        make.left.equalTo(self.view).offset(16);
        make.width.equalTo(@(24));
        make.height.equalTo(@(24));
    });
    [self.backButton setImage:TOCResourceImage(@"ic_titlebar_back_white") forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.layer.zPosition = 1000;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    self.videoSize = @(CGSizeMake(self.currentAssetModel.asset.pixelWidth, self.currentAssetModel.asset.pixelHeight));
    if (self.currentAssetModel.mediaType == DVEAlbumAssetModelMediaTypeVideo) {
         [self setUpPlayer:self.currentAssetModel];
    }
    [self setUpSelectView];
    // 底部栏
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 169)];
    self.bottomView.backgroundColor = TOCResourceColor(TOCColorBGCreation);
    [self.view addSubview:self.bottomView];
    DVEAlbumMasMaker(self.bottomView, {
        make.bottom.left.right.equalTo(self.view);
//        make.height.equalTo(@(170));
    });
    [self setupSelectedBottomViewForMixedUploading];
    [self setupSelectedViewForMixedUploading];
    //----------------
    //send message to gallerybasevc
    [self willChangeValueForKey:@"currentAssetModel"];
    [self didChangeValueForKey:@"currentAssetModel"];
    
    [self updatePhotoSelected:self.currentAssetModel greyMode:self.greyMode];
    [self dealWithPhotoChange];
    
    [self bindViewModel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    TOCBLOCK_INVOKE(self.willDismissBlock, self.currentAssetModel);
    
    [self.avPlayer pause];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self playAfterCheck];
    [self.view bringSubviewToFront:self.backButton];
}


- (void)bindViewModel
{
    @weakify(self);
    [self.KVOController observe:self.viewModel.albumDataModel keyPath:@"photoSelectAssetsModels" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        if (self.resourceType == DVEAlbumGetResourceTypeImage && self.resourceType == self.viewModel.currentResourceType) {
            [self reloadSelectedStateWithGrayMode:self.viewModel.hasSelectedMaxCount];
        }
    }];

    [self.KVOController observe:self.viewModel.albumDataModel keyPath:@"videoSelectAssetsModels" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        if (self.resourceType == DVEAlbumGetResourceTypeVideo && self.resourceType == self.viewModel.currentResourceType) {
            [self reloadSelectedStateWithGrayMode:self.viewModel.hasSelectedMaxCount];
        }
    }];

    [self.KVOController observe:self.viewModel.albumDataModel keyPath:@"mixedSelectAssetsModels" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        if (self.resourceType == DVEAlbumGetResourceTypeImageAndVideo && self.resourceType == self.viewModel.currentResourceType) {
            [self reloadSelectedStateWithGrayMode:self.viewModel.hasSelectedMaxCount];
        }
        // Update bottom view
//        self.selectedAssetsView.assetModelArray = self.viewModel.currentSelectAssetModels;
//        [self.selectedAssetsView reloadSelectView];
        [self updateNextButtonTitle];
    }];

//    [self.KVOController observe:self.viewModel.albumDataModel keyPath:@"mixedSelectAssetsModels" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
//        @strongify(self);
////        self.selectedAssetsView.assetModelArray = self.viewModel.currentSelectAssetModels;
////        [self.selectedAssetsView reloadSelectView];
//        [self updateNextButtonTitle];
//    }];
}

- (void)setUpSelectView{
    _selectedGradientView = [[DVEAlbumGradientView alloc] init];
//    _selectedGradientView.gradientLayer.startPoint = CGPointMake(0, 0);
//    _selectedGradientView.gradientLayer.endPoint = CGPointMake(0, 1);
//    _selectedGradientView.gradientLayer.locations = @[@0, @1];
//    _selectedGradientView.gradientLayer.colors = @[(__bridge id)TOCResourceColor(TOCUIColorSDSecondary).CGColor,(__bridge id)[UIColor clearColor].CGColor];
    _selectedGradientView.backgroundColor = TOCResourceColor(TOCColorBGCreation);
    [self.view addSubview:_selectedGradientView];

    DVEAlbumMasMaker(_selectedGradientView, {
        make.leading.top.trailing.mas_equalTo(self.view);
//        make.height.mas_equalTo(@(94));
    });

    // 添加标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 15)];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = TOCResourceColor(TOCUIColorTextPrimary);
    titleLabel.text = TOCLocalizedString(@"ck_preview", @"预览");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [_selectedGradientView addSubview:titleLabel];
    DVEAlbumMasMaker(titleLabel, {
        make.centerX.equalTo(_selectedGradientView);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(18);
        } else {
            make.top.equalTo(self.view).offset(18);
        }
        make.height.equalTo(@(20));
        make.bottom.equalTo(_selectedGradientView.mas_bottom).offset(-14);
    });
    return;
    // 移动选择按钮到bottomview
    UIView *selectPhotoView = [[UIView alloc] init];
    self.selectPhotoUserInteractive = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPhotoButtonClick:)];
    [selectPhotoView addGestureRecognizer:tapGesture];
    [_selectedGradientView addSubview:selectPhotoView];
    DVEAlbumMasMaker(selectPhotoView, {
        make.width.equalTo(@(80));
        make.height.equalTo(@(40));
        make.right.equalTo(self.view.mas_right);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.view.mas_top);
        }
    });
    _selectPhotoView = selectPhotoView;
    
    CGFloat checkImageHeight = 22;
    _unCheckImageView = [[UIImageView alloc] initWithImage:TOCResourceImage(@"icon_album_unselect")];
    [_selectPhotoView addSubview:_unCheckImageView];
    DVEAlbumMasMaker(_unCheckImageView, {
        make.right.equalTo(_selectPhotoView.mas_right).offset(-16);
        make.top.equalTo(_selectPhotoView.mas_top).offset(16);
        make.width.height.equalTo(@(checkImageHeight));
    });
    
    if (self.checkMarkSelectedStyle) {
        _numberBackGroundImageView = [[UIImageView alloc] initWithImage:TOCResourceImage(@"icon_album_select")];
    } else {
        UIImage *cornerImage = [UIImage acc_imageWithSize:CGSizeMake(checkImageHeight, checkImageHeight) cornerRadius:checkImageHeight * 0.5 backgroundColor:TOCResourceColor(TOCUIColorConstTextInverse)];
        _numberBackGroundImageView = [[UIImageView alloc] initWithImage:cornerImage];
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.font = [UIFont systemFontOfSize:13];
        _numberLabel.textColor = TOCResourceColor(TOCUIColorConstTextPrimary);
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        [_numberBackGroundImageView addSubview:_numberLabel];
        DVEAlbumMasMaker(_numberLabel, {
            make.edges.equalTo(_numberBackGroundImageView);
        });
    }
    
    [_selectPhotoView addSubview:_numberBackGroundImageView];
    DVEAlbumMasMaker(_numberBackGroundImageView, {
        make.left.right.top.bottom.equalTo(self.unCheckImageView);
    });
    
    _selectHintLabel = [[UILabel alloc] init];
    _selectHintLabel.font = [UIFont systemFontOfSize:15];;
    
    _selectHintLabel.textColor = TOCResourceColor(TOCUIColorIconPrimary);
    [_selectPhotoView addSubview:_selectHintLabel];
    
    DVEAlbumMasMaker(_selectHintLabel, {
        make.top.equalTo(self.unCheckImageView.mas_top);
        make.bottom.equalTo(self.unCheckImageView.mas_bottom);
        make.right.equalTo(self.unCheckImageView.mas_left).offset(-12);
        make.width.lessThanOrEqualTo(@(200));
    });

}

// 底部已选择资源
- (void)setupSelectedBottomViewForMixedUploading
{
    self.selectedAssetsBottomView = [[DVEImportMaterialSelectBottomView alloc] init];//[DVE_SelectedAssets_Obj selectedAssetsBottomView];
    [self.selectedAssetsBottomView.nextButton addTarget:self
                                                 action:@selector(onConfirm)
                                       forControlEvents:UIControlEventTouchUpInside];
    //[self.selectedAssetsBottomView.addButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.selectPhotoUserInteractive = YES;
    CGFloat baseViewHeight = 52.0f;
    baseViewHeight += TOC_IPHONE_X_BOTTOM_OFFSET;

    self.selectedAssetsBottomView.frame = CGRectMake(0, baseViewHeight, self.view.bounds.size.width, baseViewHeight);
    [self.bottomView addSubview:self.selectedAssetsBottomView];

    [self.selectedAssetsBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.bottomView);
        make.height.equalTo(@(baseViewHeight));
    }];
    [self updateNextButtonTitle];
}

- (void)onConfirm {
    @weakify(self);
    [self dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        [self.viewModel onNext];
    }];
}


- (void)setupSelectedViewForMixedUploading {

    self.selectedAssetsView = [[DVEImportMaterialSelectView alloc] init];

    self.selectedAssetsView = [[DVEImportSelectView alloc] init];//[DVE_SelectedAssets_Obj selectedAssetsView];

//    if ([self.selectedAssetsView respondsToSelector:@selector(setTemplateModel:)]) {
//        self.selectedAssetsView.templateModel = self.viewModel.inputData.cutSameTemplateModel;
//    }
//    if ([self.selectedAssetsView respondsToSelector:@selector(setSingleFragmentModel:)]) {
//        self.selectedAssetsView.singleFragmentModel = self.viewModel.inputData.singleFragment;
//    }
    self.selectedAssetsView.albumViewModel = self.viewModel;
    self.selectedAssetsView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 88.0f);
    self.selectedAssetsView.backgroundColor = TOCResourceColor(TOCColorBGCreation);
    self.selectedAssetsView.assetModelArray = self.viewModel.currentSelectAssetModels;
    @weakify(self);
    self.selectedAssetsView.deleteAssetModelBlock = ^(DVEAlbumAssetModel *_Nonnull assetModel) {
        @strongify(self);
        [self.viewModel didUnselectedAsset:assetModel];
//        [self hideSelectedAssetsBottomViewIfNeed];
///  删除照片后, 更新listVC
//        DVEAlbumListViewController *listVC = [self currentAlubmListViewController];
//        [listVC reloadVisibleCell];
        [self updateNextButtonTitle];
    };

    if ([self.selectedAssetsView respondsToSelector:@selector(setTouchAssetModelBlock:)]) {
        self.selectedAssetsView.touchAssetModelBlock = ^(DVEAlbumAssetModel *_Nonnull assetModel, NSInteger index) {
            @strongify(self);
            if (self.resourceType == DVEAlbumGetResourceTypeImage && assetModel.mediaType != DVEAlbumAssetModelMediaTypePhoto) {
                // 当前只能跳转到照片
                [[DVEAlbumToastImpl new] showError:TOCLocalizedString(@"share_img_from_sys_size_error", @"当前分类仅支持预览图片")];
                return;
            }
            if (self.resourceType == DVEAlbumGetResourceTypeVideo && assetModel.mediaType != DVEAlbumAssetModelMediaTypeVideo) {
                // 只能跳转到视频
                [[DVEAlbumToastImpl new] showError:TOCLocalizedString(@"share_img_from_sys_size_error", @"当前分类仅支持预览视频")];
                return;
            }
            if (DVEAlbumAssetModelMediaTypePhoto == assetModel.mediaType) {
                PHAsset *phAsset = assetModel.asset;
                CGFloat aspectRatio = (CGFloat) phAsset.pixelWidth / (CGFloat) phAsset.pixelHeight;
                if (aspectRatio >= 2.2 || aspectRatio <= 1.0 / 2.2) {
                    [[DVEAlbumToastImpl new] showError:TOCLocalizedString(@"share_img_from_sys_size_error", @"暂不支持该图片尺寸")];
                    return;
                }
                [DVEPhotoManager getUIImageWithPHAsset:phAsset networkAccessAllowed:NO progressHandler:^(CGFloat progress, NSError *_Nonnull error, BOOL *_Nonnull stop, NSDictionary *_Nonnull info) {

                }                           completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    @strongify(self)
                    if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue]) {
                        NSTimeInterval icloudFetchStart = CFAbsoluteTimeGetCurrent();
                        [DVEPhotoManager getOriginalPhotoDataFromICloudWithAsset:assetModel.asset progressHandler:^(CGFloat progress, NSError *_Nonnull error, BOOL *_Nonnull stop, NSDictionary *_Nonnull info) {

                        }                                             completion:^(NSData *data, NSDictionary *info) {
                            if (data) {
                                @strongify(self);
//                                [self trackPhotoiCloud:icloudFetchStart size:[data length]];
                            }
                        }];
                        [[DVEAlbumToastImpl new] show:TOCLocalizedString(@"com_mig_syncing_the_picture_from_icloud", @"该图片正在从iCloud同步，请稍后再试")];
                    } else {
                        if (!isDegraded && photo) {
                            NSInteger index = [self indexForAsset:assetModel];
                            if (index == NSNotFound) {
                                return;
                            }
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                            UICollectionViewCell *cell = [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
                            [self collectionView:self.collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
                            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                            [self updatePhotoSelected:assetModel greyMode:NO];
                            self.currentAssetModel = assetModel;
                            // 点击底部照片
//                            [self p_previewWithAsset:assetModel isFromBottomView:YES resourceType:DVEAlbumGetResourceTypeImageAndVideo];
                        }
                    }
                }];
            } else if (DVEAlbumAssetModelMediaTypeVideo == assetModel.mediaType) {
                NSInteger index = [self indexForAsset:assetModel];
                if (index == NSNotFound) {
                    return;
                }
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                UICollectionViewCell *cell = [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
                [self collectionView:self.collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
                self.currentAssetModel = assetModel;
                self.currentIndex = index;
//                self.videoSize = @(CGSizeMake(self.currentAssetModel.asset.pixelWidth, self.currentAssetModel.asset.pixelHeight));
                [self setUpPlayer:assetModel];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5), dispatch_get_main_queue(), ^{
                    [self playAfterCheck];
                });

//                [self p_previewWithAsset:assetModel isFromBottomView:YES resourceType:DVEAlbumGetResourceTypeImageAndVideo];
            }
        };
    }
    [self.bottomView addSubview:self.selectedAssetsView];
    [self.selectedAssetsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.bottomView);
        make.bottom.equalTo(self.selectedAssetsBottomView.mas_top);
        make.height.equalTo(@88.f);
    }];
}

- (NSInteger)indexForAsset:(DVEAlbumAssetModel *)assetModel {
    NSInteger index = NSNotFound;
    for (NSInteger i=0; i < self.originDataSource.count; i++) {
        if (self.originDataSource[i].asset == assetModel.asset) {
            index = i;
        }
    }
    return index;
}

- (void)updateNextButtonTitle
{
    BOOL buttonEnable = NO;
    NSString *buttonTitle = @"";
    NSInteger totalSelectedAssetCount = self.viewModel.currentSelectAssetModels.count;

    if (self.viewModel.isCutSame) {
        buttonEnable = YES;
        buttonTitle = TOCLocalizedString(@"ck_add", @"添加");

        if (totalSelectedAssetCount == self.viewModel.inputData.cutSameTemplateModel.fragmentCount) {
            self.selectedAssetsBottomView.nextButton.backgroundColor = TOCResourceColor(TOCColorPrimary);
            [self.selectedAssetsBottomView.nextButton setTitleColor:TOCResourceColor(TOCColorTextPrimary) forState:UIControlStateNormal];
            //[self.selectedAssetsBottomView.addButton setImage:TOCResourceImage(@"icon_album_add_grey") forState:UIControlStateNormal];
        } else {
            self.selectedAssetsBottomView.nextButton.backgroundColor = TOCResourceColor(TOCColorTextReverse4);
            [self.selectedAssetsBottomView.nextButton setTitleColor:TOCResourceColor(TOCColorTextPrimary) forState:UIControlStateNormal];
            //[self.selectedAssetsBottomView.addButton setImage:TOCResourceImage(@"icon_album_add") forState:UIControlStateNormal];
        }
    } else if (self.viewModel.isCutSameChangeMaterial) {
        buttonTitle = TOCLocalizedString(@"ck_add", @"添加");

        if (totalSelectedAssetCount == 1) {
            buttonEnable = YES;
            self.selectedAssetsBottomView.nextButton.backgroundColor = TOCResourceColor(TOCColorPrimary);
            [self.selectedAssetsBottomView.nextButton setTitleColor:TOCResourceColor(TOCColorTextPrimary) forState:UIControlStateNormal];
            //[self.selectedAssetsBottomView.addButton setImage:TOCResourceImage(@"icon_album_add_grey") forState:UIControlStateNormal];
        } else {
            buttonEnable = NO;
            self.selectedAssetsBottomView.nextButton.backgroundColor = TOCResourceColor(TOCColorTextReverse4);
            [self.selectedAssetsBottomView.nextButton setTitleColor:TOCResourceColor(TOCColorTextPrimary) forState:UIControlStateNormal];
            //[self.selectedAssetsBottomView.addButton setImage:TOCResourceImage(@"icon_album_add") forState:UIControlStateNormal];
        }
    }

    [self.selectedAssetsBottomView.nextButton setTitle:buttonTitle forState:UIControlStateNormal];
    [self.selectedAssetsBottomView updateNextButtonWithStatus:YES];

//    if (!self.viewModel.isCutSame || self.viewModel.isCutSameChangeMaterial) {
//        UIColor *buttonBgColor = buttonEnable ? TOCResourceColor(TOCColorPrimary) : TOCResourceColor(TOCColorTextPrimary);
//        self.selectedAssetsBottomView.nextButton.backgroundColor = buttonBgColor;
//    }

//    CGSize sizeFits = [self.selectedAssetsBottomView.nextButton sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
//    [UIView animateWithDuration:0.35f animations:^{
//        DVEAlbumMasUpdate(self.selectedAssetsBottomView.nextButton, {
//            make.width.equalTo(@(sizeFits.width + 32));
//        });
//    }];
}

#pragma mark - avplayer control

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.isDragging = YES;
    self.selectPhotoUserInteractive = NO;
    self.showLeftToast = NO;
    self.showRightToast = NO;
    [self.avPlayer pause];
}

- (void)dealWithPhotoChange{
    @weakify(self);
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
        object:nil
         queue:[NSOperationQueue mainQueue]
    usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self);
        if ([self originDataSourceCount] == 0) {
            [self back:nil];
            return ;
        } else {
            [self.collectionView reloadData];
            if (![self containsAssetModel:self.currentAssetModel]){
                if (self.currentIndex < [self originDataSourceCount] && self.currentIndex >= 0) {
                   
                } else {
                    self.currentIndex = [self originDataSourceCount] - 1;
                }
                self.currentAssetModel = [self assetModelForIndex:self.currentIndex];
                [self.collectionView setContentOffset:CGPointMake(self.currentIndex * self.collectionView.bounds.size.width, 0)];
                if (self.currentAssetModel.mediaType == DVEAlbumAssetModelMediaTypeVideo) {
                    [self setUpPlayer:self.currentAssetModel];
                }
            
                [self updatePhotoSelected:self.currentAssetModel greyMode:self.greyMode];
            }
            
        }
    }];
}

- (NSInteger)originDataSourceCount
{
    if ([self enableOptimizeRecordAlbum]) {
        return [self.assetDataModel previewNumberOfObject];
    } else {
        return self.originDataSource.count;
    }
}

- (DVEAlbumAssetModel *)assetModelForIndex:(NSInteger)index
{
    DVEAlbumAssetModel *assetModel;
    if ([self enableOptimizeRecordAlbum]) {
        assetModel = [self.assetDataModel previewObjectIndex:index];
    } else {
        assetModel = self.originDataSource[index];
    }
    // 需计算currentIndex
    assetModel.cellIndex = self.currentIndex;
    return assetModel;
}

- (BOOL)containsAssetModel:(DVEAlbumAssetModel *)object
{
    if (!object) {
        return NO;
    }
    if ([self enableOptimizeRecordAlbum]) {
        return [self.assetDataModel previewContainsObject:object];
    } else {
        return [self.originDataSource containsObject:object];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.loadingView dismiss];
    if (self.isDragging) {
        if (scrollView.contentOffset.x < -50 && self.showLeftToast == NO) {
            NSString *toastStr = @"";
            if (self.viewModel.enableMixedUploading) {
                toastStr = TOCLocalizedString(@"full_screen_firstitem_tips",@"这是第一个素材哦");
            } else {
                switch (self.resourceType) {
                    case DVEAlbumGetResourceTypeImage:
                        toastStr = TOCLocalizedString(@"full_screen_firstphoto_tips",@"这是第一张图片哦");
                        break;
                    case DVEAlbumGetResourceTypeVideo:
                        toastStr = TOCLocalizedString(@"full_screen_firstvideo_tips",@"这是第一个视频哦");
                        break;
                    default:
                        toastStr = TOCLocalizedString(@"full_screen_firstitem_tips",@"这是第一个素材哦");
                        break;
                }
            }
            self.showLeftToast = YES;
//            [[DVEAlbumToastImpl new] show:toastStr];
        }
        
        if (scrollView.contentOffset.x > scrollView.contentSize.width - scrollView.frame.size.width + 50 && self.showRightToast == NO) {
            NSString *toastStr = @"";
            if (self.viewModel.enableMixedUploading) {
                toastStr = TOCLocalizedString(@"full_screen_lastitem_tips",@"这是最后一个素材啦");
            } else {
                switch (self.resourceType) {
                    case DVEAlbumGetResourceTypeImage:
                        toastStr = TOCLocalizedString(@"full_screen_lastphoto_tips",@"这是最后一张图片啦");
                        break;
                    case DVEAlbumGetResourceTypeVideo:
                        toastStr = TOCLocalizedString(@"full_screen_lastvideo_tips",@"这是最后一个视频啦");
                        break;
                    default:
                        toastStr = TOCLocalizedString(@"full_screen_lastitem_tips",@"这是最后一个素材啦");
                        break;
                }
            }
            
            self.showRightToast = YES;
//            [[DVEAlbumToastImpl new] show:toastStr];
        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{

}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSInteger position =floor((*targetContentOffset).x/scrollView.bounds.size.width);
    if (position < [self originDataSourceCount] && position >= 0) {
            DVEAlbumAssetModel *assetModel = [self assetModelForIndex:position];
            [self updatePhotoSelected:assetModel greyMode:self.greyMode];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isDragging = NO;
    self.selectPhotoUserInteractive = YES;
    self.currentIndex = floor(scrollView.contentOffset.x/scrollView.bounds.size.width);
    if (self.currentIndex < [self originDataSourceCount] && self.currentIndex >= 0) {
        DVEAlbumAssetModel *assetModel = [self assetModelForIndex:self.currentIndex];
        if ([self.currentAssetModel isEqual:assetModel]) {
            [self playAfterCheck];
            return ;
        }
        //滑动切换的时候需要将当前的assetModel移除，加入滑动切换后的assetModel
        if ([self.viewModel.currentSelectAssets containsObject:self.currentAssetModel]) {
            [self.viewModel.currentSelectAssets removeObject:self.currentAssetModel];
        }
        if (![self.viewModel.currentSelectAssets containsObject:assetModel]) {
            [self.viewModel.currentSelectAssets addObject:assetModel];
        }
        self.currentAssetModel = assetModel;
        if (assetModel.mediaType == DVEAlbumAssetModelMediaTypeVideo) {
            [self setUpPlayer:assetModel];
        }
        
    }
    if ([self enableOptimizeRecordAlbum]) {
        if ([self.assetDataModel removePreviewInvalidAssetForPostion:self.currentIndex]) {
            self.currentIndex = [self.assetDataModel previewIndexOfObject:self.currentAssetModel];
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            [self.collectionView layoutIfNeeded];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removePlayer];
}

- (void)runLoopTheMovie:(NSNotification *)notification
{
    [self.avPlayer seekToTime:kCMTimeZero];
    [self playAfterCheck];
}

- (void)removePlayer
{
    if (_avPlayer) {
        [self.KVOController unobserve:self.avPlayerLayer keyPath:@"readyForDisplay"];
        [self.KVOController unobserve:self.avPlayer keyPath:@"status"];
        [_avPlayerLayer removeFromSuperlayer];
        _avPlayerLayer = nil;
        _avPlayer = nil;
    }
}

- (void)setUpPlayer:(DVEAlbumAssetModel *)assetModel
{
    [self trackMonitor];
    [self removePlayer];
    [self performSelector:@selector(showLoading) withObject:nil afterDelay:0.5];
    [self selectAsset:assetModel progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
    } completion:^(AVAsset *videoAsset, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loadingView dismiss];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoading) object:nil];
                if (error.userInfo){
                    NSString *errorMsg = [error.userInfo objectForKey:@"NSLocalizedDescription"];
                    if (errorMsg) {
                        [[DVEAlbumToastImpl new] show:errorMsg];
                    }
                }
            });
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[videoAsset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
                AVAssetTrack *firstTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo][0];
                CGSize dimensions = CGSizeApplyAffineTransform(firstTrack.naturalSize, firstTrack.preferredTransform);
                self.videoSize = @(CGSizeMake(fabs(dimensions.width), fabs(dimensions.height)));

            }
            [self removeAVPlayerLayer];
            self.avPlayer = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:videoAsset]];
            self.avPlayer.currentItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmSpectral;
            self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
            self.avPlayerLayer.backgroundColor = TOCResourceColor(TOCColorBGCreation).CGColor;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runLoopTheMovie:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.avPlayer.currentItem];

            @weakify(self);
            [self.KVOController observe:self.avPlayerLayer
                                keyPath:@"readyForDisplay"
                                options:0
                                  block:^(typeof(self) _Nullable observer, id object, NSDictionary *change) {
                                      @strongify(self);
                                      if (self.avPlayerLayer.readyForDisplay) {
                                          self.couldTrack = YES;
                                          [self.loadingView dismiss];
                                          [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoading) object:nil];
                                          [self playAfterCheck];
                                          NSArray *visibleCell = [self.collectionView visibleCells];
                                          if ([visibleCell count] > 0) {
                                              DVEAlbumPreviewAndSelectCell *cell = (DVEAlbumPreviewAndSelectCell *)visibleCell.firstObject;
                                              if ([cell isKindOfClass:[DVEAlbumPreviewAndSelectCell class]]) {
                                                  [cell setPlayerLayer:self.avPlayerLayer withPlayerFrame:[self playerFrame]];
                                                  [cell removeCoverImageView];

                                              }
                                          }
                                          
                                      }
                                  }];
            
            [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                @strongify(self);
                NSArray *visibleCell = [self.collectionView visibleCells];
                if ([visibleCell count] > 0) {
                    DVEAlbumPreviewAndSelectCell *cell = (DVEAlbumPreviewAndSelectCell *)visibleCell.firstObject;
                    if ([cell isKindOfClass:[DVEAlbumPreviewAndSelectCell class]]) {
                        [cell removeCoverImageView];
                    }
                }
            }];
            
            
            [self.KVOController observe:self.avPlayer
                                keyPath:@"status"
                                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                  block:^(typeof(self) _Nullable observer, id object, NSDictionary *change) {
                                      @strongify(self);
                                      AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
                                      if (status == AVPlayerStatusFailed) {
                                          self.errorOccur = YES;
                                      }
                                  }];
            [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                              object:nil
                                                               queue:[NSOperationQueue mainQueue]
                                                          usingBlock:^(NSNotification * _Nonnull note) {
                                                              @strongify(self);
                                                              [self playAfterCheck];
                                                          }];
            [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
                                                              object:nil
                                                               queue:[NSOperationQueue mainQueue]
                                                          usingBlock:^(NSNotification * _Nonnull note) {
                                                              @strongify(self);
                                                              [self.avPlayer pause];
                                                          }];
        });
    }];
}

- (void)trackMonitor{
    if (self.couldTrack && self.avPlayer.currentItem) {
        AVAsset *asset = self.avPlayer.currentItem.asset;
        CGSize videoSize = CGSizeZero;
            
        for (AVAssetTrack *track in asset.tracks) {
            if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
                videoSize = track.naturalSize;
            }
        }
        BOOL is4k = (videoSize.width > videoSize.height ? videoSize.height : videoSize.width) >= 2160;
//        [TOCMonitor() trackService:@"tool_performance_preview_video_play_status"
//                                 status:self.errorOccur ? 1:0
//                                  extra:@{
//                                        @"is_4k" : @(is4k) ,
//                                        @"video_watched_duration" : @(CMTimeGetSeconds(self.avPlayer.currentItem.currentTime)),
//                                        }];
    }
    self.couldTrack = NO;
    self.errorOccur = NO;
}

- (void)showLoading{
    self.loadingView = [DVEAlbumLoadingViewDefaultImpl showTextLoadingOnView:self.view title:@"" animated:YES];
    [self.loadingView allowUserInteraction:YES];
    [self.loadingView startAnimating];
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = self.view.bounds.size;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        [_collectionView registerClass:[self getClassFromType:DVEAlbumAssetModelMediaTypeVideo] forCellWithReuseIdentifier:NSStringFromClass([self getClassFromType:DVEAlbumAssetModelMediaTypeVideo])];
        [_collectionView registerClass:[self getClassFromType:DVEAlbumAssetModelMediaTypePhoto] forCellWithReuseIdentifier:NSStringFromClass([self getClassFromType:DVEAlbumAssetModelMediaTypePhoto])];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.alwaysBounceHorizontal = YES;
    }
    return _collectionView;
}

#pragma mark - DVEAlbumPreviewAndSelectCellDelegate
- (void)previewCellSelectRightTopWithCell:(DVEAlbumPreviewAndSelectCell *)cell isSelected:(BOOL)isSelected{
//    self.currentAssetModelSelected = isSelected;
}

- (void)updatePhotoSelected:(DVEAlbumAssetModel *)assetModel greyMode:(BOOL)greyMode
{
    NSNumber *number = assetModel.selectedNum;
    UIColor *hintColor = TOCResourceColor(TOCUIColorConstTextInverse2);
    if (number) {
        //check
        self.unCheckImageView.hidden = YES;
        self.numberBackGroundImageView.hidden = NO;
        self.numberLabel.text = [NSString stringWithFormat:@"%@", @([number integerValue])];
        self.selectHintLabel.text = TOCLocalizedString(@"full_screen_selected",@"已选");
        self.selectHintLabel.textColor = hintColor;
        
        self.unCheckImageView.alpha = 1;

    } else {
        NSTimeInterval duration = assetModel.asset.duration;
        if (greyMode || (assetModel.mediaType == DVEAlbumAssetModelMediaTypeVideo && duration < 1)) {
            self.unCheckImageView.alpha = 0.34;
            self.selectHintLabel.textColor = TOCResourceColor(TOCUIColorConstTextInverse4);
        } else {
            self.unCheckImageView.alpha = 1;
            self.selectHintLabel.textColor = hintColor;
        }
        //check
        self.unCheckImageView.hidden = NO;
        
        self.numberBackGroundImageView.hidden = YES;
        self.numberLabel.text = nil;
        self.selectHintLabel.text = TOCLocalizedString(@"full_screen_select",@"选择");
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self originDataSourceCount];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    DVEAlbumPreviewAndSelectCell *previewCell = (DVEAlbumPreviewAndSelectCell *)cell;
    if (indexPath.row < [self originDataSourceCount]) {
        DVEAlbumAssetModel *assetModel = [self assetModelForIndex:indexPath.row];
        self.videoSize = @(CGSizeMake(assetModel.asset.pixelWidth, assetModel.asset.pixelHeight));
        [previewCell configCellWithAsset:assetModel withPlayFrame:[self playerFrame] greyMode:self.greyMode];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger position = collectionView.contentOffset.x/collectionView.bounds.size.width;
    if (position < [self originDataSourceCount] && position >= 0) {
        DVEAlbumAssetModel *assetModel = [self assetModelForIndex:position];
        [self updatePhotoSelected:assetModel greyMode:self.greyMode];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self originDataSourceCount]) {
        DVEAlbumAssetModel *assetModel = [self assetModelForIndex:indexPath.row];
           DVEAlbumPreviewAndSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self getClassFromType:assetModel.mediaType]) forIndexPath:indexPath];
           cell.backgroundColor = TOCResourceColor(TOCColorBGCreation);
           for (DVEAlbumAssetModel *seletedAssetModel in self.selectedAssetModelArray) {
               if ([assetModel isEqual:seletedAssetModel]) {
                   assetModel.selectedNum = seletedAssetModel.selectedNum;
                   assetModel.selectedAmount = seletedAssetModel.selectedAmount;
               }
           }

           return cell;
    } else {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    }

}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)back:(id)sender
{
    DVEAlbumAssetModel *model = [self.viewModel.currentSelectAssets lastObject];
    if (!model.isSelected) {
        [self.viewModel.currentSelectAssets removeLastObject];
    }
//    self.exitAssetModel = self.currentAssetModel;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DVEAlbumZoomTransitionInnerContextProvider

- (DVEAlbumTransitionTriggerDirection)zoomTransitionAllowedTriggerDirection
{
    return DVEAlbumTransitionTriggerDirectionDown;
}

- (UIView *)zoomTransitionEndView
{
    //set exitAssetModel when exit;
//    self.exitAssetModel = self.currentAssetModel;
    DVEAlbumPreviewAndSelectCell *cell = [self.collectionView visibleCells].firstObject;
    if ([cell isKindOfClass:[DVEAlbumPreviewAndSelectCell class]]) {
        if (cell.assetModel.mediaType == DVEAlbumAssetModelMediaTypeVideo) {
            DVEAlbumVideoPreviewAndSelectCell *previewCell = (DVEAlbumVideoPreviewAndSelectCell *)cell;
            if ([previewCell isKindOfClass:[DVEAlbumVideoPreviewAndSelectCell class]]) {
                if (previewCell.playerView) {
                    return previewCell.playerView;
                } else {
                    return previewCell.coverImageView;
                }

            }
        } else if (cell.assetModel.mediaType == DVEAlbumAssetModelMediaTypePhoto) {
            DVEAlbumPhotoPreviewAndSelectCell *previewCell = (DVEAlbumPhotoPreviewAndSelectCell *)cell;
            if ([previewCell isKindOfClass:[DVEAlbumPhotoPreviewAndSelectCell class]]) {
                return previewCell.imageView;
            }
        } else {
            return self.view;
        }
    }
    return self.view;
}

- (NSInteger)zoomTransitionItemOffset
{
    return self.currentAssetModel.cellIndex;
}

#pragma mark - util
- (CGRect)playerFrame
{
    CGRect playerFrame = self.view.bounds;
    NSValue * sizeOfVideoValue = self.videoSize;
    if (sizeOfVideoValue) {
        CGSize sizeOfVideo = [sizeOfVideoValue CGSizeValue];
        CGSize sizeOfScreen = [UIScreen mainScreen].bounds.size;
        
        CGFloat videoScale = sizeOfVideo.width / sizeOfVideo.height;
        CGFloat screenScale = sizeOfScreen.width / sizeOfScreen.height;
        
        CGFloat playerWidth = 0;
        CGFloat playerHeight = 0;
        CGFloat playerX = 0;
        CGFloat playerY = 0;
        
        if ([UIDevice acc_isIPhoneX]) {
            if (videoScale > 9.0 / 16.0) {//两边不裁剪
                playerFrame = AVMakeRectWithAspectRatioInsideRect(sizeOfVideo, self.view.bounds);
            } else if (videoScale > screenScale) {//按高度
                playerHeight = self.view.frame.size.height;
                playerWidth = playerHeight * videoScale;
                playerY = 0;
                playerX = - (playerWidth - self.view.frame.size.width) * 0.5;
                playerFrame = CGRectMake(playerX, playerY, playerWidth, playerHeight);
            } else {//按宽度
                playerWidth = self.view.frame.size.width;
                playerHeight = playerWidth / videoScale;
                playerX = 0;
                playerY = - (playerHeight - self.view.frame.size.height) * 0.5;
                playerFrame = CGRectMake(playerX, playerY, playerWidth, playerHeight);
            }
        } else {
            //不是iphoneX全使用fit方式
            playerFrame = AVMakeRectWithAspectRatioInsideRect(sizeOfVideo, self.view.bounds);
        }
    }
    
    return playerFrame;
}

- (void)reloadSelectedStateWithGrayMode:(BOOL)greyMode{
    NSArray *visibleCells = [self.collectionView visibleCells];

    for (DVEAlbumPreviewAndSelectCell *cell in visibleCells) {
        if ([cell isKindOfClass:[DVEAlbumPreviewAndSelectCell class]]) {
            [self updatePhotoSelected:cell.assetModel greyMode:greyMode];
        }
    }
}


- (void)selectAsset:(DVEAlbumAssetModel *)assetModel progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^) (AVAsset *, NSError *))completion
{
    NSParameterAssert(completion);
    PHVideoRequestOptions *options = nil;
    if (@available(iOS 14.0, *)) {
        options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    }
    
    PHAsset *sourceAsset = assetModel.asset;
    [[PHImageManager defaultManager] requestAVAssetForVideo:sourceAsset
                                                    options:options
                                              resultHandler:^(AVAsset *_Nullable asset, AVAudioMix *_Nullable audioMix, NSDictionary *_Nullable info) {
                                                  
                                                  BOOL isICloud = [info[PHImageResultIsInCloudKey] boolValue];
                                                  if (isICloud && !asset) {
                                                      PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                                                      options.networkAccessAllowed = YES;
                                                      //progress
                                                      options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              if (progressHandler) {
                                                                  progressHandler(progress, error, stop, info);
                                                              }
                                                          });
                                                      };
                                                      if (@available(iOS 14.0, *)) {
                                                          options.version = PHVideoRequestOptionsVersionCurrent;
                                                          options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
                                                      }
                                                      
                                                      [[PHImageManager defaultManager] requestAVAssetForVideo:sourceAsset
                                                                                                      options:options
                                                                                                resultHandler:^(AVAsset *_Nullable asset, AVAudioMix *_Nullable audioMix,
                                                                                                                NSDictionary *_Nullable info) {
                                                                                                }];
                                                      
                                                      NSError *error = [NSError errorWithDomain:@"com.aweme.gallery"
                                                                                           code:3
                                                                                       userInfo:@{NSLocalizedDescriptionKey:TOCLocalizedString(@"com_mig_the_video_is_being_synced_to_icloud_try_again_later", @"该视频正在从iCloud同步，请稍后再试")}];
                                                      completion(nil, error);
                                                  } else {
                                                      if (asset) {
                                                          completion(asset, nil);
                                                      } else {
                                                          NSError *error = [NSError errorWithDomain:@"com.aweme.gallery"
                                                                                               code:3
                                                                                           userInfo:@{NSLocalizedDescriptionKey:TOCLocalizedString(@"com_mig_resource_error", @"资源错误")}];
                                                          completion(nil, error);
                                                      }
                                                  }
                                              }];
}


- (void)playAfterCheck{
    if (self.isDragging == NO && self.currentIndex < [self originDataSourceCount] && self.currentIndex >=0 && [self assetModelForIndex:self.currentIndex].mediaType == DVEAlbumAssetModelMediaTypeVideo && [DVEAlbumResponder topViewController] == self) {
        [self.avPlayer play];
    }
}

- (void)removeAVPlayerLayer{
    [self.avPlayerLayer removeFromSuperlayer];
    self.avPlayer = nil;
    self.avPlayerLayer = nil;
}

- (void)selectPhotoButtonClick:(id)sender{
    if (self.selectPhotoUserInteractive == NO) {
        return;
    }
    TOCBLOCK_INVOKE(self.didClickedTopRightIcon, self.currentAssetModel, self.currentAssetModel.selectedNum ? YES : NO);
    [self previewCellSelectRightTopWithCell:nil isSelected:self.currentAssetModel.selectedNum ? YES : NO];
}

//Consider replacing a file likes "factory"
- (Class)getClassFromType:(DVEAlbumAssetModelMediaType)type{
    switch (type) {
        case DVEAlbumAssetModelMediaTypePhoto:
            return [DVEAlbumPhotoPreviewAndSelectCell class];
            break;
        case DVEAlbumAssetModelMediaTypeVideo:
            return [DVEAlbumVideoPreviewAndSelectCell class];
            break;
        default:
            return [DVEAlbumPreviewAndSelectCell class];
            break;
    }
}


#pragma mark - Orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end

