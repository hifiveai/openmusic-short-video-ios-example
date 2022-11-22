//
//  VEHomeViewController.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEHomeViewController.h"
#import "VEMenuCollectionViewCell.h"
#import "VECollectionHeaderReusableView.h"
#import "VECollectionFooterReusableView.h"
#import "VECollectionViewVerticalLayout.h"
#import "VEBaseView.h"
#import "VEHorizontalCollectionViewCell.h"
#import "VERouteHelper.h"
#import "VEResourcePicker.h"
#import <NLEEditor/DVEUIFactory.h>
#import "VECapViewController.h"
#import <NLEEditor/DVEDraftViewController.h>
#import "LCVViewController.h"
#import "VERootVCManger.h"
#import "VEResourceLoader.h"
#import "VENLEEditorServiceContainer.h"
#import <NLEEditor/DVEViewController.h>
#import <NLEEditor/DVEService.h>
#import <TTVideoEditor/IESMMTrackerManager.h>
#import "VENLEGlobalServiceContainer.h"

#define kVEMenuCollectionViewCellIdentifier @"kVEMenuCollectionViewCellIdentifier"
#define kVEHorizontalCollectionViewCellIdentifier @"kVEHorizontalCollectionViewCellIdentifier"
#define kVECollectionHeaderReusableViewIdentifier @"kVECollectionHeaderReusableViewIdentifier"
#define kVECollectionFooterReusableViewIdentifier @"kVECollectionFooterReusableViewIdentifier"


@interface VEHomeViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
VECollectionViewBaseFlowLayoutDelegate
>

@property (nonatomic, strong) UICollectionView *collecView;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSDictionary *options;
@property (nonatomic, strong) UIButton *rightButton;

@end

