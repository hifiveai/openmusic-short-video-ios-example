//
//  DVEPhotoManager.m
//  CameraClient
//
//  Created by bytedance on 2020/7/8.
//

#import "DVEPhotoManager.h"
#import "DVEAlbumMacros.h"
#import "NSArray+DVEAlbumAdditions.h"
#import "UIImage+DVEAlbumAdditions.h"

static CGFloat const kDVEPictureMaxValue1080 = 1080;
static CGFloat const kDVEPictureMaxValue1920 = 1920;

NSString * const kDVEFetchedAssetsCountKey_IMG     = @"kDVEFetchedAssetsCountKey_IMG";
NSString * const kDVEFetchedAssetsCountKey_Video   = @"kDVEFetchedAssetsCountKey_Video";

#define kAWEPhotoManagerChunkSize (8 * 1024)

@implementation DVEPhotoManager

#pragma mark - authorization

//获取权限状态
+ (DVEAuthorizationStatus)authorizationStatus
{
    return (DVEAuthorizationStatus)[PHPhotoLibrary authorizationStatus];
}

//主动请求权限
+ (void)requestAuthorizationWithCompletionOnMainQueue:(void(^)(DVEAuthorizationStatus status))handler
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            DVEAuthorizationStatus aweStatus = (DVEAuthorizationStatus)status;
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(aweStatus);
            });
        }];
    });
}

#pragma mark - 获取所有图片或视频

+ (void)getAssetsWithAlbum:(DVEAlbumModel *)album
                      type:(DVEAlbumGetResourceType)type
               filterBlock:(BOOL (^) (PHAsset *))filterBlock
                completion:(void (^) (NSArray *, PHFetchResult *))completion
{
    PHAssetMediaType mediaType = PHAssetMediaTypeImage;
    switch (type) {
        case DVEAlbumGetResourceTypeImage:
            mediaType = PHAssetMediaTypeImage;
            break;
        case DVEAlbumGetResourceTypeVideo:
            mediaType = PHAssetMediaTypeVideo;
            break;
        default:
            break;
    }
//    AWELogToolInfo(AWELogToolTagImport, @"mediaType:%ld fetchResult:%@",(long)mediaType, album.result);
    [self getAssetsFromFetchResult:album.result filterBlock:filterBlock completion:completion];
}

+ (void)getLatestAssetWithType:(DVEAlbumGetResourceType)type
                    completion:(void (^) (DVEAlbumAssetModel *latestAssetModel))completion
{
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    PHAssetMediaType mediaType = PHAssetMediaTypeImage;
    switch (type) {
        case DVEAlbumGetResourceTypeImage:
            mediaType = PHAssetMediaTypeImage;
            break;
        case DVEAlbumGetResourceTypeVideo:
            mediaType = PHAssetMediaTypeVideo;
            break;
        default:
            break;
    }
    
    NSArray<NSSortDescriptor *> *sortDescriptor = @[
        [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(creationDate)) ascending:NO]
    ];
    fetchOptions.sortDescriptors = sortDescriptor;
    fetchOptions.fetchLimit = 1;
    fetchOptions.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary | PHAssetSourceTypeiTunesSynced;
    PHFetchResult<PHAsset *> *result;
    if (type == DVEAlbumGetResourceTypeImageAndVideo) {
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld || mediaType == %ld", PHAssetMediaTypeImage, PHAssetMediaTypeVideo];
        result = [PHAsset fetchAssetsWithOptions:fetchOptions];
    } else {
        result = [PHAsset fetchAssetsWithMediaType:mediaType options:fetchOptions];
    }
    if (result.count > 0) {
        [self getAssetsFromFetchResult:result filterBlock:^BOOL(PHAsset *asset) {
            return YES;
        } completion:^(NSArray<DVEAlbumAssetModel *> *assetModelArray, PHFetchResult *result) {
            TOCBLOCK_INVOKE(completion, [assetModelArray firstObject]);
        }];
    } else {
       [self p_getCameraRollAlbumWithType:type completion:^(DVEAlbumModel *model) {
            if (model && [model.result count]) {
                [self getAssetsFromFetchResult:model.result filterBlock:^BOOL(PHAsset * phAsset) {
                    return YES;
                } completion:^(NSArray<DVEAlbumAssetModel *> *assetModelArray, PHFetchResult *result) {
                    TOCBLOCK_INVOKE(completion, [assetModelArray lastObject]);
                }];
            } else {
                [self p_fetchAssetsWithType:type filterBlock:^BOOL(PHAsset *phAsset) {
                    return YES;
                } completion:^(NSArray<DVEAlbumAssetModel *> *assetModelArray, PHFetchResult *result) {
                    TOCBLOCK_INVOKE(completion, [assetModelArray lastObject]);
                }];
            }
        }];
    }
}

