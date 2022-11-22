//
// Created by bytedance on 2021/6/21.
//

#import "DVECurveSpeedPathUtil.h"


@implementation DVECurveSpeedPathUtil

+ (UIBezierPath *)pathFromPointA:(CGPoint)pointA toPointB:(CGPoint)pointB {
    CGPoint ctrlPointA = CGPointMake(pointA.x + (pointB.x - pointA.x) * 0.5, pointA.y);
    CGPoint ctrlPointB = CGPointMake(pointA.x + (pointB.x - pointA.x) * 0.5, pointB.y);

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pointA];
    [path addCurveToPoint:pointB controlPoint1:ctrlPointA controlPoint2:ctrlPointB];
    return path;
}

+ (NSArray<NSValue *> *)getBezierPathWithPoints:(NSArray<NSValue *> *)points {
    if (points.count < 4) return nil;
    return [self getPreBezierPathWithPoints:points];
}

+ (NSArray<NSValue *> *)getPreBezierPathWithPoints:(NSArray<NSValue *> *)points {
    CGPoint pointA = points.firstObject.CGPointValue;
    CGPoint pointB = points.lastObject.CGPointValue;
    CGFloat width = fabs(pointB.x - pointA.x);
    CGFloat height = fabs(pointB.y - pointA.y);
    NSInteger distance = sqrt(width*width + height*height);
    NSMutableArray *bezierPathPoints = [[NSMutableArray alloc] init];
    CGFloat progress = 0;
    CGFloat progressStep = 1.0f/distance;
    for (int i = 0; i < distance; i++) {
        NSArray *ps = [self recursionGetSublevelPoints:points progress:progress];
        [bezierPathPoints addObjectsFromArray:ps];
        progress += progressStep;
    }

    return bezierPathPoints;
}

+ (NSArray<NSValue *> *)recursionGetSublevelPoints:(NSArray<NSValue *> *)superPoints progress:(CGFloat)progress {
    if (superPoints.count == 1) {
        return superPoints;
    }
    NSMutableArray *tmpArr = [NSMutableArray new];
    for (int i = 0; i < superPoints.count - 1; i++) {
        CGPoint prePoint = superPoints[i].CGPointValue;
        CGPoint lastPoint = superPoints[i+1].CGPointValue;
        CGFloat diffX = lastPoint.x-prePoint.x;
        CGFloat diffY = lastPoint.y-prePoint.y;
        CGPoint currentPoint = CGPointMake(prePoint.x+diffX*progress, prePoint.y+diffY*progress);
        [tmpArr addObject:[NSValue valueWithCGPoint:currentPoint]];
    }
    return [self recursionGetSublevelPoints:tmpArr progress:progress];
}

@end