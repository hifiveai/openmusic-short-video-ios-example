//
//  DVETextBaseCell.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVETextStyleView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVETextBaseCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic) UICollectionViewScrollDirection scrollDirection;
@property (nonatomic, strong) UICollectionView *collecView;
@property (nonatomic, strong) NSMutableArray *registerArr;
@property (nonatomic, strong) NSArray *dataSourceArr;

@end

NS_ASSUME_NONNULL_END
