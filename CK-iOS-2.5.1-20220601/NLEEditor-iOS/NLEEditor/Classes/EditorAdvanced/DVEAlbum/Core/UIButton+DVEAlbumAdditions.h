//
//  UIButton+ACCAdditions.h
//  Pods
//
//  Created by bytedance on 2017/11/7.
//

#import <UIKit/UIKit.h>

typedef void (^DVEAlbumUIButtonTapBlock)(void);

@interface UIButton (DVEAlbumAdditions)

@property (nonatomic, assign) UIEdgeInsets acc_hitTestEdgeInsets;
@property (nonatomic, copy) void(^acc_disableBlock)(void);
@property (nonatomic, copy) DVEAlbumUIButtonTapBlock tap_block;

- (void)acc_centerTitleAndImageWithSpacing:(CGFloat)spacing contentEdgeInsets:(UIEdgeInsets)contentEdgeInsets;

- (void)acc_setBackgroundColor:(UIColor *)color forState:(UIControlState)state;


@end





