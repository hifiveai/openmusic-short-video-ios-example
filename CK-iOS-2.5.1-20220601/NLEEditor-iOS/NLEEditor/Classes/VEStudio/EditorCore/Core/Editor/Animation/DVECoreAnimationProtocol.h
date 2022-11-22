//
//   DVECoreAnimationProtocol.h
//   NLEEditor
//
//   Created  by bytedance on 2021/4/26.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    
#import "DVECoreProtocol.h"
#import "DVECommonDefine.h"
#import <DVETrackKit/NLEVideoAnimation_OC+NLE.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DVEModuleCutSubTypeAnimationType) {
    DVEModuleCutSubTypeAnimationTypeAdmission = 1,
    DVEModuleCutSubTypeAnimationTypeDisappear = 2,
    DVEModuleCutSubTypeAnimationTypeCombination = 0,
};

@protocol DVECoreAnimationProtocol <DVECoreProtocol>

// 添加一个动画
- (void)addAnimation:(NSString *)inAnimationPath
          identifier:(NSString *)identifier
            withType:(DVEModuleCutSubTypeAnimationType)type
            duration:(CGFloat)duration;
// 删除动画
- (void)deleteVideoAnimation;

//获取当前动画时长
- (NSDictionary *)currentAnimationDuration:(NLEVideoAnimationType)type;

@end

NS_ASSUME_NONNULL_END
