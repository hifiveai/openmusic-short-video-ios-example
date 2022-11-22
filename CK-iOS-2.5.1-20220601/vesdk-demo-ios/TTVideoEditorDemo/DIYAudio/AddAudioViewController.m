//
//  AddAudioViewController.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/13.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "AddAudioViewController.h"
#import "HFSearchViewController.h"
#import <Masonry/Masonry.h>
#import "HFNavView.h"
#import "HFMusicListView.h"
#import "HFPlaylistCollectionView.h"
#import "HFMusicListCellModel.h"
#import "HFPlaylistCollectionCellModel.h"
#import "HFListViewController.h"
#import <HFOpenApi/HFOpenApi.h>
#import "NSMutableDictionary+SafeAccess.h"
#import "NSMutableArray+SafeAccess.h"
#import "NSDictionary+SafeAccess.h"
#import "HFOpenModel.h"
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import "HFPlayerConfigManager.h"
#import "DVEAudioPlayer.h"
#import <MJRefresh/MJRefresh.h>
#import "HFMusicListPageHeaderView.h"
#import "HFMusicListViewController.h"
#import "HFPlayerView.h"
#import "DVECustomerHUD.h"
#import "HFRegistViewController.h"
#import "DVEUIHelper.h"

@interface AddAudioViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) HFNavView *navView;

@property (nonatomic ,strong) UITableView *musicList;
@property (nonatomic, strong) HFMusicListPageHeaderView *pageHeaderView;

@property (nonatomic ,strong) HFPlaylistCollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *musicListArray;
@property (nonatomic, strong) NSMutableArray *playListArray;
@property (nonatomic, strong) NSMutableArray *collectedListArray;

@property (nonatomic, assign) NSInteger collectPage;
@property (nonatomic, assign) NSInteger sheetPage;


@property (nonatomic, strong) HFPlayerView *playerView;

@property (nonatomic, assign)BOOL playerCanPlay;
@end

@implementation AddAudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = YES;
    
    
    
    [self addSubviews];
    [self makeLayoutSubviews];
    [self addActions];
    if ([HFPlayerConfigManager shared].isRegister) {
        [self InitData];
    }else {
        __weak typeof(self) weakSelf = self;
        HFRegistViewController *vc = [[HFRegistViewController alloc] initWithNibName:@"HFRegistViewController" bundle:nil];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:vc animated:YES completion:nil];
        vc.loginSuccessBlock = ^{
            [weakSelf InitData];
        };
    }
    
    
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.playerCanPlay = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[DVEAudioPlayer shareManager] pause];
    self.playerView.hidden = YES;
    [HFPlayerConfigManager shared].currentPlayModel = nil;
    [self.pageHeaderView.collectedVC reMakeConstraints];
    [self.pageHeaderView.musicListVC reMakeConstraints];
    self.playerCanPlay = NO;
}

