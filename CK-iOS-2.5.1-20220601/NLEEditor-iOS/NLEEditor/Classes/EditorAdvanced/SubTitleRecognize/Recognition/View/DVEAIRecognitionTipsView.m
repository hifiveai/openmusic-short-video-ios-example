//
//  DVEAIRecognitionTipsView.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/23.
//

#import "DVEAIRecognitionTipsView.h"
#import "DVEMacros.h"
#import "UIImage+DVEStyle.h"
#import "DVELoadingView.h"
#import "DVERecognizer.h"
#import "DVEVCContext.h"
#import "DVEUIHelper.h"
#import <DVETrackKit/UIView+VEExt.h>
#import <Masonry/Masonry.h>

@interface DVEAIRecognitionTipsView()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) DVELoadingView *loadingView;
@property (nonatomic, strong) DVERecognizer *audioToSubtitleRecognizer;
@property (nonatomic, strong) id<DVECoreStickerProtocol> stickerEditor;
@end

@implementation DVEAIRecognitionTipsView

DVEAutoInject(self.vcContext.serviceProvider, stickerEditor, DVECoreStickerProtocol)

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.backgroundColor = colorWithHex(0X101010);
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.font = SCRegularFont(14);
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = @"字幕识别中...";
    
    _closeButton = [[UIButton alloc] init];
    [_closeButton setImage:[UIImage dve_image:@"icon_close"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(handleClose) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addSubview:self.loadingView];
    [self addSubview:_titleLabel];
    [self addSubview:_closeButton];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(45);
        make.bottom.equalTo(self).offset(-16);
    }];
    
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-5);
        make.width.height.mas_equalTo(40);
        make.centerY.equalTo(self.titleLabel);
    }];
    
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.bottom.equalTo(self).offset(-30);
    }];
}

- (DVELoadingView *)loadingView {
    if(!_loadingView) {
        DVELoadingType *type = [DVELoadingType smallLoadingType];
        _loadingView = [[DVELoadingView alloc] initWithFrame:CGRectMake(0, 0, 10, 6)];
        [_loadingView setLottieLoadingWithType:type];
    }
    return _loadingView;
}

- (DVERecognizer *)audioToSubtitleRecognizer
{
    if (!_audioToSubtitleRecognizer) {
        _audioToSubtitleRecognizer = [[DVERecognizer alloc] initWithContext:self.vcContext];
    }
    return _audioToSubtitleRecognizer;
}


- (void)startAudioToSubtitleRecognizerWithCoverOldSubtitle:(BOOL)coverOldSubtitle
{
    [self showRecognizeTipsLoading];
    @weakify(self);
    [[[self.audioToSubtitleRecognizer recognizeAudioText] deliverOnMainThread] subscribeNext:^(DVESubtitleQueryModel * _Nullable x) {
        @strongify(self);
        [self.stickerEditor insertAutoSubtitle:x coverOldSubtitle:coverOldSubtitle];
        [self showRecognizeTipsFinish];
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        [self showRecognizeTipsError];
    }];
}

- (void)showRecognizeTipsLoading
{
    self.status = DVEAIRecognitionStatusLoading;
    UIView *targetView = [UIView currentWindow];
    [self showAtView:targetView title:@"字幕识别中..." autoDismiss:NO];
}


- (void)showRecognizeTipsFinish
{
    self.status = DVEAIRecognitionStatusSuccess;
    UIView *targetView = [UIView currentWindow];
    [self showAtView:targetView title:@"识别成功，已自动生成字幕" autoDismiss:YES];
}

- (void)showRecognizeTipsError
{
    self.status = DVEAIRecognitionStatusFailed;
    UIView *targetView = [UIView currentWindow];
    [self showAtView:targetView title:@"识别失败！" autoDismiss:YES];
}

- (void)showAtView:(UIView *)view
{
    [view addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(view);
        make.height.mas_equalTo(50 + VETopMargnValue);
    }];
}

- (void)showAtView:(UIView *)view title:(NSString *)title autoDismiss:(BOOL)autoDismiss;
{
    self.titleLabel.text = title;
    if (self.status == DVEAIRecognitionStatusSuccess || self.status == DVEAIRecognitionStatusFailed) {
        self.loadingView.hidden = YES;
        [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(16);
            make.bottom.equalTo(self).offset(-16);
        }];
    }
    
    [self showAtView:view];
    
    if (autoDismiss) {
        @weakify(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            @strongify(self);
            [self dismiss];
        });
    }
}

- (void)dismiss
{
    @weakify(self);
    [UIView animateWithDuration:0 delay:2 options:0 animations:^{
        @strongify(self);
        [self removeFromSuperview];
    } completion:nil];

}

#pragma mark - Action

- (void)handleClose
{
    [self dismiss];
}

@end
