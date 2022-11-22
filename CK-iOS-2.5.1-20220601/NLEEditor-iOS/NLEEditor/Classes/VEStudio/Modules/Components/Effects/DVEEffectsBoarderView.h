//
//   DVEEffectsBoarderView.h
//   NLEEditor
//
//   Created  by bytedance on 2021/4/11.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVEEffectsBoarderView : UIView
///图片
@property (nonatomic,strong) UIImage* image;
///图片展示模式
@property (nonatomic, assign) UIViewContentMode imageMode;
///是否可用
@property (nonatomic, assign) BOOL enable;

///设置未选中状态
- (void)setUnSelected;
///设置正在使用状态
- (void)setInUse;
///设置选中状态
- (void)setSelected;

@end

NS_ASSUME_NONNULL_END
