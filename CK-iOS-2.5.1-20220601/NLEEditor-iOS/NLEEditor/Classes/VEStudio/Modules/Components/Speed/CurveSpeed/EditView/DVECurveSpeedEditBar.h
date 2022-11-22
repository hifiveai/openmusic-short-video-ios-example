//
// Created by bytedance on 2021/6/21.
//

#import "DVEBaseBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVECurveSpeedEditBar : DVEBaseBar
/// 原始点
@property (nonatomic, strong) NSArray<NSValue *> *originPoints;
/// 当前点， 仅恢复现场用到
@property (nonatomic, strong, nullable) NSArray<NSValue *> *currentPoints;
@property (nonatomic, strong) id<DVEResourceCurveSpeedModelProtocol> curValue;

@property (nonatomic, strong) NLETrackSlot_OC *editingSlot;
@property (nonatomic, assign) BOOL isMainTrack;

@end

NS_ASSUME_NONNULL_END
