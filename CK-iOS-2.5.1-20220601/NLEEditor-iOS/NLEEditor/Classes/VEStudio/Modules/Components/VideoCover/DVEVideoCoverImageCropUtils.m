//
//  DVEVideoCoverImageCropUtils.m
//  NLEEditor
//
//  Created by pengzhenhuan on 2021/11/1.
//

#import "DVEVideoCoverImageCropUtils.h"


CGSize DVE_limitMaxSize(CGSize size, CGSize maxSize) {
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

CGSize DVE_aspectFitMaxSize(CGSize size, CGSize maxSize) {
    if (maxSize.width <= 0 || maxSize.height <= 0 || size.width <= 0 || size.height <= 0) {
        return CGSizeZero;
    }
    CGFloat wRatio = size.width / maxSize.width;
    CGFloat hRatio = size.height / maxSize.height;
    CGSize resultSize = CGSizeZero;
    if (wRatio >= hRatio) {
        resultSize = CGSizeMake(maxSize.width, maxSize.width * size.height / size.width);
    } else {
        resultSize = CGSizeMake(maxSize.height * size.width / size.height, maxSize.height);
    }
    return resultSize;
}

CGSize DVE_aspectFitMinSize(CGSize size, CGSize minSize) {
    if (minSize.width <= 0 || minSize.height <= 0 || size.width <= 0 || size.height <= 0) {
        return CGSizeZero;
    }
    
    CGFloat wRatio = size.width / minSize.width;
    CGFloat hRatio = size.height / minSize.height;
    CGSize resultSize = CGSizeZero;
    if (wRatio <= hRatio) {
        CGFloat compressWidth = minSize.width;
        CGFloat compressHeight = compressWidth * size.height / size.width;
        resultSize = CGSizeMake(compressWidth, compressHeight);
    } else {
        CGFloat compressHeight = minSize.height;
        CGFloat compressWidth = compressHeight * size.width / size.height;
        resultSize = CGSizeMake(compressWidth, compressHeight);
    }
    return resultSize;
}

CGRect DVE_fixCropRectForImage(CGRect rect, UIImage *image) {
    CGAffineTransform rectTransform;
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(90 / 180.0f * M_PI), 0, -image.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-90 / 180.0f * M_PI), -image.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-180 / 180.0f * M_PI), -image.size.width, -image.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };

    rectTransform = CGAffineTransformScale(rectTransform, image.scale, image.scale);
    CGRect transformedCropSquare = CGRectApplyAffineTransform(rect, rectTransform);
    return transformedCropSquare;
}


CGFloat floatInRange(CGFloat value, CGFloat minValue, CGFloat maxValue) {
    value = MIN(maxValue, value);
    value = MAX(minValue, value);
    return value;
}

CGFloat guardNormalized(CGFloat value) {
    return floatInRange(value, 0.0, 1.0);
}

CGPoint guardInZeroToOne(CGPoint point) {
    CGFloat x = guardNormalized(point.x);
    CGFloat y = guardNormalized(point.y);
    return CGPointMake(x, y);
}

NSArray<NSValue *> * DVE_defaultCropForImage(CGSize imageSize, CGSize canvasSize) {
    CGSize previewSize = imageSize;
    CGSize cropSize = DVE_limitMaxSize(canvasSize, previewSize);
    if (previewSize.width > 0 && previewSize.height > 0 && cropSize.width > 0 && cropSize.height > 0) {
        NSMutableArray *result = [NSMutableArray array];
        CGFloat halfCropWidth = cropSize.width * 0.5;
        CGFloat halfPreViewWidth = previewSize.width * 0.5;
        CGFloat halfCropHeight = cropSize.height * 0.5;
        CGFloat halfPreViewHeight = previewSize.height * 0.5;
        
        CGFloat upperLeftX = (halfPreViewWidth - halfCropWidth);
        CGFloat upperLeftY = (halfPreViewHeight - halfCropHeight);
        
        CGFloat uppeRightX = (upperLeftX + cropSize.width);
        CGFloat upperRightY = upperLeftY;
        
        CGFloat lowerLeftX = upperLeftX;
        CGFloat lowerLeftY = (upperLeftY + cropSize.height);
        
        CGFloat lowerRightX = uppeRightX;
        CGFloat lowerRightY = lowerLeftY;
        
        CGPoint upperLeftPoint  = CGPointMake(upperLeftX / previewSize.width, upperLeftY / previewSize.height);
        CGPoint upperRightPoint = CGPointMake(uppeRightX / previewSize.width, upperRightY / previewSize.height);
        CGPoint lowerLeftPoint  = CGPointMake(lowerLeftX / previewSize.width, lowerLeftY / previewSize.height);
        CGPoint lowerRightPoint = CGPointMake(lowerRightX / previewSize.width, lowerRightY / previewSize.height);
        
        [result addObject:@(guardInZeroToOne(upperLeftPoint))];
        [result addObject:@(guardInZeroToOne(upperRightPoint))];
        [result addObject:@(guardInZeroToOne(lowerLeftPoint))];
        [result addObject:@(guardInZeroToOne(lowerRightPoint))];
        return [result copy];
    }
    
    return @[@(CGPointMake(0, 0)),
             @(CGPointMake(1, 0)),
             @(CGPointMake(0, 1)),
             @(CGPointMake(1, 1))];
}