+ (void)getAssetsWithType:(DVEAlbumGetResourceType)type
              filterBlock:(BOOL (^) (PHAsset *phAsset))filterBlock
               completion:(void (^) (NSArray<DVEAlbumAssetModel *> *assetModelArray, PHFetchResult *result))completion;
{
    [self getAssetsWithType:type filterBlock:filterBlock ascending:YES completion:completion];
}

+ (void)getAssetsWithType:(DVEAlbumGetResourceType)type
              filterBlock:(BOOL (^) (PHAsset *))filterBlock
                ascending:(BOOL)ascending
               completion:(void (^)(NSArray<DVEAlbumAssetModel *> *, PHFetchResult *))completion
{
    [self p_getAssetsWithType:type filterBlock:filterBlock ascending:ascending completion:^(NSArray<DVEAlbumAssetModel *> *assetModelArray, PHFetchResult *result) {
        TOCBLOCK_INVOKE(completion,assetModelArray,result);
        [self p_cacheFetchCountWithResult:assetModelArray type:type];
    }];
}

+ (void)getAllAssetsWithType:(DVEAlbumGetResourceType)type
                   ascending:(BOOL)ascending
                  completion:(void (^)(PHFetchResult *))completion
{
    [self p_getAllAssetsWithType:type ascending:ascending completion:^(PHFetchResult *result) {
        TOCBLOCK_INVOKE(completion, result);
        [self p_cacheFetchCountWithFetchResult:result type:type];
    }];
}

#pragma mark - 相册获取
//获取相册列表-选相薄用
+ (void)getAllAlbumsForMVWithType:(DVEAlbumGetResourceType)type
                       completion:(void (^)(NSArray<DVEAlbumModel *> *))completion
{
    [self p_getAllAlbumsForMVWithType:type completion:^(NSArray<DVEAlbumModel *> *arr) {
        TOCBLOCK_INVOKE(completion,arr);
    }];
}

+ (void)getAllAlbumsWithType:(DVEAlbumGetResourceType)type
                  completion:(void (^)(NSArray<DVEAlbumModel *> *))completion
{
    [self getAllAlbumsWithType:type ascending:YES assetAscending:YES completion:completion];
}

+ (void)getAllAlbumsWithType:(DVEAlbumGetResourceType)type
                   ascending:(BOOL)ascending
              assetAscending:(BOOL)assetAscending
                  completion:(void (^)(NSArray<DVEAlbumModel *> *))completion
{
    [self p_getAllAlbumsWithType:type ascending:ascending assetAscending:assetAscending completion:^(NSArray<DVEAlbumModel *> *arr) {
        TOCBLOCK_INVOKE(completion,arr);
    }];
}

#pragma mark - asset获取

+ (void)getAssetsFromFetchResult:(PHFetchResult *)result
                     filterBlock:(BOOL (^) (PHAsset *))filterBlock
                      completion:(void (^)(NSArray<DVEAlbumAssetModel *> *assetModelArray, PHFetchResult *result))completion
{
    NSMutableArray *photoArr = [NSMutableArray array];
    [result enumerateObjectsUsingBlock:^(PHAsset *phAsset, NSUInteger idx, BOOL * _Nonnull stop) {
        DVEAlbumAssetModel *model = [self p_assetModelWithPHAsset:phAsset];
        if (model) {
            if (filterBlock) {
                if (filterBlock(model.asset)) {
                    [photoArr addObject:model];
                }
            } else {
                [photoArr addObject:model];
            }
        }
    }];
//    AWELogToolInfo(AWELogToolTagImport, @"DVEAlbumAssetModel count:%lu", (unsigned long)photoArr.count);
    TOCBLOCK_INVOKE(completion, photoArr, result);
}

