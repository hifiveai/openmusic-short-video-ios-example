//
//  DVEAlbumDefinition.h
//  CutSameIF
//
//  Created by bytedance on 2020/7/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const kDVEAlbumErrorDomain;

//@class HTSVideoData;
@class DVEAlbumAssetModel;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SCIFAlbumUploadResourceType)
{
    SCIFAlbumUploadResourceTypeImage,
    SCIFAlbumUploadResourceTypeVideo,
    SCIFAlbumUploadResourceTypeMix,
};

typedef NS_ENUM(NSInteger, SCIFAlbumErrorCode)
{
    SCIFAlbumErrorCodeNullResource = 1,
    SCIFAlbumErrorCodeDurationTooShort,
    SCIFAlbumErrorCodeDurationTooLong,
    SCIFAlbumErrorCodeUnsupportedSize,
    SCIFAlbumErrorCodeRemoteResource,
    SCIFAlbumErrorCodeImageRatioUnsupported,
};

@interface DVEAlbumDefinition : NSObject

@end

NS_ASSUME_NONNULL_END
