//
//  DVEAlbumManager.m
//  Pods
//
//  Created by bytedance on 2021/8/23.
//

#import "DVEAlbumManager.h"
#import "DVEAlbumListViewController.h"
#import "DVEAlbumFactoryManager.h"
#import "DVEAlbumResponder.h"
#import "DVEAlbumCornerBarNaviController.h"
#import "DVEAlbumMacros.h"
#import "DVEAlbumCornerBarNaviController.h"
#import "DVEAlbumResponder.h"
#import "UIImage+DVEAlbumAdditions.h"

@implementation DVEAlbumManager

+ (void)pushDVEAlbumViewControllerWithBlock:(DVEAlbumPickerBlock)block
                                 singlePick:(BOOL)singlePick
                                       type:(DVEAlbumAssetsPickType)type {
    [DVEAlbumManager pushDVEAlbumViewControllerWithBlock:block
                                              singlePick:singlePick
                                           firstCreative:NO
                                      videoLimitDuration:0
                                                    type:type];
}

+ (void)pushDVEAlbumViewControllerWithBlock:(DVEAlbumPickerBlock)block
                                 singlePick:(BOOL)singlePick
                         videoLimitDuration:(NSInteger)duration {
    [DVEAlbumManager pushDVEAlbumViewControllerWithBlock:block
                                              singlePick:singlePick
                                           firstCreative:NO
                                      videoLimitDuration:duration
                                                    type:DVEAlbumAssetsPickTypeImageVideo];
}

+ (void)pushDVEAlbumViewControllerWithBlock:(DVEAlbumPickerBlock)block
                                 singlePick:(BOOL)singlePick
                              firstCreative:(BOOL)firstCreative
                                       type:(DVEAlbumAssetsPickType)type {
    [DVEAlbumManager pushDVEAlbumViewControllerWithBlock:block
                                              singlePick:singlePick
                                           firstCreative:firstCreative
                                      videoLimitDuration:0
                                                    type:type];
}


+ (void)pushDVEAlbumViewControllerWithBlock:(DVEAlbumPickerBlock)block
                                 singlePick:(BOOL)singlePick
                              firstCreative:(BOOL)firstCreative
                         videoLimitDuration:(NSInteger)duration
                                       type:(DVEAlbumAssetsPickType)type {
    DVEAlbumTemplateModel *model = [[DVEAlbumTemplateModel alloc] init];
    model.fragmentCount = singlePick ? 1 : 1000;
    model.duration = duration;
    DVEAlbumInputData *albumInput = [[DVEAlbumInputData alloc] init];
    albumInput.isFirstCreative = firstCreative;
    albumInput.vcType = DVEAlbumVCTypeForCutSame;
    albumInput.cutSameTemplateModel = model;
    albumInput.maxPictureSelectionCount = singlePick ? 1 : 1000;
    albumInput.defaultResourceType = (type == DVEAlbumAssetsPickTypeImage ? DVEAlbumGetResourceTypeImage : (type == DVEAlbumAssetsPickTypeVideo ? DVEAlbumGetResourceTypeVideo : DVEAlbumGetResourceTypeImageAndVideo));
    
    DVEStudioAlbumViewController *albumListVC = (DVEStudioAlbumViewController *)[DVEAlbumFactoryManager albumControllerWithAlbumInputData:albumInput];
    DVEAlbumCornerBarNaviController *navigationController = [[DVEAlbumCornerBarNaviController alloc] initWithRootViewController:albumListVC];
    albumListVC.confirmBlock = ^(NSMutableArray<PHAsset *> *assets) {
        [navigationController dismissViewControllerAnimated:YES completion:^{
            if (block) {
                block(assets);
            }
        }];
    };
    
    navigationController.navigationBar.translucent = NO;
    navigationController.modalPresentationCapturesStatusBarAppearance = YES;
    navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [[DVEAlbumResponder topViewController] presentViewController:navigationController animated:YES completion:nil];
}

+ (void)getAlbumResoucesWithAsset:(PHAsset *)asset 
                       completion:(void (^)(DVEAlbumAssetMediaType,
                                            NSURL * _Nullable,
                                            NSData * _Nullable))completion {
    
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        [DVEAlbumManager requestVideoURLWithAsset:asset
                                          success:^(NSURL *videoURL) {
            if (completion) {
                completion(DVEAlbumAssetMediaTypeVideo, videoURL, nil);
            }
        }
                               failure:^(NSDictionary *info) {
            if (completion) {
                completion(DVEAlbumAssetMediaTypeVideo, nil, nil);
            }
        }];
    } else if (asset.mediaType == PHAssetMediaTypeImage) {
        [DVEPhotoManager getOriginalPhotoDataFromICloudWithAsset:asset
                                                 progressHandler:nil
                                                      completion:^(NSData * _Nonnull data, NSDictionary * _Nonnull info) {
            if (completion) {
                completion(DVEAlbumAssetMediaTypeImage, nil, data);
            }
        }];
    }
}

#pragma mark - Photos

+ (void)requestVideoURLWithAsset:(PHAsset *)asset
                         success:(void (^)(NSURL *videoURL))success
                         failure:(void (^)(NSDictionary* info))failure {
    PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    options.version = PHVideoRequestOptionsVersionOriginal;
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset
                                                    options:options
                                              resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info) {
        if ([avasset isKindOfClass:[AVURLAsset class]]) {
            NSURL *url = [(AVURLAsset *)avasset URL];
            if (success) {
                success(url);
            }
        } else if (failure) {
            failure(info);
        }
    }];
}



@end