@implementation VEHomeViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collecView performBatchUpdates:^{

    } completion:^(BOOL finished) {
        [self.collecView reloadData];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"VESDK Demo New";
    self.view.backgroundColor = HEXRGBCOLOR(0x181718);
    self.navigationController.navigationBar.hidden = YES;
    [self buildLayout];
    DVEServiceInit([VENLEGlobalServiceContainer class]);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)buildLayout
{
    [self.view addSubview:self.collecView];
        
    [self.collecView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    #if BEF_USE_CK
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:@"icon_back".UI_VEToImage forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60);
        make.left.mas_equalTo(20);
        make.width.height.mas_equalTo(44);
    }];
    @weakify(self);
    [[backButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    #endif
}

- (void)addRightBar
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark -- getter

- (UIButton *)rightButton
{
    if (!_rightButton) {
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [_rightButton setTitle:@"切换" forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(didClickedRightButton:) forControlEvents:UIControlEventTouchUpInside];
        if (@available(iOS 13.0, *)) {
            [_rightButton setTitleColor:[UIColor systemIndigoColor] forState:UIControlStateNormal];
        } else {
            [_rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    
    return _rightButton;
}


- (UICollectionView *)collecView
{
    if (!_collecView) {
        VECollectionViewVerticalLayout *flowLayout = [[VECollectionViewVerticalLayout alloc] init];
        flowLayout.delegate = self;
        flowLayout.isFloor = YES;
        flowLayout.header_suspension = NO;
        [flowLayout forceSetIsNeedReCalculateAllLayout:YES];
    
        _collecView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:flowLayout];
        _collecView.showsHorizontalScrollIndicator = NO;
        _collecView.delegate = self;
        _collecView.dataSource = self;
        _collecView.alwaysBounceVertical = YES;
        if (@available(iOS 11.0, *)) {
            _collecView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = false;
            
        }
        _collecView.backgroundColor = HEXRGBCOLOR(0x181718);
        [_collecView registerClass:[VEMenuCollectionViewCell class] forCellWithReuseIdentifier:kVEMenuCollectionViewCellIdentifier];
        [_collecView registerClass:[VEHorizontalCollectionViewCell class] forCellWithReuseIdentifier:kVEHorizontalCollectionViewCellIdentifier];
        [_collecView registerClass:[VECollectionHeaderReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kVECollectionHeaderReusableViewIdentifier];
        [_collecView registerClass:[VECollectionFooterReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kVECollectionFooterReusableViewIdentifier];
        
    }
    
    return _collecView;
}

- (NSArray *)titles
{
#if DEBUG
    return @[@"主场景",@"主功能",@"小功能"];
#else
    return @[@"主场景",@"主功能"];
#endif
}

- (NSDictionary *)options
{
#if BEF_USE_CK
    NSArray *mainScenes = @[CKEditorLocStringWithKey(@"ck_home_hepai", @"视频合拍"),CKEditorLocStringWithKey(@"ck_home_drafts", @"草稿箱"),CKEditorLocStringWithKey(@"ck_home_cut_same", @"剪同款")]; // add cutsame entry for CV
#else
    NSArray *mainScenes = @[CKEditorLocStringWithKey(@"ck_home_hepai", @"视频合拍"),CKEditorLocStringWithKey(@"ck_home_drafts", @"草稿箱"),];
#endif
    
    return @{
        @"主功能":@[CKEditorLocStringWithKey(@"ck_home_record", @"视频拍摄"),CKEditorLocStringWithKey(@"ck_home_edit", @"视频创作")],
        @"主场景":mainScenes,
        @"小功能":@[@"本地视频"],
    };
}

- (NSDictionary *)images
{
#if BEF_USE_CK
    NSArray *sceneImages = @[@"icon_home_dute",@"icon_home_draft",@"icon_home_cutsame",@""]; // add cutsame entry for CV
#else
    NSArray *sceneImages = @[@"icon_home_dute",@"icon_home_draft",@"",@""];
#endif
    
    return @{
        @"主功能":@[@"icon_home_item_camera",@"icon_home_item_creat"],
        @"主场景":sceneImages,
        @"小功能":@[@"icon_home_item_creat",@"滤镜",@"字幕"],
    };
}

#pragma mark -- VECollectionViewBaseFlowLayoutDelegate

- (ZLLayoutType)collectionView:(UICollectionView *)collectionView layout:(VECollectionViewBaseFlowLayout *)collectionViewLayout typeOfLayout:(NSInteger)section {
    return FillLayout;
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            NSString *key = self.titles[section];
            NSArray *options = self.options[key];
            return [options count];
            
        }
            break;
        case 1:
        {
            NSString *key = self.titles[section];
            NSArray *options = self.options[key];
            return [options count];
            
        }
            break;
            
        default:
            return 1;
            break;
    }
    
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            {
                VEMenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVEMenuCollectionViewCellIdentifier forIndexPath:indexPath];
                cell.titleName = self.options[self.titles[indexPath.section]][indexPath.row];
                cell.iconName = self.images[self.titles[indexPath.section]][indexPath.row];
                cell.indexPath = indexPath;
                cell.backgroundColor = HEXRGBCOLOR(0x4C4C4D);
                cell.layer.cornerRadius = 4;
                cell.clipsToBounds = YES;
                
                return cell;
            }
            break;
        case 1:
            {
                VEMenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVEMenuCollectionViewCellIdentifier forIndexPath:indexPath];
                cell.titleName = self.options[self.titles[indexPath.section]][indexPath.row];
                cell.iconName = self.images[self.titles[indexPath.section]][indexPath.row];
                cell.indexPath = indexPath;
                cell.backgroundColor = HEXRGBCOLOR(0x4C4C4D);
                cell.layer.cornerRadius = 5;
                cell.clipsToBounds = YES;
                
                return cell;
            }
            break;

            
        default:
        {
            VEMenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVEMenuCollectionViewCellIdentifier forIndexPath:indexPath];
            cell.titleName = self.options[self.titles[indexPath.section]][indexPath.row];
            cell.iconName = self.images[self.titles[indexPath.section]][indexPath.row];
            cell.indexPath = indexPath;
            cell.backgroundColor = HEXRGBCOLOR(0x4C4C4D);
            cell.layer.cornerRadius = 5;
            cell.clipsToBounds = YES;
            
            return cell;
        }
            break;
    }
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.titles.count;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        VECollectionHeaderReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kVECollectionHeaderReusableViewIdentifier forIndexPath:indexPath];
        view = header;
        
        if (indexPath.section > 0) {
//            header.titleLabel.text = self.titles[indexPath.section];
        } else {
            header.iconView.image = @"bg_home".UI_VEToImage;
            
        }        
    } else {
        VECollectionFooterReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kVECollectionFooterReusableViewIdentifier forIndexPath:indexPath];
        view = footer;
        
        if (indexPath.section == 1) {
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];//获取app版本信息

            NSLog(@"infoDictionary：%@",infoDictionary);  //这里会得到很对关于app的相关信息

            NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
            NSString *VESDKVer = [IESMMTrackerManager getEditorVersion];
            NSString *CVVer = [IESMMTrackerManager getEffectVersion];
            
            NSString *text = [NSString stringWithFormat:@"Demo:%@-build:%@-VESDK:%@-CV:%@",version,build,VESDKVer,CVVer];
//            text = [NSString stringWithFormat:@"Demo:%@-build:%@",version,build];
            footer.titleLabel.text = text;
            
        } else {
            footer.titleLabel.text = @"";
        }
    }
    view.backgroundColor = HEXRGBCOLOR(0x181718);
    
    return view;
}


