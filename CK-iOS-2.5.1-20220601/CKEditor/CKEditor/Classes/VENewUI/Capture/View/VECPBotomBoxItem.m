//
//  VECPBotomBoxItem.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECPBotomBoxItem.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "NSString+VEToImage.h"

@implementation VECPBotomBoxItem

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildLayout];
    }
    
    return self;
}


- (void)buildLayout
{
    [self addSubview:self.iconView];
    [self addSubview:self.deletButton];
    self.deletButton.center = CGPointMake(35, 5);
    
    @weakify(self);
    [[self.deletButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        if (self.deletBlock) {
            self.deletBlock(self.indexPath);
        }
    }];
}

- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    }
    
    return _iconView;
}

- (UIButton *)deletButton
{
    if (!_deletButton) {
        _deletButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_deletButton setImage:@"icon_bottombox_delet".UI_VEToImage forState:UIControlStateNormal];
    }
    
    return _deletButton;
}


- (void)setSourceValue:(VESourceValue *)sourceValue
{
    _sourceValue = sourceValue;
    
    switch (sourceValue.type) {
        case VESourceValueTypeImage:
        {
            self.iconView.image = sourceValue.image;
        }
            break;
        case VESourceValueTypeVideo:
        {
            self.iconView.image = [self getThumbnailImage:sourceValue.asset];
        }
            break;
            
        default:
            break;
    }
}

- (UIImage *)getThumbnailImage:(AVURLAsset *)asset {
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    // 设定缩略图的方向，如果不设定，可能会在视频旋转90/180/270°时，获取到的缩略图是被旋转过的，而不是正向的。
    gen.appliesPreferredTrackTransform = YES;
    // 设置图片的最大size(分辨率)
    gen.maximumSize = CGSizeMake(80, 80);
    CMTime time = CMTimeMakeWithSeconds(1.0, 600); // 取第5秒，一秒钟600帧
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if (error) {
        UIImage *placeHoldImg = [UIImage imageNamed:@"<默认图片名>"];
        return placeHoldImg;
    }
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
}

@end
