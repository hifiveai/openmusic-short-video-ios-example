//
//  LCVViewController.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/5/25.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "LCVViewController.h"
#import "LCVTableViewCell.h"
#import "LCVDataProvider.h"
#import "NSString+VEToImage.h"
#import <NLEEditor/DVEUIFactory.h>
#import "VEResourcePicker.h"
#import "VEResourceModel.h"
#import "VENLEEditorServiceContainer.h"
#import <TTVideoEditor/HTSVideoData+CacheDirPath.h>

@interface LCVViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArr;
@property (nonatomic, strong) UIImageView *emptyView;
@property (nonatomic, strong) LCVDataProvider *dataService;
@property (nonatomic, strong) UIButton *leftButton;

@end

@implementation LCVViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshDataList];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"本地视频";
    
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
    self.dataSourceArr = [[LCVDataProvider getAllDrafts] copy];
    self.title = [NSString stringWithFormat:@"%@(%zd)",@"本地视频",self.dataSourceArr.count];
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
        [_leftButton setImage:@"icon_draft_close".UI_VEToImage forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(didClickedLeftButton:) forControlEvents:UIControlEventTouchUpInside];
        if (@available(iOS 13.0, *)) {
            [_leftButton setTitleColor:[UIColor systemIndigoColor] forState:UIControlStateNormal];
        } else {
            [_leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    
    return _leftButton;
}



- (LCVDataProvider *)dataService
{
    if (!_dataService) {
        _dataService = [LCVDataProvider new];
    }
    
    return _dataService;
}

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
            [tableView registerClass:[LCVTableViewCell class] forCellReuseIdentifier:LCVTableViewCell.description];
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
    LCVTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LCVTableViewCell.description forIndexPath:indexPath];
    
    NSString *dataSource = self.dataSourceArr[indexPath.row];
    cell.textLabel.text = dataSource.lastPathComponent;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 44;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VEResourcePickerModel *model = [VEResourcePickerModel new];
    model.type = DVEResourceModelPickerTypeVideo;
    NSString *localPath = self.dataSourceArr[indexPath.row];
    NSString *path = [[HTSVideoData cacheDirPath] stringByAppendingString:[NSString stringWithFormat:@"/%@",[NSString VEUUIDString]]];
    path = [path stringByAppendingString:[NSString stringWithFormat:@".%@",localPath.pathExtension]];
    NSFileManager *fileManger = [NSFileManager defaultManager];
    [fileManger copyItemAtURL:[NSURL fileURLWithPath:localPath] toURL:[NSURL fileURLWithPath:path] error:nil];
    model.URL = [NSURL fileURLWithPath:path];
    UIViewController* vc = [DVEUIFactory createDVEViewControllerWithResources:@[model] injectService:[VENLEEditorServiceContainer new]];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
    
}

@end
