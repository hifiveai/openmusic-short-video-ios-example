//
//  DVEAlbumZoomTransitionDelegate.m
//  CameraClient
//
//  Created by bytedance on 2020/7/19.
//

#import "DVEAlbumTransitionAnimationController.h"
#import "DVEAlbumTransitionInteractionController.h"
#import "DVEAlbumZoomTransition.h"
#import "DVEAlbumMacros.h"

@interface DVEAlbumZoomTransitionDelegate()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *percentDrivenTransition;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) DVEAlbumTransitionTriggerDirection triggerDirection;

@end

@implementation DVEAlbumZoomTransitionDelegate

@synthesize outterViewController, innerViewController, isAnimating, currentTransitioningContext, contextProvider;

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    id<DVEAlbumTransitionContextProvider> contextProvider = [[DVEMagnifyTransition alloc] init];
    self.contextProvider = contextProvider;
    return [DVEAlbumTransitionAnimationController instanceWithContextProvider:contextProvider transitionDelegate:self];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    id<DVEAlbumTransitionContextProvider> contextProvider = [[DVEShrinkTransition alloc] init];
    self.contextProvider = contextProvider;
    return [DVEAlbumTransitionAnimationController instanceWithContextProvider:contextProvider transitionDelegate:self];
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    id<DVEAlbumTransitionContextProvider> contextProvider = [[DVEInteractiveShrinkTransition alloc] initWithTransitionDelegate:self];
    self.contextProvider = contextProvider;
    return [DVEAlbumTransitionInteractionController instanceWithContextProvider:contextProvider transitionDelegate:self];
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    self.outterViewController = source;
    self.innerViewController = presented;
    [self.innerViewController.view addGestureRecognizer:self.panGestureRecognizer];
    
    UIPresentationController *presentation = [[UIPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    return presentation;
}

#pragma mark - Action

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    static CGPoint startLocation;
    CGPoint currentLocation = [panGestureRecognizer locationInView:[UIApplication sharedApplication].keyWindow];
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.isAnimating = YES;
            startLocation = currentLocation;
            [self.innerViewController dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if ([self.contextProvider respondsToSelector:@selector(updateAnimationWithPosition:startPosition:)]) {
                [self.contextProvider updateAnimationWithPosition:currentLocation startPosition:startLocation];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            CGFloat progress = [self p_progressForDirection:self.triggerDirection startLocation:startLocation currentLocation:currentLocation];
            CGPoint vector = [self p_vectorForDirection:self.triggerDirection];
            CGPoint velocity = [self.panGestureRecognizer velocityInView:self.innerViewController.view];
            BOOL shouldComplete = YES;
            if (progress > 0.3 || (vector.x * velocity.x + vector.y * velocity.y)> 200) {
                // Vector codirectional
                shouldComplete = YES;
            } else {
                shouldComplete = NO;
            }
            if (!self.currentTransitioningContext) {
                self.isAnimating = NO;
                return;
            }
            if (shouldComplete) {
                @weakify(self);
                [self.contextProvider finishAnimationWithCompletionBlock:^{
                    @strongify(self);
                    [self.currentTransitioningContext finishInteractiveTransition];
                    [self.currentTransitioningContext completeTransition:YES];
                    self.isAnimating = NO;
                }];
            } else {
                @weakify(self);
                [self.contextProvider cancelAnimationWithCompletionBlock:^{
                    @strongify(self);
                    [self.currentTransitioningContext cancelInteractiveTransition];
                    [self.currentTransitioningContext completeTransition:NO];
                    self.isAnimating = NO;
                }];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (self.isAnimating) {
        return NO;
    }
    
    return [self p_zoomTransitionAllowedTrigger:gestureRecognizer];
}

#pragma mark - Utils

- (BOOL)p_zoomTransitionAllowedTrigger:(UIPanGestureRecognizer *)gestureRecognizer
{
    DVEAlbumTransitionTriggerDirection triggerDirection = [self p_directionForPan:gestureRecognizer];
    DVEAlbumTransitionTriggerDirection allowDirection = DVEAlbumTransitionTriggerDirectionAny;
    
    if ([self.innerViewController respondsToSelector:@selector(allowTriggerDirectionForContext:)]) {
        DVEAlbumTransitionContext *context = [[DVEAlbumTransitionContext alloc] init];
        context.fromViewController = self.innerViewController;
        context.fromContextProvider = self.innerViewController;
        allowDirection = [((id<DVEAlbumTransitionContextProvider>)self.innerViewController) allowTriggerDirectionForContext:context];
    }
    
    if (!(allowDirection & triggerDirection)) {
        return NO;
    }
    
    self.triggerDirection = triggerDirection;
    return YES;
}

- (DVEAlbumTransitionTriggerDirection)p_directionForPan:(UIPanGestureRecognizer *)pan
{
    DVEAlbumTransitionTriggerDirection direction = DVEAlbumTransitionTriggerDirectionNone;
    CGPoint velocity = [self.panGestureRecognizer velocityInView:self.innerViewController.view];
    if (velocity.x > 0) {
        if (velocity.y / velocity.x > 1) {
            direction = DVEAlbumTransitionTriggerDirectionDown;
        } else if (velocity.y / velocity.x < -1) {
            direction = DVEAlbumTransitionTriggerDirectionUp;
        } else {
            direction = DVEAlbumTransitionTriggerDirectionRight;
        }
    } else if (velocity.x < 0) {
        if (velocity.y / velocity.x > 1) {
            direction = DVEAlbumTransitionTriggerDirectionUp;
        } else if (velocity.y / velocity.x < -1) {
            direction = DVEAlbumTransitionTriggerDirectionDown;
        } else {
            direction = DVEAlbumTransitionTriggerDirectionLeft;
        }
    } else if (velocity.y > 0){
        direction = DVEAlbumTransitionTriggerDirectionDown;
    } else {
        direction = DVEAlbumTransitionTriggerDirectionUp;
    }
    
    return direction;
}

- (CGPoint)p_vectorForDirection:(DVEAlbumTransitionTriggerDirection)direction
{
    switch (direction) {
        case DVEAlbumTransitionTriggerDirectionUp:
            return CGPointMake(0, -1);
        case DVEAlbumTransitionTriggerDirectionDown:
            return CGPointMake(0, 1);
        case DVEAlbumTransitionTriggerDirectionLeft:
            return CGPointMake(-1, 0);
        case DVEAlbumTransitionTriggerDirectionRight:
            return CGPointMake(1, 0);
            
        default:
            break;
    }
    return CGPointZero;
}

- (CGFloat)p_progressForDirection:(DVEAlbumTransitionTriggerDirection)direction
                    startLocation:(CGPoint)startLocation
                  currentLocation:(CGPoint)currentLocation
{
    CGFloat progress = 0, total = 1;
    CGSize windowSize = [UIApplication sharedApplication].keyWindow.bounds.size;
    switch (direction) {
        case DVEAlbumTransitionTriggerDirectionUp:
            progress = startLocation.y - currentLocation.y;
            total = windowSize.height;
            break;
        case DVEAlbumTransitionTriggerDirectionDown:
            progress = currentLocation.y - startLocation.y;
            total = windowSize.height;
            break;
        case DVEAlbumTransitionTriggerDirectionLeft:
            progress = startLocation.x - currentLocation.x;
            total = windowSize.width;
            break;
        case DVEAlbumTransitionTriggerDirectionRight:
            progress = currentLocation.x - startLocation.x;
            total = windowSize.width;
            break;
            
        default:
            break;
    }
    CGFloat p = progress / total;
    if (p < 0) {
        p = 0;
    } else if (p > 1) {
        p = 1;
    }
    
    return p;
}

#pragma mark - Getter

- (UIPanGestureRecognizer *)panGestureRecognizer
{
    if (!_panGestureRecognizer) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _panGestureRecognizer.maximumNumberOfTouches = 1;
        _panGestureRecognizer.delegate = self;
    }
    return _panGestureRecognizer;
}

@end