//获取一组图片的字节数
+ (void)getPhotosBytesWithArray:(NSArray<DVEAlbumAssetModel *> *)photos completion:(void (^)(NSString *totalBytes))completion
{
    if (!photos || !photos.count) {
        if (completion) completion(@"0B");
        return;
    }
    __block NSInteger dataLength = 0;
    __block NSInteger assetCount = 0;
    for (NSInteger i = 0; i < photos.count; i++) {
        DVEAlbumAssetModel *model = photos[i];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
            if (model.mediaType != DVEAlbumAssetModelMediaTypeVideo) {
                dataLength += imageData.length;
            }
            assetCount ++;
            if (assetCount >= photos.count) {
                NSString *bytes = [self p_getBytesFromDataLength:dataLength];
                TOCBLOCK_INVOKE(completion,bytes);
            } else {
                TOCBLOCK_INVOKE(completion,@"0B");
            }
        }];
    }
}

#pragma mark - 获取UIImage

//图片尺寸根据asset计算
+ (int32_t)getUIImageWithPHAsset:(PHAsset *)asset
            networkAccessAllowed:(BOOL)networkAccessAllowed
                 progressHandler:(void (^)(CGFloat progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
                      completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion
{
    PHAsset *phAsset = asset;
    CGFloat aspectRatio = (CGFloat)phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
    CGFloat photoWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat pixelWidth = photoWidth * 2 * 1.5;
    //图片较宽
    if (aspectRatio > 1.8) {
        pixelWidth = pixelWidth * aspectRatio;
    }
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
    return [self getUIImageWithPHAsset:asset imageSize:imageSize networkAccessAllowed:networkAccessAllowed progressHandler:progressHandler completion:completion];
}

+ (int32_t)getUIImageWithPHAsset:(PHAsset *)asset
                       imageSize:(CGSize)imageSize
            networkAccessAllowed:(BOOL)networkAccessAllowed
                 progressHandler:(void (^)(CGFloat progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
                      completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    int32_t requestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *result, NSDictionary *info) {
        if ([info objectForKey:PHImageResultIsInCloudKey] && !result && networkAccessAllowed) {
            [self getUIImageFromICloudWithPHAsset:asset imageSize:imageSize progressHandler:progressHandler completion:completion];
            return;
        }
        
        BOOL noError = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (noError) {
            if (result) {
                result = [UIImage acc_fixImgOrientation:result];
            }
            TOCBLOCK_INVOKE(completion, result, info, [[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        } else {
            TOCBLOCK_INVOKE(completion, nil, info, [info[PHImageResultIsDegradedKey] boolValue]);
        }
    }];
    return requestID;
}

+ (void)getUIImageFromICloudWithPHAsset:(PHAsset *)asset
                              imageSize:(CGSize)imageSize
                        progressHandler:(void (^)(CGFloat progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
                             completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressHandler) {
                progressHandler(progress, error, stop, info);
            }
        });
    };
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        if (imageData) {
            UIImage *resultImage = [UIImage imageWithData:imageData];
            resultImage = [UIImage acc_fixImgOrientation:resultImage];
            resultImage = [UIImage acc_tryCompressImage:resultImage ifImageSizeLargeTargetSize:imageSize];
            if (completion) {
                completion(resultImage, info, NO);
            }
        } else {
            if (completion) {
                completion(nil, info, NO);
            }
        }
    }];
}

+ (void)getPhotoDataWithAsset:(PHAsset *)asset version:(PHImageRequestOptionsVersion)version completion:(void (^)(NSData *data, NSDictionary *info, BOOL isInCloud))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.version = version;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        if (imageData) {
            if (completion) completion(imageData, info, NO);
        } else {
            //图片在iCloud上
            if ([info objectForKey:PHImageResultIsInCloudKey]) {
                if (completion) completion(nil, info, YES);
            } else {
                if (completion) completion(nil, info, NO);
            }
        }
    }];
}

+ (void)getOriginalPhotoDataWithAsset:(PHAsset *)asset completion:(void (^)(NSData *data, NSDictionary *info, BOOL isInCloud))completion
{
    [self getPhotoDataWithAsset:asset version:PHImageRequestOptionsVersionOriginal completion:completion];
}

