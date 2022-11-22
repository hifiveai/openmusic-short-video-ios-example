//
//  DVBTextTemplatePickerCell.m
//  NLEEditor
//
//  Created by bytedance on 2021/4/9.
//

#import "DVBTextTemplatePickerCell.h"
#import "NSString+VEToImage.h"
#import "NSString+VEIEPath.h"
#import <DVETrackKit/UIColor+DVEStyle.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "DVEMacros.h"

@interface DVBTextTemplatePickerCell ()

@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation DVBTextTemplatePickerCell

- (void)setModel:(DVEEffectValue*)model {
    [super setModel:model];
    [self.iconView sd_setImageWithURL:model.imageURL placeholderImage:model.assetImage];
}

- (void)setStickerSelected:(BOOL)stickerSelected animated:(BOOL)animated {

    [super setStickerSelected:stickerSelected animated:animated];
    if (stickerSelected) {
        self.contentView.layer.borderColor = [UIColor dve_themeColor].CGColor;
    } else {
        self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.layer.borderWidth = 1;
        self.iconView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:self.iconView];
        self.contentView.layer.cornerRadius = 2;
    }
    return self;
}

@end
