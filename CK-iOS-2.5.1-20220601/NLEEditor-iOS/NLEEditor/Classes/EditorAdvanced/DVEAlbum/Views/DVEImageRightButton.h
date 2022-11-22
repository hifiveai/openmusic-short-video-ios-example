//
//  DVEImageRightButton.h
//  CameraClient
//
//  Created by bytedance on 2020/6/18.
//

#import "DVEAlbumAnimatedButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEImageRightButton : DVEAlbumAnimatedButton

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UIImageView *rightImageView;

- (instancetype)initWithType:(DVEAlbumAnimatedButtonType)btnType;

- (instancetype)initWithType:(DVEAlbumAnimatedButtonType)btnType titleAndImageInterval:(CGFloat)interval;

@end

NS_ASSUME_NONNULL_END
