//
//  DVEAlbumInputData.h
//  CameraClient
//
//  Created by bytedance on 2020/6/16.
//

#import <Foundation/Foundation.h>
#import "DVEAlbumAssetModel.h"
#import "DVEPhotoAlbumDefine.h"
#import "DVEAlbumDataModel.h"
#import "DVEAlbumViewUIConfig.h"
#import "DVEPhotoAlbumDefine.h"
#import "DVEAlbumTemplateModel.h"
#import "DVEAlbumCutSameFragmentModel.h"
//#import "DVEAlbumWorksPreviewViewControllerProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@interface DVEAlbumInputData : NSObject

@property (nonatomic, assign) BOOL scrollToBottom;
@property (nonatomic, assign) BOOL ascendingOrder;
@property (nonatomic, assign) BOOL needEnablePhotoToVideo;

@property (nonatomic, assign) BOOL isStoryMode;
@property (nonatomic, assign) BOOL albumTabViewHidden;
@property (nonatomic, assign) BOOL needBottomView;
@property (nonatomic, assign) BOOL checkMarkSelectedStyle;
@property (nonatomic, assign) BOOL fromStickPointAnchor;
@property (nonatomic, assign) BOOL enablePicture;
@property (nonatomic, assign) BOOL enableMixedUpload;
@property (nonatomic, assign) BOOL shouldApplyAlbumFront;

@property (nonatomic, assign) DVEAlbumGetResourceType defaultResourceType;
@property (nonatomic, assign) DVEAlbumVCType vcType;
@property (nonatomic, strong) NSArray<DVEAlbumVCModel *> *tabsInfo;
@property (nonatomic, strong) DVEAlbumModel *albumModel;
@property (nonatomic, strong) DVEAlbumViewUIConfig *albumViewUIConfig;

@property (nonatomic, copy) dispatch_block_t dismissBlock;
@property (nonatomic, copy) DVEAlbumSelectPhotoCompletion selectPhotoCompletion;
@property (nonatomic, copy) DVEAlbumSelectAssetsCompletion selectAssetsCompletion;
@property (nonatomic, copy) NSArray<DVEAlbumAssetModel *> *initialSelectedAssetModelArray;

@property (nonatomic, assign) BOOL isFirstCreative;

// photo vc
//@property (nonatomic, strong) IESEffectModel *templateEffectModel;

@property (nonatomic, assign) BOOL shouldUseOriginPublishModel;
@property (nonatomic, assign) BOOL landMomentsTab;

/// select count
@property (nonatomic, assign) NSUInteger initialSelectedPictureCount; // Number of initial selected resources when supporting append selection
@property (nonatomic, assign) NSUInteger maxPictureSelectionCount; // Select the maximum number of photos, the default is 1
@property (nonatomic, assign) NSUInteger minPictureSelectionCount; // Select the minimum number of photos, the default is 1

/// cut same
@property (nonatomic, strong) DVEAlbumTemplateModel *cutSameTemplateModel;
@property (nonatomic, strong) DVEAlbumCutSameFragmentModel *singleFragment;
@property (nonatomic, strong) DVEAlbumAssetModel *singleAssetModel;
/// track info
@property (nonatomic, copy) NSDictionary *trackExtraDic;

@property (nonatomic, copy) NSString *enterFrom;
@property (nonatomic, copy) NSString *enterMethod;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *musicId;
@property (nonatomic, copy) NSString *ugcPathRefer;
@property (nonatomic, assign) BOOL fromShareExtension;


/// next button prefix string
@property (nonatomic, strong) NSString *prefixTitle;

@property (nonatomic, strong, readonly) NSArray *titles;
@property (nonatomic, weak, readonly) NSArray<UIViewController *> *listViewControllers;

@end

NS_ASSUME_NONNULL_END