- (void)addSubviews {
    [self.view addSubview:self.navView];
    [self.view addSubview:self.musicList];
    [self.view addSubview:self.playerView];
}
- (void)makeLayoutSubviews {
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20 + (DVEIPHONE_X ? VETopMargnValue:0));
        make.leading.trailing.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    [self.musicList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom).offset(10);
        make.leading.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(-(DVEIPHONE_X ? 34:0));
    }];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(-(DVEIPHONE_X ? 34:0));
        make.height.mas_equalTo(96);
    }];
}
- (void)addActions {
    self.musicList.delegate = self;
    self.musicList.dataSource = self;
    __weak typeof(self) weakSelf = self;
    self.navView.backActionBlock = ^{
        [weakSelf closeVC];
    };
    self.navView.searchActionBlock = ^{
        [weakSelf toSearchVC];
    };
    self.musicList.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshNewData)];
    self.pageHeaderView.musicListVC.refreshNewDataBlock = ^{
        weakSelf.sheetPage = 1;
        [weakSelf getSheetData];
    };
    self.pageHeaderView.musicListVC.loadMoreDataBlock = ^{
        weakSelf.sheetPage = weakSelf.sheetPage + 1;
        [weakSelf getSheetData];
    };
    
    self.pageHeaderView.collectedVC.refreshNewDataBlock = ^{
        [weakSelf getCollectedList];
    };
    self.pageHeaderView.collectedVC.loadMoreDataBlock = ^{
        [weakSelf getCollectedList];
    };
    self.pageHeaderView.musicListVC.useMusicBlock = ^(HFMusicListCellModel * _Nonnull model) {
        if (weakSelf.chooseBlock) {
            NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
            NSString *timeStr = [NSString stringWithFormat:@"%0.f",time*1000];
            [[HFOpenApiManager shared] ugcReportListenWithMusicId:model.musicId duration:@"" timestamp:timeStr audioFormat:@"mp3" audioRate:@"320" success:^(id  _Nullable response) {
                
            } fail:^(NSError * _Nullable error) {
                
            }];
            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
            weakSelf.chooseBlock([NSURL fileURLWithPath:model.pathUrl], model.songName);
        };
    };
    self.pageHeaderView.collectedVC.useMusicBlock = ^(HFMusicListCellModel * _Nonnull model) {
        if (weakSelf.chooseBlock) {
            NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
            NSString *timeStr = [NSString stringWithFormat:@"%0.f",time*1000];
            [[HFOpenApiManager shared] ugcReportListenWithMusicId:model.musicId duration:@"" timestamp:timeStr audioFormat:@"mp3" audioRate:@"320" success:^(id  _Nullable response) {
                
            } fail:^(NSError * _Nullable error) {
                
            }];
            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
            weakSelf.chooseBlock([NSURL fileURLWithPath:model.pathUrl], model.songName);
        };
    };

    self.collectionView.collectionDidSelectBLock = ^(NSIndexPath *indexPath) {
        HFListViewController * listViewCon = [[HFListViewController alloc] init];
        HFPlaylistCollectionCellModel *model = weakSelf.playListArray[indexPath.section * 9 + indexPath.row];
        listViewCon.sheetId = model.sheetId;
        listViewCon.titleName = model.listName;
        listViewCon.chooseBlock = weakSelf.chooseBlock;
        [weakSelf.navigationController pushViewController:listViewCon animated:YES];
    };
    self.pageHeaderView.scrollBlock = ^(UIScrollView * _Nonnull scrollView) {
        CGFloat offsetY = scrollView.contentOffset.y;
        if (offsetY <= 0) {
            scrollView.contentOffset = CGPointZero;
            scrollView.scrollEnabled = NO;
            weakSelf.musicList.scrollEnabled = YES;
        }else {
            if (weakSelf.musicList.contentOffset.y < (weakSelf.collectionView.height - 20)) {
                scrollView.scrollEnabled = NO;
                weakSelf.musicList.scrollEnabled = YES;
            }
        }
    };
    self.pageHeaderView.updatePlayer = ^(HFMusicListCellModel * _Nonnull model) {
        if (self.playerCanPlay) {
            weakSelf.playerView.hidden = NO;
            [weakSelf.playerView configWithModel:model];
            [weakSelf.pageHeaderView.musicListVC reloadWithArray:weakSelf.musicListArray];
            [weakSelf.pageHeaderView.collectedVC reloadWithArray:weakSelf.collectedListArray];
        }
        
    };
    self.pageHeaderView.pausePlayer = ^{
        [weakSelf.playerView pause];
    };
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCollectedArray) name:@"HFRefreshCollected" object:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY > ([UIScreen mainScreen].bounds.size.height - 44 - 44 - 49 - (DVEIPHONE_X ? VETopMargnValue:0) + (DVEIPHONE_X ? 34:0))) {
        scrollView.scrollEnabled = NO;
        [self.pageHeaderView canScroll];
    }else {
        
    }
    
}
- (void)InitData {

    
    [self getSelectedPlaylistsData];
    self.sheetPage = 1;
    [self getSheetData];
    
    self.collectPage = 1;
    [self getCollectedList];
    
    self.musicList.tableHeaderView = self.collectionView;
}
- (void)refreshNewData {
    self.sheetPage = 1;
    [self getSheetData];
    [self getSelectedPlaylistsData];
    self.collectPage = 1;
    [self getCollectedList];
}

- (void)getSheetData {
    __weak typeof(self) weakSelf = self;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval oneYear = 3600*24*365;
    NSString *timeStr = [NSString stringWithFormat:@"%0.f",time-oneYear];
    [[HFOpenApiManager shared] baseHotWithStartTime:timeStr duration:@"365" levels:@"MUSIC" page:[NSString stringWithFormat:@"%lu",(unsigned long)self.sheetPage] pageSize:@"20" success:^(id  _Nullable response) {
        NSArray *tempArray = [HFOpenMusicModel mj_objectArrayWithKeyValuesArray:[response hfv_objectForKey_Safe:@"record"]];
        
        if (weakSelf.sheetPage == 1) {
            [weakSelf.musicListArray setArray:tempArray];
            
        }else {
            [weakSelf.musicListArray addObjectsFromArray:tempArray];
        }
        [weakSelf.pageHeaderView.musicListVC reloadWithArray:weakSelf.musicListArray];
        [weakSelf.musicList.mj_header endRefreshing];
        
    } fail:^(NSError * _Nullable error) {
        [DVECustomerHUD showMessage:error.localizedDescription];
        [weakSelf.pageHeaderView.musicListVC reloadWithArray:weakSelf.musicListArray];
    }];
}

