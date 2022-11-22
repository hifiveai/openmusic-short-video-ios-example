//
//  DVETextConfigArrangeView.h
//  NLEEditor
//
//  Created by bytedance on 2021/6/22.
//
//  排列配置
#import <UIKit/UIKit.h>
#import "DVETextSliderView.h"
@class DVEEffectValue;

NS_ASSUME_NONNULL_BEGIN

typedef void(^DVETextConfigArrangeViewSelectedBlock)(DVEEffectValue *selectedValue);

@interface DVETextConfigArrangeView : UIView
/// 字间距
@property (nonatomic, strong) DVETextSliderView *charSpacingSlider;
/// 行间距
@property (nonatomic, strong) DVETextSliderView *lineGapSlider;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) DVEEffectValue *selectedValue;
@property (nonatomic, strong) NSArray<DVEEffectValue *> *dataList;

@property (nonatomic, copy) DVETextConfigArrangeViewSelectedBlock selectedBlock;
@end

NS_ASSUME_NONNULL_END
