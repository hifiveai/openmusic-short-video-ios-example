//
//  DVEAlbumWorksPreviewViewControllerProtocol.h
//  CutSameIF
//
//  Created by bytedance on 2020/3/17.
//

#import <Foundation/Foundation.h>
#import "DVEAlbumCutSameMaterialAssetModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^DVEAlbumWorksPreviewViewControllerDismissBlock)(void);
typedef void(^DVEAlbumWorksPreviewViewControllerCompletion)(NSURL * _Nullable videoURL, NSError * _Nullable error);
typedef void(^DVEAlbumWorksPreviewViewControllerExportProgressBlock)(CGFloat progress);
typedef void(^DVEAlbumWorksPreviewViewControllerChangeMaterialCallback)(DVEAlbumCutSameMaterialAssetModel *replaceMaterialAsset);
//typedef void(^DVEAlbumWorksPreviewViewControllerChangeMaterialCallback)(PHAsset *replaceAsset);
//typedef void(^ACCWorksPreviewViewControllerChangeMaterialBlock)(NSArray<DVEAlbumCutSameMaterialAssetModel *> *currentMaterialAssets, BOOL needReverse, CMTime fragmentDuration, DVEAlbumWorksPreviewViewControllerChangeMaterialCallback callback);

@protocol DVEAlbumWorksPreviewViewControllerProtocol <NSObject>

//@property (nonatomic, strong) DVEAlbumTemplateModel *respTemplateModel;

//@property (nonatomic, strong) DVEAlbumPublishModel *publishModel;

@property (nonatomic, copy  ) NSArray<DVEAlbumCutSameMaterialAssetModel *> *materialAssets;

@property (nonatomic, copy  ) DVEAlbumWorksPreviewViewControllerDismissBlock dismissBlock;

@property (nonatomic, copy  ) DVEAlbumWorksPreviewViewControllerCompletion completion;

//@property (nonatomic, copy  ) ACCWorksPreviewViewControllerChangeMaterialBlock changeMaterialAction;

//@property (nonatomic, copy  ) dispatch_block_t startExportCallback;

@property (nonatomic, copy  ) DVEAlbumWorksPreviewViewControllerExportProgressBlock exportProgressCallback;

@optional
//@property (nonatomic, assign) BOOL isVideoAndPicMixed;

//@property (nonatomic, strong) id dataManager;

- (void)cancelExport;

@end


FOUNDATION_STATIC_INLINE id<DVEAlbumWorksPreviewViewControllerProtocol> TOCWorksPreviewViewController() {
    return nil;
}

NS_ASSUME_NONNULL_END
