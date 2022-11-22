//
//  DVEVideoCoverEditViewController.h
//  Pods
//
//  Created by bytedance on 2021/6/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DVEVCContext;
@class DVEPreview;
@class DVEViewController;
@interface DVEVideoCoverEditViewController : UIViewController

@property (nonatomic, strong) dispatch_block_t dismissBlock;

@property (nonatomic, weak) DVEViewController *parentVC;

- (instancetype)initWithContext:(DVEVCContext *)context;


@end

NS_ASSUME_NONNULL_END
