//
//  UIButton+layout.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VEButtonLayoutType) {
    VEButtonLayoutTypeNone                = 0,         //默认
    VEButtonLayoutTypeImageLeft           = 1,        //图片在左边
    VEButtonLayoutTypeImageRight          = 2,        //图片在右边
    VEButtonLayoutTypeImageTop            = 3,        //图片在上边
    VEButtonLayoutTypeImageBottom         = 4         //图片在下边
};


@interface UIButton (layout)


@property (assign, nonatomic) CGFloat space;

/**
 *  布局的类型
 */
@property (nonatomic, assign) VEButtonLayoutType layoutType;


@property (nonatomic, assign) NSInteger index;

- (void)VElayoutWithType:(VEButtonLayoutType)layoutType space:(CGFloat)space;

@end

NS_ASSUME_NONNULL_END
