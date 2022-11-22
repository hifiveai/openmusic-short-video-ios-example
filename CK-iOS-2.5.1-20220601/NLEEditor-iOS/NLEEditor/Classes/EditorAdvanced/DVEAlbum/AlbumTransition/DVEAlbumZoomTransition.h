//
//  ACCAlbumZoomTransition.h
//  CameraClient-Pods-ACCAlbumme
//
//  Created by bytedance on 2020/8/10.
//

#import <Foundation/Foundation.h>
#import "DVEAlbumTransitionContextProvider.h"
#import "DVEAlbumTransitionDelegateProtocol.h"
#import "DVEAlbumZoomTransitionDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DVEAlbumZoomTransitionOuterContextProvider

- (NSInteger)zoomTransitionItemOffset;
- (UIView *_Nullable)zoomTransitionStartViewForOffset:(NSInteger)offset;

@optional
- (BOOL)zoomTransitionWantsTabBarAnimation; // frame
- (BOOL)zoomTransitionWantsTabBarAlphaAnimation; // alpha animation
- (BOOL)zoomTransitionWantsFromVCAnimation;
- (void)zoomTransitionMigrationDidEndForView:(UIView *)migratedView;
- (UIView *)targetViewControllerSnapshotView;
- (CGRect)targetViewFrame;
- (NSTimeInterval)tabbarAnimationDuration;

@end

@protocol DVEAlbumZoomTransitionInnerContextProvider

@optional
- (UIView *)zoomTransitionEndView;
- (DVEAlbumTransitionTriggerDirection)zoomTransitionAllowedTriggerDirection;
- (BOOL)zoomTransitionWantsBlackMaskView;
- (BOOL)zoomTransitionWantsViewMigration;
- (BOOL)zoomTransitionWantsTabBarAlphaAnimation; // alpha
- (void)zoomTransitionWillStartForView:(UIView *)migratedView;
- (NSInteger)zoomTransitionItemOffset;
- (BOOL)zoomTransitionWantsRemoveSpringAnimation;
- (NSTimeInterval)animationDuration;
- (NSTimeInterval)tabbarAnimationDuration;
- (BOOL)zoomTransitionForbidShowToVCSnapshot;

@end

@interface DVEAlbumTransitionContext : NSObject

@property (nonatomic, assign) DVEAlbumTransitionTriggerDirection triggerDirection;
@property (nonatomic, strong) UIViewController *fromViewController;
@property (nonatomic, strong) UIViewController *toViewController;
@property (nonatomic, strong) id fromContextProvider;
@property (nonatomic, strong) id toContextProvider;
@property (nonatomic, strong) id<DVEAlbumTransitionContextProvider> contextProvider;

@end

@interface DVEMagnifyTransition : NSObject<DVEAlbumTransitionContextProvider>

@end

@interface DVEShrinkTransition : NSObject<DVEAlbumTransitionContextProvider>

@end

@interface DVEInteractiveShrinkTransition : NSObject<DVEAlbumTransitionContextProvider>

- (instancetype)initWithTransitionDelegate:(id<DVEAlbumTransitionDelegateProtocol>)transitionDelegate;

@end

NS_ASSUME_NONNULL_END
