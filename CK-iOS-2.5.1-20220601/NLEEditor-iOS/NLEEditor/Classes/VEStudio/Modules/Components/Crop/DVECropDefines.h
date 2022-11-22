//
//  DVECropDefines.h
//  Pods
//
//  Created by bytedance on 2021/4/9.
//

#ifndef DVECropDefines_h
#define DVECropDefines_h


typedef NS_ENUM(NSInteger, DVECropVideoPlayState) {
    DVECropVideoPlayStateNone      = 0,
    DVECropVideoPlayStateAuto      = 1,
    DVECropVideoPlayStateInterrupt = 2,
};

typedef NS_ENUM(NSInteger, DVECropVideoRateMode) {
    DVECropVideoRateInitSet = 0,
    DVECropVideoRatePlaySet = 1,
};;

typedef NS_ENUM(NSInteger, DVECropResourceType) {
    DVECropResourceImage = 0,
    DVECropResourceVideo = 1,
};

typedef NS_ENUM(NSInteger, DVECropGridVertexViewType) {
    DVECropGridVertexLeftTop     = 0,
    DVECropGridVertexRightTop    = 1,
    DVECropGridVertexLeftBottom  = 2,
    DVECropGridVertexRightBottom = 3,
};


typedef NS_ENUM(NSInteger, DVEVideoCropRatio) {
    DVEVideoCropRatioFree,
    DVEVideoCropRatioR1_1,
    DVEVideoCropRatioR1125_2436,
    DVEVideoCropRatioR16_9,
    DVEVideoCropRatioR185_100,
    DVEVideoCropRatioR2_1,
    DVEVideoCropRatioR235_100,
    DVEVideoCropRatioR3_4,
    DVEVideoCropRatioR4_3,
    DVEVideoCropRatioR9_16,
};

typedef NS_ENUM(NSInteger, DVEVideoCropEditPanPosition) {
    DVEVideoCropEditPanNone,
    DVEVideoCropEditPanLeftTop,
    DVEVideoCropEditPanRightTop,
    DVEVideoCropEditPanLeftBottom,
    DVEVideoCropEditPanRightBottom,
    DVEVideoCropEditPanLeftLine,
    DVEVideoCropEditPanRightLine,
    DVEVideoCropEditPanTopLine,
    DVEVideoCropEditPanBottomLine,
};

typedef struct {
    CGPoint upperLeft;
    CGPoint upperRight;
    CGPoint lowerLeft;
    CGPoint lowerRight;
} DVEResourceCropPointInfo;

static inline DVEResourceCropPointInfo
DVEResourceCropMakeDefalutPointInfo() {
    return (DVEResourceCropPointInfo){
        .upperLeft  = CGPointMake(0, 0),
        .upperRight = CGPointMake(1, 0),
        .lowerLeft  = CGPointMake(0, 1),
        .lowerRight = CGPointMake(1, 1)
    };
}

static inline bool
DVEResourceCropPointInfoEqual(DVEResourceCropPointInfo infoA,
                              DVEResourceCropPointInfo infoB) {
    return CGPointEqualToPoint(infoA.lowerLeft,  infoB.lowerLeft)
        && CGPointEqualToPoint(infoA.lowerRight, infoB.lowerRight)
        && CGPointEqualToPoint(infoA.upperLeft,  infoB.upperLeft)
        && CGPointEqualToPoint(infoA.upperRight, infoB.upperRight);
}

FOUNDATION_EXTERN CGFloat DVE_videoCropRatioValue(DVEVideoCropRatio ratio);
FOUNDATION_EXTERN CGSize  DVE_limitMaxSize(CGSize size ,CGSize minSize);
FOUNDATION_EXTERN CGFloat DVE_rotatedScale(CGFloat angle, CGSize previewSize);
FOUNDATION_EXTERN CGPoint DVE_rotated(CGPoint point, CGPoint center, CGFloat angle);
FOUNDATION_EXTERN CGFloat DVE_valueToAngle(CGFloat value);
FOUNDATION_EXTERN CGFloat DVE_angleToValue(CGFloat angle);
FOUNDATION_EXTERN CGFloat DVE_cropRatio(DVEResourceCropPointInfo info, CGSize size);
FOUNDATION_EXPORT BOOL    DVE_isDefaultCropPoint(DVEResourceCropPointInfo info);
FOUNDATION_EXTERN CGFloat DVE_rotatedAngle(DVEResourceCropPointInfo info, CGSize resourceSize);
FOUNDATION_EXTERN DVEResourceCropPointInfo DVE_defaultCropPointInfo(void);

#endif /* DVECropDefines_h */
