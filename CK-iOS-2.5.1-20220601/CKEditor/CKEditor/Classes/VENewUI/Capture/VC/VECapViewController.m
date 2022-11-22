//
//  VECapViewController.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECapViewController.h"
#import "VECapBaseViewController+CapLayout.h"
#import "VECapBaseViewController+PrivateForCapVC.h"
#import "VECapManager.h"
#import "VECapPreView.h"
#import "VECapExposureAndFocusView.h"
#import "VEDVideoTool.h"
#import "VECustomerHUD.h"

@interface VECapViewController ()

@property (nonatomic, strong) VECapPreView *preView;
@property (nonatomic, strong) UIView *gestureView;

@property (nonatomic, strong) NSArray *filters;
@property (nonatomic, assign) float lastProgress;
@property (nonatomic, assign) float lastscale;



@end

@implementation VECapViewController
@synthesize capManager = _capManager;

- (void)dealloc
{
    [_capManager pausePreview];
    NSLog(@"VECapViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)VECapVCWithType:(VECPViewType)viewType
{
    VECapViewController *vc = [VECapViewController  new];
    vc.viewType = viewType;
    
    return vc;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.capManager resumPreview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.bottomBar.disableTimer = YES;
    [self.capManager pausePreview];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.bottomBar.disableTimer = NO;
    
    if (self.duetURL) {
        CGSize size = [VEDVideoTool getVideoSizeWithVideoURL:self.duetURL];
        if (size.width > 1980) {
            [VECustomerHUD showMessage:@"您导入的视频分辨率过大，可能会导致性能问题" afterDele:3];
        }
        [self refreshGesture];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.hidden = YES;
    self.capManager = [[VECapManager alloc] init];
    if (self.duetURL) {
        [self.capManager setDuetURL:self.duetURL];
    }
    [self initPreview];
    [self buildLayout];
    [self initNotification];
    if (self.duetURL) {
        @weakify(self);
        [RACObserve(self.capManager, currentDuetLayoutType) subscribeNext:^(NSNumber   * _Nullable x) {
            @strongify(self);
            if (x) {
                [self refreshGesture];
            }
        }];
    }
}

- (void)initPreview
{
    [self.view addSubview:self.preView];
    [self.preView addSubview:self.gestureView];
    _preView.center = CGPointMake(VE_SCREEN_WIDTH * 0.5, VE_SCREEN_HEIGHT * 0.5);
    _gestureView.center = CGPointMake(_preView.width * 0.5, _preView.height * 0.5);
    [self.capManager startPreviewWithView:self.preView];
}

- (void)buildLayout
{
    [self buildCapLayout];
    
    
    @weakify(self);
        
//    [_preView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(0);
//        make.left.mas_equalTo(0);
//        make.right.mas_equalTo(0);
//        make.top.mas_equalTo(0);
//    }];
    
    
    
    self.bottomBar.recordAction = ^(UIButton * _Nonnull button) {
        @strongify(self);
        self.topBar.hidden = button.selected;
        self.rightBar.hidden = button.selected;
        if (button.selected) {
            self.statusView.hidden = !button.selected;
        }
        
        if (self.recordAction) {
            self.recordAction(button);
        }
    };
    
    [self.capManager setVECameraDurationBlock:^(CGFloat duration, CGFloat totalDuration) {
        @strongify(self);
        self.statusView.duration = duration;
        self.bottomBar.duration = duration;
    }];
    
    [self addGestureForVC:self];
}

- (void)initNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didEnterBackground
{
    if (!self.view.window) {
        return;
    }
    NSLog(@"VECapViewController didEnterBackground");
    self.bottomBar.disableTimer = YES;
    [self.capManager pausePreview];
}


- (void)willEnterForeground
{
    if (!self.view.window) {
        return;
    }
    NSLog(@"VECapViewController willEnterForeground");
    self.bottomBar.disableTimer = NO;
    [self.capManager resumPreview];
    [self.capManager changeExposureBias:0];
    [VECapExposureAndFocusView hideInView:self.gestureView];
}

- (void)DidBecomeActive
{
    if (!self.view.window) {
        return;
    }
    NSLog(@"VECapViewController DidBecomeActive");
    self.bottomBar.disableTimer = NO;
    [self.capManager resumPreview];
    [self.capManager changeExposureBias:0];
    [VECapExposureAndFocusView hideInView:self.gestureView];
}


#pragma mark - setter

- (void)setViewType:(VECPViewType)viewType
{
    [super setViewType:viewType];
}

#pragma mark - getter




- (void)addGestureForVC:(UIViewController *)vc
{
    @weakify(self);
    [[_gestureView VEaddTapGestureSignalWithDelegate:self]  subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self tapPreview:x];
    }];
    
    [[_gestureView VEaddPinchGestureSignalWithDelegate:self] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self pinchPreview:x];
    }];
    
   
    
