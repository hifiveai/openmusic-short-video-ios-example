//
//  DVEVideoCoverResourcePickerView.h
//  NLEEditor
//
//  Created by bytedance on 2021/6/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DVEVideoCoverResourceType) {
    DVEVideoCoverResourceTypeVideoFrame,
    DVEVideoCoverResourceTypeAlbumImage,
};

@protocol DVEVideoCoverResourcePickerDelegate <NSObject>

- (void)pickAlbumImageWithCompletion:(void(^)(UIImage * _Nullable))completion;

- (void)updatePreviewCurrentTimeWithRatio:(CGFloat)ratio;

- (void)showAlbumImageCropViewWithImage:(UIImage *)image;

@end

@interface DVEVideoCoverResourcePickerView : UIView

@property (nonatomic, weak) id<DVEVideoCoverResourcePickerDelegate> delegate;

@property (nonatomic, assign) DVEVideoCoverResourceType currentType;

- (void)updateVideoFrames:(NSArray<UIImage *> *)frames;

- (void)updateCropAlbumImage:(UIImage *)image;

- (void)updateCurrentTimeRatio:(CGFloat)ratio;

@end

NS_ASSUME_NONNULL_END
