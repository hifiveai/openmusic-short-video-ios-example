//
//  DVEAudioSourceView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEAudioSourceView.h"
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
#import "NSString+VEToImage.h"
#import "DVEMacros.h"
#import <AVFoundation/AVFoundation.h>
#import "DVELocMusicModel.h"
#import <MJExtension/MJExtension.h>

#define DVELocalMusicDic @"DVELocalMusicDic"

@interface DVEAudioSourceView ()<MPMediaPickerControllerDelegate>

@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UIButton *addAppleMusic;
@property (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) AVAssetExportSession *exportSession;

@property (nonatomic, strong) NSMutableArray<DVELocMusicModel *> *localArr;

@property (nonatomic, weak) id<DVEResourceLoaderProtocol> resourceLoader;

@end

@implementation DVEAudioSourceView

DVEOptionalInject(self.vcContext.serviceProvider, resourceLoader, DVEResourceLoaderProtocol)

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildLayout];
        self.backgroundColor = [UIColor blackColor];
    }
    
    return self;
}

- (NSMutableArray<DVELocMusicModel *> *)localArr
{
    if (!_localArr) {
        _localArr = [NSMutableArray new];
    }
    
    return _localArr;
}

- (void)buildLayout
{
    [self addSubview:self.emptyView];

#ifdef CloseAppleMusic
#else
    [self.addAppleMusic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(60);
        make.bottom.mas_equalTo(-30);
        make.centerX.equalTo(self);
    }];
#endif
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self addSubview:self.addAppleMusic];
    [self.addAppleMusic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(240);
        make.height.mas_equalTo(40);
        make.bottom.mas_equalTo(-30);
        make.centerX.equalTo(self);
    }];
}

-(void)setData:(id<DVEResourceCategoryModelProtocol>)data
{
    _data = data;
    if (data.categoryId.integerValue == 1) {
        self.addAppleMusic.hidden = NO;
    } else {
        self.addAppleMusic.hidden = YES;
    }
    if(self.data.models.count == 0  || !_data){
        [self.tableView.mj_header beginRefreshing];
    } else {
        [self reloadData];
    }
}

- (void)reloadData
{
    self.emptyView.hidden = self.data.models.count > 0;
    self.tableView.hidden = !self.emptyView.hidden;
    [self.tableView reloadData];
    
}


- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.backgroundColor = [UIColor blackColor];
            tableView.backgroundView = nil;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.separatorColor = [UIColor blackColor];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            [tableView registerClass:[DVEAudioCell class] forCellReuseIdentifier:DVEAudioCell.description];
            //下拉刷新
            tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshNewData)];
            //自动更改透明度
            tableView.mj_header.automaticallyChangeAlpha = YES;
//            //上拉刷新
//            tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
            tableView;
        });
    }
    
    return _tableView;
}

-(UIView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [UIView new];
#ifdef CloseAppleMusic
#else
        _emptyView.backgroundColor = [UIColor blackColor];
        [_emptyView addSubview:self.addAppleMusic];
        [_emptyView addSubview:self.emptyImageView];
        [_emptyView addSubview:self.emptyLabel];
        
        [_emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_emptyView);
            make.width.equalTo(@109);
            make.height.equalTo(@65);
        }];
        [_emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_emptyImageView);
            make.top.equalTo(_emptyImageView.mas_bottom);
        }];
        [self.addAppleMusic mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(300);
            make.height.mas_equalTo(60);
            make.bottom.equalTo(_emptyView.mas_bottom).mas_equalTo(-30);
            make.centerX.equalTo(_emptyView);
        }];
#endif
    }
    
    return _emptyView;
}

- (UIButton *)addAppleMusic
{
    if (!_addAppleMusic) {
        _addAppleMusic = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 60)];
        [_addAppleMusic setTitle:NLELocalizedString(@"ck_local_music_list_add", @"添加 Apple music 中的本地音乐") forState:UIControlStateNormal];
        _addAppleMusic.titleLabel.font = SCRegularFont(12);
        [_addAppleMusic setBackgroundColor:HEXRGBCOLOR(0x353434)];
        [_addAppleMusic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _addAppleMusic.layer.cornerRadius = 20;
        [_addAppleMusic addTarget:self action:@selector(addAppleAudio:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _addAppleMusic;
}
- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.font = SCRegularFont(14);
        _emptyLabel.text = NLELocalizedString(@"ck_local_music_list_empty",@"暂无本地音乐");
        _emptyLabel.textColor = [UIColor colorWithWhite:1 alpha:0.5];
    }
    return _emptyLabel;
}
- (UIImageView *)emptyImageView {
    if (!_emptyImageView) {
        _emptyImageView = [[UIImageView alloc] init];
        _emptyImageView.image = @"local_music".dve_toImage;
    }
    return _emptyImageView;
}
- (void)addAppleAudio:(UIButton *)btn
{
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    picker.prompt = @"请选择需要播放的歌曲";
    picker.showsCloudItems = NO;
    picker.allowsPickingMultipleItems = YES;
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationPopover;
    [self.firstAvailableUIViewController presentViewController:picker animated:YES completion:nil];
    [self initLocalData];
}

