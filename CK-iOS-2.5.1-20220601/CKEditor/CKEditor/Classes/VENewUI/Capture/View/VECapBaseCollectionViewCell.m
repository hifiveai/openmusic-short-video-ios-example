//
//  VECapBaseCollectionViewCell.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECapBaseCollectionViewCell.h"

@implementation VECapBaseCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildLayout];
    }
    
    return self;
}

- (void)buildLayout
{
    [self.contentView addSubview:self.button];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

#pragma mark - getter

- (VEVButton *)button
{
    if (!_button) {
        _button = [[VEVButton alloc] initWithFrame:CGRectMake(0, 0, 64, 50)];
        _button.userInteractionEnabled = NO;
    }
    
    return _button;
}

- (void)setBarValue:(VEBarValue *)barValue
{
    _barValue = barValue;
    [_button removeFromSuperview];
    _button = nil;
    [self.contentView addSubview:self.button];
    switch (barValue.valueType) {
        case VEBarValueTypeImage:
        {
            [self.button setImage:barValue.curImage forState:UIControlStateNormal];
        }
            break;
        case VEBarValueTypeText:
        {
            
            [self.button setTitle:barValue.curTitle forState:UIControlStateNormal];
        }
            break;
        case VEBarValueTypeImageAndText:
        {
            [self.button setImage:barValue.curImage forState:UIControlStateNormal];
            [self.button setTitle:barValue.curTitle forState:UIControlStateNormal];
        }
            break;
        case VEBarValueTypeNone:
        {
            
        }
            break;
            
        default:
            break;
    }
}



@end
