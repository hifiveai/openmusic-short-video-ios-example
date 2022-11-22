//
//  DVEMixedEffectItem.m
//  NLEEditor
//
//  Created by bytedance on 2021/4/19.
//

#import "DVEMixedEffectItem.h"
#import "DVEMacros.h"
#import <DVETrackKit/UIColor+DVEStyle.h>
#import <DVETrackKit/UIView+VEExt.h>
#import <DVETrackKit/DVEUILayout.h>
#import <SDWebImage/SDWebImage.h>

@implementation DVEMixedEffectItem

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.iconView];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        if ([DVEUILayout dve_alignmentWithName:DVEUILayoutMixedEffectItemTextPosition] == DVEUILayoutAlignmentBottom) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 50, 24)];
        } else {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 24)];
        }
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = SCRegularFont(12);
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        if ([DVEUILayout dve_alignmentWithName:DVEUILayoutMixedEffectItemTextPosition] == DVEUILayoutAlignmentBottom) {
            _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        } else {
            _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 24, 50, 50)];
        }
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.layer.borderWidth = 1;
        _iconView.layer.cornerRadius = [DVEUILayout dve_sizeNumberWithName:DVEUILayoutMixedEffectItemCornerRadius];
    }
    return _iconView;
    
}


- (void)setStickerSelected:(BOOL)stickerSelected animated:(BOOL)animated {
    [super setStickerSelected:stickerSelected animated:animated];
    self.clipsToBounds = YES;
    if (stickerSelected) {
        self.iconView.layer.borderColor = [UIColor dve_themeColor].CGColor;
        self.iconView.clipsToBounds = YES;
    } else {
        self.iconView.layer.borderColor = [UIColor clearColor].CGColor;
        self.iconView.clipsToBounds = NO;
    }
}

- (void)setModel:(DVEEffectValue*)model {
    [super setModel:model];
    self.titleLabel.text = model.name;
    
    [self.iconView sd_setImageWithURL:model.imageURL placeholderImage:model.assetImage];
}

- (UIView *)downloadingView
{
    UIView* view = [super downloadingView];
    view.centerY = self.iconView.centerY;
    return view;
}

@end
