//
//  DVEAlbumVCNavView.h
//  CameraClient
//
//  Created by bytedance on 2020/6/18.
//

#import <UIKit/UIKit.h>
#import "DVEImageRightButton.h"
#import "DVEPhotoAlbumDefine.h"
#import <objc/runtime.h>

typedef enum : NSUInteger {
    DVEAlbumVCNavViewModeNoPhoto,
    DVEAlbumVCNavViewModeOnePhoto,
    DVEAlbumVCNavViewModeMutiPhoto,
    DVEAlbumVCNavViewModeMutiVideo,
} DVEAlbumVCNavViewMode;

NS_ASSUME_NONNULL_BEGIN

@interface DVEAlbumVCNavView : UIView

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) DVEImageRightButton *photoNextButton;//选中 1 张照片时显示
@property (nonatomic, strong) DVEImageRightButton *photoMovieButton;//选中 >1 张照片时显示
@property (nonatomic, strong) DVEImageRightButton *videoNextButton;//选中 >=1 个video时显示
@property (nonatomic, strong) DVEImageRightButton *selectAlbumButton; //选择相册，点击显示下拉菜单展示所有相册
@property (nonatomic, strong) DVEImageRightButton *mvDoneButton; //mv影集确定按钮
@property (nonatomic, strong) UIButton *leftCancelButton;//左上角的取消按钮
@property (nonatomic, strong) UIButton *rightGoToShootButton; // 相册前置去拍摄按钮
@property (nonatomic, strong) DVEAlbumAnimatedButton *closeButton; // 相册前置删除按钮

@property (nonatomic, assign, readonly) DVEAlbumVCNavViewMode mode;
@property (nonatomic, assign, readonly) BOOL isAnimating;

- (instancetype)initWithVCType:(DVEAlbumVCType)type;

- (void)switchToMode:(DVEAlbumVCNavViewMode)mode;
- (void)updatePhotoMovieTitleWithPhotoCount:(NSInteger)count;
//-----由SMCheckProject工具删除-----
//- (void)updateVideoNextTitleWithVideoCount:(NSInteger)count enabled:(BOOL)enabled;
- (void)updateVideoNextTitleWithPrefix:(NSString * _Nullable)prefixTitle videoCount:(NSInteger)count enabled:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END

