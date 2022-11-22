//
//  DVEMixedEffectItem.h
//  NLEEditor
//
//  Created by bytedance on 2021/4/19.
//

#import <UIKit/UIKit.h>
//#import "DVEEffectValue.h"
#import "DVEPickerBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEMixedEffectItem : DVEPickerBaseCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconView;
//@property (nonatomic, strong) DVEEffectValue *effectValue;

- (void)setSelectedStatus:(BOOL)select;

@end

NS_ASSUME_NONNULL_END
