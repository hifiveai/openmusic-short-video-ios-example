//
//  DVEAlbumLoadingViewProtocol.h
//  CameraClient
//
//  Created by bytedance on 2019/11/19.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DVEAlbumProgressLoadingViewType) {
    TOCProgressLoadingViewTypeNormal = 0,
    DVEAlbumProgressLoadingViewTypeProgress, //有进度
    DVEAlbumProgressLoadingViewTypeHorizon,
};

@protocol DVEAlbumLoadingViewProtocol <NSObject>

@property (nonatomic, assign) BOOL cancelable;
@property (nonatomic, copy) dispatch_block_t cancelBlock;

- (void)startAnimating;
- (void)stopAnimating;

- (void)dismiss;
- (void)dismissWithAnimated:(BOOL)animated;

- (void)allowUserInteraction:(BOOL)allow;

@end

@protocol DVEAlbumTextLoadingViewProtcol <DVEAlbumLoadingViewProtocol>

@end

@protocol DVEAlbumProcessViewProtcol <DVEAlbumLoadingViewProtocol>

@property (nonatomic, copy, nullable) NSString *loadingTitle;
@property (nonatomic, assign) CGFloat loadingProgress;

- (void)showAnimated:(BOOL)animated;
- (void)showOnView:(UIView *)view animated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;

@end

@protocol DVEAlbumLoadingProtocol <NSObject>

#pragma mark - Simple Loading
+ (UIView<DVEAlbumLoadingViewProtocol> *)loadingView;

+ (UIView<DVEAlbumLoadingViewProtocol> *)showLoadingOnView:(UIView *)view;

#pragma mark - Text Loading
+ (UIView<DVEAlbumTextLoadingViewProtcol> *)showTextLoadingOnView:(UIView *)view title:(nullable NSString *)title animated:(BOOL)animated;

#pragma mark - Process

+ (UIView<DVEAlbumProcessViewProtcol> *)showProcessOnView:(UIView *)view title:(NSString *)title animated:(BOOL)animated;

@end

//FOUNDATION_STATIC_INLINE Class<DVEAlbumLoadingProtocol> DVEAlbumLoadingViewDefaultImpl {
//    return [DVEAlbumUnionProvider(@protocol(DVEAlbumLoadingProtocol)) class];
//}

NS_ASSUME_NONNULL_END





