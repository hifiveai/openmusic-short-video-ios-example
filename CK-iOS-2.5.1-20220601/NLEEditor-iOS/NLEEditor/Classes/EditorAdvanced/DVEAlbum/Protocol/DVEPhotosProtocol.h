//
//  DVEPhotosProtocol.h
//  Pods
//
//  Created by bytedance on 2019/9/5.
//  操作相册资源

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "DVEAlbumAssetModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    DVEAlbumGetResourceTypeImage,
    DVEAlbumGetResourceTypeVideo,
    DVEAlbumGetResourceTypeImageAndVideo,
    DVEAlbumGetResourceTypeMoments,
} DVEAlbumGetResourceType;

@protocol DVEPhotosProtocol <NSObject>

- (int32_t)getUIImageWithPHAsset:(PHAsset *)asset
                       imageSize:(CGSize)imageSize
            networkAccessAllowed:(BOOL)networkAccessAllowed
                 progressHandler:(void (^ _Nullable)(CGFloat progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
                      completion:(void (^ _Nullable)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;



- (void)getOriginalPhotoDataFromICloudWithAsset:(PHAsset *)asset
                                progressHandler:(void (^ _Nullable)(CGFloat progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
                                     completion:(void (^ _Nullable)(NSData *data, NSDictionary *info))completion;

- (void)getAssetsWithType:(DVEAlbumGetResourceType)type
              ignoreCache:(BOOL)ignore
              filterBlock:(BOOL (^) (PHAsset *phAsset))filterBlock
               completion:(void (^) (NSArray<DVEAlbumAssetModel *> *assetModelArray, PHFetchResult *result))completion;

- (void)getLatestAssetWithType:(DVEAlbumGetResourceType)type
                    completion:(void (^) (DVEAlbumAssetModel *latestAssetModel))completion;

- (void)getLatesAssetCount:(NSUInteger)count
                      type:(DVEAlbumGetResourceType)type
                completion:(void (^) (NSArray<DVEAlbumAssetModel *> *latesAssets))completion;

@end

//FOUNDATION_STATIC_INLINE id<DVEPhotosProtocol> DVEPhotos() {
//    return [DVEInnerServiceProvider() resolveObject:@protocol(DVEPhotosProtocol)];
//}

NS_ASSUME_NONNULL_END
