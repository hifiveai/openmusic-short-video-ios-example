//
//  DVEDraftViewController.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/2/28.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "DVEDraftViewController.h"
#import "DVEDraftTableViewCell.h"
#import "DVEDraftService.h"
#import <TTVideoEditor/HTSVideoData+Dictionary.h>
#import <MJExtension/MJExtension.h>
#import "DVEDraftModel.h"
#import "DVEUIFactory.h"
#import "DVEMacros.h"
#import "NSString+VEToImage.h"
#import "DVELoggerImpl.h"
#import "DVEViewController.h"
#import "DVENotification.h"
#import <DVETrackKit/DVECustomResourceProvider.h>
#import "NSBundle+DVE.h"

@interface DVEDraftViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArr;
@property (nonatomic, strong) UIImageView *emptyView;
// 直接实例化的对象，不能使用 weak，否则会被马上释放
@property (nonatomic, strong) id<DVECoreDraftServiceProtocol> draftService;
@property (nonatomic, strong) UIButton *leftButton;

@property (nonatomic, weak) UIViewController *vc;

@end

@implementation DVEDraftViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshDataList];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NLELocalizedString(@"ck_home_drafts", @"草稿箱");
    
    // Do any additional setup after loading the view.
    [self buildLayout];
    [self initNavBar];
}

- (void)buildLayout
{
    [self.view addSubview:self.tableView];
}

- (void)refreshDataList
{
    self.dataSourceArr = [[self.dratfService getAllDrafts] copy];
    self.title = [NSString stringWithFormat:@"%@(%zd)",NLELocalizedString(@"ck_home_drafts", @"草稿箱"),self.dataSourceArr.count];
    [self.tableView reloadData];
}

- (void)initNavBar
{
    [self addLeftBar];
}

- (void)addLeftBar
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)didClickedLeftButton:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark -- getter

- (UIButton *)leftButton
{
    if (!_leftButton) {
        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [_leftButton setImage:@"icon_draft_close".dve_toImage forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(didClickedLeftButton:) forControlEvents:UIControlEventTouchUpInside];
        if (@available(iOS 13.0, *)) {
            [_leftButton setTitleColor:[UIColor systemIndigoColor] forState:UIControlStateNormal];
        } else {
            [_leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    
    return _leftButton;
}

- (id<DVECoreDraftServiceProtocol>)dratfService
{
    if(!_draftService) {
        _draftService = [DVEDraftService new];
    }
    return _draftService;
}

//- (VEDDraftDataService *)dataService
//{
//    if (!_dataService) {
//        _dataService = [VEDDraftDataService new];
//    }
//
//    return _dataService;
//}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, VE_SCREEN_HEIGHT) style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.backgroundColor = [UIColor whiteColor];
            tableView.backgroundView = nil;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.separatorColor = [UIColor clearColor];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            [tableView registerClass:[DVEDraftTableViewCell class] forCellReuseIdentifier:DVEDraftTableViewCell.description];
            tableView;
        });
    }
    
    return _tableView;
}

-(UIImageView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 109, 100)];
    }
    
    return _emptyView;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self dataSourceArr] count] > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self dataSourceArr] count];
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
    DVEDraftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DVEDraftTableViewCell.description forIndexPath:indexPath];
    
    id dataSource = self.dataSourceArr[indexPath.row];
    cell.model = dataSource;
    @weakify(self);
    cell.deletDraftBlock = ^{
        @strongify(self);
        [self deletDraftAtIndexPath:indexPath];
    };
    
    
    return cell;
}

- (void)deletDraftAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = NLELocalizedString(@"ck_notice", @"提示");
    NSString *message = [NSString stringWithFormat:NLELocalizedString(@"ck_delete_draft_text", @"是否删除该草稿？")];
    DVENotificationAlertView *alertView = [DVENotification showTitle:title message:message leftAction:NLELocalizedString(@"ck_cancel", @"取消")  rightAction:NLELocalizedString(@"ck_delete",@"删除")];
    alertView.leftActionBlock = ^(UIView * _Nonnull view) {
        DVELogInfo(@"取消按钮被点击了");
    };
    alertView.rightActionBlock = ^(UIView * _Nonnull view) {
        DVELogInfo(@"确定按钮被点击了");
        [self deletDraftWithIndex:indexPath];
    };
}

- (void)deletDraftWithIndex:(NSIndexPath *)indexPath
{
    DVEDraftModel *draft = self.dataSourceArr[indexPath.row];
    [self.dratfService removeOneDraftModel:draft];
    [self refreshDataList];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 100;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DVEDraftModel *draft = self.dataSourceArr[indexPath.row];
    UIViewController *vc = [DVEUIFactory createDVEViewControllerWithDraft:draft injectService:self.serviceInjectContainer];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    self.vc = vc;
    [self presentViewController:vc animated:YES completion:^{

    }];
    
}

@end
