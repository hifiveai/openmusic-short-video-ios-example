//
//  ACCAlbumViewControllerProtocol.h
//  CutSameIF
//
//  Created by bytedance on 2020/7/31.
//

#import <Foundation/Foundation.h>
#import "DVEAlbumViewModel.h"
#import "DVEAlbumInputData.h"
#import "DVEAlbumDataModel.h"
#import "DVEAlbumAssetModel.h"
#import "DVEPhotoAlbumDefine.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DVEAlbumListViewControllerProtocol <NSObject>

@property (nonatomic, assign) DVEAlbumGetResourceType resourceType;
@property (nonatomic, assign) BOOL hasEnterCurrentVC;
@property (nonatomic, weak) id<DVEAlbumListViewControllerDelegate> vcDelegate;

- (void)albumListShowTabDotIfNeed:(void (^)(BOOL showDot, UIColor *color))showDotBlock;

@optional

- (void)requestAuthorizationCompleted;

@end


NS_ASSUME_NONNULL_END

