//
//  DVEPickerView.m
//  CameraClient
//
//  Created by bytedance on 2019/12/16.
//

#import "DVEPickerView.h"
#import "DVEPickerCollectionViewCell.h"
#import "DVEPickerBaseCell.h"
#import "DVEPickerUIConfigurationProtocol.h"
#import "DVEPickerCategoryTabView.h"
#import <Masonry/Masonry.h>

@interface DVEPickerView ()
<
DVEPickerCategoryTabViewDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource,
DVEPickerCollectionViewCellDelegate
>

@property (nonatomic, strong, readwrite) DVEPickerCategoryTabView *tabView;

@property (nonatomic, strong, readwrite) UICollectionView *stickerCollectionView;

@property (nonatomic, strong, readwrite) id<DVEPickerUIConfigurationProtocol> uiConfig;

@property (nonatomic, copy) NSArray<id<DVEPickerCategoryModel>> *categoryModels;

@property (nonatomic, strong) DVEPickerBaseCell *currentSelectedCell;

@property (nonatomic, strong) UIView<DVEPickerEffectOverlayProtocol> *loadingView;

@property (nonatomic, strong) UIView<DVEPickerEffectErrorViewProtocol> *errorView;
@property (nonatomic, strong) UIView *errorViewContainer;

@property (nonatomic, strong) UIView<DVEPickerEffectOverlayProtocol> *emptyView;

@end

@implementation DVEPickerView

- (instancetype)initWithUIConfig:(id<DVEPickerUIConfigurationProtocol>)config {
    NSAssert(config, @"config is invalid!");
    self.uiConfig = config;
//    DVEPickerCollectionViewCell.cellClass = [self.UIConfig.effectUIConfig stickerItemCellClass];
    
    if (self = [super init]) {
        self.backgroundColor = UIColor.clearColor;
        
        [self setupStickerCollectionView];
        [self setupTabViewWithUIConfig:config.categoryUIConfig];
    }
    return self;
}

- (void)dealloc {
    self.tabView.contentScrollView = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat tabH = [self.uiConfig.categoryUIConfig categoryTabListViewHeight];
    self.tabView.frame = CGRectMake(0, 0, width, tabH);
    
    CGFloat stickerCollectionViewY = CGRectGetMaxY(self.tabView.frame);
    CGFloat stickerCollectionViewH = [self.uiConfig.effectUIConfig effectListViewHeight];
    self.stickerCollectionView.frame = CGRectMake(0, stickerCollectionViewY, width, stickerCollectionViewH);
}

