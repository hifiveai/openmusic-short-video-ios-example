//
//  DVEAlbumLoadingViewDefaultImpl.m
//  VideoTemplate
//
//  Created by bytedance on 2020/12/8.
//

#import "DVEAlbumLoadingViewDefaultImpl.h"
#import <MBProgressHUD/MBProgressHUD.h>

#pragma mark - TOCLoadingViewProtocol

@interface DVEAlbumLoadingView: MBProgressHUD <DVEAlbumLoadingViewProtocol>

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation DVEAlbumLoadingView

@synthesize cancelable = _cancelable;
@synthesize cancelBlock;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.mode = MBProgressHUDModeIndeterminate;
        self.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
//        self.bezelView.blurEffectStyle = UIBlurEffectStyleDark;
        self.bezelView.color = [UIColor clearColor];
        self.backgroundView.color = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        [self setContentColor:[UIColor colorWithWhite:1 alpha:0.8]];
    }
    return self;
}

- (void)cancelAction {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)setCancelable:(BOOL)cancelable {
    if (_cancelable != cancelable) {
        if (cancelable) {
            [self addGestureRecognizer:self.tapGesture];
        } else {
            [self removeGestureRecognizer:self.tapGesture];
        }
        _cancelable = cancelable;
    }
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAction)];
        _tapGesture.numberOfTouchesRequired = 1;
        _tapGesture.numberOfTapsRequired = 1;
    }
    return _tapGesture;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [super hitTest:point withEvent:event];
    
}

+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated
{
    DVEAlbumLoadingView *hud = [[self alloc] initWithView:view];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.removeFromSuperViewOnHide = YES;
    [view addSubview:hud];
    [hud showAnimated:animated];
    return hud;
}

- (void)dismiss {
    [self dismissWithAnimated:NO];
}

- (void)dismissWithAnimated:(BOOL)animated {
    [self hideAnimated:animated];
}

- (void)startAnimating {
    [self showAnimated:YES];
}

- (void)stopAnimating {
    [self dismiss];
}

- (void)allowUserInteraction:(BOOL)allow {
    self.userInteractionEnabled = allow;
}

@end

#pragma mark - DVETextLoadingViewProtcol


@interface DVETextLoadingView: DVEAlbumLoadingView <DVEAlbumTextLoadingViewProtcol>

@end

@implementation DVETextLoadingView

+ (nonnull UIView<DVEAlbumTextLoadingViewProtcol> *)showTextLoadingOnView:(nonnull UIView *)view title:(NSString *)title animated:(BOOL)animated {

    DVETextLoadingView *hud = [[self alloc] initWithView:view];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.removeFromSuperViewOnHide = YES;
    [view addSubview:hud];
    hud.label.text = title;
    [hud showAnimated:animated];
    return hud;
}

@end

#pragma mark -

@interface DVEAlbumProcessView: DVEAlbumLoadingView <DVEAlbumProcessViewProtcol>

@end

@implementation DVEAlbumProcessView

- (void)showAnimated:(BOOL)animated
{
    [super showAnimated:animated];
}

- (void)showOnView:(UIView *)view animated:(BOOL)animated
{
    [super showAnimated:animated];
}

- (void)dismissAnimated:(BOOL)animated
{
    [self hideAnimated:animated];
}

- (void)setLoadingTitle:(NSString *)loadingTitle {
    self.label.text = loadingTitle;
}

- (NSString *)loadingTitle {
    return self.label.text;
}

- (void)setLoadingProgress:(CGFloat)loadingProgress {
    [self setProgress:loadingProgress];
}

- (CGFloat)loadingProgress {
    return self.progress;
}

+ (UIView<DVEAlbumProcessViewProtcol> *)showProgressOnView:(UIView *)view title:(NSString *)title animated:(BOOL)animated type:(DVEAlbumProgressLoadingViewType)type {

    DVEAlbumProcessView *hud = [[self alloc] initWithView:view];
    if (type == DVEAlbumProgressLoadingViewTypeHorizon) {
        hud.mode = MBProgressHUDModeDeterminateHorizontalBar;

    } else {
        hud.mode = MBProgressHUDModeAnnularDeterminate;

    }
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.backgroundColor = [UIColor clearColor];
    hud.bezelView.style = MBProgressHUDBackgroundStyleBlur;
//    hud.bezelView.blurEffectStyle = UIBlurEffectStyleDark;
    hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    hud.removeFromSuperViewOnHide = YES;
    [view addSubview:hud];
    hud.label.text = title;
    hud.button.hidden = NO;
    [hud.button setTitle:@"hahah" forState:UIControlStateNormal];
    [hud showAnimated:animated];
    return hud;
}

@synthesize loadingTitle;
@synthesize loadingProgress;
@end


@implementation DVEAlbumLoadingViewDefaultImpl

+ (UIView<DVEAlbumLoadingViewProtocol> *)loadingView {
    return [[DVEAlbumLoadingView alloc] init];
}

+ (UIView<DVEAlbumLoadingViewProtocol> *)showLoadingOnView:(UIView *)view
{
    return [DVEAlbumLoadingView showHUDAddedTo:view animated:YES];
}

+ (nonnull UIView<DVEAlbumTextLoadingViewProtcol> *)showTextLoadingOnView:(nonnull UIView *)view title:(NSString *)title animated:(BOOL)animated {
    return [DVETextLoadingView showTextLoadingOnView:view title:title animated:animated];
}

+ (UIView<DVEAlbumProcessViewProtcol> *)showProgressOnView:(UIView *)view title:(NSString *)title animated:(BOOL)animated type:(DVEAlbumProgressLoadingViewType)type
{
    return [DVEAlbumProcessView showProgressOnView:view title:title animated:animated type:type];
}

+ (UIView<DVEAlbumProcessViewProtcol> *)showProcessOnView:(UIView *)view title:(NSString *)title animated:(BOOL)animated {
    return [DVEAlbumProcessView showProgressOnView:view title:title animated:animated type:DVEAlbumProgressLoadingViewTypeProgress];
}

@end
