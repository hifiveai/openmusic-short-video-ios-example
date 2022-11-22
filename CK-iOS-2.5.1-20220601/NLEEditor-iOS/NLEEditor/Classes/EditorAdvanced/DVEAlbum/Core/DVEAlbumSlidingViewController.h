//
//  DVEAlbumSlidingViewController.h
//  CameraClient
//
//  Created by bytedance on 2018/6/22.
//

#import <UIKit/UIKit.h>
#import "DVEAlbumSlidingTabbarProtocol.h"
#import "DVEAlbumSlidingScrollView.h"

typedef NS_ENUM(NSInteger, DVEAlbumSlidingVCTransitionType) {
    SCIFSlidingVCTransitionTypeTapTab = 0,
    SCIFSlidingVCTransitionTypeScroll = 1,
};

@class DVEAlbumSlidingViewController;

@protocol DVEAlbumSlidingViewControllerDelegate <NSObject>

- (NSInteger)numberOfControllers:(DVEAlbumSlidingViewController *)slidingController;
- (UIViewController *)slidingViewController:(DVEAlbumSlidingViewController *)slidingViewController viewControllerAtIndex:(NSInteger)index;

@optional
- (void)slidingViewController:(DVEAlbumSlidingViewController *)slidingViewController didSelectIndex:(NSInteger)index;

- (void)slidingViewController:(DVEAlbumSlidingViewController *)slidingViewController didSelectIndex:(NSInteger)index transitionType:(DVEAlbumSlidingVCTransitionType)transitionType;

- (void)slidingViewController:(DVEAlbumSlidingViewController *)slidingViewController willTransitionToViewController:(UIViewController *)pendingViewController;

- (void)slidingViewController:(DVEAlbumSlidingViewController *)slidingViewController willTransitionToViewController:(UIViewController *)pendingViewController transitionType:(DVEAlbumSlidingVCTransitionType)transitionType;

- (void)slidingViewController:(DVEAlbumSlidingViewController *)slidingViewController didFinishTransitionToIndex:(NSUInteger)index; // same index after transition will call this as well

- (void)slidingViewController:(DVEAlbumSlidingViewController *)slidingViewController didFinishTransitionFromPreviousViewController:(UIViewController *)previousViewController currentViewController:(UIViewController *)currentViewController;

- (void)slidingViewController:(DVEAlbumSlidingViewController *)slidingViewController didFinishTransitionFromPreviousIndex:(NSInteger)previousIndex currentIndex:(NSInteger)currentIndex transitionType:(DVEAlbumSlidingVCTransitionType)transitionType;

- (void)slidingViewControllerDidScroll:(UIScrollView *)scrollView;

@end

@interface DVEAlbumSlidingViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, strong) UIView<DVEAlbumSlidingTabbarProtocol> *tabbarView;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) BOOL slideEnabled;
@property (nonatomic, assign) BOOL needAnimationWithTapTab;
@property (nonatomic, weak) id<DVEAlbumSlidingViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL shouldAdjustScrollInsets;
@property (nonatomic, strong) DVEAlbumSlidingScrollView *contentScrollView;
@property (nonatomic, assign) BOOL enableSwipeCardEffect; //卡片横向切换效果

- (instancetype)initWithSelectedIndex:(NSInteger)index;
- (void)reloadViewControllers;
- (UIViewController *)controllerAtIndex:(NSInteger)index;
- (Class)scrollViewClass;
- (NSInteger)currentScrollPage;
- (NSInteger)numberOfControllers;
- (NSArray<UIView *> *)visibleViews;
- (NSArray *)currentViewControllers;
//-----由SMCheckProject工具删除-----
//- (void)insertAtFrontWithViewController:(UIViewController *)viewController;
//-----由SMCheckProject工具删除-----
//- (void)replaceViewController:(UIViewController *)newVC atIndex:(NSInteger)index;
//-----由SMCheckProject工具删除-----
//- (void)appendViewController:(UIViewController *)viewController;

@end