- (void)setDefaultSelectedIndex:(NSInteger)defaultSelectedIndex {
    _defaultSelectedIndex = defaultSelectedIndex;
    
    self.tabView.defaultSelectedIndex = defaultSelectedIndex;
    [self.tabView selectItemAtIndex:defaultSelectedIndex animated:NO];
    [self.stickerCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:defaultSelectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)updateCategory:(NSArray<id<DVEPickerCategoryModel>> *)categoryModels {
    self.categoryModels = categoryModels;
    [self.tabView updateCategory:categoryModels];
    [self.stickerCollectionView reloadData];
}

- (void)executeFavoriteAnimationForIndex:(NSIndexPath *)indexPath {
    [self.tabView executeTwinkleAnimationForIndexPath:indexPath];
}

- (void)updateSelectedStickerForId:(NSString *)identifier {
    [self.currentSelectedCell setStickerSelected:NO animated:NO];
    self.currentSelectedCell = nil;
    
    if (!identifier) {
        return;
    }
    
    NSArray<DVEPickerCollectionViewCell *> *cells = [self.stickerCollectionView visibleCells];
    [cells enumerateObjectsUsingBlock:^(DVEPickerCollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<DVEPickerBaseCell *> *stickerCells = [obj.pickerCollectionView visibleCells];
        [stickerCells enumerateObjectsUsingBlock:^(DVEPickerBaseCell * _Nonnull stickerCell, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([identifier isEqualToString:stickerCell.model.identifier]) {
                [stickerCell setStickerSelected:YES animated:YES];
                self.currentSelectedCell = stickerCell;
            } else {
                [stickerCell setStickerSelected:NO animated:NO];
            }
        }];
    }];
}

- (void)updateStickerStatusForId:(NSString *)identifier {
    NSArray<DVEPickerCollectionViewCell *> *cells = [self.stickerCollectionView visibleCells];
    [cells enumerateObjectsUsingBlock:^(DVEPickerCollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<DVEPickerBaseCell *> *stickerCells = [obj.pickerCollectionView visibleCells];
        [stickerCells enumerateObjectsUsingBlock:^(DVEPickerBaseCell * _Nonnull stickerCell, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([identifier isEqualToString:stickerCell.model.identifier]) {
                [stickerCell updateShowStatus];
            }
        }];
    }];
}

- (void)reloadData {
    [self.tabView reloadData];
    DVEPickerCollectionViewCell *cell = [self.stickerCollectionView visibleCells].firstObject;
    [cell reloadData];
}

-(void)currentCategorySelectItemAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition{
    DVEPickerCollectionViewCell *cell = [self.stickerCollectionView visibleCells].firstObject;
    [cell.pickerCollectionView selectItemAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
}

- (void)selectTabForEffectId:(NSString *)effectId animated:(BOOL)animated {
    __block NSIndexPath *indexPath = nil;
    [self.categoryModels enumerateObjectsUsingBlock:^(id<DVEPickerCategoryModel> _Nonnull category, NSUInteger categoryIdx, BOOL * _Nonnull categoryStop) {
        [category.models enumerateObjectsUsingBlock:^(DVEEffectValue*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.identifier isEqualToString:effectId]) {
                    indexPath = [NSIndexPath indexPathForItem:idx inSection:categoryIdx];
                    *stop = YES;
                }
        }];
        
        if (indexPath) {
            *categoryStop = YES;
        }
    }];
    
    if (indexPath) {
        [self.tabView selectItemAtIndex:indexPath.section animated:animated];
    }
}

- (void)selectTabWithCategory:(id<DVEPickerCategoryModel>)category
{
    if (category == nil) {
        return;
    }
    __block NSIndexPath *indexPath = nil;
    [self.categoryModels enumerateObjectsUsingBlock:^(id<DVEPickerCategoryModel> _Nonnull categoryModel, NSUInteger categoryIdx, BOOL * _Nonnull categoryStop) {
        if ([categoryModel isEqual:category]) {
            indexPath = [NSIndexPath indexPathForItem:0 inSection:categoryIdx];
        }

        if (indexPath) {
            *categoryStop = YES;
        }
    }];
    
    if (indexPath) {
        [self.tabView selectItemAtIndex:indexPath.section animated:NO];
    }

}

- (void)updateLoadingWithTabIndex:(NSInteger)tabIndex {
    BOOL valid = tabIndex >= 0 && tabIndex < [self.stickerCollectionView numberOfItemsInSection:0];
    if (valid) {
        DVEPickerCollectionViewCell *cell = (DVEPickerCollectionViewCell *)[self.stickerCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:tabIndex inSection:0]];
        [cell updateStatus:DVEPickerCollectionViewCellStatusLoading];
    }
}

- (void)updateFetchFinishWithTabIndex:(NSInteger)tabIndex {
    BOOL valid = tabIndex >= 0 && tabIndex < [self.stickerCollectionView numberOfItemsInSection:0];
    if (valid) {
        DVEPickerCollectionViewCell *cell = (DVEPickerCollectionViewCell *)[self.stickerCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:tabIndex inSection:0]];
        [cell updateStatus:DVEPickerCollectionViewCellStatusDefault];
    }
}

- (void)updateFetchErrorWithTabIndex:(NSInteger)tabIndex {
    BOOL valid = tabIndex >= 0 && tabIndex < [self.stickerCollectionView numberOfItemsInSection:0];
    if (valid) {
        DVEPickerCollectionViewCell *cell = (DVEPickerCollectionViewCell *)[self.stickerCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:tabIndex inSection:0]];
        [cell updateStatus:DVEPickerCollectionViewCellStatusError];
    }
}

