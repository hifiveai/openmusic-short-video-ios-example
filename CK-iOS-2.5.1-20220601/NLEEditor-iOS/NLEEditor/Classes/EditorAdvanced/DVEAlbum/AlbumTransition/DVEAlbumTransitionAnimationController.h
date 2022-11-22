//
//  DVEAlbumTransitionAnimationController.h
//  CutSameIF
//
//  Created by bytedance on 2020/8/10.
//

#import <Foundation/Foundation.h>
#import "DVEAlbumTransitionContextProvider.h"
#import "DVEAlbumTransitionDelegateProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEAlbumTransitionAnimationController : NSObject<UIViewControllerAnimatedTransitioning>

+ (instancetype)instanceWithContextProvider:(id<DVEAlbumTransitionContextProvider>)provider transitionDelegate:(id<DVEAlbumTransitionDelegateProtocol>)transitionDelegate;

@end

NS_ASSUME_NONNULL_END
