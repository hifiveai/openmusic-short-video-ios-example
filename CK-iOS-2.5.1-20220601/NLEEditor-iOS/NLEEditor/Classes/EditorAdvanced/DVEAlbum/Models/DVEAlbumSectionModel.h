//
//  DVEAlbumSectionModel.h
//  CameraClient
//
//  Created by bytedance on 2020/7/16.
//

#import <Foundation/Foundation.h>
#import <IGListDiffKit/IGListDiffable.h>
#import "DVEAlbumAssetModel.h"
//#import "DVEPhotoManager.h"
#import "DVEAlbumDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEAlbumSectionModel : NSObject <IGListDiffable>

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) DVEAlbumGetResourceType resourceType;
@property (nonatomic, strong) NSMutableArray<DVEAlbumAssetModel *> *assetsModels;
@property (nonatomic, strong) DVEAlbumAssetDataModel *assetDataModel;

@end

NS_ASSUME_NONNULL_END
