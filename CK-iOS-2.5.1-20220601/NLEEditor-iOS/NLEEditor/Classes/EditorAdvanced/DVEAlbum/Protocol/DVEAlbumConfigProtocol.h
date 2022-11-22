//
//  DVEAlbumConfigProtocol.h
//  CameraClient
//
//  Created by bytedance on 2020/6/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DVEAlbumConfigProtocol <NSObject>

- (BOOL)isGalleryCellSelectLabelHidden;

- (BOOL)isVideoClipExportEnabled;

- (BOOL)distinctSingleVideoMode;

- (BOOL)shouldCheckShowLongVideoBubble;

- (CGFloat)slidingViewControllerOriginY;

- (BOOL)shouldSlidingTabConfigSelectionLine;

- (UIFont *)galleryTimeLabelFont;

- (UIColor *)gallerySelectHintLabelColor;

- (CGFloat)sliderViewStretchAnimationFinalLength;

- (BOOL)supportOnePhoto;

@end

NS_ASSUME_NONNULL_END
