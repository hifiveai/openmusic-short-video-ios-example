//
//  DVECropDefines.m
//  NLEEditor
//
//  Created by bytedance on 2021/4/12.
//

#import "DVECropDefines.h"

CGSize DVE_limitMaxSize(CGSize size ,CGSize maxSize) {
    if (maxSize.width <= 0 || maxSize.height <= 0 || size.width <= 0 || size.height <= 0) {
        return CGSizeZero;
    }
    
    CGFloat sRatio = size.width / size.height;
    CGFloat tRatio = maxSize.width / maxSize.height;
    
    if (sRatio >= tRatio) {
        return CGSizeMake(maxSize.width, maxSize.width / sRatio);
    } else {
        return CGSizeMake(maxSize.height * sRatio, maxSize.height);
    }
}

CGFloat DVE_rotatedScale(CGFloat angle, CGSize previewSize) {
    CGSize newSize = previewSize.width > previewSize.height ? CGSizeMake(previewSize.height, previewSize.width) : previewSize;
    return fabs(cos(angle)) + fabs(sin(angle)) * newSize.height / newSize.width;
}

CGPoint DVE_rotated(CGPoint point, CGPoint center, CGFloat angle) {
    CGFloat x = (point.x - center.x) * cos(angle) - (point.y - center.y) * sin(angle) + center.x;
    CGFloat y = (point.x - center.x) * sin(angle) + (point.y - center.y) * cos(angle) + center.y;
    return CGPointMake(x, y);
}

CGFloat DVE_valueToAngle(CGFloat value) {
    return value * 180 / M_PI;
}

CGFloat DVE_angleToValue(CGFloat angle) {
    return angle * M_PI / 180.0;
}

CGFloat DVE_videoCropRatioValue(DVEVideoCropRatio ratio) {
    switch (ratio) {
        case DVEVideoCropRatioFree:
            return 0.0;
        case DVEVideoCropRatioR16_9:
            return 16.0/ 9.0;
        case DVEVideoCropRatioR1_1:
            return 1.0;
        case DVEVideoCropRatioR4_3:
            return 4.0 / 3.0;
        case DVEVideoCropRatioR3_4:
            return 3.0 / 4.0;
        case DVEVideoCropRatioR9_16:
            return 9.0 / 16.0;
        case DVEVideoCropRatioR2_1:
            return 2.0;
        case DVEVideoCropRatioR235_100:
            return 2.35;
        case DVEVideoCropRatioR185_100:
            return 1.85;
        case DVEVideoCropRatioR1125_2436:
            return 1125.0 / 2436.0;
        default:
            return 1.0;
    }
    
}

CGFloat DVE_cropRatio(DVEResourceCropPointInfo info, CGSize size) {
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return 1.0;;
    }
    
    //裁剪坐标值需要从NLE的模型中获取
    /**默认坐标如下
            (0,0)        (1,0)
     
            (0,1)         (1.1)
     */
    CGFloat h = (info.upperRight.y - info.upperLeft.y) * size.height;
    CGFloat w = (info.upperRight.x - info.upperLeft.x) * size.width;
    CGFloat width = sqrt(h * h + w * w);

    h = (info.lowerLeft.y - info.upperLeft.y) * size.height;
    w = (info.lowerLeft.x - info.upperLeft.x) * size.width;
    CGFloat height = sqrt(h * h + w * w);

    return width / height;
}

CGFloat DVE_rotatedAngle(DVEResourceCropPointInfo info, CGSize resourceSize) {
    CGFloat h = (info.upperRight.y - info.upperLeft.y) * resourceSize.height;
    CGFloat w = (info.upperRight.x - info.upperLeft.x) * resourceSize.width;
    CGFloat angle = atanf(fabs(h) / fabs(w));
    return (h < 0 ? angle : -angle);
}

BOOL DVE_isDefaultCropPoint(DVEResourceCropPointInfo info) {
    return CGPointEqualToPoint(info.upperLeft, CGPointMake(0, 0)) &&
           CGPointEqualToPoint(info.upperRight, CGPointMake(1, 0)) &&
           CGPointEqualToPoint(info.lowerLeft, CGPointMake(0, 1)) &&
           CGPointEqualToPoint(info.lowerRight, CGPointMake(1, 1));
}

DVEResourceCropPointInfo DVE_defaultCropPointInfo(void) {
    DVEResourceCropPointInfo defaultPointInfo;
    defaultPointInfo.upperLeft = CGPointMake(0, 0);
    defaultPointInfo.upperRight = CGPointMake(1, 0);
    defaultPointInfo.lowerLeft = CGPointMake(0, 1);
    defaultPointInfo.lowerRight = CGPointMake(1, 1);
    return defaultPointInfo;
}
