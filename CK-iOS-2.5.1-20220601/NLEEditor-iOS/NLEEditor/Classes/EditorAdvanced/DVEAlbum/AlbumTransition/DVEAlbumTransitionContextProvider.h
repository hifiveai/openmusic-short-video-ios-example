//
//  DVEAlbumTransitionContextProvider.h
//  CutSameIF
//
//  Created by bytedance on 2020/8/10.
//

#import <UIKit/UIKit.h>

@class DVEAlbumTransitionContext;

typedef NS_ENUM(NSUInteger, DVEAlbumTransitionInteractionType)
{
    DVEAlbumTransitionInteractionTypeNone,
    DVEAlbumTransitionInteractionTypePercentageDriven,
    DVEAlbumTransitionInteractionTypeCustomPanDriven,
};

typedef NS_ENUM(NSUInteger, DVEAlbumTransitionTriggerDirection)
{
    DVEAlbumTransitionTriggerDirectionNone = 0,
    DVEAlbumTransitionTriggerDirectionUp = 1,
    DVEAlbumTransitionTriggerDirectionDown = 1 << 1,
    DVEAlbumTransitionTriggerDirectionLeft = 1 << 2,
    DVEAlbumTransitionTriggerDirectionRight = 1 << 3,
    
    DVEAlbumTransitionTriggerDirectionAny = DVEAlbumTransitionTriggerDirectionUp | DVEAlbumTransitionTriggerDirectionDown | DVEAlbumTransitionTriggerDirectionLeft | DVEAlbumTransitionTriggerDirectionRight,
};

@protocol DVEAlbumTransitionContextProvider <NSObject>

@optional

- (BOOL)isForAppear;

- (DVEAlbumTransitionInteractionType)interactionType;

// Percentage driven animation
- (NSTimeInterval)transitionDuration;
- (void)startDefaultAnimationWithFromVC:(UIViewController *)fromVC
                                   toVC:(UIViewController *)toVC
                    fromContextProvider:(id)fromCP
                      toContextProvider:(id)toCP
                          containerView:(UIView *)containerView
                                context:(id<UIViewControllerContextTransitioning>)context
                        interactionType:(DVEAlbumTransitionInteractionType)type
                      completionHandler:(void(^)(BOOL completed))completionHander;

// Custom pan driven animation
- (DVEAlbumTransitionTriggerDirection)allowTriggerDirectionForContext:(DVEAlbumTransitionContext *)context;
- (void)startCustomAnimationWithFromVC:(__kindof UIViewController *)fromVC
                                  toVC:(__kindof UIViewController *)toVC
                   fromContextProvider:(id)fromCP
                     toContextProvider:(id)toCP
                         containerView:(UIView *)containerView
                               context:(id<UIViewControllerContextTransitioning>)context;

- (void)updateAnimationWithPosition:(CGPoint)currentPosition
                      startPosition:(CGPoint)startPosition;

- (void)finishAnimationWithCompletionBlock:(void (^)(void))completionBlock;

- (void)cancelAnimationWithCompletionBlock:(void (^)(void))completionBlock;

@end
