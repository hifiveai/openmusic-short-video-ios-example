//
//  DVEAlbumButton.m
//  DVEAlbumme
//
//  Created by bytedance on 16/9/6.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

//#import "UIView+DVEAlbumMasonry.h"
#import "DVEAlbumButton.h"

@implementation DVEAlbumButton

+ (instancetype)buttonWithSelectedAlpha:(CGFloat)selectedAlpha
{
    DVEAlbumButton *button = [self buttonWithType:UIButtonTypeCustom];
    button.selectedAlpha = selectedAlpha;

    return button;
}

//-----由SMCheckProject工具删除-----
//+ (instancetype)imageButtonWithSelectedAlpha:(CGFloat)selectedAlpha
//{
//    DVEAlbumButton *button = [self buttonWithSelectedAlpha:selectedAlpha];
//    
//    button.imageContentView = [UIImageView new];
//    [button addSubview:button.imageContentView];
//    DVEAlbumMasMaker(button.imageContentView, {
//        make.edges.equalTo(button);
//    });
//    
//    return button;
//}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if(self.highlighted) {
        [UIView animateWithDuration:0.15 animations:^{
            [self setAlpha:self.selectedAlpha];
        }];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.15 animations:^{
                [self setAlpha:1];
            }];
        });
    }
}

@end


@implementation UIButton (VerticalLayout)

- (void)centerVerticallyWithPadding:(float)padding
{
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    
    CGFloat totalHeight = (imageSize.height + titleSize.height + padding);
    
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height),
                                            0.0f,
                                            0.0f,
                                            - titleSize.width);
    
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0f,
                                            - imageSize.width,
                                            - (totalHeight - titleSize.height),
                                            0.0f);
    
}


- (void)centerVertically
{
    const CGFloat kDefaultPadding = 6.0f;
    
    [self centerVerticallyWithPadding:kDefaultPadding];
}


@end
