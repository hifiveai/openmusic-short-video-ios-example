//
//  DIYListViewController.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/13.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "HFListViewController.h"
#import "HFNavView.h"
#import "HFMusicListView.h"
#import "HFMusicListCellModel.h"
#import <HFOpenApi/HFOpenApi.h>
#import "HFOpenModel.h"
#import <MJExtension/MJExtension.h>
#import "NSMutableDictionary+SafeAccess.h"
#import "NSMutableArray+SafeAccess.h"
#import "NSDictionary+SafeAccess.h"
#import "DVEAudioPlayer.h"
#import "DVECustomerHUD.h"
#import "DVEUIHelper.h"


@interface HFListViewController ()

@property (nonatomic ,strong) HFNavView *navView;
@property (nonatomic ,strong) HFMusicListView *musicList;

@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,assign) NSInteger page;

@end

@implementation HFListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor blackColor];
    [self addSubviews];
    [self makeLayoutSubviews];
    [self addActions];
    [self initData];
    // Do any additional setup after loading the view.
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[DVEAudioPlayer shareManager] pause];
}

- (void)addSubviews {
    [self.view addSubview:self.navView];
    [self.view addSubview:self.musicList];
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
}
- (void)addActions {
    __weak typeof(self) weakSelf = self;
    self.navView.backActionBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    self.musicList.useMusicBlock = ^(HFMusicListCellModel * _Nonnull model) {
        if (weakSelf.chooseBlock) {
            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
            weakSelf.chooseBlock([NSURL fileURLWithPath:model.pathUrl], model.songName);
        }
    };
    
    self.musicList.refreshNewDataBlock = ^{
        weakSelf.page = 1;
        [weakSelf getMusic];
    };
    self.musicList.loadMoreDataBlock = ^{
        weakSelf.page = weakSelf.page + 1 ;
        [weakSelf getMusic];
    };
}
- (void)initData {
    self.page = 1;
    
    [self getMusic];
}

- (void)getMusic {
    __weak typeof(self) weakSelf = self;
    [[HFOpenApiManager shared] sheetMusicWithSheetId:self.sheetId language:@"0" page:[NSString stringWithFormat:@"%ld",self.page] pageSize:@"10" success:^(id  _Nullable response) {
        NSArray *tempArray = [HFOpenMusicModel mj_objectArrayWithKeyValuesArray:[response hfv_objectForKey_Safe:@"record"]];
        if (weakSelf.page == 1) {
            [weakSelf.dataArray setArray:tempArray];
            [weakSelf.musicList reloadWithArray:tempArray];
        }else {
            [weakSelf.dataArray addObjectsFromArray:tempArray];
            [weakSelf.musicList reloadWithArray:weakSelf.dataArray];
        }
        
    } fail:^(NSError * _Nullable error) {
        [DVECustomerHUD showMessage:error.localizedDescription];
        [weakSelf.musicList reloadWithArray:weakSelf.dataArray];
    }];
}

- (HFNavView *)navView {
    if (!_navView) {
        _navView = [HFNavView configWithFrame:CGRectZero title:self.titleName closeImage:@"" searchImage:@"" backImage:@"back_icon"];
    }
    return _navView;
}

- (HFMusicListView *)musicList {
    if (!_musicList) {
        _musicList = [[HFMusicListView alloc] init];
        _musicList.noDataImageName = @"noData";
        _musicList.noDataTitle = @"歌单内没有歌曲";
    }
    return _musicList;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

@end
