//
//  DIYSearchViewController.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/13.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "HFSearchViewController.h"
#import "HFMusicListView.h"
#import "HFMusicListCellModel.h"
#import "HFSearchBarView.h"
#import <MJRefresh/MJRefresh.h>
#import <HFOpenApi/HFOpenApi.h>
#import "HFOpenModel.h"
#import "NSMutableDictionary+SafeAccess.h"
#import "NSMutableArray+SafeAccess.h"
#import "NSDictionary+SafeAccess.h"
#import <MJExtension/MJExtension.h>
#import "HFNoDataView.h"
#import "DVEAudioPlayer.h"
#import "DVECustomerHUD.h"
#import "DVEUIHelper.h"

@interface HFSearchViewController ()

@property (nonatomic ,strong) HFSearchBarView *searchBarView;
@property (nonatomic ,strong) HFMusicListView *musicList;

@property (nonatomic ,strong) NSString *currentKeyword;
@property (nonatomic ,assign) NSInteger page;

@property (nonatomic ,strong) NSMutableArray *dataArray;

@end

@implementation HFSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self addSubviews];
    [self makeLayoutSubviews];
    [self configUI];
    [self addActions];
    [self initData];
    // Do any additional setup after loading the view.
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[DVEAudioPlayer shareManager] pause];
}

- (void)addSubviews {
    [self.view addSubview:self.searchBarView];
    [self.view addSubview:self.musicList];
}
- (void)makeLayoutSubviews {
    [self.searchBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20+ (DVEIPHONE_X ? VETopMargnValue:0));
        make.leading.trailing.mas_equalTo(0);
        make.height.mas_equalTo(60);
    }];
    [self.musicList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBarView.mas_bottom).offset(10);
        make.leading.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(-(DVEIPHONE_X ? 34:0));
    }];
}
- (void)addActions {
    __weak typeof(self) weakSelf = self;
    
    self.searchBarView.cancelBtnBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    self.searchBarView.searchActionBlock = ^(NSString * _Nonnull searchName) {
        weakSelf.page = 1;
        [weakSelf searchWith:searchName];
        [weakSelf.searchBarView endEditing:YES];
    };
    self.musicList.useMusicBlock = ^(HFMusicListCellModel * _Nonnull model) {
        if (weakSelf.chooseBlock) {
            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
            weakSelf.chooseBlock([NSURL fileURLWithPath:model.pathUrl], model.songName);
        }
    };
    
    self.musicList.loadMoreDataBlock = ^{
        if (weakSelf.currentKeyword && weakSelf.currentKeyword.length != 0) {
            weakSelf.page = weakSelf.page + 1;
            [weakSelf searchWith:weakSelf.currentKeyword];
        }
        
    };
    self.musicList.scrollBlock = ^(UIScrollView * _Nonnull scrollView) {
        [weakSelf.searchBarView.searchTextFieldView resignFirstResponder];
    };
}
- (void)configUI {
    self.musicList.tableView.mj_header = nil;
    self.musicList.noDataTitle = @"没有搜索结果";
    self.musicList.noDataImageName = @"noSearchData";
}

- (void)searchWith:(NSString *)keyword {
    __weak typeof(self) weakSelf = self;
    self.currentKeyword = keyword;
    
    [[HFOpenApiManager shared] searchMusicWithTagIds:nil priceFromCent:nil priceToCent:nil bpmFrom:nil bpmTo:nil durationFrom:nil durationTo:nil keyword:keyword language:nil searchFiled:nil searchSmart:@"1" levels:@"MUSIC" page:[NSString stringWithFormat:@"%ld",self.page] pageSize:@"20" success:^(id  _Nullable response) {
        
        NSArray *musicArray = [HFOpenMusicModel mj_objectArrayWithKeyValuesArray: [response hfv_objectForKey_Safe:@"record"]];
        if (weakSelf.page == 1) {
            [weakSelf.dataArray setArray:musicArray];
            [weakSelf.musicList reloadWithArray:musicArray];
        }else {
            [weakSelf.dataArray addObjectsFromArray:musicArray];
            [weakSelf.musicList reloadWithArray:weakSelf.dataArray];
        }
        
    } fail:^(NSError * _Nullable error) {
        [DVECustomerHUD showMessage:error.localizedDescription];
    }];
}


- (void)initData {
    self.page = 1;
    [self.searchBarView.searchTextFieldView becomeFirstResponder];
}

- (HFMusicListView *)musicList {
    if (!_musicList) {
        _musicList = [[HFMusicListView alloc] initWithFrame:CGRectZero];
    }
    return _musicList;
}

- (HFSearchBarView *)searchBarView {
    if (!_searchBarView) {
        _searchBarView = [HFSearchBarView configWithFrame:CGRectZero searchImage:@"searchbar_icon" placeHolder:@"搜索歌曲名称、艺人、标签"];
    }
    return _searchBarView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

@end
