//
// Created by bytedance on 2021/6/21.
//

#import <Foundation/Foundation.h>

@interface DVECurveSpeedPathUtil : NSObject
/// 绘制从A->B的曲线
+ (UIBezierPath *)pathFromPointA:(CGPoint)pointA toPointB:(CGPoint)pointB;
/**
根据n阶贝塞尔曲线
起始点 + 终点 + 控制点
获取贝塞尔曲线上面的所有点
*/
+ (NSArray<NSValue *> *)getBezierPathWithPoints:(NSArray<NSValue *> *)points;

@end