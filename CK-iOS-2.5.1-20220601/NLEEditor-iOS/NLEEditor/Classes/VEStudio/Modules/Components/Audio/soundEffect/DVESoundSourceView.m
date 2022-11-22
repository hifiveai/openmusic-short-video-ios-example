//
//  DVESoundSourceView.m
//  NLEEditor
//
//  Created by bytedance on 2021/7/4.
//

#import "DVESoundSourceView.h"
#import "DVEAudioCell.h"
#import "DVEMacros.h"
#import "DVEEffectValue.h"
#import "DVECustomerHUD.h"
#import "DVEVCContext.h"
#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>
#import <DVETrackKit/UIView+VEExt.h>
#import <MediaPlayer/MPMediaPickerController.h>
#import "UIView+VEFindVC.h"
#import <AVFoundation/AVFoundation.h>


@interface DVESoundSourceView ()

@property (nonatomic, strong) UIImageView *emptyView;
@property (nonatomic, strong) UIButton *addAppleMusic;

@property (nonatomic, weak) id<DVEResourceLoaderProtocol> resourceLoader;

@end

@implementation DVESoundSourceView

DVEOptionalInject(self.vcContext.serviceProvider, resourceLoader, DVEResourceLoaderProtocol)

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildLayout];
        self.backgroundColor = [UIColor blackColor];
    }
    
    return self;
}

- (void)buildLayout
{
    [self addSubview:self.emptyView];
    [self addSubview:self.addAppleMusic];
    [self.addAppleMusic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(60);
        make.bottom.mas_equalTo(-30);
        make.centerX.equalTo(self);
    }];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(200);
        make.center.equalTo(self);
    }];
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

-(void)setData:(id<DVEResourceCategoryModelProtocol>)data
{
    _data = data;
    [self reloadData];
}

- (void)reloadData
{
    self.emptyView.hidden = self.data.models.count > 0;
    self.addAppleMusic.hidden = self.emptyView.hidden;
    [self.tableView reloadData];
    self.tableView.hidden = self.data.models.count == 0;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if(self.data.models.count == 0){
        [self.tableView.mj_header beginRefreshing];
    }
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.backgroundColor = [UIColor clearColor];
            tableView.backgroundView = nil;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.separatorColor = [UIColor clearColor];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            [tableView registerClass:[DVEAudioCell class] forCellReuseIdentifier:DVEAudioCell.description];
            //下拉刷新
            tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshNewData)];
            //自动更改透明度
            tableView.mj_header.automaticallyChangeAlpha = YES;
            //上拉刷新
            tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
            tableView;
        });
    }
    
    return _tableView;
}

-(UIImageView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [UIImageView new];
    }
    
    return _emptyView;
}



-(void)refreshNewData {
    if(!self.vcContext || !self.resourceLoader || [self.tableView.mj_footer isRefreshing]){
        [self.tableView.mj_header endRefreshing];
        return;
    }
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @strongify(self);
        [self.resourceLoader soundRefresh:self.data handler:^(NSArray<id<DVEResourceModelProtocol>>* _Nullable newData, NSString* _Nullable error) {
           @weakify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                if(error){
                    ///如果有错误信息则提示错误
                    if(error){
                        [DVECustomerHUD showMessage:error];
                    }
                    [self.tableView.mj_header endRefreshing];
                }else{
                    self.data.models = newData;
                    if(newData.count > 0){//有更新数据则重制加载更多状态
                        [self.tableView.mj_footer resetNoMoreData];
                    }
                    [self.tableView.mj_header endRefreshing];
                    [self reloadData];
                }
            });
        }];
    });

}

-(void)loadMoreData {
    if(!self.vcContext || !self.resourceLoader || [self.tableView.mj_header isRefreshing]){
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @strongify(self);
        [self.resourceLoader soundLoadMore:self.data handler:^(NSArray<id<DVEResourceModelProtocol>>* _Nullable moreData, NSString* _Nullable error) {
            @weakify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                if(error){
                    ///如果有错误信息则提示错误
                    if(error){
                        [DVECustomerHUD showMessage:error];
                    }
                    [self.tableView.mj_footer endRefreshing];
                }else{
                    //没有更多数据则屏蔽加载更多状态
                    if(moreData.count == 0){
                        [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    }else{
                        NSMutableArray* array = [NSMutableArray arrayWithArray:self.data.models];
                        [array addObjectsFromArray:moreData];
                        self.data.models = array;
                        [self.tableView.mj_footer endRefreshing];
                        [self reloadData];
                    }
                }
            });
        }];
    });
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.data.models count] > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data.models count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DVEAudioCell *cell = [tableView dequeueReusableCellWithIdentifier:DVEAudioCell.description forIndexPath:indexPath];
    cell.isSound = YES;
    
    id audioSource = self.data.models[indexPath.row];
    cell.audioSource = audioSource;
    cell.indexPath = indexPath;
    cell.backgroundColor = [UIColor clearColor];
    @weakify(self);
    cell.addBlock = ^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self);
        if (self.selectBlock) {
            DVEEffectValue *evalue = (DVEEffectValue *)self.data.models[indexPath.row];
            self.selectBlock([NSURL fileURLWithPath:evalue.sourcePath], NO, evalue.name);
        }
    };
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 85;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

@end
