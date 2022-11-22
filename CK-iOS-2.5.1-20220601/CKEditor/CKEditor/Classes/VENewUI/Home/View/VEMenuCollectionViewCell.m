//
//  VEMenuCollectionViewCell.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEMenuCollectionViewCell.h"

@interface VEMenuCollectionViewCell ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation VEMenuCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildLayout];
    }
    
    return self;
}

- (void)buildLayout
{
    [self addSubview: self.button];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

- (void)setTitleName:(NSString *)titleName
{
    _titleName = titleName;
    [_button setTitle:titleName forState:UIControlStateNormal];
}

- (void)setIconName:(NSString *)iconName
{
    _iconName = iconName;
    [_button setImage:iconName.UI_VEToImage forState:UIControlStateNormal];
}

- (void)setIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    switch (indexPath.section) {
        case 0:
        {
            _button.titleLabel.font = SCRegularFont(12);
        }
            break;
        case 1:
        {
            _button.titleLabel.font = SCRegularFont(14);
        }
            break;
            
        default:
            break;
    }
    
    _button.frame = self.bounds;
    [_button VElayoutWithType:VEButtonLayoutTypeImageTop space:6];
}

#pragma mark - getter

- (UIButton *)button
{
    if (!_button) {
        _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _button.titleLabel.textColor = [UIColor whiteColor];
        _button.titleLabel.textAlignment = NSTextAlignmentCenter;
        _button.userInteractionEnabled = NO;
    }
    
    return _button;
}

@end
