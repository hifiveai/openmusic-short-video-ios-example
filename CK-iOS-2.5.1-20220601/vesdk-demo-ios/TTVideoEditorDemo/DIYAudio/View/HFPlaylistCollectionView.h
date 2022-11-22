//
//  HFCollectionView.h
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/14.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HFPlaylistCollectionView : UIView 

@property (nonatomic ,strong) UICollectionView *collectionView;

@property (nonatomic ,copy) void(^collectionDidSelectBLock)(NSIndexPath* indexPath);

- (void)reloadCollectWith:(NSArray *)dataArray;

@end

NS_ASSUME_NONNULL_END
