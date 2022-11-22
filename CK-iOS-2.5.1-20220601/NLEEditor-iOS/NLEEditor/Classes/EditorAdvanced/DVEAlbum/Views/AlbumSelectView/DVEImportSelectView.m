//
//  DVEImportSelectView.m
//  CutSameIF
//
//  Created by bytedance on 2020/3/5.
//

#import "DVEImportSelectView.h"
#import "DVEImportSelectCollectionViewCell.h"
#import "DVEAlbumMacros.h"
#import "DVEAlbumLanguageProtocol.h"
#import "DVEAlbumResourceUnion.h"
#import "DVEAlbumToastImpl.h"
//#import <EffectPlatformSDK/IESEffectModel.h>
//#import "DVEAlbumPreviewAndSelectController.h"
//#import "DVEResponder.h"
#import <KVOController/KVOController.h>


@interface DVEImportSelectView ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong, readwrite) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray<DVEImportMaterialSelectCollectionViewCellModel *> *allModels;

@property (nonatomic, strong) UIView *seperatorLineView;

@end

@implementation DVEImportSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _isVideoAndPicMixed = YES && NO;
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI
{
//    self.seperatorLineView.frame = CGRectMake(0, 0, self.bounds.size.width, 0.5);
//    [self addSubview:self.seperatorLineView];
    [self addSubview:self.collectionView];

}


- (void)bindViewModel {
    @weakify(self);
    [self.KVOController observe:self.albumViewModel keyPath:@"selectedViewModels" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id _Nullable observer, id _Nonnull object, NSDictionary<NSString *, id> *_Nonnull change) {
        @strongify(self);
        [self.collectionView reloadData];
    }];
}

- (void)setAlbumViewModel:(DVEAlbumViewModel *)albumViewModel {
    _albumViewModel = albumViewModel;
    [self bindViewModel];
    [self.collectionView reloadData];

}

- (NSMutableArray<DVEImportMaterialSelectCollectionViewCellModel *> *)allModels {
    return self.albumViewModel.selectedViewModels;
}

//- (void)setTemplateModel:(LVTemplateModel *)templateModel
//{
//    if (_templateModel != templateModel) {
//        _templateModel = templateModel;
//
//        self.allModels = [NSMutableArray array];
//
//        [templateModel.extraModel.fragments enumerateObjectsUsingBlock:^(LVCutSameFragmentModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if (obj.duration != nil) {
//                [self.allModels addObject:({
//                    DVEImportMaterialSelectCollectionViewCellModel *cellModel = [[DVEImportMaterialSelectCollectionViewCellModel alloc] init];
//                    if (idx == 0) {
//                        cellModel.highlight = YES;
//                    }
//                    cellModel.duration = obj.duration.doubleValue/1000.0;
//                    cellModel.shouldShowDuration = YES;
//
//                    cellModel;
//                })];
//            }
//        }];
//
//        [self reloadSelectView];
//    }
//}

//- (void)setSingleFragmentModel:(LVCutSameFragmentModel *)singleFragmentModel
//{
//    if (_singleFragmentModel != singleFragmentModel) {
//        _singleFragmentModel = singleFragmentModel;
//
//        self.allModels = [NSMutableArray array];
//        if (singleFragmentModel.duration != nil) {
//            [self.allModels addObject:({
//                DVEImportMaterialSelectCollectionViewCellModel *cellModel = [[DVEImportMaterialSelectCollectionViewCellModel alloc] init];
//                cellModel.duration = singleFragmentModel.duration.doubleValue;
//                cellModel.shouldShowDuration = YES;
//                cellModel;
//            })];
//        }
//
//        [self reloadSelectView];
//    }
//}

- (void)deleteAssetAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - DVESelectedAssetsViewProtocol
//- (void)reloadSelectView
//{
//    if (self.templateModel || self.singleFragmentModel) {
//        NSMutableArray<DVEAlbumAssetModel *> *tmpAssetModelArray = [NSMutableArray arrayWithArray:self.assetModelArray];
//        NSMutableArray<DVEImportMaterialSelectCollectionViewCellModel *> *nilAssetModel = [NSMutableArray array];
//        // 移除不存在于assetModelArray的assetModel
//        [self.allModels enumerateObjectsUsingBlock:^(DVEImportMaterialSelectCollectionViewCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSInteger index = [self.assetModelArray indexOfObject:obj.assetModel];
//            obj.highlight = NO;
//            if (index == NSNotFound) {
//                obj.assetModel = nil;
//            }
//
//            if (obj.assetModel) {
//                [tmpAssetModelArray removeObject:obj.assetModel];
//            } else {
//                [nilAssetModel addObject:obj];
//            }
//        }];
//        // 添加assetModelArray新的assetModel
//        [tmpAssetModelArray enumerateObjectsUsingBlock:^(DVEAlbumAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if (nilAssetModel.count <= idx) {
//                *stop = YES;
//            } else {
//                nilAssetModel[idx].assetModel = obj;
//            }
//        }];
//
//        // 寻找第一个空的model
//        [self.allModels enumerateObjectsUsingBlock:^(DVEImportMaterialSelectCollectionViewCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if (obj.assetModel == nil) {
//                obj.highlight = YES;
//                *stop = YES;
//            }
//        }];
//
//        [self.collectionView reloadData];
//    }
//}

