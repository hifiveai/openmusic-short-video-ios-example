//
//  ACCSelectAlbumAssetsProtocol.h
//  Pods
//
//  Created by bytedance on 2019/8/9.
//  打开相册选择页面

#import <Foundation/Foundation.h>
//#import <EffectPlatformSDK/IESEffectModel.h>
//#import "TOCInnerDefines.h"
NS_ASSUME_NONNULL_BEGIN

@class DVEAlbumAssetModel, DVEAlbumVCNavView;

typedef void(^DVEAlbumDismissBlock)(void);
typedef void(^DVEAlbumSelectPhotoCompletion)(DVEAlbumAssetModel * _Nullable asset);
//typedef void(^DVEAlbumSelectRemoteResourceCompletion)(NSArray <NSString *> * _Nullable url, IESEffectModel *effectModel);
typedef void(^DVEAlbumSelectAssetsCompletion)( NSArray<DVEAlbumAssetModel*> * _Nullable assets);
typedef BOOL(^DVEAlbumSelectShouldStartClipBlock)(void);

typedef NS_ENUM(NSUInteger, DVEAlbumSelectAlbumAssetsType) {
    DVEAlbumSelectAlbumAssetsTypeMusicDetail,//@"上传", 生成照片电影（音乐详情页的样式）
    DVEAlbumSelectAlbumAssetsTypeDirectRecordUpload, // 直接开拍的上传
    DVEAlbumSelectAlbumAssetsTypeStory,
    DVEAlbumSelectAlbumAssetsTypeMV, // 新照片电影
    DVEAlbumSelectAlbumAssetsTypePixaloop, // pixaloop 照片变视频
    DVEAlbumSelectAlbumAssetsTypeVideoBG, // 视频背景
    DVEAlbumSelectAlbumAssetsTypeGreenScreen, // green screen mode 视频
    DVEAlbumSelectAlbumAssetsTypeCustomSticker, // Custom sticker
    DVEAlbumSelectAlbumAssetsTypeAIVideoClip,             // 卡点音乐追加视频
    DVEAlbumSelectAlbumAssetsTypeCutSame,                 // Cut the Same, videoMixPic MV  use cutsame vc type either
    DVEAlbumSelectAlbumAssetsTypeCutSameChangeMaterial,   // Cut the Same, change material
    DVEAlbumSelectAlbumAssetsTypePhotoToVideo,            // single or multi photo transform to video
    DVEAlbumSelectAlbumAssetsTypeFirstCreative,  // 首发奖励的入口，只展示混合页
};

@protocol DVEAlbumSelectAlbumAssetsDelegate <NSObject>

@optional

- (void)albumViewControllerDidRequestPhotoAuthorization;

@end

@protocol DVEAlbumSelectAlbumAssetsComponetProtocol <NSObject>

//@property (nonatomic, strong) DVEAlbumPublishModel *originUploadPublishModel;
@property (nonatomic, strong) DVEAlbumVCNavView *topNavView;
@property (nonatomic, assign) BOOL needEnablePhotoToVideo;
//@property (nonatomic, copy) DVEAlbumPublishModel *(^handleCancelMusicBlock)(DVEAlbumPublishModel *);
@property (nonatomic, weak, nullable) id<DVEAlbumSelectAlbumAssetsDelegate> delegate;

@end

@class DVEAlbumPublishModel;
@protocol DVEAlbumSelectAlbumAssetsInputDataProtocol <NSObject>
@property (nonatomic, strong) DVEAlbumPublishModel *originUploadPublishModel;
@property (nonatomic, assign) BOOL shouldUseOriginPublishModel;
@property (nonatomic, assign) BOOL landMomentsTab;
@property (nonatomic, assign) BOOL shouldApplyAlbumFront;
@end

FOUNDATION_STATIC_INLINE id<DVEAlbumSelectAlbumAssetsInputDataProtocol> TOCSelectAlbumAssetsInputData() {
    return nil;
}

NS_ASSUME_NONNULL_END
