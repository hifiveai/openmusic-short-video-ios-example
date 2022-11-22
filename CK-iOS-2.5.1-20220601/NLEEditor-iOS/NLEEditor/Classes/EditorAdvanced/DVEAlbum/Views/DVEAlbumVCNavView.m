//
//  DVEAlbumVCNavView.m
//  CameraClient
//
//  Created by bytedance on 2020/6/18.
//

#import "UIView+DVEAlbumMasonry.h"
#import "DVEAlbumVCNavView.h"
#import "DVEAlbumConfigProtocol.h"
#import <Masonry/Masonry.h>
#import "UIButton+DVEAlbumAdditions.h"
#import "DVEAlbumLanguageProtocol.h"
#import "DVEAlbumResourceUnion.h"

@interface UIView (AWESelectAlbum)

@property (nonatomic, assign) CGFloat acc_finalShowAlpha;

@end

@implementation UIView (AWESelectAlbum)

- (void)setAcc_finalShowAlpha:(CGFloat)acc_finalShowAlpha
{
    NSNumber *value = @(acc_finalShowAlpha);
    objc_setAssociatedObject(self, @selector(acc_finalShowAlpha), value, OBJC_ASSOCIATION_RETAIN);
}

- (CGFloat)acc_finalShowAlpha
{
    NSNumber *value = objc_getAssociatedObject(self, @selector(acc_finalShowAlpha));
    if (!value) {
        value = @(1.0);
    }
    return [value doubleValue];
}

@end

@interface DVEAlbumVCNavView () <CAAnimationDelegate>

@property (nonatomic, strong) NSArray *switchToViewArray;

@property (nonatomic, assign, readwrite) BOOL isAnimating;
@property (nonatomic, assign) BOOL isEliteVersion;

@property (nonatomic, strong) UIImageView *galleryImageView;
@property (nonatomic, assign) DVEAlbumVCNavViewMode mode;

@property (nonatomic, assign) DVEAlbumVCType type;
@property (nonatomic, strong) UIView *galleryRemindView;

@property (nonatomic, strong) id<DVEAlbumConfigProtocol> config;

@end

@implementation DVEAlbumVCNavView

//DVEAutoInject(TOCBaseServiceProvider(), config, DVEAlbumConfigProtocol)

- (instancetype)initWithVCType:(DVEAlbumVCType)type
{
    self = [super init];
    if (self) {
        _type = type;
        _isEliteVersion = NO;
        [self p_setupUI];
    }
    return self;
}

- (void)p_setupUI
{
    self.backgroundColor = TOCResourceColor(TOCUIColorConstBGContainer);
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.photoNextButton];
    [self addSubview:self.photoMovieButton];
    [self addSubview:self.videoNextButton];
    [self addSubview:self.leftCancelButton];
    [self addSubview:self.selectAlbumButton];
    [self addSubview:self.rightGoToShootButton];
    [self addSubview:self.closeButton];

    DVEAlbumMasMaker(self.rightGoToShootButton, {
        make.right.equalTo(@-16);
        make.centerY.equalTo(self.mas_centerY);
    });
    DVEAlbumMasMaker(self.closeButton, {
        make.left.equalTo(@16);
        make.centerY.equalTo(self.mas_centerY);
    });

    DVEAlbumMasMaker(self.photoMovieButton, {
        make.right.equalTo(self.mas_right).offset(-13);
        make.centerY.equalTo(self.mas_centerY);
    });
    DVEAlbumMasMaker(self.photoNextButton, {
        make.right.equalTo(self.mas_right).offset(-13);
        make.centerY.equalTo(self.mas_centerY);
    });
    DVEAlbumMasMaker(self.videoNextButton, {
        make.right.equalTo(self.mas_right).offset(-13);
        make.centerY.equalTo(self.mas_centerY);
    });
    
    DVEAlbumMasMaker(self.leftCancelButton, {
        make.left.equalTo(@16);
        make.centerY.equalTo(self.mas_centerY);
    });
    
    [self.photoMovieButton.leftLabel sizeToFit];
    CGFloat photoMovieWidth = self.photoMovieButton.leftLabel.frame.size.width + 27;
    DVEAlbumMasMaker(self.selectAlbumButton, {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
//        make.width.mas_lessThanOrEqualTo(TOC_SCREEN_WIDTH - photoMovieWidth * 2);
        make.width.mas_equalTo(@(90));
    });
    
    switch (self.type) {
        case DVEAlbumVCTypeForCutSame:
        case DVEAlbumVCTypeForCutSameChangeMaterial:
        {
            [self.titleLabel sizeToFit];
            self.titleLabel.hidden = NO;
            self.leftCancelButton.hidden = NO;
            self.selectAlbumButton.hidden = NO;
        }
            break;
    }
    self.mode = DVEAlbumVCNavViewModeNoPhoto;

    if (self.type == DVEAlbumVCTypeForCutSame || self.type == DVEAlbumVCTypeForCutSameChangeMaterial) {
        self.switchToViewArray = @[
                                   self.titleLabel,
                                   ];
    } else {
        self.switchToViewArray = @[];
    }
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGRect frame;
    CGFloat diff = 0;
    frame = self.titleLabel.frame;
    frame.origin.x = (w - frame.size.width) / 2;
    frame.origin.y = (h - frame.size.height) / 2 + diff;
    self.titleLabel.frame = frame;
}