- (void)getSelectedPlaylistsData {
    __weak typeof(self) weakSelf = self;
    [[HFOpenApiManager shared] sheetWithLanguage:nil recoNum:nil tagId:nil tagFilter:nil page:@"1" pageSize:@"50" success:^(id  _Nullable response) {
        NSArray *recordArray = [response hfv_objectForKey_Safe:@"record"];
        [weakSelf.playListArray removeAllObjects];
        for (NSDictionary *dataDict in recordArray) {
            HFPlaylistCollectionCellModel *model = [[HFPlaylistCollectionCellModel alloc] init];
            model.listName = [dataDict hfv_objectForKey_Safe:@"sheetName"];
            long sheetId= [[dataDict hfv_objectForKey_Safe:@"sheetId"] longValue];
            model.sheetId = [NSString stringWithFormat:@"%ld",sheetId];
            NSArray *covers = [dataDict hfv_objectForKey_Safe:@"cover"];
            NSDictionary *cover = covers.firstObject;
            model.picUrl = [cover hfv_objectForKey_Safe:@"url"];
            [weakSelf.playListArray addObject:model];
        }
        [weakSelf.collectionView reloadCollectWith:weakSelf.playListArray];
        } fail:^(NSError * _Nullable error) {
            [DVECustomerHUD showMessage:error.localizedDescription];
            [weakSelf.collectionView reloadCollectWith:weakSelf.playListArray];
        }];
}

- (void)getCollectedList {
    
    __weak typeof(self) weakSelf = self;
    [[HFOpenApiManager shared] fetchMemberSheetListWithMemberOutId:@"1" page:@"1" pageSize:@"20" success:^(id  _Nullable response) {
        for (NSDictionary *tempDict in [response hfv_objectForKey_Safe:@"record"]) {
            int type = [[tempDict hfv_objectForKey_Safe:@"type"] intValue];
            if (type == 2) {
                [HFPlayerConfigManager shared].sheetId = [NSString stringWithFormat:@"%ld",[[tempDict hfv_objectForKey_Safe:@"sheetId"] longValue]] ;
                break;
            }
            
        }
        [[HFOpenApiManager shared] fetchMemberSheetMusicWithSheetId:[HFPlayerConfigManager shared].sheetId page:@"1" pageSize:@"100" success:^(id  _Nullable response) {
            NSArray *tempArray = [HFOpenMusicModel mj_objectArrayWithKeyValuesArray:[response hfv_objectForKey_Safe:@"record"]];
            [weakSelf.collectedListArray setArray:tempArray];
            [[HFPlayerConfigManager shared].collectedArray setArray:weakSelf.collectedListArray];
            [weakSelf.pageHeaderView.collectedVC reloadWithArray:weakSelf.collectedListArray];
            } fail:^(NSError * _Nullable error) {
                [DVECustomerHUD showMessage:error.localizedDescription];
                [weakSelf.pageHeaderView.collectedVC reloadWithArray:[HFPlayerConfigManager shared].collectedArray ];
            }];
        } fail:^(NSError * _Nullable error) {
            [weakSelf.pageHeaderView.collectedVC reloadWithArray:[HFPlayerConfigManager shared].collectedArray ];
        }];
    

}


- (void)closeVC {
    _pageHeaderView = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toSearchVC {
    HFSearchViewController *searchVC = [[HFSearchViewController alloc] init];
    searchVC.chooseBlock = self.chooseBlock;
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void)refreshCollectedArray {
    [self.pageHeaderView.collectedVC reloadWithArray:[HFPlayerConfigManager shared].collectedArray];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    return nil;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return [UIScreen mainScreen].bounds.size.height - 44 - 44  - (DVEIPHONE_X ? VETopMargnValue:0) + (DVEIPHONE_X ? 34:0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return [UIScreen mainScreen].bounds.size.height - 44 - 44 - (DVEIPHONE_X ? VETopMargnValue:0) + (DVEIPHONE_X ? 34:0) ;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return self.pageHeaderView;
        
}

- (HFNavView *)navView {
    if (!_navView) {
        _navView = [HFNavView configWithFrame:CGRectZero title:@"添加音乐" closeImage:@"" searchImage:@"search_icon" backImage:@"back_icon"];
    }
    return _navView;
}

- (UITableView *)musicList {
    if (!_musicList) {
        _musicList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _musicList.backgroundColor = [UIColor blackColor];
    }
    return _musicList;
}

- (HFPlaylistCollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[HFPlaylistCollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 540)];
    }
    return _collectionView;
}

- (HFMusicListPageHeaderView *)pageHeaderView {
    if (!_pageHeaderView) {
        __weak typeof(self) weakSelf = self;
        _pageHeaderView = [[HFMusicListPageHeaderView alloc] initWithFrame:CGRectZero presentVC:weakSelf];
    }
    return _pageHeaderView;
}
- (HFPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[HFPlayerView alloc] initWithFrame:CGRectZero];
        _playerView.hidden = YES;
    }
    return _playerView;
}

- (NSMutableArray *)musicListArray {
    if (!_musicListArray) {
        _musicListArray = [[NSMutableArray alloc] init];
    }
    return _musicListArray;
}
- (NSMutableArray *)playListArray {
    if (!_playListArray) {
        _playListArray = [[NSMutableArray alloc] init];
    }
    return _playListArray;
}

- (NSMutableArray *)collectedListArray {
    if (!_collectedListArray) {
        _collectedListArray = [[NSMutableArray alloc] init];
    }
    return _collectedListArray;
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
