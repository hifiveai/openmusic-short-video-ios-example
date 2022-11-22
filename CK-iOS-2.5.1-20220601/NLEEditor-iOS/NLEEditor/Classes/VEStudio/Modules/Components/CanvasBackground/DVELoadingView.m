//
//  DVELoadingView.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/9.
//

#import "DVELoadingView.h"
#import "DVEMacros.h"
#import "NSString+VEToImage.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "NSBundle+DVE.h"
#import <DVETrackKit/DVECustomResourceProvider.h>
#import <Lottie/LOTAnimationView.h>
#import <Lottie/Lottie.h>
#import <Masonry/Masonry.h>

@implementation DVELoadingType

- (instancetype)initWithRawValue:(NSString *)rawValue {
    if (self = [super init]) {
        _rawValue = rawValue;
    }
    return self;
}

+ (instancetype)smallLoadingType {
    static DVELoadingType *smallType = nil;
    if (!smallType) {
        smallType = [[DVELoadingType alloc] initWithRawValue:@"lv_loading_s"];
    }
    return smallType;
}


+ (instancetype)largeLoadingType {
    static DVELoadingType *largeType = nil;
    if (!largeType) {
        largeType = [[DVELoadingType alloc] initWithRawValue:@"lv_loading_L"];
    }
    return largeType;
}

+ (instancetype)lightSmallLoadingType {
    static DVELoadingType *lightSmallType = nil;
    if (!lightSmallType) {
        lightSmallType = [[DVELoadingType alloc] initWithRawValue:@"lv_loading_s_light"];
    }
    return lightSmallType;
}

+ (instancetype)lightLargeLoadingType {
    static DVELoadingType *lightLargeType = nil;
    if (!lightLargeType) {
        lightLargeType = [[DVELoadingType alloc] initWithRawValue:@"lv_loading_L_light"];
    }
    return lightLargeType;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[DVELoadingType class]]) {
        return NO;
    }
    return [self.rawValue isEqualToString:[(DVELoadingType *)object rawValue]];
}

@end

@interface DVELoadingView ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) LOTAnimationView *animationView;

@property (nonatomic, assign) BOOL isImageviewAnimating;

@property (nonatomic, assign) BOOL isAnimationViewAnimating;

@property (nonatomic, strong) id<NSObject> imageEnterForegroundNotify;

@property (nonatomic, strong) id<NSObject> imageEnterBackgroundNotify;

@property (nonatomic, strong) id<NSObject> lottieEnterForegroundNotify;

@property (nonatomic, strong) id<NSObject> lottieEnterBackgroundNotify;

@end

@implementation DVELoadingView

- (void)dealloc {
    if (self.imageEnterForegroundNotify) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.imageEnterForegroundNotify];
    }
    if (self.imageEnterBackgroundNotify) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.imageEnterBackgroundNotify];
    }
    if (self.lottieEnterForegroundNotify) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.lottieEnterForegroundNotify];
    }
    if (self.lottieEnterBackgroundNotify) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.lottieEnterBackgroundNotify];
    }
}

- (void)startLoadingWithImage:(UIImage *)image {
    
    if (self.isImageviewAnimating) {
        return;
    }
    UIImage *icon = [@"loading_small" dve_toImage];
    @weakify(self);
    _imageEnterForegroundNotify = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                                                    object:nil
                                                                                     queue:[NSOperationQueue mainQueue]
                                                                                usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self);
        [self p_stopLoading];
        [self p_startLoadingWithImage:icon];
    }];
    _imageEnterBackgroundNotify = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                                                     object:nil
                                                                                      queue:[NSOperationQueue mainQueue]
                                                                                 usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self);
        [self p_stopLoading];
    }];
    self.isImageviewAnimating = YES;
}