+ (void)getOriginalPhotoDataFromICloudWithAsset:(PHAsset *)asset
                                progressHandler:(void (^)(CGFloat progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
                                     completion:(void (^)(NSData *data, NSDictionary *info))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressHandler) {
                progressHandler(progress, error, stop, info);
            }
        });
    };
    option.networkAccessAllowed = YES;
    option.version = PHImageRequestOptionsVersionOriginal;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        if (completion) {
            completion(imageData, info);
        }
    }];

}

+ (void)cancelImageRequest:(int32_t)requestID
{
    [[PHImageManager defaultManager] cancelImageRequest:requestID];
}

#pragma mark - process


#pragma mark - md5

+ (NSURL *_Nullable)privateVideoURLWithInfo:(NSDictionary *)info
{
    NSArray *videoArray = [info allValues];
    NSString *videoPath = nil;
    for (NSString *string in videoArray) {
        if ([string isKindOfClass:[NSString class]] && [string containsString:@"private"]) {
            NSRange range = [string rangeOfString:@"private"];
            NSInteger index = range.length + range.location;
            videoPath = [string substringFromIndex:index];
        }
    }
    NSURL *videoURL = nil;
    if (videoPath.length && [videoPath containsString:@"DCIM"]) {
        videoURL = [NSURL fileURLWithPath:videoPath];
    }
    return videoURL;
}

+ (NSString *)timeStringWithDuration:(NSTimeInterval)duration
{
    NSInteger seconds = (NSInteger)round(duration);
    NSInteger second = seconds % 60;
    NSInteger minute = seconds / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minute, (long)second];
}

#pragma mark - private methods

+ (BOOL)p_isCameraRollAlbum:(PHAssetCollection *)collection
{
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1) {
        versionStr = [versionStr stringByAppendingString:@"00"];
    } else if (versionStr.length <= 2) {
        versionStr = [versionStr stringByAppendingString:@"0"];
    }
    CGFloat version = versionStr.floatValue;
    // 目前已知8.0.0 ~ 8.0.2系统，拍照后的图片会保存在最近添加中
    if (version >= 800 && version <= 802) {
        return collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded;
    } else {
        return collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary;
    }
}

+ (BOOL)p_isRecentlyDeleteAlbum:(PHAssetCollection *)collection
{
    return collection.assetCollectionSubtype == 1000000201;
}

+ (DVEAlbumModel *)p_modelWithResult:(PHFetchResult *)result name:(NSString *)name isCameraRoll:(BOOL)isCameraRoll assetAscending:(BOOL)assetAscending
{
    DVEAlbumModel *model = [[DVEAlbumModel alloc] init];
    model.result = result;
    model.name = name;
    model.count = result.count;
    model.lastUpdateDate = [(assetAscending ? [result lastObject] :[result firstObject]) creationDate];
    return model;
}

+ (DVEAlbumAssetModel *)p_assetModelWithPHAsset:(PHAsset *)asset
{
    if (![asset isKindOfClass:[PHAsset class]]) {
        return nil;
    }
    
    DVEAlbumAssetModel *model = [[DVEAlbumAssetModel alloc] init];
    model.mediaType = DVEAlbumAssetModelMediaTypeUnknow;
    model.mediaSubType = DVEAlbumAssetModelMediaSubTypeUnknow;
    switch (asset.mediaType) {
        case PHAssetMediaTypeVideo:
            model.mediaType = DVEAlbumAssetModelMediaTypeVideo;
            if (asset.mediaSubtypes == PHAssetMediaSubtypeVideoHighFrameRate) {
                model.mediaSubType = DVEAlbumAssetModelMediaSubTypeVideoHighFrameRate;
            }
            break;
        case PHAssetMediaTypeAudio:
            model.mediaType = DVEAlbumAssetModelMediaTypeAudio;
            break;
        case PHAssetMediaTypeImage: {
            model.mediaType = DVEAlbumAssetModelMediaTypePhoto;
            if (@available(iOS 9.1, *)) {
                if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                    model.mediaSubType = DVEAlbumAssetModelMediaSubTypePhotoLive;
                }
                break;
            }
            if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
                model.mediaSubType = DVEAlbumAssetModelMediaSubTypePhotoGif;
            }
        }
            break;
        default:
            break;
    }

    model.selectedNum = nil;
    model.selectedAmount = 0;
    model.asset = asset;
    if (model.mediaType == DVEAlbumAssetModelMediaTypeVideo) {
        model.videoDuration = [self timeStringWithDuration:asset.duration];
    }
    return model;
}

