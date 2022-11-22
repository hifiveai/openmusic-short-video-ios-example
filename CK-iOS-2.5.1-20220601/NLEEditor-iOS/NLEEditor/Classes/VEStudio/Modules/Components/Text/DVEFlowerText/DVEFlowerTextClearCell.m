//
//  DVEFlowerTextClearCell.m
//  NLEEditor
//
//  Created by bytedance on 2021/4/14.
//

#import "DVEFlowerTextClearCell.h"
#import "DVEMacros.h"
#import <DVETrackKit/UIColor+DVEStyle.h>
@interface DVEFlowerTextClearCell ()

@property (nonatomic, strong) UIImageView *iconView;


@end

@implementation DVEFlowerTextClearCell

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
        self.iconView.image = @"iconFilterwu".dve_toImage;
        [self.contentView addSubview:self.iconView];
        
        self.contentView.layer.cornerRadius = 2;
    }
    return self;
}

@end
