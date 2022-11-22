//
//  DVEAlbumAnimatedButton.h
//  Aweme
//
//  Created by bytedance on 2017/6/8.
//  Copyright © 2017年 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DVEAlbumAnimatedButtonType) {
    SCIFAnimatedButtonTypeScale,        // 放大缩小动画
    SCIFAnimatedButtonTypeAlpha,        // 透明度动画
};

@interface DVEAlbumAnimatedButton : UIButton

@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) CGFloat highlightedScale;
@property (nonatomic, strong) NSURL *audioURL;

/**
 根据传入的 frame 与 按钮按下时需要做的动画类型生成 DVEAlbumAnimatedButton 的实例

 @param frame frame
 @param btnType 按钮的动画类型，为 DVEAlbumAnimatedButtonType
 @return 对应类型的 DVEAlbumAnimatedButton 实例
 */
- (instancetype)initWithFrame:(CGRect)frame type:(DVEAlbumAnimatedButtonType)btnType;

/**
 根据传入的按钮按下时需要做的动画类型生成 DVEAlbumAnimatedButton 的实例

 @param btnType 按钮的动画类型，为 DVEAlbumAnimatedButtonType
 @return 对应类型的ACCAnimatedButton 实例
 */
- (instancetype)initWithType:(DVEAlbumAnimatedButtonType)btnType;


/**
 生成 SCIFAnimatedButtonTypeScale 类型的 DVEAlbumAnimatedButton 实例

 @param frame frame
 @return SCIFAnimatedButtonTypeScale 类型的 DVEAlbumAnimatedButton 实例
 */
- (instancetype)initWithFrame:(CGRect)frame;

@end
