//
//  ACCPhotoAlbumDefine.h
//  CameraClient
//
//  Created by bytedance on 2020/6/18.
//
#import <UIKit/UIKit.h>

#ifndef DVEPhotoAlbumDefine_h
#define DVEPhotoAlbumDefine_h

typedef NS_OPTIONS(NSInteger, DVEAlbumResourceTabOptions) {
    DVEAlbumResourceTabVideo = 1,
    DVEAlbumResourceTabPhoto = 1 << 1,
    DVEAlbumResourceTabAll = 1 << 2,
    DVEAlbumResourceTabRemoteResource = 1 << 3,
    DVEAlbumResourceTabMoments = 1 << 4,
};

typedef NS_ENUM(NSUInteger, DVEAlbumVCType) {
    DVEAlbumVCTypeForUpload = 6,            // 直接开拍的上传
    DVEAlbumVCTypeForCutSame,               // Cut the Same
    DVEAlbumVCTypeForCutSameChangeMaterial, // Cut the Same, change material
};

UIKIT_EXTERN NSString * const kAWESelectMusicVCGalleryHasBeenReminded;//是否在上传按钮上使用黄点提醒

@class IESEffectModel, DVEAlbumAssetModel;

typedef BOOL(^DVEAlbumShouldStartClipBlock)(void);
typedef void(^DVEAlbumSelectPhotoCompletion)(DVEAlbumAssetModel * _Nullable asset);
typedef void(^DVEAlbumSelectAssetsCompletion)(NSArray<DVEAlbumAssetModel*> * _Nullable assets);

#endif /* ACCPhotoAlbumDefine_h */

@protocol DVEAlbumListViewControllerDelegate <NSObject>

@optional

- (void)albumListVC:(UIViewController *)listVC didAllowMultiButton:(id)sender;
- (BOOL)albumListVC:(UIViewController *)listVC shouldSelectAsset:(DVEAlbumAssetModel *)assetModel;
- (void)albumListVC:(UIViewController *)listVC didSelectedVideo:(DVEAlbumAssetModel *)assetModel;
- (void)albumListVC:(UIViewController *)listVC didClickedCell:(DVEAlbumAssetModel *)assetModel;


- (BOOL)checkVideoValidForCutSame:(DVEAlbumAssetModel *)assetModel;

@end



