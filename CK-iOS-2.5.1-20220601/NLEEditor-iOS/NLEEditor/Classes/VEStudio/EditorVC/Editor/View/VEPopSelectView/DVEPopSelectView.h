//
//  DVEPopSelectView.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVEPopSelectView : UIView<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UICollectionView *collecView;
@property (nonatomic, strong) NSArray <NSString *>*dataSourceArr;

+ (DVEPopSelectView *)showSelectInView:(UIView *)view
                               angleX:(CGFloat)angleX
                       withDataSource:(NSArray *)dataSourceArr
                   defaultSelectIndex:(NSInteger)index
                         CompletBlock:(void(^)(NSInteger selectIndex))completBlock;

@end

NS_ASSUME_NONNULL_END
