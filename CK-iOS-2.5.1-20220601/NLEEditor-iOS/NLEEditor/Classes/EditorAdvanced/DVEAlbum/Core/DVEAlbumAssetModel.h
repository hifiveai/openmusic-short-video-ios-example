//
//  DVEAlbumAssetModel.h
//  VideoTemplate
//
//  Created by bytedance on 2021/4/22.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    DVEAlbumAssetModelMediaTypeUnknow,
    DVEAlbumAssetModelMediaTypePhoto,
    DVEAlbumAssetModelMediaTypeVideo,
    DVEAlbumAssetModelMediaTypeAudio,
} DVEAlbumAssetModelMediaType;

typedef enum : NSUInteger {
    DVEAlbumAssetModelMediaSubTypeUnknow = 0,
    //视频
    DVEAlbumAssetModelMediaSubTypeVideoHighFrameRate = 1,
    //图片
    DVEAlbumAssetModelMediaSubTypePhotoGif,
    DVEAlbumAssetModelMediaSubTypePhotoLive,
} DVEAlbumAssetModelMediaSubType;


/// 相册素材模型
@interface DVEAlbumAssetModel: NSObject <NSCopying>

/// 素材
@property (nonatomic, strong) PHAsset *asset;
/// 视频时长
@property (nonatomic, copy) NSString *videoDuration;
/// 素材类型
@property (nonatomic, assign) DVEAlbumAssetModelMediaType mediaType;
/// 素材子类
@property (nonatomic, assign) DVEAlbumAssetModelMediaSubType mediaSubType;
/// 选择顺序
@property (nonatomic, strong) NSNumber *selectedNum;
/// asset选择的个数
@property (nonatomic, assign) NSInteger selectedAmount;
/// 创建时间
@property (nonatomic, strong, readonly) NSDate *creationDate;

@property (nonatomic, strong) UIImage *coverImage;
@property (nonatomic, strong) AVAsset *avAsset;
@property (nonatomic, copy) NSDictionary *info;

@property (nonatomic, assign) BOOL isDegraded;

@property (nonatomic, assign) CGFloat iCloudSyncProgress;


@property(nonatomic) NSInteger cellIndex;

@property(nonatomic, copy) NSString *dateFormatStr;

@property (nonatomic, strong) NSDictionary *cropInfo;

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, assign) BOOL isGIFImage;

@property (nonatomic, assign) BOOL canSelect;

+ (instancetype)createWithPHAsset:(PHAsset *)asset;

- (BOOL)isEqualToAssetModel:(DVEAlbumAssetModel *)model identity:(BOOL)identity;

@end


@interface DVEAlbumModel : NSObject

@property (nonatomic, copy) NSString *localIdentifier;
@property (nonatomic, strong) PHFetchResult * result;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSDate *lastUpdateDate;

@property (nonatomic, strong) NSArray<DVEAlbumAssetModel *> *models;

@end


NS_ASSUME_NONNULL_END
