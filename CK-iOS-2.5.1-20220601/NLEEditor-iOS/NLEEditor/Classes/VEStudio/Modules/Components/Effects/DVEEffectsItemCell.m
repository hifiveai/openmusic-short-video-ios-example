//
//   DVEEffectsItemCell.m
//   NLEEditor
//
//   Created  by bytedance on 2021/4/11.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEEffectsItemCell.h"
#import "NSString+VEToImage.h"
#import "DVEMacros.h"
#import "DVEEffectsBoarderView.h"
#import "DVELoadingView.h"
#import <SDWebImage/SDWebImage.h>
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface DVEEffectsItemCell()

@property (nonatomic, strong) DVEEffectsBoarderView *imageBorder;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *downloadingView;

@end

@implementation DVEEffectsItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imageBorder];
        [self addSubview:self.titleLabel];
        self.style = DVEEffectsItemDefault;
    }
    
    return self;
}

#pragma mark layz Method

- (DVEEffectsBoarderView*) imageBorder
{
    if(!_imageBorder) {
        _imageBorder = [DVEEffectsBoarderView new];
    }
    return _imageBorder;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = SCRegularFont(10);
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter ;
    }
    
    return _titleLabel;
}

- (void)setStyle:(DVEEffectsItemStyle)style
{
    if(_style == style) return;
    _style = style;
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);
    ///根据外部初始化frame计算子view展示区域
    if(_style == DVEEffectsItemDefault){
        self.imageBorder.frame = CGRectMake(0, 0, w, w);
        self.titleLabel.frame = CGRectMake(0, CGRectGetMaxY(self.imageBorder.frame), w, h - CGRectGetMaxY(self.imageBorder.frame));
    }else{
        self.imageBorder.frame = CGRectMake(0, h - w, w, w);
        self.titleLabel.frame = CGRectMake(0, 0, w, h - CGRectGetHeight(self.imageBorder.frame));
    }
}

#pragma mark override parent Method

- (BOOL) stickerSelected
{
    DVEEffectValue* eValue = (DVEEffectValue*)self.model;
    return eValue.valueState == VEEffectValueStateInUse;
}

- (void)setStickerSelected:(BOOL)stickerSelected animated:(BOOL)animated
{
    [super setStickerSelected:stickerSelected animated:animated];
    if (stickerSelected) {
        [self.imageBorder setSelected];
    } else {
        [self.imageBorder setUnSelected];
    }
}

-(void)updateStickerIconImage
{
    if(self.model.imageURL == nil){
        [self setImage:self.model.assetImage];
    }else{
        @weakify(self);
        [[SDWebImageManager sharedManager] loadImageWithURL:self.model.imageURL options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            @strongify(self);
            [self setImage:image];
        }];
    }
}


#pragma mark private Method

- (void)setModel:(DVEEffectValue*)model
{
    [super setModel:model];
    [self updateStickerIconImage];
    [self setTitleText:model.name];
}

-(void)setTitleText:(NSString *)text
{
    self.titleLabel.text = text;
}

-(NSString*)titleText
{
    return self.titleLabel.text;
}

-(void)setImage:(UIImage *)image
{
    self.imageBorder.image = image;
}

-(void)setImageBackgroundColor:(UIColor *)imageBackgroundColor
{
    self.imageBorder.backgroundColor = imageBackgroundColor;
}

-(UIColor*)imageBackgroundColor
{
    return self.imageBorder.backgroundColor;
}

-(UIImage*)image
{
    return self.imageBorder.image;
}

- (UIViewContentMode)imageMode
{
    return self.imageBorder.contentMode;
}

- (void)setImageMode:(UIViewContentMode)imageMode
{
    self.imageBorder.imageMode = imageMode;
}

-(UIFont*)font
{
    return self.titleLabel.font;
}

-(void)setFont:(UIFont *)font
{
    self.titleLabel.font = font;
}

-(void)setEnable:(BOOL)enable
{
    _enable = enable;
    self.titleLabel.enabled = enable;
    self.imageBorder.enable = enable;
}

- (UIView *)downloadingView {
    if(!_downloadingView) {
        DVELoadingType* type = [DVELoadingType smallLoadingType];
        DVELoadingView* view = [[DVELoadingView alloc] initWithFrame:self.imageBorder.frame];
        [view setLottieLoadingWithType:type];
        _downloadingView = view;
    }
    return _downloadingView;
}

@end
