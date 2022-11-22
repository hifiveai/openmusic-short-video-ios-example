//
//  HFMusicListPageHeaderView.h
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/29.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class HFMusicListViewController;
@class HFMusicListCellModel;
@interface HFMusicListPageHeaderView : UIView

@property (nonatomic ,strong) UIViewController *presntVC;

@property (nonatomic, strong) HFMusicListViewController *musicListVC;
@property (nonatomic, strong) HFMusicListViewController *collectedVC;

@property (nonatomic ,copy) void(^scrollBlock)(UIScrollView *scrollView);

@property (nonatomic ,copy) void(^updatePlayer)(HFMusicListCellModel *model);

@property (nonatomic ,copy) void(^pausePlayer)(void);

- (instancetype)initWithFrame:(CGRect)frame presentVC:(UIViewController *)presentVC;

- (void)canScroll;

@end

NS_ASSUME_NONNULL_END
