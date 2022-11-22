//
//  CGRect+DVE.m
//  NLEEditor-iOS
//
//  Created by bytedance on 2021/4/1.
//

#import "CGRect+DVE.h"

/// 居中填充在rect中
///
/// - Parameter rect: 包含的rect
/// - Returns: 自己在rect中的位置
CGRect dve_scaleAspectFit(CGSize originSize, CGRect toRect)
{
    if (CGSizeEqualToSize(originSize, CGSizeZero)) {
        CGPoint pos = CGPointMake(toRect.size.width / 2.0, toRect.size.height / 2.0);
        return CGRectMake(pos.x, pos.y, 0, 0);
    }
    
    CGFloat ratio = toRect.size.width / toRect.size.height;
    CGFloat sizeRatio = originSize.width / originSize.height;
    
    CGFloat resultWidth = 0.0;
    CGFloat resultHeight = 0.0;
    CGFloat resultX = toRect.origin.x;
    CGFloat resultY = toRect.origin.y;
    
    if (sizeRatio >= ratio) {
        resultWidth = toRect.size.width;
        resultHeight = resultWidth / sizeRatio;
        resultY += (toRect.size.height - resultHeight) / 2.0;
    } else {
        resultHeight = toRect.size.height;
        resultWidth = resultHeight * sizeRatio;
        resultX += (toRect.size.width - resultWidth) / 2.0;
    }
    
    return CGRectMake(resultX, resultY, resultWidth, resultHeight);
}
