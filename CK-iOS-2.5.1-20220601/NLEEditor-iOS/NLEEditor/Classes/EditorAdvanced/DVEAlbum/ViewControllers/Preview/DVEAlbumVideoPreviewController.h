//
//  DVEAlbumVideoPreviewController.h
//  CutSameIF
//
//  Created by bytedance on 2020/7/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DVEAlbumAssetModel;

@interface DVEAlbumVideoPreviewController : UIViewController

- (instancetype)initWithAssetModel:(DVEAlbumAssetModel *)assetModel coverImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
