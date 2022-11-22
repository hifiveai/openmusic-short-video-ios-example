//
//  DVEVideoCoverResourcePickerView.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/28.
//

#import "DVEVideoCoverResourcePickerView.h"
#import "DVEMacros.h"
#import "DVEUIHelper.h"
#import "DVEVideoCoverVideoFramePickerView.h"
#import "DVEVideoCoverAlbumImagePickerView.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface  DVEVideoCoverResourcePickerView ()
<
DVEVideoCoverVideoFramePickerDelegate,
DVEVideoCoverAlbumImagePickerDelegate
>

@property (nonatomic, strong) UIButton *videoFrame;
@property (nonatomic, strong) UIView *leftBottomLine;
@property (nonatomic, strong) UIButton *albumImport;
@property (nonatomic, strong) UIView *rightBottomLine;

@property (nonatomic, strong) DVEVideoCoverVideoFramePickerView *framePickerView;
@property (nonatomic, strong) DVEVideoCoverAlbumImagePickerView *imagePickerView;

@end


@implementation DVEVideoCoverResourcePickerView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        return;
    }
    
    [self addSubview:self.videoFrame];
    [self addSubview:self.albumImport];
    [self addSubview:self.leftBottomLine];
    [self addSubview:self.rightBottomLine];
    
    NSDictionary *dic = @{NSFontAttributeName : self.videoFrame.titleLabel.font};
    CGRect rect = [self.videoFrame.titleLabel.text boundingRectWithSize:CGSizeMake(VE_SCREEN_WIDTH, 24) options:0 attributes:dic context:nil];
    
    [self.videoFrame mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.right.equalTo(self).offset(-VE_SCREEN_WIDTH * 0.5 - 15);
        make.size.mas_equalTo(CGSizeMake(rect.size.width, 24));
    }];
    
    [self.albumImport mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.mas_equalTo(self.videoFrame.mas_right).offset(30);
        make.centerY.equalTo(self.videoFrame);
        make.size.mas_equalTo(CGSizeMake(56, 24));
    }];
    
    [self.leftBottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(42, 2));
        make.top.mas_equalTo(self.videoFrame.mas_bottom);
        make.centerX.mas_equalTo(self.videoFrame.mas_centerX);
    }];

    [self.rightBottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(56, 2));
        make.top.mas_equalTo(self.albumImport.mas_bottom);
        make.centerX.mas_equalTo(self.albumImport.mas_centerX);
    }];
    
    [self addSubview:self.framePickerView];
    [self addSubview:self.imagePickerView];
    
    [self.framePickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.mas_width);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.top.mas_equalTo(self.leftBottomLine.mas_bottom).offset(45);
        make.left.mas_equalTo(self);
    }];
    
    [self.imagePickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.mas_width);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.top.mas_equalTo(self.leftBottomLine.mas_bottom).offset(45);
        make.left.mas_equalTo(self);
    }];

    [self configRACObserve];
    [self configData];
}

- (void)configData {
    self.currentType = DVEVideoCoverResourceTypeVideoFrame;
    
}

- (void)configRACObserve {
    
    @weakify(self);
    [[self.videoFrame rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        if (self.currentType != DVEVideoCoverResourceTypeVideoFrame) {
            self.currentType = DVEVideoCoverResourceTypeVideoFrame;
            self.imagePickerView.hidden = YES;
            self.framePickerView.hidden = NO;
        }
    }];
    
    [[self.albumImport rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        if (self.currentType != DVEVideoCoverResourceTypeAlbumImage) {
            [self updateAlbumImageIfNeed];
        }
    }];
    
    [[RACObserve(self, currentType) deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (self.currentType == DVEVideoCoverResourceTypeVideoFrame) {
            self.videoFrame.alpha = 1.0;
            self.leftBottomLine.hidden = NO;
            self.albumImport.alpha = 0.5;
            self.rightBottomLine.hidden = YES;
            
            self.imagePickerView.hidden = YES;
            self.framePickerView.hidden = NO;
        } else if (self.currentType == DVEVideoCoverResourceTypeAlbumImage) {
            self.videoFrame.alpha = 0.5;
            self.leftBottomLine.hidden = YES;
            self.albumImport.alpha = 1.0;
            self.rightBottomLine.hidden = NO;
            
            self.imagePickerView.hidden = NO;
            self.framePickerView.hidden = YES;
        }
    }];
}

