//
//  DVEChangAudioItem.h
//  NLEEditor
//
//  Created by bytedance on 2021/7/6.
//

#import "DVEPickerBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEChangAudioItem : DVEPickerBaseCell

@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *hitView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconView;

@end

NS_ASSUME_NONNULL_END
