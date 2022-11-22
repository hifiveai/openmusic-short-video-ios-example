//
//  DVEAlbumCutSameMaterialAssetModel.h
//  VideoTemplate
//
//  Created by bytedance on 2021/4/20.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "DVEAlbumAssetModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface DVEAlbumCutSameMaterialAssetModel : NSObject

@property (nonatomic, strong) DVEAlbumAssetModel *DVEAlbumAssetModel;

@property (nonatomic, copy  ) NSURL *currentImageFileURL;

@property (nonatomic, strong) UIImage *currentImage;

@property (nonatomic, copy) NSString *currentImageName;

@property (nonatomic, assign) CGSize currentImageSize;

@property (nonatomic, copy  ) NSURL *processedImageFileURL;

@property (nonatomic, strong) UIImage *processedImage;

@property (nonatomic, copy) NSString *processedImageName;

@property (nonatomic, assign) CGSize processedImageSize;


@property (nonatomic, strong) AVURLAsset *processAsset;

@property (nonatomic, assign) PHImageRequestID requestId;

@property (nonatomic, assign) CGFloat avCompressProgress;

@property (nonatomic, assign) BOOL isReady;

@property (nonatomic, assign) BOOL needReverse;

@end

NS_ASSUME_NONNULL_END
