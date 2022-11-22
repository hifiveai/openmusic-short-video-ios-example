//
//  HFMusicListViewController.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/29.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "HFMusicListViewController.h"
#import "HFMusicListView.h"
#import <MJRefresh/MJRefresh.h>

@interface HFMusicListViewController ()


@end

@implementation HFMusicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubviews];
    [self makeLayoutSubviews];
    [self addActions];
}

- (void)addSubviews {
    [self.view addSubview:self.musicList];
}
- (void)makeLayoutSubviews {
    
    [self.musicList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.leading.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    self.musicList.tableView.contentInset = UIEdgeInsetsZero;
}

- (void)addActions {
    __weak typeof(self) weakSelf = self;
    
    self.musicList.tableView.mj_header = nil;
    
    self.musicList.refreshNewDataBlock = ^{
        if (weakSelf.refreshNewDataBlock) {
            weakSelf.refreshNewDataBlock();
        }

    };
    self.musicList.loadMoreDataBlock = ^{
        if (weakSelf.loadMoreDataBlock) {
            weakSelf.loadMoreDataBlock();
        }

    };

    self.musicList.useMusicBlock = ^(HFMusicListCellModel * _Nonnull model) {
        if (weakSelf.useMusicBlock) {
            weakSelf.useMusicBlock(model);
        }
    };
    self.musicList.scrollBlock = ^(UIScrollView * _Nonnull scrollView) {
        if (weakSelf.scrollBlock) {
            weakSelf.scrollBlock(scrollView);
        }
    };
    self.musicList.updatePlayer = ^(HFMusicListCellModel * _Nonnull model) {
        if (weakSelf.updatePlayer) {
            weakSelf.updatePlayer(model);
        }
    };
    self.musicList.pausePlayer = ^{
        if (weakSelf.pausePlayer) {
            weakSelf.pausePlayer();
        }
    };
}

- (void)reloadWithArray:(NSArray *)dataArray {
    [self.musicList reloadWithArray:dataArray];
}

- (void)reMakeConstraints {
    self.musicList.tableView.contentInset = UIEdgeInsetsZero;
}

- (HFMusicListView *)musicList {
    if (!_musicList) {
        _musicList = [[HFMusicListView alloc] initWithFrame:CGRectZero];
        _musicList.noDataImageName = @"noData";
        _musicList.noDataTitle = @"您还没有收藏歌曲";
    }
    return _musicList;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