//    [[vc.view VESwipePanGestureSignalWithDelegate:self] subscribeNext:^(id  _Nullable x) {
//        @strongify(self);
//        [self SwipePreview:x];
//    }];
//
//    [[vc.view VEaddPanGestureSignalWithDelegate:self] subscribeNext:^(id  _Nullable x) {
//        @strongify(self);
//        [self panPreview:x];
//    }];
}

- (VECapPreView *)preView
{
    if (!_preView) {
        _preView = [[VECapPreView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, VE_SCREEN_WIDTH * 16 /9)];
        _preView.backgroundColor = [UIColor blackColor];
    }
    
    return _preView;
}

- (UIView *)gestureView
{
    if (!_gestureView) {
        _gestureView = [[VECapPreView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, VE_SCREEN_WIDTH * 16 /9)];
        _gestureView.backgroundColor = HEXRGBACOLOR(0xFFFFFF, 0.0);
    }
    
    return _gestureView;
}


- (void)tapPreview:(UITapGestureRecognizer *)tap
{
    CGPoint spoint = [tap locationInView:tap.view];
    CGPoint point = [self.gestureView convertPoint:spoint toView:self.preView];
    CGFloat x               = point.x / CGRectGetWidth(self.view.bounds);
    CGFloat y               = point.y / CGRectGetHeight(self.view.bounds);
    CGPoint pointOfInterest = CGPointMake(x, y);
    [self.capManager tapAtPoint:pointOfInterest];
    [self.capManager changeExposureBias:0];
    @weakify(self);
    [VECapExposureAndFocusView showInView:tap.view minValue:[self.capManager minExposureBias] maxValue:[self.capManager maxExposureBias] curValue:0 point:spoint exposureChangeBlock:^(CGFloat exposureValue) {
        @strongify(self);
        [self.capManager changeExposureBias:exposureValue];
    }];
    
}

- (void)pinchPreview:(UIPinchGestureRecognizer *)pinch
{
    switch (pinch.state) {
        case UIGestureRecognizerStateBegan:
            self.lastscale = [self.capManager currentCameraZoomFactor];
            break;
        case UIGestureRecognizerStateEnded:
            break;
        case UIGestureRecognizerStateChanged: {
            
            [self.capManager cameraSetZoomFactor:pinch.scale * self.lastscale];
        } break;
        default: break;
    }

    
}

- (void)panPreview:(UIPanGestureRecognizer *)recognizer
{
    CGPoint t = [recognizer translationInView:recognizer.view];
    float progress = 0.5;
    if (t.x > 0) {
       progress = t.x / VE_SCREEN_WIDTH;
        
    } else {
        progress = (VE_SCREEN_WIDTH + t.x) / VE_SCREEN_WIDTH;
    }
    
    if (fabsf(progress -self.lastProgress) > 0.01) {
        [self.capManager switchFilterWithLeftPath:self.filters.firstObject rightPath:self.filters.lastObject progress:progress];
    }
                   
}

- (void)SwipePreview:(UISwipeGestureRecognizer *)pinch
{
    [self.capManager switchCameraSource];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{

    if ([touch.view isEqual:gestureRecognizer.view] && ![touch.view isKindOfClass:[UISlider class]]) {
        return YES;
    } else {
        return NO;
    }
}


- (void)refreshGesture
{
    switch (self.capManager.currentDuetLayoutType) {
        case VECPDuetLayoutTypeHorizontal:
        {
            self.gestureView.bounds = CGRectMake(0, 0, VE_SCREEN_WIDTH * 0.5, VE_SCREEN_WIDTH * 0.5 * 16 / 9);
            self.gestureView.center = CGPointMake(VE_SCREEN_WIDTH * 0.25, _preView.height * 0.5);
        }
            break;
        case VECPDuetLayoutTypeVertical:
        {
            self.gestureView.bounds = CGRectMake(0, 0, VE_SCREEN_WIDTH , VE_SCREEN_WIDTH * 16 / 9);
            self.gestureView.center = CGPointMake(VE_SCREEN_WIDTH * 0.5, (_preView.height  * 0.5 - (VE_SCREEN_WIDTH * 16 / 9) * 0.5) * 0.5);
        }
            break;
        case VECPDuetLayoutTypeThree:
        {
            self.gestureView.bounds = CGRectMake(0, 0, VE_SCREEN_WIDTH, VE_SCREEN_WIDTH  * 16 / 9 / 3);
            self.gestureView.center = CGPointMake(VE_SCREEN_WIDTH * 0.5, _preView.height * 0.5);
        }
            break;
            
        default:
            break;
    }
}


@end
