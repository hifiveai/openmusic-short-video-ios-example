//
//  DVEMaskItem.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/3/31.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVEPickerBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEMaskItem : DVEPickerBaseCell

@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *hitView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconView;

@end

NS_ASSUME_NONNULL_END
