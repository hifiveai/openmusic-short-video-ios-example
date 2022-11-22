//
//  DVEPopSelectView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "DVEPopSelectView.h"
#import "DVEPopSelectItem.h"
#import "DVEUIHelper.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEMacros.h"
#import "NSString+VEToImage.h"

@interface DVEPopSelectView ()

@property (nonatomic, strong) UIImageView *angleView;
@property (nonatomic, copy) void(^completBlock)(NSInteger selectIndex);

@end

@implementation DVEPopSelectView

+ (DVEPopSelectView *)showSelectInView:(UIView *)view
                               angleX:(CGFloat)angleX
                       withDataSource:(NSArray *)dataSourceArr
                   defaultSelectIndex:(NSInteger)index
                         CompletBlock:(void(^)(NSInteger selectIndex))completBlock
{
    DVEPopSelectView *popView = [[DVEPopSelectView alloc] initWithFrame:CGRectMake(15, 80 - VETopMargnValue + VETopMargn, VE_SCREEN_WIDTH - 30, 56)];
    popView.backgroundColor = [UIColor clearColor];
    popView.angleView.centerX = angleX - 15;
    popView.completBlock = completBlock;
    popView.dataSourceArr = dataSourceArr;
    popView.tag = 15903;
    UIView *tagview = [view viewWithTag:popView.tag];
    if ([tagview isKindOfClass:[DVEPopSelectView class]]) {
        DVEPopSelectView *lastView = (DVEPopSelectView *)tagview;
        
        
        if (lastView.angleView.centerX == popView.angleView.centerX) {
            [tagview removeFromSuperview];
            return nil;
        } else {
            [tagview removeFromSuperview];
        }
        
        
    }
    [view addSubview:popView];
    [popView.collecView setAllowsSelection:YES];
    [popView.collecView selectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    
    
    
    return popView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = HEXRGBCOLOR(0x181718);
        
        [self buildBaseLayout];
    }
    
    return self;
}

- (void)buildBaseLayout
{
    [self addSubview:self.angleView];
    [self addSubview:self.collecView];
    
}

-(UIImageView *)angleView
{
    if (!_angleView) {
        _angleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 6)];
        _angleView.image = @"icon_topbar_angle".dve_toImage;
    }
    
    return _angleView;
}


- (UICollectionView *)collecView
{
    if (!_collecView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
        _collecView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 6, self.frame.size.width, 50) collectionViewLayout:flowLayout];
        _collecView.showsHorizontalScrollIndicator = NO;
        _collecView.showsVerticalScrollIndicator = NO;
        _collecView.delegate = self;
        _collecView.dataSource = self;
        _collecView.layer.cornerRadius = 6;
        _collecView.clipsToBounds = YES;
        _collecView.backgroundColor = [UIColor blackColor];
        
        if (@available(iOS 11.0, *)) {
            _collecView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            
            
        }
        
        
        [_collecView registerClass:[DVEPopSelectItem class] forCellWithReuseIdentifier:DVEPopSelectItem.description];
    }
    
    return _collecView;
}

- (void)setDataSourceArr:(NSArray *)dataSourceArr

{
    _dataSourceArr = dataSourceArr;
    [self.collecView reloadData];
    
}


#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceArr.count;
    
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DVEPopSelectItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DVEPopSelectItem.description forIndexPath:indexPath];
    NSString *title = self.dataSourceArr[indexPath.row];
    if (title.length > 0) {
        cell.titleLable.text = title;
    }
    
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
    return CGSizeMake(50, 50);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 30, 0,30);
   
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 20;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 20;
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
   
    if (self.completBlock) {
        self.completBlock(indexPath.row);
    }
    
    [self removeFromSuperview];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self]) {
        return NO;
    } else {
        return YES;
    }
}


@end
