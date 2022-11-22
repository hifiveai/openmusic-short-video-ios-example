//
//  DVECanvasBlurItem.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/3.
//

#import "DVECanvasBlurItem.h"

@interface DVECanvasBlurItem ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *coverView;

@end

@implementation DVECanvasBlurItem

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.coverView];
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 50, 50)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 56, 56)];
        _coverView.layer.cornerRadius = 2.0;
        _coverView.layer.borderWidth = 1;
        _coverView.clipsToBounds = YES;
        _coverView.layer.borderColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.27 alpha:1.0].CGColor;
        _coverView.hidden = YES;
    }
    return _coverView;
}

- (void)setStickerSelected:(BOOL)stickerSelected animated:(BOOL)animated {
    [super setStickerSelected:stickerSelected animated:animated];
    self.coverView.hidden = !stickerSelected;
}

- (void)setModel:(DVEEffectValue *)model {
    [super setModel:model];
    self.imageView.image = model.assetImage;
}


@end
