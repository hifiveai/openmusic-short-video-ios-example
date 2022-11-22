//
//  DVECanvasStyleContentView.h
//  NLEEditor
//
//  Created by bytedance on 2021/6/3.
//

#import <UIKit/UIKit.h>
#import "DVEResourceLoaderProtocol.h"
#import "DVEVCContext.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DVECanvasStyleApplyDelegate <NSObject>

- (void)applyCanvasStyleWithValue:(DVEEffectValue *)value;
- (void)cancelApplyCanvasStyleIfNeed;

@end

@interface DVECanvasStyleContentView : UIView

@property (nonatomic, weak) DVEVCContext *vcContext;

@property (nonatomic, weak) id<DVECanvasStyleApplyDelegate> delegate;

- (DVEEffectValue *)currentSelectedValue;

@end

NS_ASSUME_NONNULL_END