- (BOOL)topVCIsPreviewVC
{
    //UIViewController *topVC = [DVEResponder topViewController];
    // TODO: DVE判断是否预览界面
//    if ([topVC isKindOfClass:[DVEAlbumPreviewAndSelectController class]]) {
//        return YES;
//    }
    return NO;
}

- (BOOL)checkVideoValidForCutSameTemplate:(DVEAlbumAssetModel *)assetModel
{
    NSInteger duration = (NSInteger)round(assetModel.asset.duration);
    
    NSInteger __block curIdx;
    DVEImportMaterialSelectCollectionViewCellModel __block *curCellModel = nil;
    [self.allModels enumerateObjectsUsingBlock:^(DVEImportMaterialSelectCollectionViewCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.assetModel == nil) {
            curIdx = idx;
            curCellModel = obj;
            *stop = YES;
        }
    }];
    CGFloat cellDuration = round(curCellModel.duration*10)/10;
    if (curCellModel &&
        duration < cellDuration) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:curIdx inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *hintContent = [NSString stringWithFormat:TOCLocalizedString(@"mv_select_video_toast", @"视频时长不能小于  %.1f 秒"), curCellModel.duration];
            [[DVEAlbumToastImpl new] show:hintContent];
        });
        
        return NO;
    }
    
    return YES;
}

- (NSMutableArray<DVEAlbumAssetModel *> *)currentAssetModelArray
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [self.allModels enumerateObjectsUsingBlock:^(DVEImportMaterialSelectCollectionViewCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.assetModel) {
            [result addObject:obj.assetModel];
        }
    }];
    
    return result;
}

- (void)scrollToNextSelectCell
{
    NSIndexPath __block *targetIndexPath;
    [self.allModels enumerateObjectsUsingBlock:^(DVEImportMaterialSelectCollectionViewCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.assetModel == nil) {
            targetIndexPath = [NSIndexPath indexPathForItem:idx inSection:0];
            *stop = YES;
        }
    }];
    
    if (targetIndexPath == nil) {
        targetIndexPath = [NSIndexPath indexPathForItem:self.allModels.count-1 inSection:0];
    }
    [self.collectionView scrollToItemAtIndexPath:targetIndexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:YES];
}

#pragma mark - Lazy load properties
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 5.0;
        layout.sectionInset = UIEdgeInsetsMake(0, 10.0, 0.0, 10.0);
        layout.itemSize = CGSizeMake(60.0, 60.0);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[DVEImportSelectCollectionViewCell class]
            forCellWithReuseIdentifier:@"Cell"];
    }
    
    return _collectionView;
}

- (UIView *)seperatorLineView
{
    if (!_seperatorLineView) {
        _seperatorLineView = [[UIView alloc] init];
        _seperatorLineView.backgroundColor = TOCResourceColor(TOCColorLineReverse2);
        _seperatorLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    
    return _seperatorLineView;
}

#pragma mark - UICollectionViewDataSource
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DVEImportSelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [cell bindModel:self.allModels[indexPath.item]];
    cell.currentIndexPath = indexPath;
    
    @weakify(self);
    cell.deleteAction = ^(DVEImportSelectCollectionViewCell * _Nonnull cell) {
        @strongify(self);
        DVEAlbumAssetModel *assetModel = cell.cellModel.assetModel;
        cell.cellModel.assetModel = nil;
        
//        BOOL __block highlightFlag = YES;
//        [self.allModels enumerateObjectsUsingBlock:^(DVEImportMaterialSelectCollectionViewCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
////            if (obj.assetModel == nil) {
//                obj.highlight = YES;
//                *stop = YES;
////                highlightFlag = NO;
////            } else {
////                obj.highlight = NO;
////            }
//        }];
        
        [self.assetModelArray removeObject:assetModel];
        TOCBLOCK_INVOKE(self.deleteAssetModelBlock, assetModel);

        [self.collectionView reloadData];
        
    };
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allModels.count;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.touchAssetModelBlock) {
        self.touchAssetModelBlock(self.allModels[indexPath.item].assetModel, indexPath.row);
    }
}

@end

@implementation DVEImportMaterialSelectView

@end
