//
//  VEResourcePicker.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEResourcePicker.h"
#import "DVEMacros.h"
#import "DVECustomerHUD.h"
#import "NSString+VEIEPath.h"
#import <Photos/Photos.h>
#import <TTVideoEditor/HTSVideoData+CacheDirPath.h>
#import <NLEEditor/DVEAlbumManager.h>
#import <NLEEditor/NSData+DVE.h>
#import <NLEEditor/UIImage+DVEAlbumAdditions.h>
#import <SDWebImage/UIImage+GIF.h>

static DVEResourcePickerCompletion pickResultBlock;


@implementation VEResourcePickerModel

- (instancetype)initWithURL:(NSURL *)videoUrl {
    if (self = [super init]) {
        _URL = videoUrl;
        _type = DVEResourceModelPickerTypeVideo;
        _imageDuration = CMTimeMakeWithSeconds(3, USEC_PER_SEC);
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageDuration = CMTimeMakeWithSeconds(3, USEC_PER_SEC);
    }
    return self;
}

- (AVURLAsset *)videoAsset
{
    if (!_videoAsset) {
        if (self.type == DVEResourceModelPickerTypeVideo) {
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.URL options:@{
                AVURLAssetPreferPreciseDurationAndTimingKey: @(YES)}];
            _videoAsset = (AVURLAsset *)asset;
        }
    }
    
    return _videoAsset;
}

- (NSURL *)URL
{
    if (!_URL) {
        NSString *filePath = [[HTSVideoData cacheDirPath] stringByAppendingPathComponent:[NSString VEUUIDString]];
        [UIImageJPEGRepresentation(self.image, 1) writeToFile:filePath atomically:YES];
        NSURL *picURL = [NSURL fileURLWithPath:filePath];
        _URL = picURL;
    }
    
    return _URL;
}

@end

@interface VEResourcePicker ()


@end

@implementation VEResourcePicker

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)pickResourcesWithCompletion:(DVEResourcePickerCompletion)completion {
    pickResultBlock = completion;
//    self.maxCount = 10000;
//    [self pushTZImagePickerController];
    [DVEAlbumManager pushDVEAlbumViewControllerWithBlock:^(NSArray<PHAsset *> *assets) {
        NSMutableArray *array = [NSMutableArray array];
        [VEResourcePicker getResourceWithAssets:assets arr:array];
    } singlePick:NO firstCreative:YES type:DVEAlbumAssetsPickTypeImageVideo];
}

- (void)pickSingleResourceWithCompletion:(DVEResourcePickerCompletion)completion {
    pickResultBlock = completion;
//    self.maxCount = 1;
//    [self pushTZImagePickerController];
    [DVEAlbumManager pushDVEAlbumViewControllerWithBlock:^(NSArray<PHAsset *> *assets) {
        NSMutableArray *array = [NSMutableArray array];
        [VEResourcePicker getResourceWithAssets:assets arr:array];
    } singlePick:YES type:DVEAlbumAssetsPickTypeImageVideo];
}

- (void)pickVideoResourcesWithCompletion:(DVEResourcePickerCompletion)completion {
    pickResultBlock = completion;
//    self.maxCount = 1;
//    self.onlyVideo = YES;
//    [self pushTZImagePickerController];
//    self.onlyVideo = NO;
    [DVEAlbumManager pushDVEAlbumViewControllerWithBlock:^(NSArray<PHAsset *> *assets) {
        NSMutableArray *array = [NSMutableArray array];
        [VEResourcePicker getResourceWithAssets:assets arr:array];
    } singlePick:YES type:DVEAlbumAssetsPickTypeVideo];
}

- (void)pickSingleImageResourceWithCompletion:(DVEResourcePickerCompletion)completion {
    pickResultBlock = completion;
//    self.onlyImage = YES;
//    self.onlyVideo = NO;
//    self.allowPreview = self.allowTakePicture = NO;
//    self.maxCount = 1;
//    [self pushTZImagePickerController];
//    self.onlyImage = NO;
//    self.allowPreview = self.allowTakePicture = YES;
    [DVEAlbumManager pushDVEAlbumViewControllerWithBlock:^(NSArray<PHAsset *> *assets) {
        NSMutableArray *array = [NSMutableArray array];
        [VEResourcePicker getResourceWithAssets:assets arr:array];
    } singlePick:YES type:DVEAlbumAssetsPickTypeImage];
}

