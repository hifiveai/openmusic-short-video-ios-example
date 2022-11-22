//
//  VEEMakeUpSelectBar.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "VEEMakeUpSelectBar.h"
#import "VEEBeautyItem.h"

#define kVEEBeautyItemIdentifier @"kVEEBeautyItemIdentifier"

@interface VEEMakeUpSelectBar ()
<UICollectionViewDelegate,UICollectionViewDataSource>



@property (nonatomic, strong) UICollectionView *collecView;
@property (nonatomic, strong) DVEEffectValue *curValue;

@end

@implementation VEEMakeUpSelectBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self buildLayout];
    }
    
    return self;
}

- (void)buildLayout
{
    [self addSubview:self.eyeButton];
    [self addSubview:self.collecView];
}

- (UIButton *)eyeButton
{
    if (!_eyeButton) {
        _eyeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 53)];
        [_eyeButton setBackgroundColor:[UIColor blackColor]];
        [_eyeButton setImage:@"icon_close".UI_VEToImage forState:UIControlStateNormal];
    
        
        @weakify(self);
        [[_eyeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            x.selected = !x.selected;
            [self removeFromSuperview];
            
        }];
    }
    
    return _eyeButton;
}

- (void)setSubSelectIndex:(NSInteger)subSelectIndex

{
    _subSelectIndex = subSelectIndex;
    
}


- (UICollectionView *)collecView
{
    if (!_collecView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
        _collecView = [[UICollectionView alloc] initWithFrame:CGRectMake(60, 0, self.frame.size.width - 60, 53) collectionViewLayout:flowLayout];
        _collecView.showsHorizontalScrollIndicator = NO;
        _collecView.showsVerticalScrollIndicator = NO;
        _collecView.delegate = self;
        _collecView.dataSource = self;
        _collecView.backgroundColor = [UIColor blackColor];
        
        [_collecView registerClass:[VEEBeautyItem class] forCellWithReuseIdentifier:kVEEBeautyItemIdentifier];
    }
    
    return _collecView;
}

- (void)setDataSourceArr:(NSArray *)dataSourceArr
{
    _dataSourceArr = dataSourceArr;
//    @weakify(self);
//    [self.collecView performBatchUpdates:^{
//        @strongify(self);
//        
//    } completion:^(BOOL finished) {
//        @strongify(self);
//        
//    }];
    
    [self.collecView reloadData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self upSelect];
    });
    
    
}

- (void)upSelect
{
    if (self.subSelectIndex >= 0) {
        [self.collecView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.subSelectIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceArr.count;
    
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VEEBeautyItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVEEBeautyItemIdentifier forIndexPath:indexPath];
    
    DVEEffectValue *value = self.dataSourceArr[indexPath.row];
    
    cell.eValue = value;
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSourceArr.count > 0 ? 1 : 0;
}



#pragma mark -- UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(64, 53);
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

#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DVEEffectValue *value = self.dataSourceArr[indexPath.row];
    
    self.curValue = value;
    self.curValue.subSelectIndex = indexPath.row;
    if (self.didSelectedBlock) {
        self.didSelectedBlock(value,self.index);
    }
    
    
}


@end