+ (NSString *)p_getBytesFromDataLength:(NSInteger)dataLength
{
    NSString *bytes;
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%0.1fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%0.0fK",dataLength/1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%@",@(dataLength)];
    }
    return bytes;
}

+ (void)p_getAssetsWithType:(DVEAlbumGetResourceType)type
                filterBlock:(BOOL (^) (PHAsset *))filterBlock
                  ascending:(BOOL)ascending
                 completion:(void (^)(NSArray<DVEAlbumAssetModel *> *, PHFetchResult *))completion
{
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    PHAssetMediaType mediaType = PHAssetMediaTypeImage;
    switch (type) {
        case DVEAlbumGetResourceTypeImage:
            mediaType = PHAssetMediaTypeImage;
            break;
        case DVEAlbumGetResourceTypeVideo:
            mediaType = PHAssetMediaTypeVideo;
            break;
        default:
            break;
    }
    
    
    NSArray<NSSortDescriptor *> *sortDescriptor = @[
        [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(creationDate)) ascending:ascending]
    ];
    fetchOptions.sortDescriptors = sortDescriptor;
    fetchOptions.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary | PHAssetSourceTypeiTunesSynced;
    PHFetchResult<PHAsset *> *result;
    if (type == DVEAlbumGetResourceTypeImageAndVideo) {
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld || mediaType == %ld", PHAssetMediaTypeImage, PHAssetMediaTypeVideo];
        result = [PHAsset fetchAssetsWithOptions:fetchOptions];
    } else {
        result = [PHAsset fetchAssetsWithMediaType:mediaType options:fetchOptions];
    }
    if (result.count > 0) {
        [self getAssetsFromFetchResult:result filterBlock:filterBlock completion:completion];
    } else {
        [self p_getCameraRollAlbumWithType:type completion:^(DVEAlbumModel *model) {
            if (model && [model.result count]) {
                [self getAssetsFromFetchResult:model.result filterBlock:filterBlock completion:completion];
            } else {
                [self p_fetchAssetsWithType:type filterBlock:filterBlock completion:completion];
            }
        }];
    }
}

+ (void)p_getAllAssetsWithType:(DVEAlbumGetResourceType)type
                     ascending:(BOOL)ascending
                    completion:(void (^)(PHFetchResult *))completion
{
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    PHAssetMediaType mediaType = PHAssetMediaTypeImage;
    switch (type) {
        case DVEAlbumGetResourceTypeImage:
            mediaType = PHAssetMediaTypeImage;
            break;
        case DVEAlbumGetResourceTypeVideo:
            mediaType = PHAssetMediaTypeVideo;
            break;
        default:
            break;
    }

    NSArray<NSSortDescriptor *> *sortDescriptor = @[
        [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(creationDate)) ascending:ascending]
    ];
    fetchOptions.sortDescriptors = sortDescriptor;
    fetchOptions.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary | PHAssetSourceTypeiTunesSynced;
    PHFetchResult<PHAsset *> *result;
    if (type == DVEAlbumGetResourceTypeImageAndVideo) {
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld || mediaType == %ld", PHAssetMediaTypeImage, PHAssetMediaTypeVideo];
        result = [PHAsset fetchAssetsWithOptions:fetchOptions];
    } else {
        result = [PHAsset fetchAssetsWithMediaType:mediaType options:fetchOptions];
    }
//    AWELogToolInfo(AWELogToolTagImport, @"fetchAssetsWithMediaType:%ld fetchResult count:%ld",(long)mediaType, (long)[result count]);
    if (result.count > 0) {
        TOCBLOCK_INVOKE(completion, result);
    } else {
        [self p_getCameraRollAlbumWithType:type completion:^(DVEAlbumModel *model) {
            if (model && [model.result count]) {
                TOCBLOCK_INVOKE(completion, result);
            } else {
                [self p_fetchAssetsWithType:type filterBlock:nil completion:^(NSArray<DVEAlbumAssetModel *> *assetModelArr, PHFetchResult *result) {
                    TOCBLOCK_INVOKE(completion, result);
                }];
            }
        }];
    }
}

