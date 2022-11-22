//
//  VECapBaseView.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VECPViewType) {
    VECPViewTypeDefault = 0,
    VECPViewTypePicture,
    VECPViewTypeVideo,
    VECPViewTypeDuet,
};

@interface VECapBaseView : UIView<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic) UICollectionViewScrollDirection scrollDirection;
@property (nonatomic, strong) UICollectionView *collecView;
@property (nonatomic, strong) NSMutableArray *registerArr;
@property (nonatomic, strong) NSArray *dataSourceArr;

@property (nonatomic, assign) VECPViewType viewType;

@end

NS_ASSUME_NONNULL_END
