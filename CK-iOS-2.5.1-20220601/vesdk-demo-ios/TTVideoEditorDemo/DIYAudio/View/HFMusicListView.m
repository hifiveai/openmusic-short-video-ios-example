//
//  HFMusicListView.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/14.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "HFMusicListView.h"
#import "HFMusicListTableViewCell.h"
#import "HFMusicListCellModel.h"
#import "HFPlayerView.h"
#import <MJRefresh/MJRefresh.h>
#import "HFOpenModel.h"
#import "HFNoDataView.h"
#import "HFMusicListNoDataCell.h"
#import "DVECustomerHUD.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "DVEAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "HFPlayerConfigManager.h"

@interface HFMusicListView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) HFPlayerView *playerView;

@property (nonatomic, strong) NSString *currentMusicId;

@property (nonatomic, assign) BOOL noData;

@property (nonatomic, assign) BOOL canScroll;
@end

@implementation HFMusicListView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
        [self makeLayoutSubviews];
        [self addActions];
        [self configTableView];
    }
    return self;
}

- (void)addSubviews {
    [self addSubview:self.tableView];
    [self addSubview:self.playerView];
}
- (void)makeLayoutSubviews {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.mas_equalTo(0);
    }];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(0);
        make.height.mas_equalTo(96);
    }];
    
}
- (void)addActions {
    __weak typeof(self) weakSelf = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [RACObserve([DVEAudioPlayer shareManager].player, rate) subscribeNext:^(id _Nullable x) {
        HFOpenMusicModel * currentModel;
        int index = 0;
        for (HFOpenMusicModel * model in self.dataArray) {
            if ([model.musicId isEqualToString:self.currentMusicId]) {
                currentModel = model;
                break;
            }
            index++;
        }
        float rateValue = [x floatValue];
        if (rateValue == 0.0) {
            [HFPlayerConfigManager shared].currentPlayModel.isPlaying = NO;
            currentModel.isPlaying = NO;
            if (weakSelf.pausePlayer) {
                weakSelf.pausePlayer();
            }else {
                [weakSelf.playerView pause];
            }
        }else {
            [HFPlayerConfigManager shared].currentPlayModel.isPlaying = YES;
            currentModel.isPlaying = YES;
            [weakSelf.playerView play];
        }
        if (currentModel) {
            [weakSelf updateModelDownloadStatus:currentModel index:index];
            [weakSelf.tableView reloadData];
            
            [weakSelf.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        
        
    }];
}

- (void)configTableView {
    self.tableView.backgroundColor = [UIColor blackColor];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    if (self.noData) {
        HFMusicListNoDataCell * cell = [tableView dequeueReusableCellWithIdentifier:@"HFMusicListNoDataCell"];
        [cell configWithTitle:self.noDataTitle imageName:self.noDataImageName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    HFMusicListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"HFMusicListTableViewCell" forIndexPath:indexPath];
    HFOpenMusicModel * model = self.dataArray[indexPath.row];
    HFMusicListCellModel *listModel = [HFMusicListCellModel configWith:model];
    [cell configWith:listModel];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.useActionBlock = ^(HFMusicListCellModel * _Nonnull model) {
        if (weakSelf.useMusicBlock) {
            weakSelf.useMusicBlock(model);
        }
    };
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.noData) {
        return 1;
    }
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.noData) {
        return 508;
    }
    return 76;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    if (self.noData) {
        return;
    }
    HFOpenMusicModel * model = self.dataArray[indexPath.row];
    
    HFMusicListCellModel *listModel = [HFMusicListCellModel configWith:model];
    
    self.currentMusicId = listModel.musicId;
    if (!listModel.pathUrl) {
        model.isDownloading = YES;
        [self updateModelDownloadStatus:model index:indexPath.row];
        [self.tableView reloadData];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [listModel downloadMusic:^{
            [weakSelf.tableView reloadData];
            if ([listModel.musicId isEqualToString: weakSelf.currentMusicId]) {
                if (weakSelf.updatePlayer) {
                    weakSelf.updatePlayer(listModel);
                }else {
                    [weakSelf.playerView configWithModel:listModel];
                }
                [weakSelf.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            
        } failed:^(NSError * _Nonnull error) {
            model.isDownloading = NO;
            [weakSelf updateModelDownloadStatus:model index:indexPath.row];
            [weakSelf.tableView reloadData];
            [DVECustomerHUD showMessage:error.localizedDescription];
        }];
    }
    if (self.updatePlayer) {
        self.updatePlayer(listModel);
        
    }else {
        self.playerView.hidden = NO;
        [self.playerView configWithModel:listModel];
    }
    tableView.contentInset = UIEdgeInsetsMake(0, 0, self.playerView.height, 0);
}

- (void)updateModelDownloadStatus:(HFOpenMusicModel *)model index:(NSInteger)index{
    NSMutableArray *datas = [[NSMutableArray alloc] initWithArray:self.dataArray];
    [datas replaceObjectAtIndex:index withObject:model];
    self.dataArray = datas;
}
- (void)reloadWith:(HFMusicListCellModel *)model {
    HFOpenMusicModel * currentModel;
    self.currentMusicId = model.musicId;
    int index = 0;
    for (HFOpenMusicModel * tmodel in self.dataArray) {
        if ([model.musicId isEqualToString:tmodel.musicId]) {
            currentModel = tmodel;
            currentModel.isPlaying = model.isPlaying;
            break;
        }
        index++;
    }
    if (currentModel) {
        [self updateModelDownloadStatus:currentModel index:index];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    if (model) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.playerView.height, 0);
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollBlock) {
        self.scrollBlock(scrollView);
    }
    if (!scrollView.mj_header) {
        CGFloat offsetY = scrollView.contentOffset.y;
        if (offsetY < 0) {
            scrollView.contentOffset = CGPointZero;
        }
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section {
    
    return 1;
}




- (void)reloadWithArray:(NSArray *)dataArray {
    self.dataArray = dataArray;
    if (self.dataArray.count == 0) {
        self.noData = YES;
        self.tableView.mj_footer.hidden = YES;
        self.tableView.mj_header.hidden = YES;
    }else {
        self.tableView.mj_footer.hidden = NO;
        self.tableView.mj_header.hidden = NO;
        self.noData = NO;
    }
    [self.tableView reloadData];
    [self reloadWith:[HFPlayerConfigManager shared].currentPlayModel];
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}
- (void)refreshNewData {
    if (self.refreshNewDataBlock) {
        self.refreshNewDataBlock();
    }
    [self.tableView.mj_header endRefreshing];
}

- (void)loadMoreData {
    if (self.loadMoreDataBlock) {
        self.loadMoreDataBlock();
    }
    [self.tableView.mj_footer endRefreshing];
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:HFMusicListTableViewCell.class forCellReuseIdentifier:@"HFMusicListTableViewCell"];
        [_tableView registerClass:HFMusicListNoDataCell.class forCellReuseIdentifier:@"HFMusicListNoDataCell"];
        _tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.16];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 94, 0, 0);
        //下拉刷新
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshNewData)];
        //自动更改透明度
        _tableView.mj_header.automaticallyChangeAlpha = YES;
        //上拉刷新
        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    }
    return _tableView;
}

- (HFPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[HFPlayerView alloc] initWithFrame:CGRectZero];
        _playerView.hidden = YES;
    }
    return _playerView;
}
- (void)dealloc {
    
}

@end
