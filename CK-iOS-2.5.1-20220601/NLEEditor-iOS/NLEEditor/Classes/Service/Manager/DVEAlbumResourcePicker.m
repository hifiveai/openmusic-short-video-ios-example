//
//  DVEAlbumResourcePicker.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/23.
//

#import "DVEAlbumResourcePicker.h"
#import "NSString+VEIEPath.h"
#import "NSData+DVE.h"
#import <SDWebImage/UIImage+GIF.h>
#import <Photos/PHImageManager.h>
#if ENABLE_DVEALBUM
#import "DVEAlbumManager.h"
#import "UIImage+DVEAlbumAdditions.h"
#endif


@implementation DVEAlbumResourcePicker

- (void)pickResourcesWithCompletion:(DVEResourcePickerCompletion)completion {
#if ENABLE_DVEALBUM
    [DVEAlbumManager pushDVEAlbumViewControllerWithBlock:^(NSArray<PHAsset *> *assets) {
        [self getAlbumResoucesWithAssets:assets completion:completion];
    } singlePick:NO type:DVEAlbumAssetsPickTypeImageVideo];
#endif
}

- (void)pickVideoResourcesWithCompletion:(DVEResourcePickerCompletion)completion {
#if ENABLE_DVEALBUM
    [DVEAlbumManager pushDVEAlbumViewControllerWithBlock:^(NSArray<PHAsset *> *assets) {
        [self getAlbumResoucesWithAssets:assets completion:completion];
    } singlePick:NO type:DVEAlbumAssetsPickTypeVideo];
#endif
}

- (void)pickSingleResourceWithCompletion:(DVEResourcePickerCompletion)completion {
#if ENABLE_DVEALBUM
    [DVEAlbumManager pushDVEAlbumViewControllerWithBlock:^(NSArray<PHAsset *> *assets) {
        [self getAlbumResoucesWithAssets:assets completion:completion];
    } singlePick:self type:DVEAlbumAssetsPickTypeImageVideo];
#endif
}

- (void)pickSingleImageResourceWithCompletion:(DVEResourcePickerCompletion)completion {
#if ENABLE_DVEALBUM
    [DVEAlbumManager pushDVEAlbumViewControllerWithBlock:^(NSArray<PHAsset *> *assets) {
        [self getAlbumResoucesWithAssets:assets completion:completion];
    } singlePick:YES type:DVEAlbumAssetsPickTypeImage];
#endif
}

- (void)pickSingleResourceWithLimitDuration:(NSInteger)duration
                                 completion:(DVEResourcePickerCompletion)completion {
#if ENABLE_DVEALBUM
    [DVEAlbumManager pushDVEAlbumViewControllerWithBlock:^(NSArray<PHAsset *> *assets) {
        [self getAlbumResoucesWithAssets:assets completion:completion];
    } singlePick:YES videoLimitDuration:duration];
#endif
}

- (void)pickSingleCropImageResourceWithCompletion:(DVEResourcePickerCompletion)completion {
    [self pickSingleImageResourceWithCompletion:completion];
}

- (void)getAlbumResoucesWithAssets:(NSArray<PHAsset *> *)assets
                        completion:(DVEResourcePickerCompletion)completion {
#if ENABLE_DVEALBUM
    NSMutableArray<DVEAlbumResourcePickerModel *> *models = [NSMutableArray array];
    dispatch_group_t group = dispatch_group_create();
    for (PHAsset *asset in assets) {
        dispatch_group_enter(group);
        [DVEAlbumManager getAlbumResoucesWithAsset:asset
                                        completion:^(DVEAlbumAssetMediaType type,
                                                     NSURL * _Nullable assetURL,
                                                     NSData * _Nullable imageData) {
            DVEAlbumResourcePickerModel *model = [[DVEAlbumResourcePickerModel alloc] init];
            if (type == DVEAlbumAssetMediaTypeVideo) {
                model.type = DVEResourceModelPickerTypeVideo;
                NSString *path = [[DVEAlbumResourcePickerModel tempImageResourceDirectory] stringByAppendingString:[NSString stringWithFormat:@"/%@",[NSString VEUUIDString]]];
                path = [path stringByAppendingString:[NSString stringWithFormat:@".%@",assetURL.pathExtension]];
                [[NSFileManager defaultManager] copyItemAtURL:assetURL toURL:[NSURL fileURLWithPath:path] error:nil];
                model.URL = [NSURL fileURLWithPath:path];
            } else if (type == DVEAlbumAssetMediaTypeImage) {
                model.type = DVEResourceModelPickerTypeImage;
                model.isGIFImage = [imageData dve_isGIFImage];
                if (model.isGIFImage) {
                    NSString *imagePath = [[DVEAlbumResourcePickerModel tempImageResourceDirectory] stringByAppendingPathComponent:[NSString VEUUIDString]];
                    imagePath = [imagePath stringByAppendingString:@".GIF"];
                    [imageData writeToFile:imagePath atomically:YES];
                    model.URL = [NSURL fileURLWithPath:imagePath];
                } else {
                    model.image = [UIImage acc_fixImgOrientation:[UIImage imageWithData:imageData]];
                }
            }
            [models addObject:model];
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completion) {
            completion(models, nil, NO);
        }
    });
#endif
}



@end
