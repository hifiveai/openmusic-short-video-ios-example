//
//  HFMusicListView.h
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/14.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HFMusicListCellModel;
@class HFNoDataView;
@class HFMusicListCellModel;
@interface HFMusicListView : UIView

@property (nonatomic ,copy) void(^refreshNewDataBlock)(void);
@property (nonatomic ,copy) void(^loadMoreDataBlock)(void);
@property (nonatomic ,copy) void(^useMusicBlock)(HFMusicListCellModel *model);
@property (nonatomic ,copy) void(^scrollBlock)(UIScrollView *scrollView);

@property (nonatomic ,copy) void(^updatePlayer)(HFMusicListCellModel *model);
@property (nonatomic ,copy) void(^pausePlayer)(void);

@property (nonatomic ,strong) UITableView *tableView;


@property (nonatomic ,strong) NSString *noDataTitle;
@property (nonatomic ,strong) NSString *noDataImageName;


- (void)reloadWithArray:(NSArray *)dataArray;

- (void)reloadWith:(HFMusicListCellModel *)model;
@end

NS_ASSUME_NONNULL_END
