//
//  DVEAlbumVerticalSliderView.m
//  AWEStudio
//
//  Created by bytedance on 2020/3/12.
//

#import "DVEAlbumVerticalSliderView.h"
#import "DVEAlbumConfigProtocol.h"
#import "DVEAlbumResourceUnion.h"

@interface DVEAlbumVerticalSliderView () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, strong) UIImageView *sliderBottomImageView;
@property (nonatomic, strong) UIImageView *sliderUpperImageView;
@property (nonatomic, strong) NSString *currentStateStr;
@property (nonatomic, strong) id<DVEAlbumConfigProtocol> galleryConfig;

@end

@implementation DVEAlbumVerticalSliderView
//DVEAutoInject(TOCBaseServiceProvider(), galleryConfig, DVEAlbumConfigProtocol)

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.sliderBottomImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.sliderBottomImageView.image = TOCResourceImage(@"icon_album_slider_bottom");
        [self addSubview:self.sliderBottomImageView];
        self.userInteractionEnabled = YES;
        
        self.sliderUpperImageView = [[UIImageView alloc] initWithFrame:CGRectMake(28, 28, 12, 24)];
        self.sliderUpperImageView.image = TOCResourceImage(@"icon_album_slider_upper");
        [self addSubview:self.sliderUpperImageView];
        
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 29, 0, 21)];
        self.dateLabel.text = @"";
        self.dateLabel.font = self.galleryConfig.galleryTimeLabelFont;
        self.dateLabel.textColor = TOCResourceColor(TOCUIColorConstTextPrimary);
        if (@available(iOS 13.0, *)) {
            self.dateLabel.textColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    return TOCResourceColor(TOCUIColorConstTextInverse2);
                } else {
                    return TOCResourceColor(TOCUIColorConstTextPrimary);
                }
            }];
        }
        
        [self addSubview:self.dateLabel];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        pan.minimumNumberOfTouches = 1;
        pan.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:pan];
        
        self.hidden = YES;
        
        self.currentStateStr = @"slide";
    }
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)panGest {
    if (panGest.state == UIGestureRecognizerStateBegan) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(disappearAnimation) object:nil];
        self.originalFrame = self.frame;
        if ([self.delegate respondsToSelector:@selector(verticalSliderViewWillScroll:)]) {
            [self.delegate verticalSliderViewWillScroll:self];
        }
        [self stretchAnimation];
    } else if (panGest.state == UIGestureRecognizerStateChanged) {
        CGRect rect = self.originalFrame;
        CGFloat top = rect.origin.y;
        CGFloat translation = [panGest translationInView:self.superview].y;
        if (top + translation < self.topBoundary) {
            rect.origin.y = self.topBoundary;
        } else if (top + rect.size.height + translation > self.bottomBoundary) {
            rect.origin.y = self.bottomBoundary - rect.size.height;
        } else {
            rect.origin.y += translation;
        }
        
        if ([self.delegate respondsToSelector:@selector(verticalSliderViewDidScroll:withScrollPosition:)]) {
            [self.delegate verticalSliderViewDidScroll:self withScrollPosition:rect.origin.y - self.topBoundary ] ;
        }
        
        self.frame = rect;
    } else if (panGest.state == UIGestureRecognizerStateEnded || panGest.state == UIGestureRecognizerStateCancelled || panGest.state == UIGestureRecognizerStateFailed) {
        if ([self.delegate respondsToSelector:@selector(verticalSliderViewFinishScroll:)]) {
            [self.delegate verticalSliderViewFinishScroll:self];
        }
        [self shrinkAnimation];
        self.currentStateStr = @"click";
        [self performSelector:@selector(disappearAnimation) withObject:nil afterDelay:3];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longGest{
    if (longGest.state == UIGestureRecognizerStateBegan) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(disappearAnimation) object:nil];
        [self stretchAnimation];
    } else if (longGest.state == UIGestureRecognizerStateChanged) {

    } else if (longGest.state == UIGestureRecognizerStateEnded) {
        [self shrinkAnimation];
        [self performSelector:@selector(disappearAnimation) withObject:nil afterDelay:3];
    }
}

#pragma mark - animation
- (void)appearAnimation{
    if (self.showAnimation == NO) {
        self.hidden = NO;
        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        CGFloat startX = self.frame.origin.x;
        self.frame = CGRectMake(startX, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = CGRectMake(startX - 56, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
        } completion:^(BOOL finished) {
        }];
        self.showAnimation = YES;
        self.currentStateStr = @"slide";
    }
}

- (void)disappearAnimation {
    if (self.showAnimation == YES) {
        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 56, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        CGFloat startX = self.frame.origin.x;
        self.frame = CGRectMake(startX, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = CGRectMake(startX + 56, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
        } completion:^(BOOL finished) {
            self.hidden = YES;
        }];
        self.showAnimation = NO;
    }
}

- (void)stretchAnimation {
    if (self.stretchedAnimation == NO) {
        self.sliderBottomImageView.frame = self.bounds;
        self.dateLabel.frame = CGRectMake(14, 29, 0, 21);
        CGFloat finalLenth = self.galleryConfig.sliderViewStretchAnimationFinalLength;
        self.dateLabel.alpha = 0;
        
        [UIView animateWithDuration:0.15 delay:0.15 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dateLabel.alpha = 1;
        } completion:^(BOOL finished) {
        }];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.sliderBottomImageView.frame = CGRectMake(self.bounds.size.width - finalLenth, 0, finalLenth, self.bounds.size.height);
            self.dateLabel.frame = CGRectMake(self.bounds.size.width - finalLenth + 34 , 29, finalLenth - 76, self.dateLabel.bounds.size.height);
            
        } completion:^(BOOL finished) {
        }];
        self.stretchedAnimation = YES;
    }
}

- (void)shrinkAnimation {
    if (self.stretchedAnimation == YES) {
        CGFloat finalLenth = self.galleryConfig.sliderViewStretchAnimationFinalLength;
        self.sliderBottomImageView.frame = CGRectMake(self.bounds.size.width - finalLenth, 0, finalLenth, self.bounds.size.height);
        self.dateLabel.frame = CGRectMake(self.bounds.size.width - finalLenth + 34 , 29, finalLenth - 76, self.dateLabel.bounds.size.height);
        self.dateLabel.alpha = 1;
        
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dateLabel.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.sliderBottomImageView.frame = self.bounds;
            self.dateLabel.frame = CGRectMake(14, 29, 0, 21);
        } completion:^(BOOL finished) {
            
        }];
        self.stretchedAnimation = NO;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
