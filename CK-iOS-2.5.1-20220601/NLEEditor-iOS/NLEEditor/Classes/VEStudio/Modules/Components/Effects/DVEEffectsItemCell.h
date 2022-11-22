//
//   DVEEffectsItemCell.h
//   NLEEditor
//
//   Created  by bytedance on 2021/4/11.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import <UIKit/UIKit.h>
#import "DVEPickerBaseCell.h"
#import "DVEEffectValue.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    DVEEffectsItemUnknown = 0,   //无效
    DVEEffectsItemDefault,  //默认模式图片在上，文本在下
    DVEEffectsItemImageBottom, //图片在下，文本在上
} DVEEffectsItemStyle;
 
typedef void (^DVEEffectsItemCallBackBlock)(DVEEffectValue *model);

@interface DVEEffectsItemCell : DVEPickerBaseCell

///展示模式
@property (nonatomic, assign) DVEEffectsItemStyle style;
///图片
@property (nonatomic, strong) UIImage* image;
///标题
@property (nonatomic, copy) NSString* titleText;
///标题字体 默认 SCRegularFont（10）
@property (nonatomic, strong) UIFont* font;
///图片对象背景色
@property (nonatomic, strong) UIColor* imageBackgroundColor;
///图片展示模式
@property (nonatomic, assign) UIViewContentMode imageMode;
///是否可用状态
@property (nonatomic, assign) BOOL enable;


@end

NS_ASSUME_NONNULL_END
