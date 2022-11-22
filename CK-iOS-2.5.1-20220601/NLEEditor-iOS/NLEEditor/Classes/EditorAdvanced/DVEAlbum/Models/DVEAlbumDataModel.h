//
//  DVEAlbumDataModel.h
//  CameraClient
//
//  Created by bytedance on 2020/6/22.
//

#import <Foundation/Foundation.h>
#import "DVEAlbumAssetModel.h"
#import "DVEPhotoManager.h"
#import "DVEPhotosProtocol.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface DVEAlbumVCModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) DVEAlbumGetResourceType resourceType;
@property (nonatomic, strong) UIViewController *listViewController;
@property (nonatomic, assign) BOOL canMutilSelected;

@end

@interface DVEAlbumAssetModelManager : NSObject

+ (instancetype)createWithPHFetchResult:(PHFetchResult *)result;
- (DVEAlbumAssetModel *)objectIndex:(NSInteger)index;
- (DVEAlbumAssetModel *)assetModelForPhAsset:(PHAsset *)asset;
- (BOOL)containsObject:(DVEAlbumAssetModel *)anObject;
- (NSInteger)indexOfObject:(DVEAlbumAssetModel *)model;
- (PHFetchResult *)fetchResult;

@end

@interface DVEAlbumAssetDataModel : NSObject
@property (nonatomic, assign) DVEAlbumGetResourceType resourceType;
@property (nonatomic, strong) DVEAlbumAssetModelManager *assetModelManager;

- (DVEAlbumAssetModel *)objectIndex:(NSInteger)index;
- (NSInteger)numberOfObject;
- (NSInteger)indexOfObject:(DVEAlbumAssetModel *)model;
- (BOOL)containsObject:(DVEAlbumAssetModel *)anObject;
- (void)configShowIndexFilterBlock:(BOOL (^)(PHAsset *asset))filterBlock;

#pragma mark - only for preview
- (DVEAlbumAssetModel *)previewObjectIndex:(NSInteger)index;
- (NSInteger)previewNumberOfObject;
- (NSInteger)previewIndexOfObject:(DVEAlbumAssetModel *)model;
- (BOOL)previewContainsObject:(DVEAlbumAssetModel *)anObject;
- (void)configDataWithPreviewFilterBlock:(BOOL (^)(PHAsset *asset))filterBlock;
- (BOOL)removePreviewInvalidAssetForPostion:(NSInteger)position;

@end

@interface DVEAlbumDataModel : NSObject

@property (nonatomic, strong) DVEAlbumModel *albumModel;
@property (nonatomic, strong) NSIndexPath *targetIndexPath;

//performance
@property (nonatomic, assign) NSTimeInterval timeNextButtonPress;

// album list
@property (nonatomic, strong) NSArray<DVEAlbumModel *> *allAlbumModels;

// data source
@property (nonatomic, strong) NSMutableArray<DVEAlbumAssetModel *> *videoSourceAssetsModels;  // videos
@property (nonatomic, strong) NSMutableArray<DVEAlbumAssetModel *> *photoSourceAssetsModels;  // photos
@property (nonatomic, strong) NSMutableArray<DVEAlbumAssetModel *> *mixedSourceAssetsModels;  // videos && photos

@property (nonatomic, strong) DVEAlbumAssetDataModel *videoSourceAssetsDataModel;
@property (nonatomic, strong) DVEAlbumAssetDataModel *photoSourceAssetsDataModel;
@property (nonatomic, strong) DVEAlbumAssetDataModel *mixedSourceAssetsDataModel;

@property (nonatomic, strong) RACSubject<DVEAlbumAssetDataModel *> *resultSourceAssetsSubject;

// selected assets
@property (nonatomic, strong) NSMutableArray<DVEAlbumAssetModel *> *videoSelectAssetsModels;  // selected videos
@property (nonatomic, strong) NSMutableArray<DVEAlbumAssetModel *> *photoSelectAssetsModels;  // selected videos
@property (nonatomic, strong) NSMutableArray<DVEAlbumAssetModel *> *mixedSelectAssetsModels;  // selected videos && photos

// fetch result
@property (nonatomic, strong) PHFetchResult *fetchResult;

@property (nonatomic, assign) BOOL isMV;
@property (nonatomic, assign) BOOL hasEnterMomentsVC;
@property (nonatomic, assign) NSInteger beforeSelectedPhotoCount;

- (void)addAsset:(DVEAlbumAssetModel *)model forResourceType:(DVEAlbumGetResourceType)resourceType;

- (void)removeAsset:(DVEAlbumAssetModel *)model forResourceType:(DVEAlbumGetResourceType)resourceType;

- (void)removeAllAssetsForResourceType:(DVEAlbumGetResourceType)resourceType;

@end
