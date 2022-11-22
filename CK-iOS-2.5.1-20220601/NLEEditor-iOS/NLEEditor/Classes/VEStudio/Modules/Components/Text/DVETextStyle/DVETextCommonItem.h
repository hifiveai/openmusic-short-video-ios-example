//
//  DVETextCommonItem.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVECommonDefine.h"
#import "DVEEffectValue.h"
#import "DVEPickerBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVETextCommonItem : DVEPickerBaseCell

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) UIImageView *imageView;

@end

NS_ASSUME_NONNULL_END
