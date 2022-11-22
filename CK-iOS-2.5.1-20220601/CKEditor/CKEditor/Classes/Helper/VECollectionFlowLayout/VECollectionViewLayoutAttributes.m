//
//  VECollectionViewLayoutAttributes.m
//  VECollectionView
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2018年 VE. All rights reserved.
//

#import "VECollectionViewLayoutAttributes.h"


@implementation VECollectionViewLayoutAttributes
@synthesize orginalFrame = _orginalFrame;

+ (instancetype)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind withIndexPath:(NSIndexPath *)indexPath orginalFrmae:(CGRect)orginalFrame{
    VECollectionViewLayoutAttributes *layoutAttributes = [super layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath];
    [layoutAttributes setValue:[NSValue valueWithCGRect:orginalFrame] forKey:@"orginalFrame"];
    layoutAttributes.frame = orginalFrame;
    return layoutAttributes;
}

-(CGRect)orginalFrame {
    if ([self.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return _orginalFrame;
    } else {
        return self.frame;
    }
}

@end
