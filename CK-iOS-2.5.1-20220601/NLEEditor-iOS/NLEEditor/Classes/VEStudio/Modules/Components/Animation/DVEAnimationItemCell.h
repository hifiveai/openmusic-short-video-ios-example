//
//  DVEAnimationItemCell.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVEPickerBaseCell.h"
#import "DVEEffectValue.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEAnimationItemCell : DVEPickerBaseCell

@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIView *coverView;


@end

NS_ASSUME_NONNULL_END
