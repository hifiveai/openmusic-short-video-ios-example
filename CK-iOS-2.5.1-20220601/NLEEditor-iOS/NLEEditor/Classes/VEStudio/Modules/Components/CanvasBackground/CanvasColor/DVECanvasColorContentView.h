//
//  DVECanvasColorContentView.h
//  NLEEditor
//
//  Created by bytedance on 2021/6/3.
//

#import <Foundation/Foundation.h>
#import "DVEEffectValue.h"
#import "DVEVCContext.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DVECanvasColorApplyDelegate <NSObject>

- (void)applyCanvasColorWithValue:(NSNumber *)value;

@end

@interface DVECanvasColorContentView : UIView

@property (nonatomic, weak) id<DVECanvasColorApplyDelegate> delegate;

@property (nonatomic, weak) DVEVCContext *vcContext;

- (NSNumber *)currentSelectedColorValue;

@end

NS_ASSUME_NONNULL_END