- (void)switchFrom:(NSArray *)fromViewsArray toViews:(NSArray *)toViewsArray
{
    self.switchToViewArray = toViewsArray;
    
    NSMutableSet *sameViewSet = [NSMutableSet setWithArray:fromViewsArray];
    NSMutableSet *toViewsSet = [NSMutableSet setWithArray:toViewsArray];
    [sameViewSet intersectSet:toViewsSet];
    
    NSMutableArray *fromViews = [fromViewsArray mutableCopy];
    NSMutableArray *toViews = [toViewsArray mutableCopy];
    
    for (UIView *sameView in sameViewSet) {
        sameView.hidden = NO;
        sameView.alpha = sameView.acc_finalShowAlpha;
        [fromViews removeObject:sameView];
        [toViews removeObject:sameView];
    }
    
    for (UIView *view in fromViews) {
        view.hidden = NO;
        view.alpha = view.acc_finalShowAlpha;
        view.userInteractionEnabled = NO;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        for (UIView *view in fromViews) {
            view.alpha = 0;
        }
    } completion:^(BOOL finished) {
        for (UIView *view in fromViews) {
            view.hidden = YES;
            view.userInteractionEnabled = YES;
        }
        
        for (UIView *view in toViews) {
            view.hidden = NO;
            view.alpha = 0;
        }
        [UIView animateWithDuration:0.3 animations:^{
            for (UIView *view in toViews) {
                view.alpha = view.acc_finalShowAlpha;
            }
        }];
    }];
}

#pragma mark - Public Method

- (void)switchToMode:(DVEAlbumVCNavViewMode)mode
{
    if (self.mode == mode) {
        return;
    }
    
    self.mode = mode;
    NSArray *toViews = nil;
    switch (mode) {
        case DVEAlbumVCNavViewModeNoPhoto:
            if (self.type == DVEAlbumVCTypeForCutSame || self.type == DVEAlbumVCTypeForCutSameChangeMaterial) {
                toViews = @[
                            self.titleLabel,
                            ];
            } else {
                toViews = @[];
            }
            break;
        case DVEAlbumVCNavViewModeOnePhoto:
            if (self.type == DVEAlbumVCTypeForCutSame || self.type == DVEAlbumVCTypeForCutSameChangeMaterial) {
                toViews = @[
                            self.titleLabel,
                            self.photoNextButton,
                            ];
            } else {
                toViews = @[
                            self.photoNextButton,
                            ];
            }
            break;
        case DVEAlbumVCNavViewModeMutiPhoto: {
            toViews = @[
                        self.titleLabel,
                        self.photoMovieButton,
                        ];
            self.photoMovieButton.acc_finalShowAlpha = 1.0;
        }
            break;
        case DVEAlbumVCNavViewModeMutiVideo: {
            toViews = @[
                        self.titleLabel,
                        self.videoNextButton,
                        ];
        }
            break;
    }
    [self switchFrom:self.switchToViewArray toViews:toViews];
}

- (void)updatePhotoMovieTitleWithPhotoCount:(NSInteger)count
{
    self.photoMovieButton.leftLabel.text = [NSString stringWithFormat:TOCLocalizedString(@"com_mig_slideshow_zd",@"照片电影(%zd)"), count];
}

//-----由SMCheckProject工具删除-----
//- (void)updateVideoNextTitleWithVideoCount:(NSInteger)count enabled:(BOOL)enabled
//{
//    [self updateVideoNextTitleWithPrefix:nil videoCount:count enabled:enabled];
//}

- (void)updateVideoNextTitleWithPrefix:(NSString * _Nullable)prefixTitle videoCount:(NSInteger)count enabled:(BOOL)enabled
{
    if (prefixTitle == nil) {
        self.videoNextButton.leftLabel.text = [NSString stringWithFormat:TOCLocalizedString(@"com_mig_next_zd_07oymg", @"下一步(%zd)"), count];
    } else {
        self.videoNextButton.leftLabel.text = [NSString stringWithFormat:TOCLocalizedString(@"%@(%zd)",@"%@(%zd)"), prefixTitle, count];
    }

    if (enabled) {
        self.videoNextButton.leftLabel.textColor = TOCResourceColor(TOCUIColorConstPrimary);
    } else {
        self.videoNextButton.leftLabel.textColor = TOCResourceColor(TOCUIColorConstTextTertiary);
    }
}

