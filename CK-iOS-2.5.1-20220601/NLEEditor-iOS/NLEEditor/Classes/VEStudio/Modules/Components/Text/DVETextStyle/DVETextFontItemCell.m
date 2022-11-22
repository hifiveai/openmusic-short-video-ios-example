//
//  DVETextFontItemCell.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/22.
//

#import "DVETextFontItemCell.h"
#import "DVEMacros.h"

@implementation DVETextFontItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.contentView.layer.cornerRadius = 2;
        self.imageView.layer.cornerRadius = 2;
        [self p_updateBGColor];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self p_updateBGColor];
}

#pragma mark -- Private

- (void)p_updateBGColor {
    if (self.selected) {
        self.contentView.backgroundColor = UIColor.blackColor;
    } else {
        self.contentView.backgroundColor = HEXRGBCOLOR(0x434242);
    }
}

@end