//new solution for fixing album assets fetch empty bug
+ (void)p_fetchAssetsWithType:(DVEAlbumGetResourceType)mediaType
                  filterBlock:(BOOL (^) (PHAsset *phAsset))filterBlock
                   completion:(void (^)(NSArray<DVEAlbumAssetModel *> *, PHFetchResult *))completion
{
    NSMutableArray *otherAlbumsAssetArray = [NSMutableArray array];//album assets except default album
    NSMutableArray *userLibraryAssetArray = [NSMutableArray array];//default album assets
    NSMutableDictionary *userLibraryIdentifiersDic = [NSMutableDictionary dictionary];//default album identifiers
    
    //fetch assets from all albums
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    
    NSMutableArray *allAlbums = [NSMutableArray array];
    [allAlbums acc_addObject:myPhotoStreamAlbum];
    [allAlbums acc_addObject:topLevelUserCollections];
    [allAlbums acc_addObject:syncedAlbums];
    [allAlbums acc_addObject:sharedAlbums];
    [allAlbums acc_addObject:smartAlbums];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    switch (mediaType) {
        case DVEAlbumGetResourceTypeImage:
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
            break;
        case DVEAlbumGetResourceTypeVideo:
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeVideo];
            break;
        default:
            break;
    }
    
    PHFetchResult<PHAsset *> *defaultFetchResult;
    for (PHFetchResult *fetchResult in allAlbums) {
        for (PHAssetCollection *collection in fetchResult) {
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            if (collection.estimatedAssetCount <= 0 && ![self p_isCameraRollAlbum:collection]) continue;
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) continue;
            if ([self p_isRecentlyDeleteAlbum:collection]) continue;
            
            PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            if (assets.count) {
                if ([self p_isCameraRollAlbum:collection]) {//default album
                    defaultFetchResult = assets;
                    for (PHAsset *ass in assets) {
                        if ([ass.localIdentifier length]) {
                            if (filterBlock) {
                                if (filterBlock(ass)) {
                                    [userLibraryAssetArray acc_addObject:[self p_assetModelWithPHAsset:ass]];
                                }
                            } else {
                                [userLibraryAssetArray acc_addObject:[self p_assetModelWithPHAsset:ass]];
                            }
                        }
                    }
                } else {//other albums
                    for (PHAsset *ass in assets) {
                        if ([ass.localIdentifier length]) {
                            if (filterBlock) {
                                if (filterBlock(ass)) {
                                    [otherAlbumsAssetArray acc_addObject:[self p_assetModelWithPHAsset:ass]];
                                }
                            } else {
                                [otherAlbumsAssetArray acc_addObject:[self p_assetModelWithPHAsset:ass]];
                            }
                        }
                    }
                }
            }
        }
    }
//    AWELogToolInfo(AWELogToolTagImport, @"fetch assets total time %.2f type:%ld",fabs(CFAbsoluteTimeGetCurrent() - startFetch),(long)mediaType);
    
    //filter duplicate asstes in different albums
    NSMutableArray *finalArray = [NSMutableArray array];
    if ([userLibraryAssetArray count]) {
        [finalArray addObjectsFromArray:userLibraryAssetArray];
        
        //filter logic
        [userLibraryIdentifiersDic removeAllObjects];
        [userLibraryAssetArray enumerateObjectsUsingBlock:^(DVEAlbumAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.asset.localIdentifier length]) {
                userLibraryIdentifiersDic[obj.asset.localIdentifier] = obj.asset.localIdentifier;
            }
        }];
        
        [otherAlbumsAssetArray enumerateObjectsUsingBlock:^(DVEAlbumAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.asset.localIdentifier length]) {
                if (!userLibraryIdentifiersDic[obj.asset.localIdentifier]) {
                    [finalArray acc_addObject:obj];
                }
            }
        }];
    } else {
        [finalArray addObjectsFromArray:otherAlbumsAssetArray];
    }
    
    //remove tmp for memory
    [allAlbums removeAllObjects];
    [otherAlbumsAssetArray removeAllObjects];
    [userLibraryAssetArray removeAllObjects];
    [userLibraryIdentifiersDic removeAllObjects];
    
//    AWELogToolInfo(AWELogToolTagImport, @"mediaType:%ld fetchResult count:%ld",(long)mediaType, (long)[finalArray count]);
    //finally callback
    dispatch_async(dispatch_get_main_queue(), ^{
        TOCBLOCK_INVOKE(completion,finalArray,defaultFetchResult);
    });
}