#pragma mark - Getter

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = TOCResourceColor(TOCUIColorConstTextTertiary);
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (DVEImageRightButton *)selectAlbumButton
{
    if (!_selectAlbumButton) {
        _selectAlbumButton = [[DVEImageRightButton alloc] initWithType:SCIFAnimatedButtonTypeAlpha titleAndImageInterval:4];
        _selectAlbumButton.leftLabel.text = @"所有照片";
        _selectAlbumButton.leftLabel.font = [UIFont boldSystemFontOfSize:17];
        _selectAlbumButton.leftLabel.backgroundColor = [UIColor clearColor];
        _selectAlbumButton.leftLabel.textColor = TOCResourceColor(TOCUIColorConstTextPrimary);
        _selectAlbumButton.rightImageView.image = TOCResourceImage(@"icon_mv_arrow_down");
        _selectAlbumButton.hidden = YES;
    }
    return _selectAlbumButton;
}

- (DVEImageRightButton *)mvDoneButton
{
    if (!_mvDoneButton) {
        _mvDoneButton = [[DVEImageRightButton alloc] initWithType:SCIFAnimatedButtonTypeScale];
        _mvDoneButton.leftLabel.text = [NSString stringWithFormat:TOCLocalizedString(@"com_mig_ok_zd",@"确定(%zd)"), 0];
        _mvDoneButton.leftLabel.textColor = TOCResourceColor(TOCUIColorConstTextTertiary);
        _mvDoneButton.enabled = NO;
        _mvDoneButton.hidden = YES;
    }
    return _mvDoneButton;
}

- (DVEImageRightButton *)photoNextButton
{
    if (!_photoNextButton) {
        _photoNextButton = [[DVEImageRightButton alloc] initWithType:SCIFAnimatedButtonTypeScale];
        _photoNextButton.leftLabel.text = TOCLocalizedString(@"common_next", @"下一步");
        _photoNextButton.leftLabel.textColor = TOCResourceColor(TOCUIColorConstTextPrimary);
        _photoNextButton.hidden = YES;
    }
    return _photoNextButton;
}

- (DVEImageRightButton *)videoNextButton
{
    if (!_videoNextButton) {
        _videoNextButton = [[DVEImageRightButton alloc] initWithType:SCIFAnimatedButtonTypeScale];
        _videoNextButton.leftLabel.text = TOCLocalizedString(@"common_next", @"下一步");
        _videoNextButton.leftLabel.textColor = TOCResourceColor(TOCUIColorConstTextPrimary);
        _videoNextButton.hidden = YES;
    }
    return _videoNextButton;
}

- (DVEImageRightButton *)photoMovieButton
{
    if (!_photoMovieButton) {
        _photoMovieButton = [[DVEImageRightButton alloc] initWithType:SCIFAnimatedButtonTypeScale];
        _photoMovieButton.leftLabel.text = TOCLocalizedString(@"com_mig_slideshow_1", @"照片电影(1)");
        _photoMovieButton.leftLabel.textColor = TOCResourceColor(TOCUIColorConstTextPrimary);
        _photoMovieButton.hidden = YES;
        _photoMovieButton.leftLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    return _photoMovieButton;
}

- (UIButton *)leftCancelButton
{
    if (!_leftCancelButton) {
        UIImage *closeImage = TOCResourceImage(@"icon_album_close");
        _leftCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftCancelButton setImage:closeImage forState:UIControlStateNormal];
        _leftCancelButton.acc_hitTestEdgeInsets = UIEdgeInsetsMake(-8, -8, -8, -8);
        _leftCancelButton.accessibilityLabel = TOCLocalizedString(@"back_confirm",@"返回");
    }
    return _leftCancelButton;
}

- (UIButton *)rightGoToShootButton
{
    if (!_rightGoToShootButton) {
        _rightGoToShootButton = [[UIButton alloc] init];
        [_rightGoToShootButton setImage:TOCResourceImage(@"icon_camera") forState:UIControlStateNormal];
        [_rightGoToShootButton setTitle:TOCLocalizedString(@"creation_album_shoot", @"去拍摄") forState:UIControlStateNormal];
        _rightGoToShootButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_rightGoToShootButton setTitleColor:TOCResourceColor(TOCColorTextReverse) forState:UIControlStateNormal];
        [_rightGoToShootButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 6)];
        _rightGoToShootButton.hidden = YES;
        [_rightGoToShootButton sizeToFit];
    }
    return _rightGoToShootButton;
}

- (DVEAlbumAnimatedButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [[DVEAlbumAnimatedButton alloc] initWithFrame:CGRectMake(6, 20, 44, 44)];
        [_closeButton setTintColor:TOCResourceColor(TOCColorTextReverse)];
        [_closeButton setImage:[TOCResourceImage(@"ic_titlebar_close_white") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _closeButton.hidden = YES;
    }
    return _closeButton;
}

@end

