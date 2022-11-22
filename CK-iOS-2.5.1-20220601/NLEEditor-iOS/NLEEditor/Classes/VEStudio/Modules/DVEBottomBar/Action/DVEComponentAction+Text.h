//
//   DVEComponentAction+Text.h
//   NLEEditor
//
//   Created  by bytedance on 2021/5/27.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEComponentAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEComponentAction (Text)

/// 检查当前位置是否可拆分
- (BOOL)canSplitWithSlot:(NLETrackSlot_OC *)slot;

- (NSString *)textSegmentId;

- (NSString *)splitSlot;

- (NSString *)copySlot;

- (BOOL)deleteSlot;

@end

NS_ASSUME_NONNULL_END
