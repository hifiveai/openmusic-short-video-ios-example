//
//  VEHButton.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEHButton.h"


@implementation VEHButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 内部图标居中
//        self.imageView.contentMode = UIViewContentModeCenter;
        // 文字对齐
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        // 文字颜色
//        [self setTitleColor:RGB(131, 131, 131) forState:UIControlStateNormal];
        // 字体
        
        // 高亮的时候不需要调整内部的图片为灰色
        self.adjustsImageWhenHighlighted = NO;
    }
    return self;
}

/**
 *  设置内部图标的frame
 */
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageY = 0;
    CGFloat imageX = 0;
    CGFloat imageH = self.frame.size.height;
    CGFloat imageW = self.frame.size.height;
    
    
    return CGRectMake(imageX, imageY, imageW, imageH);
}

/**
 *  设置内部文字的frame
 */
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleY = 0;
    CGFloat titleW = self.frame.size.width - self.frame.size.height;
    CGFloat titleH = self.frame.size.height;
    CGFloat titleX = self.frame.size.width - titleW + 3;
    return CGRectMake(titleX, titleY, titleW, titleH);
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    
    // 1.计算文字的尺寸
    CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName : self.titleLabel.font}];
    
    // 2.计算按钮的宽度
//    self.width = titleSize.width + self.height ;
    self.titleLabel.top = self.height - titleSize.height;
//    self.titleLabel.height = titleSize.height;
    
}

@end
