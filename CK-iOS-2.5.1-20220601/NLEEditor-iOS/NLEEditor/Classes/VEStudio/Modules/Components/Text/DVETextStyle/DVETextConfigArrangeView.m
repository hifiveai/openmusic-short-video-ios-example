//
//  DVETextConfigArrangeView.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/22.
//

#import "DVETextConfigArrangeView.h"

// model

// mgr

// view
#import "DVETextCommonItem.h"
// view model

// support
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEMacros.h"
#import <SDWebImage/SDWebImage.h>

@interface DVETextConfigArrangeViewCell : DVETextCommonItem
@end

@implementation DVETextConfigArrangeViewCell

- (void)setModel:(DVEEffectValue *)model {
    [super setModel:model];
    
    @weakify(self)
    [[SDWebImageManager sharedManager] loadImageWithURL:model.imageURL options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        @strongify(self)
        // 拿到image后，重新渲染成别的颜色
        self.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.imageView.tintColor = UIColor.whiteColor;
    }];
}

- (void)setSelected:(BOOL)selected {
    self.imageView.tintColor = selected ? HEXRGBCOLOR(0xFE6646) : UIColor.whiteColor;
}

@end

@interface DVETextConfigArrangeView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation DVETextConfigArrangeView

static const int8_t kSliderHeight = kDVETextSliderPreferHeight;

// MARK: - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
        [self addSubview:self.lineGapSlider];
        [self addSubview:self.charSpacingSlider];
    }
    return self;
}

// MARK: - Event

// MARK: - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataList.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DVETextConfigArrangeViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DVETextConfigArrangeViewCell.description forIndexPath:indexPath];
    DVEEffectValue *value = self.dataList[indexPath.row];
    cell.model = value;
    cell.imageView.frame = CGRectMake(10, 10, 20, 20);
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataList.count > 0 ? 1 : 0;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedValue = _dataList[indexPath.row];
    !_selectedBlock ? : _selectedBlock(_selectedValue);
}

// MARK: - Private

// MARK: - Getters and setters

- (DVETextSliderView *)charSpacingSlider {
    if (!_charSpacingSlider) {
        _charSpacingSlider = [[DVETextSliderView alloc] initWithFrame:CGRectMake(0, self.collectionView.bottom, self.width, kSliderHeight)];
        _charSpacingSlider.textLabel.text = NLELocalizedString(@"ck_text_sticker_char_spacing",@"字间距");
        _charSpacingSlider.minimumTrackTintColor = UIColor.whiteColor;
        [_charSpacingSlider setValueRange:DVEMakeFloatRang(-10, 100) defaultProgress:0];
    }
    return _charSpacingSlider;
}

- (DVETextSliderView *)lineGapSlider {
    if (!_lineGapSlider) {
        _lineGapSlider = [[DVETextSliderView alloc] initWithFrame:CGRectMake(0, self.charSpacingSlider.bottom, self.width, kSliderHeight)];
        _lineGapSlider.textLabel.text = NLELocalizedString(@"ck_text_sticker_line_gap",@"行间距");
        _lineGapSlider.minimumTrackTintColor = UIColor.whiteColor;
        [_lineGapSlider setValueRange:DVEMakeFloatRang(-10, 100) defaultProgress:0];
    }
    return _lineGapSlider;
}

- (void)setDataList:(NSArray *)dataList {
    _dataList = dataList;
    [self.collectionView reloadData];
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 30;
        flowLayout.minimumLineSpacing = 30;
        flowLayout.itemSize = CGSizeMake(40, 40);
        flowLayout.sectionInset = UIEdgeInsetsMake(3, 10, 3, 10);
    
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, 50) collectionViewLayout:flowLayout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;

        _collectionView.backgroundColor = [UIColor clearColor];
        
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    
        [_collectionView registerClass:[DVETextConfigArrangeViewCell class] forCellWithReuseIdentifier:DVETextConfigArrangeViewCell.description];
    }
    
    return _collectionView;
}

@end

