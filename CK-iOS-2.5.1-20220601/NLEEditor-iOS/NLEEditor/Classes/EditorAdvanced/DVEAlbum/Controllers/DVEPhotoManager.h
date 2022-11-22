//
//  DVEPhotoManager.h
//  CameraClient
//
//  Created by bytedance on 2020/7/8.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "DVEAlbumAssetModel.h"
#import "DVEPhotosProtocol.h"

typedef enum : NSUInteger {
    DVEAuthorizationStatusNotDetermined = PHAuthorizationStatusNotDetermined,
    DVEAuthorizationStatusRestricted = PHAuthorizationStatusRestricted,
    DVEAuthorizationStatusDenied = PHAuthorizationStatusDenied,
    DVEAuthorizationStatusAuthorized = PHAuthorizationStatusAuthorized,
} DVEAuthorizationStatus;

FOUNDATION_EXPORT NSString * const kDVEFetchedAssetsCountKey_IMG;
FOUNDATION_EXPORT NSString * const kDVEFetchedAssetsCountKey_Video;

NS_ASSUME_NONNULL_BEGIN

@interface DVEPhotoManager : NSObject

+ (DVEAuthorizationStatus)authorizationStatus;
+ (void)requestAuthorizationWithCompletionOnMainQueue:(void(^)(DVEAuthorizationStatus status))handler;

+ (void)getAllAlbumsForMVWithType:(DVEAlbumGetResourceType)type completion:(void (^)(NSArray<DVEAlbumModel *> *))completion;
+ (void)getAllAlbumsWithType:(DVEAlbumGetResourceType)type completion:(void (^)(NSArray<DVEAlbumModel *> *))completion;

+ (void)getLatestAssetWithType:(DVEAlbumGetResourceType)type
                    completion:(void (^) (DVEAlbumAssetModel *latestAssetModel))completion;

+ (void)getAssetsFromFetchResult:(PHFetchResult *)result
                     filterBlock:(BOOL (^) (PHAsset *))filterBlock
                      completion:(void (^)(NSArray<DVEAlbumAssetModel *> *assetModelArray, PHFetchResult *result))completion;

+ (void)getAssetsWithAlbum:(DVEAlbumModel *)album
                      type:(DVEAlbumGetResourceType)type
               filterBlock:(BOOL (^) (PHAsset *))filterBlock
                completion:(void (^) (NSArray *, PHFetchResult *))completion;

+ (void)getAllAlbumsWithType:(DVEAlbumGetResourceType)type
                   ascending:(BOOL)ascending
              assetAscending:(BOOL)assetAscending
                  completion:(void (^)(NSArray<DVEAlbumModel *> *))completion;

//获取图片或视频
+ (void)getAssetsWithType:(DVEAlbumGetResourceType)type
              filterBlock:(BOOL (^) (PHAsset *phAsset))filterBlock
               completion:(void (^) (NSArray<DVEAlbumAssetModel *> *assetModelArray, PHFetchResult *result))completion;

+ (void)getAssetsWithType:(DVEAlbumGetResourceType)type
              filterBlock:(BOOL (^) (PHAsset *))filterBlock
                ascending:(BOOL)ascending
               completion:(void (^) (NSArray<DVEAlbumAssetModel *> *assetModelArray, PHFetchResult *result))completion;

+ (void)getAllAssetsWithType:(DVEAlbumGetResourceType)type
                   ascending:(BOOL)ascending
                  completion:(void (^)(PHFetchResult *))completion;
//获取UIImage
//图片尺寸根据asset计算
+ (int32_t)getUIImageWithPHAsset:(PHAsset *)asset
            networkAccessAllowed:(BOOL)networkAccessAllowed
                 progressHandler:(void (^)(CGFloat progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
                      completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;

+ (int32_t)getUIImageWithPHAsset:(PHAsset *)asset
                       imageSize:(CGSize)imageSize
            networkAccessAllowed:(BOOL)networkAccessAllowed
                 progressHandler:(void (^)(CGFloat progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
                      completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;

//获取image data
+ (void)getPhotoDataWithAsset:(PHAsset *)asset version:(PHImageRequestOptionsVersion)version completion:(void (^)(NSData *data, NSDictionary *info, BOOL isInCloud))completion;
+ (void)getOriginalPhotoDataWithAsset:(PHAsset *)asset completion:(void (^)(NSData *data, NSDictionary *info, BOOL isInCloud))completion;
+ (void)getOriginalPhotoDataFromICloudWithAsset:(PHAsset *)asset
                                progressHandler:(void (^)(CGFloat progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
                                     completion:(void (^)(NSData *data, NSDictionary *info))completion;

//取消request
+ (void)cancelImageRequest:(int32_t)requestID;

+ (NSURL *_Nullable)privateVideoURLWithInfo:(NSDictionary *)info;

+ (NSString *)timeStringWithDuration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END




