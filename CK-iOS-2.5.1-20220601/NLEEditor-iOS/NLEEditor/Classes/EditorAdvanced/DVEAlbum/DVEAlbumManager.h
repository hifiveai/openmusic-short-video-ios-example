//
//  DVEAlbumManager.h
//  Pods
//
//  Created by bytedance on 2021/8/23.
//

#import <Foundation/Foundation.h>
#import <Photos/PHAsset.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DVEAlbumPickerBlock)(NSArray<PHAsset *> *);

typedef NS_ENUM(NSInteger, DVEAlbumAssetsPickType) {
    DVEAlbumAssetsPickTypeImage,
    DVEAlbumAssetsPickTypeVideo,
    DVEAlbumAssetsPickTypeImageVideo,
};

typedef NS_ENUM(NSInteger, DVEAlbumAssetMediaType) {
    DVEAlbumAssetMediaTypeVideo,
    DVEAlbumAssetMediaTypeImage,
};

@interface DVEAlbumManager : NSObject

+ (void)pushDVEAlbumViewControllerWithBlock:(DVEAlbumPickerBlock)block
                                 singlePick:(BOOL)singlePick
                              firstCreative:(BOOL)firstCreative
                                       type:(DVEAlbumAssetsPickType)type;

+ (void)pushDVEAlbumViewControllerWithBlock:(DVEAlbumPickerBlock)block
                                 singlePick:(BOOL)singlePick
                                       type:(DVEAlbumAssetsPickType)type;

+ (void)pushDVEAlbumViewControllerWithBlock:(DVEAlbumPickerBlock)block
                                 singlePick:(BOOL)singlePick
                         videoLimitDuration:(NSInteger)duration;

+ (void)getAlbumResoucesWithAsset:(PHAsset *)asset 
                       completion:(void(^)(DVEAlbumAssetMediaType type,
                                           NSURL * _Nullable assetURL,
                                           NSData * _Nullable imageData))completion;

@end

NS_ASSUME_NONNULL_END
