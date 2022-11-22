//
//  VECollectionViewBaseFlowLayout.m
//  VECollectionView
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2019 VE. All rights reserved.
//

#import "VECollectionViewBaseFlowLayout.h"
#import "VECollectionViewLayoutAttributes.h"

typedef NS_ENUM(NSUInteger, LewScrollDirction) {
    LewScrollDirctionStay,
    LewScrollDirctionToTop,
    LewScrollDirctionToEnd,
};

@interface VECollectionViewBaseFlowLayout ()

@property (nonatomic) LewScrollDirction continuousScrollDirection;
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation VECollectionViewBaseFlowLayout {
    BOOL _isNeedReCalculateAllLayout;
}

- (instancetype)init {
    if (self == [super init]) {
        self.isFloor = YES;
        self.canDrag = NO;
        self.header_suspension = NO;
        self.layoutType = FillLayout;
        self.columnCount = 1;
        self.fixTop = 0;
        _isNeedReCalculateAllLayout = YES;
        _headerAttributesArray = @[].mutableCopy;
    }
    return self;
}

#pragma mark - 当尺寸有所变化时，重新刷新
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return self.header_suspension;
}

//+ (Class)layoutAttributesClass {
//    return [VECollectionViewLayoutAttributes class];
//}

- (void)invalidateLayoutWithContext:(UICollectionViewLayoutInvalidationContext *)context {
    //外部调用relaodData或变更任意数据时则认为需要进行全量布局的刷新
    //好处是在外部变更数据时内部布局会及时刷新
    //劣势是在你在上拉加载某一页时,布局会全部整体重新计算一遍,并非只计算新增的布局
    _isNeedReCalculateAllLayout = context.invalidateEverything || context.invalidateDataSourceCounts;
    [super invalidateLayoutWithContext:context];
}

// 注册所有的背景view(传入类名)
- (void)registerDecorationView:(NSArray<NSString*>*)classNames {
    for (NSString* className in classNames) {
        if (className.length > 0) {
            [self registerClass:NSClassFromString(className) forDecorationViewOfKind:className];
        }
    }
}

- (void)dealloc {
}

#pragma mark - 所有cell和view的布局属性
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    if (!self.attributesArray) {
        return [super layoutAttributesForElementsInRect:rect];
    } else {
        if (self.header_suspension) {
            //只在headerAttributesArray里面查找需要悬浮的属性
            for (UICollectionViewLayoutAttributes *attriture in self.headerAttributesArray) {
                if (![attriture.representedElementKind isEqualToString:UICollectionElementKindSectionHeader])
                    continue;
                NSInteger section = attriture.indexPath.section;
                CGRect frame = attriture.frame;
                BOOL isNeedChangeFrame = NO;
                if (section == 0) {
                    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                        CGFloat offsetY = self.collectionView.contentOffset.y + self.fixTop;
                        if (offsetY > 0 && offsetY < [self.collectionHeightsArray[0] floatValue]) {
                            frame.origin.y = offsetY;
                            attriture.zIndex = 1000+section;
                            attriture.frame = frame;
                            isNeedChangeFrame = YES;
                        }
                    } else {
                        CGFloat offsetX = self.collectionView.contentOffset.y + self.fixTop;
                        if (offsetX > 0 && offsetX < [self.collectionHeightsArray[0] floatValue]) {
                            frame.origin.x = offsetX;
                            attriture.zIndex = 1000+section;
                            attriture.frame = frame;
                            isNeedChangeFrame = YES;
                        }
                    }
                } else {
                    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                        CGFloat offsetY = self.collectionView.contentOffset.y + self.fixTop;
                        if (offsetY > [self.collectionHeightsArray[section-1] floatValue] &&
                            offsetY < [self.collectionHeightsArray[section] floatValue]) {
                            frame.origin.y = offsetY;
                            attriture.zIndex = 1000+section;
                            attriture.frame = frame;
                            isNeedChangeFrame = YES;
                        }
                    } else {
                        CGFloat offsetX = self.collectionView.contentOffset.y + self.fixTop;
                        if (offsetX > [self.collectionHeightsArray[section-1] floatValue] &&
                            offsetX < [self.collectionHeightsArray[section] floatValue]) {
                            frame.origin.x = offsetX;
                            attriture.zIndex = 1000+section;
                            attriture.frame = frame;
                            isNeedChangeFrame = YES;
                        }
                    }
                }
                
                if (!isNeedChangeFrame) {
                    /*
                      这里需要注意，在悬浮的情况下改变了headerAtt的frame
                      在滑出header又滑回来时,headerAtt已经被修改过，需要改回原始值
                      否则header无法正确归位
                     */
                    if ([attriture isKindOfClass:[VECollectionViewLayoutAttributes class]]) {
                        attriture.frame = ((VECollectionViewLayoutAttributes*)attriture).orginalFrame;
                    }
                }
            }
        }
        return self.attributesArray;
    }
}



- (void)invalidateDisplayLink{
    _continuousScrollDirection = LewScrollDirctionStay;
    [_displayLink invalidate];
    _displayLink = nil;
}


- (void)forceSetIsNeedReCalculateAllLayout:(BOOL)isNeedReCalculateAllLayout
{
    _isNeedReCalculateAllLayout = isNeedReCalculateAllLayout;
}
@end
