//
//  DVEPreviewViewController.h
//  NLEEditor
//
//  Created by bytedance on 2021/6/10.
//

#import <UIKit/UIKit.h>
#import "DVEPreview.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEPreviewViewController : UIViewController

@property (nonatomic, copy) dispatch_block_t closeBlock;
@property (nonatomic, weak) DVEVCContext *vcContext;
@property (nonatomic, weak) DVEPreview *preview;
@property (nonatomic, assign) BOOL isPlayed;//主编辑界面是否播放着视频
@property (nonatomic, weak) UIViewController *parentVC;

- (instancetype)initWithContext:(DVEVCContext *)vcContext
                        preview:(DVEPreview *)preview
                       isPLayed:(BOOL)isPlayed
                       parentVC:(UIViewController *)parentVC
                     closeBlock:(dispatch_block_t)closeBlock;

@end

NS_ASSUME_NONNULL_END
