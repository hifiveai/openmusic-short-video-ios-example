//
//  DVECanvasBlurContentView.h
//  NLEEditor
//
//  Created by bytedance on 2021/6/3.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "DVEVCContext.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DVECanvasBlurApplyDelegate <NSObject>

- (void)applyCanvasBlurWithBlurRadius:(float)blurRadius;
- (void)cancelApplyCanvasBlurIfNeed;

@end

@interface DVECanvasBlurContentView : UIView

@property (nonatomic, weak) DVEVCContext *vcContext;

@property (nonatomic, weak) id<DVECanvasBlurApplyDelegate> delegate;

- (float)currentSelectedBlurRadius;

@end

NS_ASSUME_NONNULL_END
