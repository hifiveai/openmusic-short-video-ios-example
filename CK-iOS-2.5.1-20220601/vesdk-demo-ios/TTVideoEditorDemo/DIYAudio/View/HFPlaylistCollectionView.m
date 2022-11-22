//
//  HFCollectionView.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/14.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "HFPlaylistCollectionView.h"
#import "HFPlaylistCollectionViewCell.h"
#import "HFPlaylistCollectionViewFlowLayout.h"
#import "HFPlaylistCollectionCellModel.h"
#import "HFPlaylistCollectionHeaderView.h"
#import "HFNoDataView.h"

@interface HFPlaylistCollectionView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic ,strong) UIPageControl *page;
@property (nonatomic ,strong) NSArray *dataArray;
@property (nonatomic ,strong) HFPlaylistCollectionViewFlowLayout *flowLayout;
@property (nonatomic ,strong) HFPlaylistCollectionHeaderView *headerView;
@property (nonatomic ,strong) HFNoDataView *noDataView;
@end

@implementation HFPlaylistCollectionView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
        [self makeLayoutSubviews];
        [self addActions];
        [self configCollectionView];
    }
    return self;
}

- (void)addSubviews {
    [self addSubview:self.headerView];
    [self addSubview:self.collectionView];
    [self addSubview:self.page];
    [self addSubview:self.noDataView];
}
- (void)makeLayoutSubviews {
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom).offset(10);
        make.leading.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(-40);
    }];
    [self.page mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionView.mas_bottom).offset(12);
        make.centerX.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(100, 15));
//        make.bottom.mas_equalTo(-12);
    }];
    [self.noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.mas_equalTo(0);
    }];
}
- (void)addActions {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)configCollectionView {
    self.backgroundColor = [UIColor blackColor];
    self.headerView.titleLable.text = @"精选歌单";
    [self.noDataView updateTitle:@"您还没有精选歌单"];
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    HFPlaylistCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HFPlaylistCollectionViewCell" forIndexPath:indexPath];
    NSInteger index = (indexPath.section * 9) + indexPath.row;
    HFPlaylistCollectionCellModel * model = self.dataArray[index];
    [cell configWith:model];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int page = ceil(self.dataArray.count/9.0) - 1;
    int remainder = self.dataArray.count % 9;
    if (section < page) {
        return 9;
    }
    if (remainder == 0) {
        return 9;
    }
    return remainder;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return ceil(self.dataArray.count/9.0);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.collectionDidSelectBLock) {
        self.collectionDidSelectBLock(indexPath);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int currentPage = scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    self.page.currentPage = currentPage;
}

- (void)reloadCollectWith:(NSArray *)dataArray {
    self.dataArray = dataArray;
    [self.collectionView reloadData];
    
    int page = ceil(self.dataArray.count/9.0);
    if (page == 0) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, (144 + 12) * 3 + 27);
        self.page.hidden = YES;
        self.collectionView.hidden = YES;
        self.noDataView.hidden = NO;
    }else if (page == 1) {
        self.page.hidden = YES;
        CGFloat viewHeight = (104 + 40 + 12) * ceil(self.dataArray.count / 3.0);
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, viewHeight);
        self.flowLayout.rowCount = ceil(self.dataArray.count / 3.0);
        [self.collectionView setCollectionViewLayout:self.flowLayout];
        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
        }];
        self.collectionView.hidden = NO;
        self.noDataView.hidden = YES;
    }else {
        self.page.hidden = NO;
        self.collectionView.hidden = NO;
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, (144 + 12) * 3 + 27 + 40);
        self.noDataView.hidden = YES;
    }

    self.page.numberOfPages = page;
    
    
}

- (HFPlaylistCollectionHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[HFPlaylistCollectionHeaderView alloc] initWithFrame:CGRectZero];
    }
    return _headerView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        HFPlaylistCollectionViewFlowLayout *flowLayout = [[HFPlaylistCollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 12;
        flowLayout.minimumInteritemSpacing = 6;
        flowLayout.itemSize = CGSizeMake(104, 144);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        flowLayout.itemCountPerRow = 3;
        flowLayout.rowCount = 3;
//        flowLayout.headerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 30);
        _flowLayout = flowLayout;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:HFPlaylistCollectionViewCell.class forCellWithReuseIdentifier:@"HFPlaylistCollectionViewCell"];
    }
    return _collectionView;
}

-(UIPageControl *)page {
    if (!_page) {
        _page = [[UIPageControl alloc] initWithFrame:CGRectZero];
//        _page.backgroundColor = [UIColor clearColor];
        _page.pageIndicatorTintColor = [UIColor colorWithWhite:1 alpha:0.3];
        _page.currentPageIndicatorTintColor = [UIColor whiteColor];
        if(@available(iOS 14.0, *)){
            _page.backgroundStyle = UIPageControlBackgroundStyleMinimal;
        }
    }
    return _page;
}

- (HFNoDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[HFNoDataView alloc] init];
        _noDataView.hidden = YES;
    }
    return _noDataView;
}

@end
