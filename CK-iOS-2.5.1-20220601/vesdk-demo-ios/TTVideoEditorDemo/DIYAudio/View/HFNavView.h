//
//  HFNavView.h
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/13.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HFNavView : UIView

@property (nonatomic ,copy) void(^closeActionBlock)(void);
@property (nonatomic ,copy) void(^backActionBlock)(void);
@property (nonatomic ,copy) void(^searchActionBlock)(void);
+ (HFNavView *)configWithFrame:(CGRect)frame title:(NSString *)title closeImage:(NSString *)imageName searchImage:(NSString *)searchName backImage:(NSString *)backName;
@end

NS_ASSUME_NONNULL_END