- (void)updateStatus:(DVEPickerCollectionViewCellStatus)status {
//    DVEPickerLogInfo(@"updateStatus|status=%zi|categoryName=%@", status, self.categoryModel.categoryName);
    [self hideEmptyView];
    [self hideLoadingView];
    [self hideErrorView];
    
    switch (status) {
        case DVEPickerCollectionViewCellStatusDefault:
        {
            [self reloadData];
            if (self.categoryModels.count == 0) {
                [self showEmptyView];
            }
        }
            break;
            
        case DVEPickerCollectionViewCellStatusLoading:
        {
            [self showLoadingView];
        }
            break;
            
        case DVEPickerCollectionViewCellStatusError:
        {
            [self showErrorView];
        }
            break;
            
        default:
            NSAssert(NO, @"status(%zi) is invalid!!!", status);
            break;
    }
}

- (void)updateLoading{
    [self updateStatus:DVEPickerCollectionViewCellStatusLoading];
}

- (void)updateFetchFinish{
    [self updateStatus:DVEPickerCollectionViewCellStatusDefault];
}

- (void)updateFetchError {
    [self updateStatus:DVEPickerCollectionViewCellStatusError];
}

- (void)showLoadingView {
    if ([self.uiConfig respondsToSelector:@selector(panelLoadingView)]) {
        self.loadingView = [self.uiConfig panelLoadingView];
    }
    if([self.loadingView respondsToSelector:@selector(showOnView:)]){
        [self.loadingView showOnView:self];
    }
}

- (void)hideLoadingView {
    if([self.loadingView respondsToSelector:@selector(dismiss)]){
        [self.loadingView dismiss];
    }
    self.loadingView = nil;
}

