//
//  HFMusicListPageHeaderView.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/29.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "HFMusicListPageHeaderView.h"
#import <SGPagingView/SGPagingView.h>
#import "HFMusicListViewController.h"
#import "HFConfigModel.h"
#import "HFMusicListView.h"
#import "DVEUIHelper.h"


@interface HFMusicListPageHeaderView ()<SGPageTitleViewDelegate,SGPageContentScrollViewDelegate>

@property (nonatomic, strong) SGPageTitleView *pageTitleView;
@property (nonatomic, strong) SGPageContentScrollView *pageContentScrollView;



@end

@implementation HFMusicListPageHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame presentVC:(UIViewController *)presentVC {
    self = [self initWithFrame:frame];
    if (self) {
        self.presntVC = presentVC;
        [self addSubviews];
        [self makeLayoutSubviews];
        [self addActions];
    }
    return self;
}
- (void)addSubviews {
    [self addSubview:self.pageTitleView];
    [self addSubview:self.pageContentScrollView];
}

- (void)makeLayoutSubviews {
    [self.pageTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    
    [self.pageContentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.top.equalTo(self.pageTitleView.mas_bottom);
        make.height.mas_equalTo(([UIScreen mainScreen].bounds.size.height - 44 - 44 - 49 - (DVEIPHONE_X ? VETopMargnValue:0) + (DVEIPHONE_X ? 34:0)));
    }];
}

- (void)addActions {
    __weak typeof(self) weakSelf = self;
    self.pageContentScrollView.delegatePageContentScrollView = self;
    self.musicListVC.scrollBlock = ^(UIScrollView * _Nonnull scrollView) {
        if (weakSelf.scrollBlock) {
            weakSelf.scrollBlock(scrollView);
        }
    };
    self.collectedVC.scrollBlock = ^(UIScrollView * _Nonnull scrollView) {
        if (weakSelf.scrollBlock) {
            weakSelf.scrollBlock(scrollView);
        }
    };
    
    self.musicListVC.updatePlayer = ^(HFMusicListCellModel * _Nonnull model) {
        if (weakSelf.updatePlayer) {
            [weakSelf.collectedVC.musicList reloadWith:model];
            weakSelf.updatePlayer(model);
        }
    };
    self.collectedVC.updatePlayer = ^(HFMusicListCellModel * _Nonnull model) {
        if (weakSelf.updatePlayer) {
            [weakSelf.musicListVC.musicList reloadWith:model];
            weakSelf.updatePlayer(model);
        }
    };
    
    self.musicListVC.pausePlayer = ^{
        if (weakSelf.pausePlayer) {
            weakSelf.pausePlayer();
        }
    };
    self.collectedVC.pausePlayer = ^{
        if (weakSelf.pausePlayer) {
            weakSelf.pausePlayer();
        }
    };
}

- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex {
    [self.pageContentScrollView setPageContentScrollViewCurrentIndex:selectedIndex];
}
- (void)pageContentScrollView:(SGPageContentScrollView *)pageContentScrollView progress:(CGFloat)progress originalIndex:(NSInteger)originalIndex targetIndex:(NSInteger)targetIndex {
    [self.pageTitleView setPageTitleViewWithProgress:progress originalIndex:originalIndex targetIndex:targetIndex];
}

- (void)pageContentScrollViewWillBeginDragging {
    
}
- (void)pageContentScrollViewDidEndDecelerating {
    
}
- (void)pageContentScrollView:(SGPageContentScrollView *)pageContentScrollView index:(NSInteger)index {
    /// 说明：在此获取标题or当前子控制器下标值
    __weak typeof(self) weakSelf = self;
    if (index == 0) {
        if (self.scrollBlock) {
            self.scrollBlock(weakSelf.musicListVC.musicList.tableView);
        }
    }else if (index == 1) {
        if (self.scrollBlock) {
            self.scrollBlock(weakSelf.collectedVC.musicList.tableView);
        }
        
    }
}

- (void)canScroll {
    self.musicListVC.musicList.tableView.scrollEnabled = YES;
    self.collectedVC.musicList.tableView.scrollEnabled = YES;
}
- (SGPageTitleView *)pageTitleView {
    if (!_pageTitleView) {
        SGPageTitleViewConfigure *config = [SGPageTitleViewConfigure pageTitleViewConfigure];
        config.equivalence = NO;
        config.bounce = NO;
        config.bounces = NO;
        config.showIndicator = NO;
        config.showBottomSeparator = NO;
        config.titleFont = [HFConfigModel palyViewNameFont];
        config.titleSelectedFont = [HFConfigModel bodyFont];
        config.titleColor = [HFConfigModel subodyColor];
        config.titleSelectedColor = [HFConfigModel mainTitleColor];
        _pageTitleView = [SGPageTitleView pageTitleViewWithFrame:CGRectZero delegate:self titleNames:@[@"推荐音乐",@"我的收藏"] configure:config];
        _pageTitleView.backgroundColor = [UIColor blackColor];
    }
    return _pageTitleView;
}

- (SGPageContentScrollView *)pageContentScrollView {
    if (!_pageContentScrollView) {
        __weak typeof(self) weakSelf = self;
        _pageContentScrollView = [[SGPageContentScrollView alloc] initWithFrame:CGRectZero parentVC:weakSelf.presntVC childVCs:@[self.musicListVC,self.collectedVC]];
    }
    return _pageContentScrollView;
}

- (HFMusicListViewController *)musicListVC {
    if (!_musicListVC) {
        _musicListVC = [[HFMusicListViewController alloc] init];
        _musicListVC.musicList.noDataTitle = @"您还没有推荐歌曲";
    }
    return _musicListVC;
}
- (HFMusicListViewController *)collectedVC {
    if (!_collectedVC) {
        _collectedVC = [[HFMusicListViewController alloc] init];
    }
    return _collectedVC;
}


@end
