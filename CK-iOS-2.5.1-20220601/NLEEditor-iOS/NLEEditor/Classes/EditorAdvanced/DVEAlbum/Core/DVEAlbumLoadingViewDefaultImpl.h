//
//  DVEAlbumLoadingViewDefaultImpl.h
//  VideoTemplate
//
//  Created by bytedance on 2020/12/8.
//

#import <Foundation/Foundation.h>
#import "DVEAlbumLoadingViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEAlbumLoadingViewDefaultImpl : NSObject <DVEAlbumLoadingProtocol>

@property (nonatomic, assign) BOOL cancelable;
@property (nonatomic, copy) dispatch_block_t cancelBlock;

- (void)startAnimating;
- (void)stopAnimating;

- (void)dismiss;
- (void)dismissWithAnimated:(BOOL)animated;

- (void)allowUserInteraction:(BOOL)allow;

@end

NS_ASSUME_NONNULL_END
