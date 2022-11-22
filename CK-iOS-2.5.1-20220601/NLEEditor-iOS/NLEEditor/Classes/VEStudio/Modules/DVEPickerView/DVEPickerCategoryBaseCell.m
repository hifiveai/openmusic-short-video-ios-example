//
//  DVEPickerCategoryBaseCell.m
//  Pods
//
//  Created by bytedance on 2020/8/20.
//

#import "DVEPickerCategoryBaseCell.h"

@implementation DVEPickerCategoryBaseCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)categoryDidUpdate {}

@end
