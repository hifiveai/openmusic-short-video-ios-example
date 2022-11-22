//
//  VEEStickerItem.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVEEffectValue.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEEStickerItem : UICollectionViewCell

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) DVEEffectValue *eValue;

@end

NS_ASSUME_NONNULL_END
