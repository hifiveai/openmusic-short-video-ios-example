
//
//  DVEStudioAlbumViewController.m
//  AWEStudio-Pods-Aweme
//
//  Created by bytedance on 2020/8/12.
//


#import "DVEAlbumMacros.h"
//#import "TOCAPMProtocol.h"
#import "DVEAlbumLoadingViewProtocol.h"
//#import "IESEffectModel+TOCUtil.h"
//#import "ACCSettingsProtocol.h"
//#import "TOCMonitorProtocol.h"
//#import "AWEVideoRecordOutputParameter.h"
//#import "DVEResponder.h"
//#import "ACCABTestProtocol.h"
#import "DVEAlbumFactoryManager.h"

//#import <CutSameIF/DVECutSameSDK.h>
//#import "DVEAlbumWorksPreviewViewController.h"
//#import "DVEAlbumLoadingViewController.h"
#import "DVEAlbumToastImpl.h"
#import "DVEAlbumLoadingViewDefaultImpl.h"

@interface DVEStudioAlbumViewController ()

@property (nonatomic, weak) DVEAlbumInputData *inputData;
@property (nonatomic, weak) DVEAlbumConfigViewModel *configViewModel;
//@property (nonatomic, strong) AWETranslationTransitionController *nextTranslationTransitionDelegate;

@end

@implementation DVEStudioAlbumViewController


#pragma mark - Override

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    // 初次打开相册的时候才创建source, 替换素材的时候不能重新创建
//    if (!DVECutSameSDK.shareInstance.source) {
//        [DVECutSameSDK.shareInstance createSource];
//    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.path = path.CGPath;
    self.view.layer.mask = shapeLayer;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - Export

//- (void)handleAssetsForCutSame:(NSMutableArray<DVEAlbumAssetModel *> *)models
//{
//    if ([self p_checkEnableCutSame]) {
//        [self p_toCutSameSolution];
//        return;
//    }
//
//    if ([self p_checkEnableCutSameChangeMaterialVC]) {
//        [self p_toCutSameChangeMaterialVCWithCompletion:nil];
//        return;
//    }
//}

#pragma mark - Cut Same

//- (BOOL)p_checkEnableCutSame
//{
//    BOOL enableCutSame = self.inputData.cutSameTemplateModel != nil;
//    enableCutSame = enableCutSame && self.inputData.singleFragment == nil;
//    enableCutSame = enableCutSame && self.inputData.cutSameTemplateModel.fragmentCount == self.viewModel.currentSelectAssetModels.count;
//
//    return enableCutSame;
//}


//- (BOOL)p_checkEnableCutSameChangeMaterialVC
//{
//    return ![self p_checkEnableCutSame] && self.inputData.singleFragment && self.viewModel.currentSelectAssetModels.count > 0;
//}

//- (void)p_toCutSameSolution {
//    DVECutSameSource *source = DVECutSameSDK.shareInstance.source;
//
//    source.selectedAssets = self.viewModel.currentSelectAssetModels;
////    DVECutSameSource *source = [DVECutSameSDK.shareInstance createSource];
//
//    DVEAlbumLoadingViewController *loaddingVC = [DVEAlbumLoadingViewController showInViewController:self];
//    @weakify(self);
//    loaddingVC.cancelAction = ^{
//        @strongify(self);
//        [DVECutSameSDK.shareInstance.source setSelectedTemplate:self.cutSameTemplateModel];
//    };
////    @weakify(self);
//    @weakify(loaddingVC);
//    [source prepareSourceWithProgress:^(CGFloat progress) {
//        progress = progress > 1 ? 1 : progress;
//        [loaddingVC_weak_ updateHintWithText:[NSString stringWithFormat:@"视频合成中 %2.0f%%", progress*100]];
//    } completion:^(NSArray<DVECutSameMaterialAssetModel *> * _Nonnull materialAssetModels, NSError *error) {
//        @strongify(self);
//        [loaddingVC dismissSelf];
//        if (error) {
//            [[DVEAlbumToastImpl new] showError:@"视频合成失败"];
//            return;
//        }
//        DVEAlbumWorksPreviewViewController *worksVc = [[DVEAlbumWorksPreviewViewController alloc] init];
//        worksVc.dismissBlock = ^{
//            @strongify(self);
//            [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
//        };
//
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:worksVc];
//        nav.navigationBarHidden = YES;
//        nav.modalPresentationStyle = UIModalPresentationFullScreen;
//        nav.modalPresentationCapturesStatusBarAppearance = YES;
//
//        [[DVEResponder topViewController] presentViewController:nav animated:YES completion:nil];
//    }];
//}

//- (UIView<DVEProcessViewProtcol> *)progressView {
//    UIView *view = [UIApplication sharedApplication].keyWindow;
//    UIView<DVEProcessViewProtcol> *progressView = [DVEAlbumLoadingViewDefaultImpl showProcessOnView:view title:TOCLocalizedString(@"mv_generating_hint", @"正在合成中") animated:YES];
//    progressView.cancelable = YES;
//    @weakify(progressView);
//    @weakify(self);
//    progressView.cancelBlock = ^{
//        @strongify(self);
//        [DVECutSameSDK.shareInstance.source setSelectedTemplate:self.cutSameTemplateModel];
//        toc_dispatch_main_async_safe(^{
//            @strongify(progressView);
//            [progressView dismissAnimated:YES];
//        });
//    };
//    return progressView;
//    return nil;
//}

//- (void)p_toCutSameChangeMaterialVCWithCompletion:(void (^)(BOOL, DVEPublishModel *_Nullable))completion
//{
    
//    DVECutSameSource *source = DVECutSameSDK.shareInstance.source;
//
//    DVEAlbumLoadingViewController *loaddingVC = [DVEAlbumLoadingViewController showInViewController:self];
//    [loaddingVC updateHintWithText:[NSString stringWithFormat:@"视频合成中 %2.0f%%", 0.0f*100]];
//
//    @weakify(self)
//    [source replaceAsset:self.viewModel.inputData.singleAssetModel withAsset:self.viewModel.currentSelectAssetModels.firstObject progress:^(CGFloat progress) {
//        progress = progress > 1 ? 1 : progress;
//        [loaddingVC updateHintWithText:[NSString stringWithFormat:@"视频合成中 %2.0f%%", progress * 100]];
//    } completion:^(DVECutSameMaterialAssetModel *martrialAsset, NSError *error) {
//        @strongify(self);
//        [loaddingVC dismissSelf];
//        if (error) {
//            [[DVEAlbumToastImpl new] showError:@"视频合成失败"];
//            return;
//        }
//        if (martrialAsset.processAsset || martrialAsset.currentImageFileURL.path) {
//            TOCBLOCK_INVOKE(self.changeMaterialCallback, martrialAsset);
//            if ([[self.navigationController viewControllers] firstObject] == self || !self.navigationController) {
//                [self dismissViewControllerAnimated:YES completion:nil];
//            } else {
//                [self.navigationController popViewControllerAnimated:YES];
//            }
//        }
//    }];
//}

//#pragma mark - Getter
//
//
//- (DVEAlbumInputData *)inputData
//{
//    return self.viewModel.inputData;
//}
//
//- (DVEAlbumConfigViewModel *)configViewModel
//{
//    return self.viewModel.configViewModel;
//}
//
//- (DVEAlbumTemplateModel *)cutSameTemplateModel
//{
//    return self.viewModel.inputData.cutSameTemplateModel;
//}
//
//- (DVEAlbumCutSameFragmentModel *)singleFragment
//{
//    return self.viewModel.inputData.singleFragment;
//}


@end
