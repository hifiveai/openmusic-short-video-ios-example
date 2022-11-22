//
//  HFMusicListViewController.h
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/29.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class HFMusicListCellModel;
@class HFMusicListView;
@interface HFMusicListViewController : UIViewController
@property (nonatomic ,strong) HFMusicListView *musicList;

@property (nonatomic ,copy) void(^refreshNewDataBlock)(void);
@property (nonatomic ,copy) void(^loadMoreDataBlock)(void);
@property (nonatomic ,copy) void(^useMusicBlock)(HFMusicListCellModel *model);
@property (nonatomic ,copy) void(^scrollBlock)(UIScrollView *scrollView);
@property (nonatomic ,copy) void(^updatePlayer)(HFMusicListCellModel *model);
@property (nonatomic ,copy) void(^pausePlayer)(void);

- (void)reloadWithArray:(NSArray *)dataArray;

- (void)reMakeConstraints;

@end

NS_ASSUME_NONNULL_END