- (void)stopLoading {
    if (!self.isImageviewAnimating) {
        return;
    }
    
    if (self.imageEnterForegroundNotify) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.imageEnterForegroundNotify];
        self.imageEnterForegroundNotify = nil;
    }
    if (self.imageEnterBackgroundNotify) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.imageEnterBackgroundNotify];
        self.imageEnterBackgroundNotify = nil;
    }
    
    [self p_stopLoading];
    self.isImageviewAnimating = NO;
}

- (void)p_startLoadingWithImage:(UIImage * _Nullable)icon {
    UIImageView *imgView = [[UIImageView alloc] initWithImage:icon];
    [self addSubview:imgView];
    imgView.center = self.center;
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    anim.duration = 0.5;
    anim.fromValue = @(0.0);
    anim.toValue = @(-2.0 * M_PI);
    anim.repeatCount = FLT_MAX;
    [imgView.layer addAnimation:anim forKey:@"LoadingViewProtocol.loading"];
    self.imageView = imgView;
}

- (void)p_stopLoading {
    [self.imageView.layer removeAllAnimations];
    [self.imageView removeFromSuperview];
    self.imageView = nil;
}


- (void)setLottieLoadingWithType:(DVELoadingType *)type {
    [self p_setLottieLoadingWithName:type.rawValue];
}

- (void)startLottieLoadingWithType:(DVELoadingType *)type loopAnimation:(BOOL)loopAnimation {
    if (self.isAnimationViewAnimating) {
        return;
    }
    NSString *name = type.rawValue;
    [self p_startLottieLoadingWithName:name loopAnimation:loopAnimation];
    @weakify(self);
    _lottieEnterForegroundNotify = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                                                     object:nil
                                                                                      queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self);
        if (self && self.animationView && self.isAnimationViewAnimating) {
            return;
        }
        [self.animationView play];
    }];
    _lottieEnterBackgroundNotify = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                                                     object:nil
                                                                                      queue:[NSOperationQueue mainQueue]
                                                                                 usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self);
        if (self && self.animationView && self.isAnimationViewAnimating) {
            return;
        }
        [self.animationView stop];
    }];
    
    self.isAnimationViewAnimating = YES;
}

- (void)stopLottieLoading {
    if (!self.isAnimationViewAnimating) {
        return;
    }
    if (self.lottieEnterForegroundNotify) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.lottieEnterForegroundNotify];
        self.lottieEnterForegroundNotify = nil;
    }
    if (self.lottieEnterBackgroundNotify) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.lottieEnterBackgroundNotify];
        self.lottieEnterBackgroundNotify = nil;
    }
    [self p_stopLottieLoading];
    self.isAnimationViewAnimating = NO;
}

- (void)p_setLottieLoadingWithName:(NSString *)name{
    if (self.animationView) {
        return;
    }
    NSString *filePath = [[DVECustomResourceProvider shareManager] pathForResource:name ofType:@"json"];
    LOTAnimationView *lotAnimationView = [LOTAnimationView animationWithFilePath:filePath];
    
    [lotAnimationView play];
    [self addSubview:lotAnimationView];
    lotAnimationView.frame = CGRectMake(0, 0, 21, 12);
    lotAnimationView.center = self.center;
    self.animationView = lotAnimationView;
}

- (void)p_startLottieLoadingWithName:(NSString *)name
                       loopAnimation:(BOOL)loopAnimation
                                {
    if (!self.animationView) {
        [self p_setLottieLoadingWithName:name];
    }
    self.animationView.loopAnimation = loopAnimation;
    [self.animationView play];
}


- (void)p_stopLottieLoading {
    [self.animationView stop];
    [self.animationView removeFromSuperview];
    self.animationView = nil;
}

- (void)showOnView:(UIView *)view {
    [self startLottieLoadingWithType:[DVELoadingType smallLoadingType] loopAnimation:YES];
    [view addSubview:self];
    self.size = view.size;
    self.center = view.center;
}

- (void)dismiss {
    [self stopLottieLoading];
    [self removeFromSuperview];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self stopLottieLoading];
    } else {
        [self startLottieLoadingWithType:[DVELoadingType smallLoadingType] loopAnimation:YES];
    }
}

@end
