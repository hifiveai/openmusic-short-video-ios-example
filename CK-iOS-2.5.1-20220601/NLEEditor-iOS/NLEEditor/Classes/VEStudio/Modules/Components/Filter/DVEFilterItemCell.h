//
//  DVEFilterItemCell.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVEEffectValue.h"
#import "DVEPickerBaseCell.h"

//#define itemSpace (VE_SCREEN_WIDTH - 38 * 5 - 19 * 2) * 0.25

NS_ASSUME_NONNULL_BEGIN

@interface DVEFilterItemCell : DVEPickerBaseCell

@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *hitView;

@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UIImageView *iconView;

@end

NS_ASSUME_NONNULL_END
