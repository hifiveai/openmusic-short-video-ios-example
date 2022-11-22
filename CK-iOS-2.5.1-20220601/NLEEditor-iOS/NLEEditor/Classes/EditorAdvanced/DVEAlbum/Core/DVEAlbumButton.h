//
//  DVEAlbumButton.h
//  ACCme
//
//  Created by bytedance on 16/9/6.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DVEAlbumButton : UIButton

IBInspectable @property (nonatomic, assign) CGFloat selectedAlpha;
@property (nonatomic, strong) UIImageView *imageContentView;

+ (instancetype)buttonWithSelectedAlpha:(CGFloat)selectedAlpha;
//-----由SMCheckProject工具删除-----
//+ (instancetype)imageButtonWithSelectedAlpha:(CGFloat)selectedAlpha;

@end


@interface UIButton (VerticalLayout)

- (void)centerVerticallyWithPadding:(float)padding;
- (void)centerVertically;

@end
