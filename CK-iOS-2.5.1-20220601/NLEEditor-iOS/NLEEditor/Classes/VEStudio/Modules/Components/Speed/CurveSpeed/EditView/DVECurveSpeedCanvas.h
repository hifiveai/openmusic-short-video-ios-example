//
// Created by bytedance on 2021/6/21.
//

#import <UIKit/UIKit.h>
#import "DVEBaseView.h"
#import <NLEPlatform/NLECurveSpeedCalculator+iOS.h>

typedef NS_ENUM(NSUInteger, DVECurveSpeedCanvasActionType) {
    DVECurveSpeedCanvasActionAdd,
    DVECurveSpeedCanvasActionDelete,
    DVECurveSpeedCanvasActionDisable,
};

@interface DVECurveSpeedCanvas : DVEBaseView

@property (nonatomic, strong) NLETrackSlot_OC *editingSlot;
@property (nonatomic, assign) BOOL isMainTrack;
/// 初始点
@property (nonatomic, strong) NSArray<NSValue *> *originPoints;
/// 当前点
@property (nonatomic, strong) NSArray<NSValue *> *currentPoints;
///
@property (nonatomic, strong) NSArray<NSValue *> *currentTransFomedPoints;

/// 可以进行的操作的类型
@property (nonatomic, assign, readonly) DVECurveSpeedCanvasActionType actionType;
/// 横坐标进度
@property (nonatomic, assign) CGFloat progress;
/// updating speed
@property (nonatomic, assign) CGFloat updatingSpeed;
@property (nonatomic, strong) NLECurveSpeedCalculator_OC *transUtil;

/// 1. 横坐标的数值范围为0-1，表示播放器的播放进度。纵坐标的数值范围为0.1到10，表示速度的倍速。
- (void)updateCurveWithPoints:(NSArray<NSValue *> *)points;
/// 当前点{[0,1],[0.1,10]}
- (NSArray<NSValue *> *)points;
/// 添加或删除点； 根据有(无)选中点，删除(添加)点
-(void)action;
/// 重置
- (void)reset;


@end
