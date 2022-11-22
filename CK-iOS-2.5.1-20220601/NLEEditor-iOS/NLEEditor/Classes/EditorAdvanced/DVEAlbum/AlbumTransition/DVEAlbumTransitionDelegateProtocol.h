//
//  DVEAlbumTransitionDelegateProtocol.h
//  CutSameIF
//
//  Created by bytedance on 2020/8/10.
//

#import <UIKit/UIKit.h>
#import "DVEAlbumTransitionContextProvider.h"

@protocol DVEAlbumTransitionDelegateProtocol <NSObject>

@property (nonatomic, weak) UIViewController *outterViewController;
@property (nonatomic, weak) UIViewController *innerViewController;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, weak) id<UIViewControllerContextTransitioning> currentTransitioningContext;
@property (nonatomic, strong) id<DVEAlbumTransitionContextProvider> contextProvider;


@end
