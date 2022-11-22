//
//  DVEVideoCoverAlbumImagePickerView.h
//  NLEEditor
//
//  Created by bytedance on 2021/6/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DVEVideoCoverAlbumImagePickerDelegate <NSObject>

- (void)updateSelectedAlbumImageWithCompletion:(void(^)(UIImage * _Nullable))completion;

- (void)showAlbumImageCropViewWithImage:(UIImage *)image;

@end

@interface DVEVideoCoverAlbumImagePickerView : UIView

@property (nonatomic, weak) id<DVEVideoCoverAlbumImagePickerDelegate> delegate;

@property (nonatomic, strong) UIImage *selectedImage;

@end

NS_ASSUME_NONNULL_END
