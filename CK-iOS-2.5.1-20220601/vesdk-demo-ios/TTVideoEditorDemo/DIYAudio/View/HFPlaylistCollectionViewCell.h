//
//  HFCollectionViewCell.h
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/14.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HFPlaylistCollectionCellModel;
NS_ASSUME_NONNULL_BEGIN

@interface HFPlaylistCollectionViewCell : UICollectionViewCell

- (void)configWith:(HFPlaylistCollectionCellModel *)model;

@end

NS_ASSUME_NONNULL_END
