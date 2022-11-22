//
//  DVEAnimationListView.m
//  NLEEditor
//
//  Created by bytedance on 2021/7/1.
//

#import "DVEAnimationListView.h"
#import "DVEAnimationListCell.h"
#import <Masonry/Masonry.h>
#import "NSString+VEToImage.h"


@interface DVEAnimationListView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewCell *selectedCell;
@property (nonatomic, strong) DVETextAnimationModel *selectedAnimation;
@property (nonatomic, strong) NSArray<DVETextAnimationModel *> *animations;

@end


@implementation DVEAnimationListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayout];
        [self setupStyle];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)setupLayout {
    [self addSubview:self.collectionView];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}
- (void)setupStyle {
    
}
- (void)showAnimations:(NSArray<DVETextAnimationModel *> *)animations selectedAnimation:(DVETextAnimationModel *)animation {
    _selectedAnimation = animation;
    self.animations = animations;
    [self.collectionView reloadData];
}
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        
        [_collectionView registerClass:[DVEAnimationListCell class] forCellWithReuseIdentifier:NSStringFromClass(DVEAnimationListCell.class)];
    }
    return _collectionView;
}
#pragma mark - UICollectionViewDataSource
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DVEAnimationListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(DVEAnimationListCell.class) forIndexPath:indexPath];
    if (indexPath.item == 0) {
        cell.titleLabel.text = NLELocalizedString(@"ck_none", @"无");
        cell.imageView.image = @"iconFilterwu".dve_toImage;
        if (!_selectedAnimation) {
            [cell setSelected:YES];
            _selectedCell = cell;
        }
        return cell;
    }
    DVETextAnimationModel *model = _animations[indexPath.item - 1];
    if ([_selectedAnimation.name isEqualToString:model.name]) {
        [cell setSelected:YES];
        _selectedCell = cell;
    }
    cell.titleLabel.text = model.name;
    [cell.imageView sd_setImageWithURL:[NSURL fileURLWithPath:model.icon]];
    
    return cell;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _animations.count + 1;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DVETextAnimationModel *model;
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell setSelected:YES];
    [_selectedCell setSelected:NO];
    _selectedCell = cell;
    
    if (indexPath.item > 0) {
        model = _animations[indexPath.item - 1];
    }
    [_delegate listView:self didSelectAnimation:model];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50, 70);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0,0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 16;
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
@end
