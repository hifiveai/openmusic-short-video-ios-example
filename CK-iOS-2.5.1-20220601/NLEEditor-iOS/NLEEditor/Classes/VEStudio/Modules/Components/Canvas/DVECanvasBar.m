//
//  DVECanvasBar.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVECanvasBar.h"
#import "DVEModuleItem.h"
#import <SDWebImage/SDWebImage.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "DVEViewController.h"
#import "DVEBundleLoader.h"

#define ItemWidth 64

@interface DVECanvasBar()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UICollectionView *collecView;
@property (nonatomic, strong) NSArray<DVEEffectValue *> *dataSource;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@end

@implementation DVECanvasBar
DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initView];
        [self addObserver];
    }
    return self;
}

- (instancetype)init
{
    if(self = [super init]) {
        [self initView];
        [self addObserver];
    }
    return self;
}

-(void)initView
{
    [self addSubview:self.collecView];
}

-(void)addObserver
{
    [self.actionService addUndoRedoListener:self];
}

-(void)buildLayout
{
    [[DVEBundleLoader shareManager] canvasRatio:self.vcContext
                                        handler:^(NSArray<DVEEffectValue *> * _Nullable datas, NSString * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dataSource = datas;
            if (self.backButton) {
                self.collecView.frame = CGRectMake(ItemWidth, 0, VE_SCREEN_WIDTH - ItemWidth, ItemWidth);
            } else {
                if ((self.dataSource.count * ItemWidth) > VE_SCREEN_WIDTH) {
                    self.collecView.frame = CGRectMake(0,0, VE_SCREEN_WIDTH, ItemWidth);
                } else {
                    self.collecView.frame = CGRectMake(VE_SCREEN_WIDTH - self.dataSource.count * ItemWidth,0, self.dataSource.count * ItemWidth, ItemWidth);
                }
            }
            
            [DVEAutoInline(self.vcContext.serviceProvider, DVECoreActionServiceProtocol) addUndoRedoListener:self];
            [self.collecView reloadData];
            [self refreshSelectedItem];
        });
    }];

}

- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, ItemWidth, ItemWidth)];
        [_backButton setImage:@"icon_vevc_back_level_one".dve_toImage forState:UIControlStateNormal];
        @weakify(self);
        [[_backButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self dismiss:NO];
        }];
        
        [self addSubview:_backButton];
    }
    
    return _backButton;
}


- (void)showInView:(UIView *)view animation:(BOOL)animation
{
    [super showInView:view animation:animation];
    [self buildLayout];
}

- (UICollectionView *)collecView
{
    if (!_collecView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        _collecView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collecView.showsHorizontalScrollIndicator = NO;
        _collecView.showsVerticalScrollIndicator = NO;
        _collecView.delegate = self;
        _collecView.dataSource = self;

        _collecView.backgroundColor = [UIColor clearColor];

        if (@available(iOS 11.0, *)) {
            _collecView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            
        }
        [_collecView registerClass:[DVEModuleItem class] forCellWithReuseIdentifier:NSStringFromClass(DVEModuleItem.class)];
    }

    return _collecView;
}

- (void)undoRedoClikedByUser
{
    [self refreshSelectedItem];
}

- (void)refreshSelectedItem
{
    DVECanvasRatio ratioType = [DVEAutoInline(self.vcContext.serviceProvider, DVECoreCanvasProtocol) ratio];
    NSInteger curIndex = 0;
    for (NSInteger i = 0; i < [self.dataSource count]; i++) {
        id<DVEResourceModelProtocol> model = self.dataSource[i].injectModel;
        if (model.canvasType == (DVEModuleCanvasType)ratioType) {
            curIndex = i;
            break;
        }
    }
    
    [self.collecView selectItemAtIndexPath:[NSIndexPath indexPathForItem:curIndex inSection:0]
                                  animated:NO
                            scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;

}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DVEModuleItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(DVEModuleItem.class) forIndexPath:indexPath];
    cell.titleLable.text = self.dataSource[indexPath.item].injectModel.name;
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSource.count > 0 ? 1 : 0;
}


#pragma mark -- UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(ItemWidth, ItemWidth);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0,0);

}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    @[@"原始",@"9:16",@"3:4",@"1:1",@"4:3",@"16:9"]
    DVEViewController* vc = self.parentVC;
    DVEModuleCanvasType type = self.dataSource[indexPath.item].injectModel.canvasType;
    switch (type) {
        case DVEModuleCanvasTypeOriginal:
        {
            [vc setCanvasRatio:DVECanvasRatioOriginal];

        }
            break;
        case DVEModuleCanvasType9_16:
        {
            [vc setCanvasRatio:DVECanvasRatio9_16];
        }
            break;
        case DVEModuleCanvasType3_4:
        {
            [vc setCanvasRatio:DVECanvasRatio3_4];
        }
            break;
        case DVEModuleCanvasType1_1:
        {
            [vc setCanvasRatio:DVECanvasRatio1_1];
        }
            break;
        case DVEModuleCanvasType4_3:
        {
            [vc setCanvasRatio:DVECanvasRatio4_3];

        }
            break;
        case DVEModuleCanvasType16_9:
        {
            [vc setCanvasRatio:DVECanvasRatio16_9];
        }
            break;
        default:
            break;
    }
}


@end