+ (void)p_getAllAlbumsForMVWithType:(DVEAlbumGetResourceType)type
                         completion:(void (^)(NSArray<DVEAlbumModel *> *))completion
{
    NSMutableArray *albumArr = [NSMutableArray array];
    
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    switch (type) {
        case DVEAlbumGetResourceTypeImage:
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %@", @(PHAssetMediaTypeImage)];
            break;
        case DVEAlbumGetResourceTypeVideo:
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %@", @(PHAssetMediaTypeVideo)];
            break;
        case DVEAlbumGetResourceTypeImageAndVideo:
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %@ || mediaType == %@", @(PHAssetMediaTypeImage), @(PHAssetMediaTypeVideo)];
            break;
        case DVEAlbumGetResourceTypeMoments:
            break;
    }
    NSArray<NSSortDescriptor *> *sortDescriptor = @[
                                                    [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(creationDate)) ascending:YES]
                                                    ];
    option.sortDescriptors = sortDescriptor;
    
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    NSArray *allAlbums = @[myPhotoStreamAlbum,smartAlbums,topLevelUserCollections,syncedAlbums,sharedAlbums];
    
    for (PHFetchResult *fetchResult in allAlbums) {
        for (PHAssetCollection *collection in fetchResult) {
            if (![collection isKindOfClass:[PHAssetCollection class]]) {
                continue;
            }
            
            if (collection.estimatedAssetCount <= 0 && ![self p_isCameraRollAlbum:collection]) {
                continue;
            }
            
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (fetchResult.count < 1 && ![self p_isCameraRollAlbum:collection]) {
                continue;
            }
            
            if ([self p_isRecentlyDeleteAlbum:collection]) {
                continue;
            }
            
            if ([self p_isCameraRollAlbum:collection]) {
                DVEAlbumModel *albumModel = [self p_modelWithResult:fetchResult name:collection.localizedTitle isCameraRoll:YES assetAscending:YES];
                albumModel.localIdentifier = collection.localIdentifier;
                [albumArr insertObject:albumModel atIndex:0];
            } else {
                DVEAlbumModel *albumModel = [self p_modelWithResult:fetchResult name:collection.localizedTitle isCameraRoll:NO assetAscending:YES];
                albumModel.localIdentifier = collection.localIdentifier;
                [albumArr addObject:albumModel];
            }
        }
    }
    
    TOCBLOCK_INVOKE(completion, albumArr);
}

//获取相机胶卷
+ (void)p_getCameraRollAlbumWithType:(DVEAlbumGetResourceType)type completion:(void (^)(DVEAlbumModel *model))completion
{
    __block DVEAlbumModel *model = nil;
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    switch (type) {
        case DVEAlbumGetResourceTypeImage:
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %@", @(PHAssetMediaTypeImage)];
            break;
        case DVEAlbumGetResourceTypeVideo:
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %@", @(PHAssetMediaTypeVideo)];
            break;
        case DVEAlbumGetResourceTypeImageAndVideo:
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %@ || mediaType == %@", @(PHAssetMediaTypeImage), @(PHAssetMediaTypeVideo)];
            break;
        case DVEAlbumGetResourceTypeMoments:
            break;
    }
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in smartAlbums) {
        if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
        if (collection.estimatedAssetCount <= 0) continue;
        if ([self p_isCameraRollAlbum:collection]) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            model = [self p_modelWithResult:fetchResult name:collection.localizedTitle isCameraRoll:YES assetAscending:YES];
            model.localIdentifier = collection.localIdentifier;
            break;
        }
    }
//    AWELogToolInfo(AWELogToolTagImport, @"mediaType:%ld fetchResult count:%ld",(long)type, (long)[model.result count]);
    TOCBLOCK_INVOKE(completion,model);
}

