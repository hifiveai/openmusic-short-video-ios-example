//
//  VEEventCallDefine.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VEEventCallType) {
    VEEventCallTypeNone = 0,
    VEEventCallRecordTimeType,
    VEEventCallDuteTimeType,
    VEEventCallCaptureTimeType,
    VEEventCallFlashState,
    VEEventCallLightState,
    VEEventCallRatioType,
    VEEventCallResolutionType,
    VEEventCallCamraPosion,
};

typedef NS_ENUM(NSInteger, VEEventCallRecordTimeSubType) {
    VEEventCallRecordTimeTypeFree = 0,
    VEEventCallRecordTimeType3,
    VEEventCallRecordTimeType7,
};

typedef NS_ENUM(NSInteger, VEEventCallCaptureTimeSubType) {
    VEEventCallCaptureTimeSubTypeNow = 0,
    VEEventCallCaptureTimeSubType3,
    VEEventCallCaptureTimeSubType7,
};

typedef NS_ENUM(NSInteger, VEEventCallFlashSubState) {
    VEEventCallFlashSubStateOff = 0,
    VEEventCallFlashSubStateOn,
};

typedef NS_ENUM(NSInteger, VEEventCallLightSubState) {
    VEEventCallLightSubStateOn = 1,
    VEEventCallLightSubStateOff = 0,
};

typedef NS_ENUM(NSInteger, VEEventCallRatioSubType) {
    
    VEEventCallRatioSubType9_16 = 0,
    VEEventCallRatioSubType3_4,
    VEEventCallRatioSubType1_1,
    VEEventCallRatioSubType4_3,
    VEEventCallRatioSubType16_9,
    
};

typedef NS_ENUM(NSInteger, VEEventCallResolutionSubType) {
    VEEventCallResolutionSubType720P,
    VEEventCallResolutionSubType1080P,
    VEEventCallResolutionSubType540P,
    VEEventCallResolutionSubType4K,
};

typedef NS_ENUM(NSInteger, VEEventCallCamraSubPosion) {
    VEEventCallCamraSubPosionFront = 0,
    VEEventCallCamraSubPosionBack,
};


NS_ASSUME_NONNULL_END
