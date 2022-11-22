//
//   DVECoreKeyFrameProtocol.h
//   NLEEditor
//
//   Created  by ByteDance on 2021/8/18.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "DVECoreProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DVECoreKeyFrameProtocol <DVECoreProtocol>

/// 是否存在关键帧
/// @param slot 指定Slot
-(BOOL)hasKeyframe:(NLETrackSlot_OC*)slot;

/// 当前关键帧覆盖范围
-(CMTime)currentKeyframeTimeRange;

///刷新当前slot的关键帧数据
- (void)refreshAllKeyFrameIfNeedWithSlot:(NLETrackSlot_OC *)slot;

@end

NS_ASSUME_NONNULL_END
