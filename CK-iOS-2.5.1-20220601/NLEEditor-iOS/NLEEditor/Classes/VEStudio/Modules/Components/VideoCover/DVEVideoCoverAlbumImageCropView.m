//
//  DVEVideoCoverAlbumImageCropView.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/29.
//

#import "DVEVideoCoverAlbumImageCropView.h"
#import "DVEMacros.h"
#import "DVEUIHelper.h"
#import "NSString+VEToImage.h"
#import "DVEVideoCoverImageCropUtils.h"
#import "UIImage+dve_videoCover.h"
#import <DVETrackKit/UIView+VEExt.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>
#import <Metal/Metal.h>

@interface DVEVideoCoverAlbumImageCropLayer : CAShapeLayer

@property (nonatomic, strong) CAShapeLayer *cropLayer;

- (void)hollowOutInRect:(CGRect)rect;

@end

@implementation DVEVideoCoverAlbumImageCropLayer

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor].CGColor;
        self.fillColor = [UIColor colorWithWhite:0.0 alpha:0.6].CGColor;
        self.fillRule = kCAFillRuleEvenOdd;
        
        self.cropLayer = [[CAShapeLayer alloc] init];
        [self addSublayer:self.cropLayer];
        self.cropLayer.borderWidth = 2.0;
        self.cropLayer.borderColor = [UIColor whiteColor].CGColor;
    }
    return self;
}

- (void)hollowOutInRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cropPath = [UIBezierPath bezierPathWithRect:rect];
    [path appendPath:cropPath];
    path.usesEvenOddFillRule = YES;
    self.path = path.CGPath;
    self.cropLayer.frame = rect;
}

@end

@interface DVEVideoCoverAlbumImageCropView () <UIScrollViewDelegate>

@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) DVEVideoCoverAlbumImageCropLayer *imageCropLayer;
@property (nonatomic, assign) CGSize previewSize;
@property (nonatomic, assign) CGSize cropSize;
@property (nonatomic, weak) id<DVEVideoCoverAlbumImageCropDelegate> delegate;

@end

@implementation DVEVideoCoverAlbumImageCropView

- (instancetype)initWithImage:(UIImage *)image
                     delegate:(id<DVEVideoCoverAlbumImageCropDelegate>)delegate {
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.imageView.image = image;
        self.delegate = delegate;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        return;
    }
    [self setUpLayout];
}

- (void)setUpLayout {
    self.backgroundColor = colorWithHex(0x101010);
    [self configCropPreview];
    
    [self addSubview:self.hintLabel];
    [self addSubview:self.backButton];
    [self addSubview:self.confirmButton];
    
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(155, 84));
        make.left.mas_equalTo(self.mas_left).offset(110);
        make.top.mas_equalTo(self.mas_top).offset(VETopMargn + 24);
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(64, 65));
        make.left.mas_equalTo(self.mas_left);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-(34 - VEBottomMargnValue + VEBottomMargn));
    }];
    
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(49, 26));
        make.right.mas_equalTo(self.mas_right).offset(-14);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-(54 - VEBottomMargnValue + VEBottomMargn));
    }];
    
}

- (void)configCropPreview {
    [self addSubview:self.scrollView];
    self.scrollView.frame = CGRectMake(12, 56, self.bounds.size.width - 12 * 2, self.bounds.size.height - 2 * 56);
    
    CGSize maxSize = CGSizeMake(self.frame.size.width - 2 * 12, self.frame.size.height - 2 * 56 - VETopMargn - VEBottomMargn - 54);
    CGSize fixSize = [self.imageView.image dve_fixOrientation].size;
    self.cropSize = DVE_aspectFitMaxSize(self.canvasSize, maxSize);
    self.previewSize = DVE_aspectFitMinSize(fixSize, self.cropSize);
    
    NSArray<NSValue *> *cropPoints = DVE_defaultCropForImage([self.imageView.image dve_origialImageSize], self.canvasSize);
    [self configCropRegionWithMaxSize:maxSize cropPoints:cropPoints];
    
    CGFloat horizontalOffset = (self.scrollView.frame.size.width - self.cropSize.width) / 2;
    CGFloat verticalOffset = (self.scrollView.frame.size.height - self.cropSize.height) / 2;
    
    self.scrollView.contentInset = UIEdgeInsetsMake(verticalOffset, horizontalOffset, verticalOffset, horizontalOffset);
    self.scrollView.contentSize = CGSizeMake(self.previewSize.width, self.previewSize.height);
    self.imageView.frame = CGRectMake(0, 0, self.previewSize.width, self.previewSize.height);
    [self.scrollView addSubview:self.imageView];
    
    CGPoint cropOrigin = CGPointMake(self.imageCropLayer.frame.size.width / 2 - self.cropSize.width / 2, self.imageCropLayer.frame.size.height / 2 - self.cropSize.height / 2);
    CGRect cropRect = CGRectMake(cropOrigin.x, cropOrigin.y, self.cropSize.width, self.cropSize.height);
    
    [self.imageCropLayer hollowOutInRect:cropRect];
    [self.layer addSublayer:self.imageCropLayer];
}

