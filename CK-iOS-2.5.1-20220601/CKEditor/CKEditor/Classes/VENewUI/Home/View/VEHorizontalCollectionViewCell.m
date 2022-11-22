//
//  VEHorizontalCollectionViewCell.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEHorizontalCollectionViewCell.h"
#import "VEMenuItemCell.h"


#define kVEMenuItemCellIdentifier @"kVEMenuItemCellIdentifier"
@interface VEHorizontalCollectionViewCell ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collecView;
@property (nonatomic, strong) NSDictionary *options;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation VEHorizontalCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildLayout];
    }
    
    return self;
}

- (void)buildLayout
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
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
        _collecView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:flowLayout];
        _collecView.showsHorizontalScrollIndicator = NO;
        _collecView.delegate = self;
        _collecView.dataSource = self;
        _collecView.bounces = YES;
        if (@available(iOS 13.0, *)) {
            _collecView.backgroundColor = [UIColor systemGray6Color];
        } else {
            _collecView.backgroundColor = [UIColor whiteColor];
        }
        [_collecView registerClass:[VEMenuItemCell class] forCellWithReuseIdentifier:kVEMenuItemCellIdentifier];
        
    }
    
    return _collecView;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    NSArray *arr = [self.options valueForKey:title];
    self.dataSource = arr;
    [self.collecView performBatchUpdates:^{
        [self.collecView reloadData];
    } completion:^(BOOL finished) {
        
    }];
}

- (NSDictionary *)options
{
    return @{
        @"主场景":@[@"MV",@"影集",@"合拍",@"影集",@"合拍",@"影集",@"合拍"],
        @"小功能":@[@"选封面",@"滤镜",@"字幕",@"影集",@"合拍",@"影集",@"合拍"],
    };
}


#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
    
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VEMenuItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVEMenuItemCellIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = self.dataSource[indexPath.row];
    cell.backgroundColor = randomColor;
    cell.layer.cornerRadius = 8;
    
    return cell;
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
    return CGSizeMake(90, 90);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(vemargn, vemargn, vemargn,vemargn);
   
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return vemargn;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return vemargn;
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
    
}

@end
