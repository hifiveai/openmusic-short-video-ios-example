//
//  DVEAlbumTransitionInteractionController.h
//  CutSameIF
//
//  Created by bytedance on 2020/8/10.
//

#import <UIKit/UIKit.h>
#import "DVEAlbumTransitionContextProvider.h"
#import "DVEAlbumTransitionDelegateProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEAlbumTransitionInteractionController : NSObject<UIViewControllerInteractiveTransitioning>

+ (instancetype)instanceWithContextProvider:(id<DVEAlbumTransitionContextProvider>)provider transitionDelegate:(id<DVEAlbumTransitionDelegateProtocol>)transitionDelegate;

@end

NS_ASSUME_NONNULL_END