- (void)configCropRegionWithMaxSize:(CGSize)maxSize
                         cropPoints:(NSArray<NSValue *> *)cropPoints {
    CGSize previewSize = self.previewSize;
    CGSize cropSize = self.cropSize;
    BOOL isEqualY = cropSize.height == previewSize.height ? YES : NO;
    if (isEqualY) {
        CGFloat heightUniformValue = cropPoints[2].CGPointValue.y - cropPoints[0].CGPointValue.y;
        CGFloat scale = 1.0 / (heightUniformValue > 0 ? heightUniformValue : 1.0);
        self.scrollView.minimumZoomScale = 1.0 / (scale > 0 ? scale : 1.0);
        self.previewSize = CGSizeMake(previewSize.width * scale, previewSize.height * scale);
    } else {
        CGFloat widthUniformValue = cropPoints[1].CGPointValue.x - cropPoints[0].CGPointValue.x;
        CGFloat scale = 1.0 / (widthUniformValue > 0 ? widthUniformValue : 1.0);
        self.scrollView.minimumZoomScale = 1.0 / (scale > 0 ? scale : 1.0);
        self.previewSize = CGSizeMake(previewSize.width * scale, previewSize.height * scale);
    }
    CGFloat topPadding = (maxSize.height - cropSize.height) / 2.0;
    CGFloat leftPadding = (maxSize.width - cropSize.width) / 2.0;
    CGFloat offsetX = cropPoints[0].CGPointValue.x * self.previewSize.width - leftPadding;
    CGFloat offsetY = cropPoints[0].CGPointValue.y * self.previewSize.height - topPadding;
    self.scrollView.contentOffset = CGPointMake(offsetX, offsetY);
}

- (UILabel *)hintLabel {
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.text = NLELocalizedString(@"ck_drag_select_show_region", @"拖动或双指缩放调整画面");
        _hintLabel.textColor = [UIColor whiteColor];
        _hintLabel.textAlignment = NSTextAlignmentCenter;
        _hintLabel.font = SCRegularFont(14);
    }
    return _hintLabel;
}


- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[@"icon_cover_return" dve_toImage] forState:UIControlStateNormal];
        @weakify(self);
        [[_backButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self removeFromSuperview];
            [self.delegate backImageResourcePickerView];
        }];
    }
    return _backButton;
}


- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:NLELocalizedString(@"ck_confirm",@"确定") forState:UIControlStateNormal];
        _confirmButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _confirmButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:12];
        _confirmButton.titleLabel.textColor = [UIColor whiteColor];
        _confirmButton.layer.cornerRadius = 12;
        _confirmButton.layer.borderWidth = 1;
        _confirmButton.layer.masksToBounds = YES;
        _confirmButton.backgroundColor = colorWithHex(0xFE6646);
        @weakify(self);
        [[_confirmButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self presentCropAlbumImage];
            [self removeFromSuperview];
        }];
    }
    return _confirmButton;
}


- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = colorWithHex(0x101010);
        _scrollView.clipsToBounds = NO;
        _scrollView.scrollEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 100.0;
        _scrollView.zoomScale = 1.0;
        _scrollView.bounces = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _scrollView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (DVEVideoCoverAlbumImageCropLayer *)imageCropLayer {
    if (!_imageCropLayer) {
        _imageCropLayer = [[DVEVideoCoverAlbumImageCropLayer alloc] init];
        _imageCropLayer.frame = self.bounds;
    }
    return _imageCropLayer;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.zoomScale < scrollView.minimumZoomScale) {
        scrollView.zoomScale = scrollView.minimumZoomScale;
    }
    
}

#pragma mark - Private

- (CGRect)cropRectForAlbumImage {
    CGRect frame = [self.imageCropLayer convertRect:self.imageCropLayer.cropLayer.frame
                                            toLayer:self.imageView.layer];
    CGFloat originX = frame.origin.x < 0.0 ? 0.0 : frame.origin.x;
    CGFloat originY = frame.origin.y < 0.0 ? 0.0 : frame.origin.y;
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    CGFloat leftX  = (originX / self.imageView.bounds.size.width) >= 1 ? 1.0 : (originX / self.imageView.bounds.size.width);
    CGFloat topY = (originY / self.imageView.bounds.size.height) >= 1 ? 1.0 : (originY / self.imageView.bounds.size.height);
    CGFloat rightX = ((originX + width) / self.imageView.bounds.size.width) >= 1 ? 1.0 : ((originX + width) / self.imageView.bounds.size.width);
    CGFloat downY = ((originY + height) / self.imageView.bounds.size.height) >= 1 ? 1.0 : ((originY + height) / self.imageView.bounds.size.height);
    return CGRectMake(leftX * self.imageView.image.size.width, topY * self.imageView.image.size.height, (rightX - leftX) * self.imageView.image.size.width, (downY - topY) * self.imageView.image.size.height);
}

- (void)presentCropAlbumImage {
    CGRect rect = [self cropRectForAlbumImage];
    UIImage *image = self.imageView.image;
    CGRect cropRect = DVE_fixCropRectForImage(rect, image);
    CGImageRef cgImage = [self.imageView.image CGImage];
    CGImageRef cropCGImage = CGImageCreateWithImageInRect(cgImage, cropRect);
    [self.delegate presentCropAlbumImageForVideoCover:[UIImage imageWithCGImage:cropCGImage
                                                                          scale:image.scale
                                                                    orientation:image.imageOrientation]];
}

@end