- (void)pickSingleResourceWithLimitDuration:(NSInteger)duration
                                 completion:(DVEResourcePickerCompletion)completion {
    pickResultBlock = completion;
    [DVEAlbumManager pushDVEAlbumViewControllerWithBlock:^(NSArray<PHAsset *> *assets) {
        NSMutableArray *array = [NSMutableArray array];
        [VEResourcePicker getResourceWithAssets:assets arr:array];
    } singlePick:YES videoLimitDuration:duration];
}

+ (void)getResourceWithAssets:(NSMutableArray <PHAsset *>*)assets arr:(NSMutableArray *)arr
{
    if (arr.count == assets.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *resultArr = [VEResourcePicker afterProcessResources:arr];
            [DVECustomerHUD hidProgress];
            if (pickResultBlock) {
                pickResultBlock(resultArr, nil, NO);
            }
        });
        return;
    }
    
    PHAsset *obj = assets[arr.count];
    VEResourcePickerModel *model = [VEResourcePickerModel new];
    [arr addObject:model];
     __block NSString *path = [[HTSVideoData cacheDirPath] stringByAppendingString:[NSString stringWithFormat:@"/%@",[NSString VEUUIDString]]];
    [DVEAlbumManager getAlbumResoucesWithAsset:obj
                                    completion:^(DVEAlbumAssetMediaType type,
                                                 NSURL * _Nullable assetURL,
                                                 NSData * _Nullable imageData) {
        if (type == DVEAlbumAssetMediaTypeVideo) {
            model.type = DVEResourceModelPickerTypeVideo;
            path = [path stringByAppendingString:[NSString stringWithFormat:@".%@",assetURL.pathExtension]];
            NSFileManager *fileManger = [NSFileManager defaultManager];
            [fileManger copyItemAtURL:assetURL toURL:[NSURL fileURLWithPath:path] error:nil];
            model.URL = [NSURL fileURLWithPath:path];
        } else if (type == DVEAlbumAssetMediaTypeImage) {
            model.type = DVEResourceModelPickerTypeImage;
            model.isGIFImage = [imageData dve_isGIFImage];
            if (model.isGIFImage) {
                NSString *imagePath = [[HTSVideoData cacheDirPath] stringByAppendingPathComponent:[NSString VEUUIDString]];
                imagePath = [imagePath stringByAppendingString:@".GIF"];
                [imageData writeToFile:imagePath atomically:YES];
                model.URL = [NSURL fileURLWithPath:imagePath];
                model.image = [UIImage acc_fixImgOrientation:[UIImage sd_imageWithGIFData:imageData]];
            } else {
                model.image = [UIImage acc_fixImgOrientation:[UIImage imageWithData:imageData]];
            }
        }
        [VEResourcePicker getResourceWithAssets:assets arr:arr];
    }];
    
    
}

+ (NSArray *)afterProcessResources:(NSMutableArray *)arr {
    NSMutableArray *result = [NSMutableArray array];
    for (VEResourcePickerModel *model in arr) {
        BOOL isVaildModel = NO;
        if (model.type == DVEResourceModelPickerTypeVideo) {
            isVaildModel = (model.URL != nil && [model.URL isFileURL] && [model.URL checkResourceIsReachableAndReturnError:nil]);
        } else if (model.type == DVEResourceModelPickerTypeImage) {
            if (model.isGIFImage) {
                isVaildModel = (model.URL != nil && [model.URL isFileURL] && [model.URL checkResourceIsReachableAndReturnError:nil] && model.image != nil);
            } else {
                isVaildModel = (model.image != nil);
            }
        }
        
        if (isVaildModel) {
            [result addObject:model];
        }
    }
    
    return [result copy];
}


@end
