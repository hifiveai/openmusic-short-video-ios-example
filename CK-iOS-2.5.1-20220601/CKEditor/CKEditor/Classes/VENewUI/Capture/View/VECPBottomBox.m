//
//  VECPBottomBox.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECPBottomBox.h"
#import "VECPBotomBoxItem.h"
#import "VEPhotoPreviewVC.h"
#import "VEWebViewController.h"

#define kVECPBotomBoxItemIdentifier @"kVECPBotomBoxItemIdentifier"


@interface VECPBottomBox ()

@property (nonatomic, strong) UIButton *nextStep;


@end

@implementation VECPBottomBox
@synthesize viewType = _viewType;


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collecView.top = 0;
        self.collecView.height = 40;
        self.dataSource = [NSMutableArray new];
        
        self.hidden = YES;
        
        [self.collecView registerClass:[VECPBotomBoxItem class] forCellWithReuseIdentifier:kVECPBotomBoxItemIdentifier];
        
        [self addSubview:self.nextStep];
        
        [self.collecView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(25);
            make.right.mas_equalTo(- 25 - 40);
            make.height.mas_equalTo(self.collecView.height);
        }];
        
        self.nextStep.right = VE_SCREEN_WIDTH - 20;
        
        [self buildLayout];
        
        
    }
    
    return self;
}

- (void)setViewType:(VECPViewType)viewType
{
    _viewType = viewType;
    
}

- (void)buildLayout
{
    
}

- (void)addOneSource:(VESourceValue *)value
{
    self.capManager.boxState = VECPBoxStateInprocess;
    [self.dataSource addObject:value];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collecView reloadData];
        self.hidden = NO;
    });
    
}


- (UIButton *)nextStep
{
    if (!_nextStep) {
        _nextStep = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
        [_nextStep setImage:@"icon_bottom_nextstep".UI_VEToImage forState:UIControlStateNormal];
        @weakify(self);
        [[_nextStep rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            if (self.nextActionBlock) {
                self.nextActionBlock(x);
            }
        }];
    }
    
    return _nextStep;
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
    
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VECPBotomBoxItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVECPBotomBoxItemIdentifier forIndexPath:indexPath];
    cell.indexPath = indexPath;
    
    VESourceValue *value = nil;
    value = self.dataSource[indexPath.row];
    cell.sourceValue = value;
    @weakify(self);
    cell.deletBlock = ^(NSIndexPath * _Nonnull index) {
        @strongify(self);
        [self removeObjAtIndex:index.item];
        NSLog(@"delet:%@",index);
        if (self.deletActionBlock) {
            self.deletActionBlock(index);
        }
    };
    
    cell.deletButton.hidden = NO;

    
    return cell;
}

- (void)removeObjAtIndex:(NSInteger)index
{
    [self.dataSource removeObjectAtIndex:index];
    [self.collecView reloadData];
    [self.capManager removeLastVideoAsset];
    self.hidden = self.dataSource.count == 0;
    if (self.hidden) {
        self.capManager.boxState = VECPBoxStateIdle;
    }
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSource.count > 0 ? 1 : 0;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    
    return nil;
}


#pragma mark -- UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(40, 40);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0,0, 0,0);
   
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 25;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 25;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}

#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    VESourceValue *value = nil;
    value = self.dataSource[indexPath.row];
    
    if (value.type == VESourceValueTypeVideo) {
        AVURLAsset *asset = value.asset;
        NSURL *url = asset.URL;
        VEWebViewController *vc = [VEWebViewController new];
        vc.url = url;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self.firstAvailableUIViewController presentViewController:nav animated:YES completion:nil];
    } else {
        VEPhotoPreviewVC *vc = [[VEPhotoPreviewVC alloc] init];
        vc.image = value.image;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.firstAvailableUIViewController presentViewController:vc animated:YES completion:nil];
    }
}

- (void)clean
{
    
}


@end
