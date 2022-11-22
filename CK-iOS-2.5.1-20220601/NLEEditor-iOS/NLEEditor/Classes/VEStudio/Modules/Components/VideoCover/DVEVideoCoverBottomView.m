//
//  DVEVideoCoverBottomView.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/30.
//

#import "DVEVideoCoverBottomView.h"
#import "DVEModuleItem.h"
#import "NSString+VEToImage.h"
#import <Masonry/Masonry.h>

static NSString * const DVEVideoCoverBottomIdentifier = @"DVEVideoCoverBottomIdentifier";

@interface DVEVideoCoverBottomView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<NSString *> *titles;
@property (nonatomic, strong) NSArray<UIImage *> *icons;

@end

@implementation DVEVideoCoverBottomView

- (instancetype)init {
    if (self = [super init]) {
        [self setUpData];
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)setUpData {
    self.titles = @[NLELocalizedString(@"ck_apply_text_sticker_cover", @"添加文字") ];
    self.icons = @[[@"icon_vevc_text" dve_toImage]];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                              collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.allowsMultipleSelection = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = NO;
        [_collectionView registerClass:[DVEModuleItem class]
             forCellWithReuseIdentifier:DVEVideoCoverBottomIdentifier];
    }
    return _collectionView;
}


#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self.titles count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DVEModuleItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DVEVideoCoverBottomIdentifier
                                                                    forIndexPath:indexPath];
    UIImage *icon = self.icons[indexPath.row];
    NSString *title = self.titles[indexPath.row];
    cell.iconView.image = icon;
    cell.titleLable.text = title;
    cell.type = VEVCModuleItemTypeCover;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            [self.delegate showTextView];
            break;
        }
        default:
            break;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, collectionView.bounds.size.width - self.titles.count * 64, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(64, 64);
}


@end
