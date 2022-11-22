//
//   DVECoreTransitionProtocol.h
//   NLEEditor
//
//   Created  by bytedance on 2021/4/26.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    
#import "DVECoreProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DVECoreTransitionProtocol <DVECoreProtocol>

// 添加一个转场
- (NSString *)addTransitionWithEffectResource:(NSString *)path
                                   resourceId:(NSString *)resourceId
                                     duration:(CGFloat)duraion
                                    isOverlap:(BOOL)overlap
                                      forSlot:(NLETrackSlot_OC *)slot;
// 删除一个转场
- (void)deleteCurrentTransitionForSlot:(NLETrackSlot_OC *)slot;

- (double)getMaxTranstisionTimeBySlot:(NLETrackSlot_OC *)slot;

@end

NS_ASSUME_NONNULL_END
