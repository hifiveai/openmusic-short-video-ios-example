//
//  DVETextCommonItem.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVETextCommonItem.h"
#import "NSArray+RGBA.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEMacros.h"
#import "NSString+VEIEPath.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation DVETextCommonItem
@synthesize model = _model;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildLayout];
    }
    
    return self;
}

- (void)buildLayout
{
    [self.contentView addSubview:self.imageView];
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    
    return _imageView;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        _imageView.layer.borderColor = HEXRGBCOLOR(0xFE6646).CGColor;
        _imageView.layer.borderWidth = 1;
    } else {
        _imageView.layer.borderColor = [UIColor clearColor].CGColor;
        _imageView.layer.borderWidth = 0;
    }
}

- (void)setModel:(DVEEffectValue *)model
{
    _model = model;
    if (model.color) {
        self.imageView.image = [UIImage new];
        self.imageView.backgroundColor = RGBCOLOR([model.color[0] floatValue] * 255, [model.color[1] floatValue] * 255, [model.color[2] floatValue] * 255);
    } else {
        self.imageView.backgroundColor = UIColor.clearColor;
        [self.imageView sd_setImageWithURL:model.imageURL placeholderImage:model.assetImage];
    }
}

@end
