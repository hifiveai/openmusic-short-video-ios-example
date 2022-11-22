//
//  DVEPopSelectItem.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "DVEPopSelectItem.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEMacros.h"
#import <DVETrackKit/UIColor+DVEStyle.h>

@implementation DVEPopSelectItem

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildLayout];
    }
    
    return self;
}

- (void)buildLayout
{
    [self addSubview:self.titleLable];
    self.titleLable.centerY = self.height * 0.5;
}

- (UILabel *)titleLable
{
    if (!_titleLable) {
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 15)];
        _titleLable.textColor = [UIColor whiteColor];
        _titleLable.font = HelBoldFont(12);
        _titleLable.textAlignment = NSTextAlignmentCenter;
    }
    
    return _titleLable;
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        _titleLable.textColor = [UIColor dve_themeColor];
    } else {
        _titleLable.textColor = [UIColor whiteColor];
    }
}

@end