- (void)initLocalData
{
    NSString *audioLocalPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
    audioLocalPath = [audioLocalPath stringByAppendingPathComponent:DVELocalMusicDic];
    
    NSFileManager *fileM = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileM fileExistsAtPath:audioLocalPath isDirectory:&isDir];
    if (!(isDir && isExist)) {
        [fileM createDirectoryAtPath:audioLocalPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *json = [[NSUserDefaults standardUserDefaults] valueForKey:DVELocalMusicDic];
    if (json.length > 0) {
        NSMutableArray *dic = json.mj_JSONObject;
        self.localArr = [DVELocMusicModel mj_objectArrayWithKeyValuesArray:dic];
    }
}

- (void)saveLocal
{
    NSMutableArray *dic = [DVELocMusicModel mj_keyValuesArrayWithObjectArray:self.localArr];
    NSString *json = dic.mj_JSONString;
    
    [[NSUserDefaults standardUserDefaults] setValue:json forKey:DVELocalMusicDic];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [mediaPicker dismissViewControllerAnimated:NO completion:nil];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [DVECustomerHUD showProgress];
    [mediaPicker dismissViewControllerAnimated:NO completion:^{
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self exportMusicWithArr:[mediaItemCollection.items mutableCopy]];
        });
        
    }];
    
}

- (void)exportMusicWithArr:(NSMutableArray<MPMediaItem *> *)arr
{
    if (arr.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DVECustomerHUD hidProgress];
            [DVECustomerHUD showMessage:@"导出音频成功"];
            [self saveLocal];
            [self.tableView.mj_header beginRefreshing];
        });
        return;
    }
    MPMediaItem *item = arr.firstObject;
    NSURL *assetUrl = item.assetURL;
    
    //检查是否存在相同音乐
    NSInteger index = [self.localArr indexOfObjectPassingTest:^BOOL(DVELocMusicModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([assetUrl.absoluteString isEqualToString:obj.identifier]){
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if(index != NSNotFound){
        dispatch_async(dispatch_get_main_queue(), ^{
            [DVECustomerHUD hidProgress];
            [DVECustomerHUD showMessage:@"您已经添加该音乐"];
            [self.tableView.mj_header beginRefreshing];
        });
        return;
    }
    
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:[AVURLAsset assetWithURL:assetUrl] presetName:AVAssetExportPresetAppleM4A];
    NSString *audioLocalPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
    audioLocalPath = [audioLocalPath stringByAppendingPathComponent:DVELocalMusicDic];
    audioLocalPath = [audioLocalPath stringByAppendingPathComponent:[NSString VEUUIDString]];
    audioLocalPath = [audioLocalPath stringByAppendingString:@".m4a"];
    
    exportSession.outputURL = [NSURL fileURLWithPath:audioLocalPath];
    exportSession.outputFileType = AVFileTypeAppleM4A;
    exportSession.shouldOptimizeForNetworkUse = YES;
    self.exportSession = exportSession;
    
    
    @weakify(self);
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        @strongify(self);
        
        if (exportSession.status == AVAssetExportSessionStatusCompleted)
        {
            NSLog(@"AV export succeeded.");
            DVELocMusicModel *model = [DVELocMusicModel new];
            model.sourcePath = audioLocalPath;
            model.name = item.title;
            model.identifier = assetUrl.absoluteString;
            model.singer = item.artist;
            [self.localArr addObject:model];
        }
        else if (exportSession.status == AVAssetExportSessionStatusCancelled)
        {
            NSLog(@"AV export cancelled.");
        }
        else
        {
            NSLog(@"AV export failed with error: %@ (%ld)", exportSession.error.localizedDescription, (long)exportSession.error.code);
        }
        NSFileManager *file = [NSFileManager defaultManager];
        BOOL ok = [file fileExistsAtPath:exportSession.outputURL.path];
        if (ok) {
            NSLog(@"---------%@",exportSession.outputURL);
            [arr removeObjectAtIndex:0];
            [self exportMusicWithArr:[self remove:arr existItem:item]];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [DVECustomerHUD showMessage:@"导出音频失败"];
                [self saveLocal];
                [DVECustomerHUD hidProgress];
                [self.tableView.mj_header beginRefreshing];
            });
        }
    }];
}

-(NSMutableArray<MPMediaItem *> *)remove:(NSMutableArray<MPMediaItem *> *)array existItem:(MPMediaItem*)item
{
    NSMutableArray* target = [NSMutableArray arrayWithArray:array];
    NSURL *assetUrl = item.assetURL;
    [array enumerateObjectsUsingBlock:^(MPMediaItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj.assetURL.absoluteString isEqualToString:assetUrl.absoluteString]){
            [target removeObject:obj];
        }
    }];
    return target;
}

-(void)refreshNewData {
    if(!self.vcContext || !self.resourceLoader || [self.tableView.mj_footer isRefreshing]){
        [self.tableView.mj_header endRefreshing];
        return;
    }
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @strongify(self);
        [self.resourceLoader musicRefresh:self.data handler:^(NSArray<id<DVEResourceModelProtocol>>* _Nullable newData, NSString* _Nullable error) {
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
        [self.resourceLoader musicLoadMore:self.data handler:^(NSArray<id<DVEResourceModelProtocol>>* _Nullable moreData, NSString* _Nullable error) {
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
    cell.isSound = NO;
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