- (void)showErrorView {
    if ([self.uiConfig respondsToSelector:@selector(panelErrorView)]) {
        self.errorView = [self.uiConfig panelErrorView];
        if(self.errorView){
            self.errorViewContainer = [[UIView alloc] init];
            [self.errorView showOnView:self.errorViewContainer];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onErrorTap)];
            [self.errorViewContainer addGestureRecognizer:tap];
        }
    }
    if(self.errorViewContainer){
        [self addSubview:self.errorViewContainer];
        [self.errorViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
}

- (void)hideErrorView {
    if([self.errorView respondsToSelector:@selector(dismiss)]){
        [self.errorView dismiss];
    }
    self.errorView = nil;
    if(self.errorViewContainer){
        [self.errorViewContainer removeFromSuperview];
        self.errorViewContainer = nil;
    }
}

- (void)onErrorTap {
    [self hideErrorView];
    if([self.delegate respondsToSelector:@selector(pickerViewErrorViewTap:)]){
        [self.delegate pickerViewErrorViewTap:self];
    }
}

- (void)showEmptyView {
    if ([self.uiConfig respondsToSelector:@selector(panelEmptyView)]) {
        self.emptyView = [self.uiConfig panelEmptyView];
    }
    if(self.emptyView){
        [self addSubview:self.emptyView];
        [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }

}

- (void)hideEmptyView {
    if([self.emptyView respondsToSelector:@selector(dismiss)]){
        [self.emptyView dismiss];
    }
    self.emptyView = nil;
}


- (id<DVEPickerUIConfigurationProtocol>)uiConfig {
    return _uiConfig;
}

-(void)performBatchUpdates:(void (NS_NOESCAPE ^ _Nullable)(void))updates completion:(void (^ _Nullable)(BOOL finished))completion {
    [self.stickerCollectionView performBatchUpdates:updates completion:completion];
}

#pragma mark - private

- (void)setupTabViewWithUIConfig:(id<DVEPickerCategoryUIConfigurationProtocol>)config {
    self.tabView = [[DVEPickerCategoryTabView alloc] initWithUIConfig:config];
    [self.tabView.clearStickerApplyBtton addTarget:self action:@selector(clearStickerApplyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.tabView.delegate = self;
    [self addSubview:self.tabView];
    self.tabView.contentScrollView = self.stickerCollectionView;
}

- (void)setupStickerCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsZero;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.stickerCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.stickerCollectionView.backgroundColor = [UIColor clearColor];
    [self.stickerCollectionView registerClass:[DVEPickerCollectionViewCell class]
               forCellWithReuseIdentifier:[DVEPickerCollectionViewCell identifier]];
    self.stickerCollectionView.showsVerticalScrollIndicator = NO;
    self.stickerCollectionView.showsHorizontalScrollIndicator = NO;
    self.stickerCollectionView.pagingEnabled = YES;
    self.stickerCollectionView.delegate = self;
    self.stickerCollectionView.dataSource = self;
    self.stickerCollectionView.backgroundColor = self.uiConfig.effectUIConfig.effectListViewBackgroundColor;
    if (@available(iOS 10.0, *)) {
        self.stickerCollectionView.prefetchingEnabled = NO;
    }
    [self addSubview:self.stickerCollectionView];
}

- (void)clearStickerApplyButtonClicked:(UIButton *)btn {
    btn.selected = !btn.selected;
    if ([self.delegate respondsToSelector:@selector(pickerViewDidClearSticker:)]) {
        [self.delegate pickerViewDidClearSticker:self];
    }
}

- (void)notifySelectedTabIndex:(NSInteger)index {
    if (index < self.categoryModels.count) {
        if (index >= 0) {
            [self.categoryModels[index] loadModelListIfNeeded];
        }
        // 回调 delegate 选中了某个分类
        if ([self.delegate respondsToSelector:@selector(pickerView:didSelectTabIndex:)]) {
            [self.delegate pickerView:self didSelectTabIndex:index];
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categoryModels.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DVEPickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DVEPickerCollectionViewCell identifier] forIndexPath:indexPath];
    cell.delegate = self;
    [cell updateUIConfig:self.uiConfig.effectUIConfig];
    cell.categoryModel = self.categoryModels[indexPath.item];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    DVEPickerCollectionViewCell *stickerPickerCollectionViewCell = (DVEPickerCollectionViewCell *)cell;
    stickerPickerCollectionViewCell.delegate = self;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = collectionView.bounds.size;
    return size;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == self.stickerCollectionView) {
        CGFloat width = scrollView.bounds.size.width;
        CGFloat targetX = targetContentOffset->x;
        NSInteger targetIndex = targetX / width;
        if (targetIndex < 0) {
            targetIndex = 0;
        }
        
        [self notifySelectedTabIndex:targetIndex];
    }
}

#pragma mark - DVEPickerCategoryTabViewDelegate

- (void)categoryTabView:(DVEPickerCategoryTabView *)collectionView didSelectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.stickerCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
    [self notifySelectedTabIndex:index];
}

#pragma mark - DVEPickerCollectionViewCellDelegate

- (BOOL)pickerCollectionViewCell:(DVEPickerCollectionViewCell *)cell isSelected:(DVEEffectValue*)sticker {
    if ([self.delegate respondsToSelector:@selector(pickerView:isSelected:)]) {
        return [self.delegate pickerView:self isSelected:sticker];
    }
    return NO;
}

- (void)pickerCollectionViewCell:(DVEPickerCollectionViewCell *)cell
                       didSelect:(DVEEffectValue*)sticker
                               category:(id<DVEPickerCategoryModel>)category
                              indexPath:(nonnull NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pickerView:didSelectSticker:category:indexPath:)]) {
        NSInteger tabIdx = self.tabView.selectedIndex;
        NSInteger item = indexPath.item;
        NSIndexPath *idxPath = [NSIndexPath indexPathForItem:item inSection:tabIdx];
        [self.delegate pickerView:self didSelectSticker:sticker category:category indexPath:idxPath];
    }
}

- (void)pickerCollectionViewCell:(DVEPickerCollectionViewCell *)cell
                     willDisplay:(DVEEffectValue*)sticker
                              indexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pickerView:willDisplaySticker:indexPath:)]) {
        [self.delegate pickerView:self willDisplaySticker:sticker indexPath:indexPath];
    }
}

- (void)pickerCollectionViewCell:(DVEPickerCollectionViewCell *)cell performDynamicSize:(UICollectionViewFlowLayout *)layout
{
    if (![self.delegate respondsToSelector:@selector(pickerView:numberOfItemsInComponent:)]) {
        return;
    }
    
    NSInteger num = [self.delegate pickerView:self numberOfItemsInComponent:0];
    CGFloat space = layout.minimumInteritemSpacing;
    CGFloat side = (self.frame.size.width - (num - 1) * space - layout.sectionInset.left - layout.sectionInset.right) / num;
    layout.itemSize = CGSizeMake(side, side);
}

@end
