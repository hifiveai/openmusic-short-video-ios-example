//
//  HFCollectionViewFlowLayout.h
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/15.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HFPlaylistCollectionViewFlowLayout : UICollectionViewFlowLayout
//  一行中 cell 的个数
@property (nonatomic,assign) NSUInteger itemCountPerRow;

//    一页显示多少行
@property (nonatomic,assign) NSUInteger rowCount;
@end

NS_ASSUME_NONNULL_END
