//
//  VECPBotomBoxItem.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VESourceValue.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^deletActionBlock)(NSIndexPath *);


@interface VECPBotomBoxItem : UICollectionViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) VESourceValue *sourceValue;

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIButton *deletButton;
@property (nonatomic, copy) deletActionBlock deletBlock;

@end

NS_ASSUME_NONNULL_END
