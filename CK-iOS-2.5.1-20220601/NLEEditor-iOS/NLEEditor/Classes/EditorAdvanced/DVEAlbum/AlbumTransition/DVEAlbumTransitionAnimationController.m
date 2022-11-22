//
//  DVEAlbumTransitionAnimationController.m
//  CutSameIF
//
//  Created by bytedance on 2020/8/10.
//

#import "DVEAlbumTransitionAnimationController.h"

@interface DVEAlbumTransitionAnimationController ()

@property (nonatomic, strong) id<DVEAlbumTransitionContextProvider> contextProvider;
@property (nonatomic, weak) id<DVEAlbumTransitionDelegateProtocol> transitionDelegate;

@end

@implementation DVEAlbumTransitionAnimationController

+ (instancetype)instanceWithContextProvider:(id<DVEAlbumTransitionContextProvider>)provider transitionDelegate:(id<DVEAlbumTransitionDelegateProtocol>)transitionDelegate
{
    DVEAlbumTransitionAnimationController *controller = [[DVEAlbumTransitionAnimationController alloc] init];
    controller.contextProvider = provider;
    controller.transitionDelegate = transitionDelegate;
    return controller;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if ([self.contextProvider respondsToSelector:@selector(transitionDuration:)]) {
        return [self.contextProvider transitionDuration];
    }
    
    return 0.35;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionDelegate.currentTransitioningContext = transitionContext;
    DVEAlbumTransitionInteractionType type = DVEAlbumTransitionInteractionTypeNone;//self.contextProvider.interactionType;
    self.transitionDelegate.isAnimating = YES;
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if ([self.contextProvider isForAppear]) {
        [self.contextProvider startDefaultAnimationWithFromVC:fromViewController
                                                         toVC:toViewController
                                          fromContextProvider:self.transitionDelegate.outterViewController
                                            toContextProvider:self.transitionDelegate.innerViewController
                                                containerView:transitionContext.containerView
                                                      context:transitionContext
                                              interactionType:type
                                            completionHandler:^(BOOL completed) {
            [transitionContext completeTransition:completed];
            self.transitionDelegate.isAnimating = NO;
        }];
    } else {
        [self.contextProvider startDefaultAnimationWithFromVC:fromViewController
                                                         toVC:toViewController
                                          fromContextProvider:self.transitionDelegate.innerViewController
                                            toContextProvider:self.transitionDelegate.outterViewController
                                                containerView:transitionContext.containerView
                                                      context:transitionContext
                                              interactionType:type
                                            completionHandler:^(BOOL completed) {
            [transitionContext completeTransition:completed];
            self.transitionDelegate.isAnimating = NO;
        }];
    }
}

@end