#pragma mark -- UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemMargn = 25;
    CGSize size = CGSizeZero;
    switch (indexPath.section) {
        case 0:
        {
            CGFloat w = (VE_SCREEN_WIDTH - itemMargn * 2 - 15) * 0.5 * 0.5 - 7.5;
            switch (indexPath.item) {
                case 0:
                    {
                        size = CGSizeMake(w, 70);
                    }
                    break;
                case 1:
                    {
                        size = CGSizeMake(w, 70);
                    }
                    break;
                    
                default:
                    size = CGSizeMake(w , 70);
                    break;
            }
        }
        break;
            case 1:
            {
                CGFloat w = (VE_SCREEN_WIDTH - itemMargn * 2 - 15) * 0.5;
                switch (indexPath.item) {
                    case 0:
                        {
                            size = CGSizeMake(w, 80);
                        }
                        break;
                    case 1:
                        {
                            size = CGSizeMake(w, 80);
                        }
                        break;
                        
                    default:
                        size = CGSizeMake(w , 80);
                        break;
                }
            }
            break;
            
        default:
        {
            CGFloat w = (VE_SCREEN_WIDTH - itemMargn * 2 - 15) * 0.5;
            size = CGSizeMake(w, 80);
        }
            break;
    }
    return size;
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    switch (section) {
        case 0:
            return UIEdgeInsetsMake(15, 25, 0,25);
            break;
        case 1:
            return UIEdgeInsetsMake(15, 25, 0,25);
            break;
            
        default:
            return UIEdgeInsetsMake(15, 25, 0,25);
            break;
    }
   
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 15;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 15;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            CGFloat h = (VE_SCREEN_HEIGHT - (252 - VEBottomMargnValue + VEBottomMargn));
            return CGSizeMake(VE_SCREEN_WIDTH, h);
        }           
            break;
            
        default:
            return CGSizeMake(VE_SCREEN_WIDTH, 0);
            break;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGFloat h = 0;
    if (section == 1) {
        h = 74 - VEBottomMargnValue + VEBottomMargn;
    }
    return CGSizeMake(VE_SCREEN_WIDTH, h);
}

#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    @weakify(self);
                    [[VEResourcePicker new] pickVideoResourcesWithCompletion:^(NSArray<id<DVEResourcePickerModel>> * _Nonnull resources, NSError * _Nullable error, BOOL cancel) {
                        @strongify(self);
                        id<DVEResourcePickerModel> model = resources.firstObject;
                        VECapViewController *vc = [VECapViewController VECapVCWithType:VECPViewTypeDuet];
                        UINavigationController *nav  = [[UINavigationController alloc] initWithRootViewController:vc];
                        nav.modalPresentationStyle = UIModalPresentationFullScreen;
                        vc.duetURL = model.URL;
                        [self presentViewController:nav animated:YES completion:^{
                            
                        }];
                    }];
                }
                    break;
                case 1:
                {
                    UIViewController *vc = [DVEUIFactory createDVEDraftViewControllerWithInjectService:[VENLEEditorServiceContainer new]];
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    nav.modalPresentationStyle = UIModalPresentationPopover;
                    [self presentViewController:nav animated:YES completion:^{
                        
                    }];
                }
                    break;
                case 2:
                {
                #if BEF_USE_CK
                    Class managerClass = NSClassFromString(@"CSIFManager");
                    if (managerClass) {
                        // pop CK first, avoid license covered by cutsame
                        UINavigationController *parentNav = self.navigationController;
                        [parentNav popViewControllerAnimated:NO];
                        
                        // init cutsame and jump
                        id instance = [managerClass performSelector:@selector(shareManager)];
                        [instance performSelector:@selector(setupCutSameSDK)];
                        [instance performSelector:@selector(showUISDK)];
                    }
                #endif
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            if (indexPath.row == 1) {
                @weakify(self);
                [[VEResourcePicker new] pickResourcesWithCompletion:^(NSArray<id<DVEResourcePickerModel>> * _Nonnull resources, NSError * _Nullable error, BOOL cancel) {
                    if (resources.count > 0) {
                        @strongify(self);
                        UIViewController* vc = [DVEUIFactory createDVEViewControllerWithResources:resources injectService:[VENLEEditorServiceContainer new]];
                        vc.modalPresentationStyle = UIModalPresentationFullScreen;
                        [self presentViewController:vc animated:YES completion:^{
                            
                        }];
                    }
                }];
               
               
            } else {
                VECapViewController *vc = [VECapViewController VECapVCWithType:VECPViewTypeDefault];
                UINavigationController *nav  = [[UINavigationController alloc] initWithRootViewController:vc];
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:nav animated:YES completion:^{
                    
                }];
            }
        }
            break;
        case 2:
        {
            LCVViewController *vc = [LCVViewController new];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            nav.modalPresentationStyle = UIModalPresentationPopover;
            [self presentViewController:nav animated:YES completion:^{
                
            }];
        }
        default:
            break;
    }
    
}

- (void)didClickedRightButton:(UIButton *)button
{
    [[VERootVCManger shareManager] swichRootVC];
}


@end