- (UIButton *)videoFrame {
    if (!_videoFrame) {
        _videoFrame = [UIButton buttonWithType:UIButtonTypeCustom];
        _videoFrame.backgroundColor = [UIColor clearColor];
        [_videoFrame setTitle:NLELocalizedString(@"ck_video_frame", @"视频帧")  forState:UIControlStateNormal];
        _videoFrame.titleLabel.textColor = [UIColor whiteColor];
        _videoFrame.titleLabel.font = SCRegularFont(14);
        _videoFrame.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _videoFrame;
}

- (UIButton *)albumImport {
    if (!_albumImport) {
        _albumImport = [UIButton buttonWithType:UIButtonTypeCustom];
        _albumImport.backgroundColor = [UIColor clearColor];
        [_albumImport setTitle:NLELocalizedString(@"ck_import_from_album",@"相册导入") forState:UIControlStateNormal];
        _albumImport.titleLabel.textColor = [UIColor whiteColor];
        _albumImport.titleLabel.font = SCRegularFont(14);
        _albumImport.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _albumImport;
}

- (UIView *)leftBottomLine {
    if (!_leftBottomLine) {
        _leftBottomLine = [[UIView alloc] init];
        _leftBottomLine.backgroundColor = [UIColor whiteColor];
        _leftBottomLine.layer.cornerRadius = 1;
        _leftBottomLine.layer.masksToBounds = YES;
    }
    return _leftBottomLine;
}

- (UIView *)rightBottomLine {
    if (!_rightBottomLine) {
        _rightBottomLine = [[UIView alloc] init];
        _rightBottomLine.backgroundColor = [UIColor whiteColor];
        _rightBottomLine.layer.cornerRadius = 1;
        _rightBottomLine.layer.masksToBounds = YES;
    }
    return _rightBottomLine;
}


- (DVEVideoCoverVideoFramePickerView *)framePickerView {
    if (!_framePickerView) {
        _framePickerView = [[DVEVideoCoverVideoFramePickerView alloc] init];
        _framePickerView.delegate = self;
    }
    return _framePickerView;
}

- (DVEVideoCoverAlbumImagePickerView *)imagePickerView {
    if (!_imagePickerView) {
        _imagePickerView = [[DVEVideoCoverAlbumImagePickerView alloc] init];
        _imagePickerView.delegate = self;
    }
    return _imagePickerView;
}

- (void)updateVideoFrames:(NSArray<UIImage *> *)frames {
    [self.framePickerView updateVideoFrames:frames];
}

- (void)updateCropAlbumImage:(UIImage *)image {
    //图片已被裁剪
    self.imagePickerView.selectedImage = image;
    [self switchToAlbumImage];
}

- (void)updateCurrentTimeRatio:(CGFloat)ratio {
    [self.framePickerView updateCurrentTimeRatio:ratio];
}

- (void)updateAlbumImageIfNeed {
    if (self.imagePickerView.selectedImage) {
        [self switchToAlbumImage];
        return;
    }
    
    @weakify(self);
    [self.delegate pickAlbumImageWithCompletion:^(UIImage * _Nullable image) {
        if (!image) {
            return;
        }
        @strongify(self);
        [self.delegate showAlbumImageCropViewWithImage:image];
    }];
}

- (void)switchToAlbumImage {
    if (!self.imagePickerView.selectedImage) {
        return;
    }
    self.currentType = DVEVideoCoverResourceTypeAlbumImage;
    self.imagePickerView.hidden = NO;
    self.framePickerView.hidden = YES;
}

#pragma mark - DVEVideoCoverVideoFramePickerDelegate

- (void)updatePreviewWithCurrentTimeRatio:(CGFloat)timeRatio {
    [self.delegate updatePreviewCurrentTimeWithRatio:timeRatio];
}

#pragma mark - DVEVideoCoverAlbumImagePickerDelegate

- (void)updateSelectedAlbumImageWithCompletion:(void (^)(UIImage * _Nullable))completion {
    [self.delegate pickAlbumImageWithCompletion:^(UIImage * _Nullable image) {
        if (completion) {
            completion(image);
        }
    }];
}

- (void)showAlbumImageCropViewWithImage:(UIImage *)image {
    [self.delegate showAlbumImageCropViewWithImage:image];
}

@end
