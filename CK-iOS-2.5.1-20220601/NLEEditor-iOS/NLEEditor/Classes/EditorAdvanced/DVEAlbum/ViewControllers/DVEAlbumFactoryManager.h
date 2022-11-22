//
//  DVEAlbumFactoryManager.h
//  AWEStudio-Pods-Aweme
//
//  Created by bytedance on 2020/8/12.
//

#import <Foundation/Foundation.h>
#import "DVEPhotoAlbumDefine.h"
#import "DVEAlbumInputData.h"
#import "DVEAlbumViewController.h"
#import "DVEAlbumSelectAlbumAssetsProtocol.h"
#import "DVEStudioAlbumViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEAlbumFactoryManager : NSObject

+ (UIViewController<DVEAlbumSelectAlbumAssetsComponetProtocol> *)albumControllerWithAlbumInputData:(DVEAlbumInputData *)inputData;

@end

NS_ASSUME_NONNULL_END
