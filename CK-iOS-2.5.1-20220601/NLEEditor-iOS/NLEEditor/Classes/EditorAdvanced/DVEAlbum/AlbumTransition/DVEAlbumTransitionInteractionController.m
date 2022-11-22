//
//  DVEAlbumTransitionInteractionController.m
//  CutSameIF
//
//  Created by bytedance on 2020/8/10.
//

#import "DVEAlbumTransitionInteractionController.h"

@interface DVEAlbumTransitionInteractionController ()

@property (nonatomic, strong) id<DVEAlbumTransitionContextProvider> contextProvider;
@property (nonatomic, weak) id<DVEAlbumTransitionDelegateProtocol> transitionDelegate;

@end

@implementation DVEAlbumTransitionInteractionController

+ (instancetype)instanceWithContextProvider:(id<DVEAlbumTransitionContextProvider>)provider transitionDelegate:(id<DVEAlbumTransitionDelegateProtocol>)transitionDelegate
{
    switch (provider.interactionType) {
        case DVEAlbumTransitionInteractionTypeNone:
        case DVEAlbumTransitionInteractionTypePercentageDriven:
            return nil;
            break;
            
        default:
            break;
    }
    DVEAlbumTransitionInteractionController *controller = [[DVEAlbumTransitionInteractionController alloc] init];
    controller.contextProvider = provider;
    controller.transitionDelegate = transitionDelegate;
    return controller;
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionDelegate.currentTransitioningContext = transitionContext;
    switch (self.contextProvider.interactionType) {
        case DVEAlbumTransitionInteractionTypeCustomPanDriven:
            [self startCustomPanDrivenTransition:transitionContext];
            break;
        default:
            break;
    }
    
    if (!self.transitionDelegate.isAnimating) {
        [self.contextProvider finishAnimationWithCompletionBlock:^{
            [transitionContext finishInteractiveTransition];
            [transitionContext completeTransition:YES];
        }];
        return;
    }
}

- (void)startCustomPanDrivenTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [self.contextProvider startCustomAnimationWithFromVC:fromViewController
                                                    toVC:toViewController
                                     fromContextProvider:self.transitionDelegate.innerViewController
                                       toContextProvider:self.transitionDelegate.outterViewController
                                           containerView:transitionContext.containerView
                                                 context:transitionContext];
}

@end

