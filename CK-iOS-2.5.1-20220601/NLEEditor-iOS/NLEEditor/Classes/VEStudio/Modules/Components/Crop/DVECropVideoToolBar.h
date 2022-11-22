//
//  DVEVideoToolBar.h
//  NLEEditor
//
//  Created by bytedance on 2021/4/14.
//

#import <UIKit/UIKit.h>
#import "DVEVCContext.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DVECropVideoToolBarDelegate <NSObject>

- (void)videoPlay;
- (void)videoPause;
- (void)videoRestartPlay;

@end

@interface DVECropVideoToolBar : UIView

@property (nonatomic, weak) DVEVCContext *vcContext;

@property (nonatomic, weak) id<DVECropVideoToolBarDelegate> delegate;

- (void)updateVideoPlayTime:(NSTimeInterval)curTime duration:(NSTimeInterval)duration;

- (void)setPlayToEnd;

@end

NS_ASSUME_NONNULL_END
