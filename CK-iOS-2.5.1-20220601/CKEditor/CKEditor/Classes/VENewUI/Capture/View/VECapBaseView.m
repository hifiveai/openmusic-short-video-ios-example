//
//  VECapBaseView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECapBaseView.h"
#import "VECapBaseCollectionViewCell.h"

#define VECapBaseCollectionViewCellIdentifier @"VECapBaseCollectionViewCellIdentifier"

@interface VECapBaseView ()

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@end


@implementation VECapBaseView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildBaseLayout];        
    }
    
    return self;
}

- (void)buildBaseLayout
{
    [self addSubview:self.collecView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (UICollectionView *)collecView
{
    if (!_collecView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = self.scrollDirection;
        self.flowLayout = flowLayout;
    
        _collecView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50) collectionViewLayout:flowLayout];
        _collecView.showsHorizontalScrollIndicator = NO;
        _collecView.showsVerticalScrollIndicator = NO;
        _collecView.delegate = self;
        _collecView.dataSource = self;

        _collecView.backgroundColor = [UIColor clearColor];
        
        if (@available(iOS 11.0, *)) {
            _collecView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            
            
        }
        
        
        [_collecView registerClass:[VECapBaseCollectionViewCell class] forCellWithReuseIdentifier:VECapBaseCollectionViewCellIdentifier];
    }
    
    return _collecView;
}

- (void)setDataSourceArr:(NSArray *)dataSourceArr

{
    _dataSourceArr = dataSourceArr;
//    [self.collecView reloadData];
    
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    _scrollDirection = scrollDirection;
    self.flowLayout.scrollDirection = scrollDirection;
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceArr.count;
    
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VECapBaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:VECapBaseCollectionViewCellIdentifier forIndexPath:indexPath];
    
    id obj = self.dataSourceArr[indexPath.section];
    
    VEBarValue *value = nil;
    if ([obj isKindOfClass:[NSArray class]]) {
        value = self.dataSourceArr[indexPath.section][indexPath.row];
    } else {
        value = self.dataSourceArr[indexPath.row];
    }
    cell.barValue = value;
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSourceArr.count > 0 ? 1 : 0;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    
    return nil;
}


#pragma mark -- UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, 50);
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
    id obj = self.dataSourceArr[indexPath.section];
    
    VEBarValue *value = nil;
    if ([obj isKindOfClass:[NSArray class]]) {
        value = self.dataSourceArr[indexPath.section][indexPath.row];
    } else {
        value = self.dataSourceArr[indexPath.row];
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isEqual:gestureRecognizer.view]) {
        return YES;
    } else {
        return NO;
    }
}


@end
