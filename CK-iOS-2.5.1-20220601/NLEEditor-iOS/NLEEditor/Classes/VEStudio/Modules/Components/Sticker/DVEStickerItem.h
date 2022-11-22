//
//  DVEStickerItem.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVEPickerBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

#define itemSpace (VE_SCREEN_WIDTH - 38 * 5 - 19 * 2) * 0.25

@interface DVEStickerItem : DVEPickerBaseCell

@property (nonatomic, strong) UIImageView *iconView;

@end

NS_ASSUME_NONNULL_END