+ (void)p_getAllAlbumsWithType:(DVEAlbumGetResourceType)type
                     ascending:(BOOL)ascending
                assetAscending:(BOOL)assetAscending
                    completion:(void (^)(NSArray<DVEAlbumModel *> *))completion
{
    NSMutableArray *albumArr = [NSMutableArray array];
    NSMutableArray *sortedAlbumArr = [NSMutableArray array];
    
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    switch (type) {
        case DVEAlbumGetResourceTypeImage:
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %@", @(PHAssetMediaTypeImage)];
            break;
        case DVEAlbumGetResourceTypeVideo:
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %@", @(PHAssetMediaTypeVideo)];
            break;
        case DVEAlbumGetResourceTypeImageAndVideo:
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %@ || mediaType == %@", @(PHAssetMediaTypeImage), @(PHAssetMediaTypeVideo)];
            break;
        case DVEAlbumGetResourceTypeMoments:
            break;
    }
    NSArray<NSSortDescriptor *> *sortDescriptor = @[
                                                    [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(creationDate)) ascending:assetAscending]
                                                    ];
    option.sortDescriptors = sortDescriptor;
    
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    NSArray *allAlbums = @[myPhotoStreamAlbum,smartAlbums,topLevelUserCollections,syncedAlbums,sharedAlbums];
    for (PHFetchResult *fetchResult in allAlbums) {
        for (PHAssetCollection *collection in fetchResult) {
            if (![collection isKindOfClass:[PHAssetCollection class]] || [self p_isRecentlyDeleteAlbum:collection]) continue;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if ([self p_isCameraRollAlbum:collection]) {
                DVEAlbumModel *albumModel = [self p_modelWithResult:fetchResult name:collection.localizedTitle isCameraRoll:YES assetAscending:assetAscending];
                albumModel.localIdentifier = collection.localIdentifier;
                [sortedAlbumArr addObject:albumModel];
            } else {
                DVEAlbumModel *albumModel = [self p_modelWithResult:fetchResult name:collection.localizedTitle isCameraRoll:NO assetAscending:assetAscending];
                [albumArr addObject:albumModel];
                albumModel.localIdentifier = collection.localIdentifier;
            }
        }
    }
    
    NSMutableArray *hasLastUpdateDateAlbum = [[albumArr acc_filter:(^(DVEAlbumModel *album){
        return (BOOL)(album.lastUpdateDate != nil);
    })] mutableCopy];
    
    [hasLastUpdateDateAlbum sortUsingComparator:^NSComparisonResult(DVEAlbumModel *album1, DVEAlbumModel *album2) {
        if (ascending) {
            return [album1.lastUpdateDate compare:album2.lastUpdateDate];
        } else {
            return [album2.lastUpdateDate compare:album1.lastUpdateDate];
        }
    }];
    
    [hasLastUpdateDateAlbum addObjectsFromArray:[albumArr acc_filter:(^(DVEAlbumModel *album){
        return (BOOL)(album.lastUpdateDate == nil);
    })]];
    
    [sortedAlbumArr addObjectsFromArray:[hasLastUpdateDateAlbum copy]];
    TOCBLOCK_INVOKE(completion, sortedAlbumArr);
}

+(void)p_cacheFetchCountWithResult:(NSArray<DVEAlbumAssetModel *> *)assetModelArray type:(DVEAlbumGetResourceType)type
{
//    NSString *storageKey = type == DVEAlbumGetResourceTypeImage ? kDVEFetchedAssetsCountKey_IMG : kDVEFetchedAssetsCountKey_Video;
//    NSNumber *lastTimeCached = [TOCCache() objectForKey:storageKey];
//    BOOL shouldCache = YES;
//    if (lastTimeCached && (!assetModelArray.count || lastTimeCached.integerValue == assetModelArray.count)) {
//        shouldCache = NO;
//    }
//
//    if (shouldCache) {
//        [TOCCache() setObject:@([assetModelArray count]) forKey:storageKey];
//    }
}

+ (void)p_cacheFetchCountWithFetchResult:(PHFetchResult *)result type:(DVEAlbumGetResourceType)type
{
//    NSString *storageKey = type == DVEAlbumGetResourceTypeImage ? kDVEFetchedAssetsCountKey_IMG : kDVEFetchedAssetsCountKey_Video;
//    NSNumber *lastTimeCached = [TOCCache() objectForKey:storageKey];
//    BOOL shouldCache = YES;
//    if (lastTimeCached && (!result.count || lastTimeCached.integerValue == result.count)) {
//        shouldCache = NO;
//    }
//    if (shouldCache) {
//        [TOCCache() setObject:@([result count]) forKey:storageKey];
//    }
}

@end




