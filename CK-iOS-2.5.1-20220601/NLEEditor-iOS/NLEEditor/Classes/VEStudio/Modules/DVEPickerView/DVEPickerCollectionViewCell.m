//
//  DVEPickerCollectionViewCell.m
//  CameraClient
//
//  Created by bytedance on 2020/4/26.
//

#import "DVEPickerCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import "DVEPickerViewModels.h"
#import "DVEPickerBaseCell.h"


@interface DVEPickerCollectionViewCell () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIView<DVEPickerEffectOverlayProtocol> *loadingView;

@property (nonatomic, strong) UIView<DVEPickerEffectErrorViewProtocol> *errorView;
@property (nonatomic, strong) UIView *errorViewContainer;

@property (nonatomic, strong) UIView<DVEPickerEffectOverlayProtocol> *emptyView;

@property (nonatomic, strong) id<DVEPickerEffectUIConfigurationProtocol> UIConfig;

@end

@implementation DVEPickerCollectionViewCell

+ (NSString *)identifier {
    return NSStringFromClass(self);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        UICollectionViewLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _pickerCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _pickerCollectionView.backgroundColor = [UIColor clearColor];
        _pickerCollectionView.showsVerticalScrollIndicator = NO;
        _pickerCollectionView.showsHorizontalScrollIndicator = NO;
        _pickerCollectionView.allowsMultipleSelection = NO;
        if (@available(iOS 10.0, *)) {
            _pickerCollectionView.prefetchingEnabled = NO;
        }
        _pickerCollectionView.dataSource = self;
        _pickerCollectionView.delegate = self;
        [self.contentView addSubview:_pickerCollectionView];
        
        [_pickerCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)updateUIConfig:(id<DVEPickerEffectUIConfigurationProtocol>)config {
    NSAssert([config conformsToProtocol:@protocol(DVEPickerEffectUIConfigurationProtocol)], @"config is invalid!!!");
    UICollectionViewLayout *layout = [config stickerListViewLayout];
    if ([self.delegate respondsToSelector:@selector(pickerCollectionViewCell:performDynamicSize:)]) {
        [self.delegate pickerCollectionViewCell:self performDynamicSize:layout];
    }
    [self.pickerCollectionView setCollectionViewLayout:layout];
    self.UIConfig = config;
    NSDictionary<NSString*,Class> *dic = self.UIConfig.stickerItemCellKeyClass;
    for(NSString* identifier in dic.allKeys){
        [self.pickerCollectionView registerClass:[dic objectForKey:identifier] forCellWithReuseIdentifier:identifier];
    }
    [self.pickerCollectionView reloadData];
}

- (void)updateStatus:(DVEPickerCollectionViewCellStatus)status {
//    DVEPickerLogInfo(@"updateStatus|status=%zi|categoryName=%@", status, self.categoryModel.categoryName);
    [self hideEmptyView];
    [self hideLoadingView];
    [self hideErrorView];
    
    switch (status) {
        case DVEPickerCollectionViewCellStatusDefault:
        {
            [self.pickerCollectionView reloadData];
            if (self.categoryModel.favorite && self.categoryModel.models.count == 0) {
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

- (void)reloadData {
//    DVEPickerLogDebug(@"collection view cell reloadData|categoryName=%@", self.categoryModel.categoryName);
    [self.pickerCollectionView reloadData];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.pickerCollectionView.contentOffset = CGPointZero;
    self.categoryModel = nil;
    
    [self hideLoadingView];
    [self hideErrorView];
    [self hideEmptyView];
}

- (void)setCategoryModel:(id<DVEPickerCategoryModel>)categoryModel {
    _categoryModel = categoryModel;
    [self.pickerCollectionView reloadData];
    
    if (_categoryModel.isLoading) {
        [self showLoadingView];
    } else if (_categoryModel.favorite) {
        // 如果是收藏面板，并且收藏道具为空，展示空视图
        [self hideEmptyView];
    }
}

#pragma mark - Private Methods

- (void)updateIconImageIfNeededWithSticker:(DVEEffectValue*)sticker forCell:(DVEPickerBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [NSString stringWithFormat:@"dynamic_icon_%@", sticker.identifier];
    BOOL isDynamicIconEverClicked = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    if (!isDynamicIconEverClicked) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
        [cell updateStickerIconImage];
        [self.pickerCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categoryModel.models.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    DVEEffectValue* stickerModel = [self.categoryModel.models objectAtIndex:indexPath.item];
    DVEPickerBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self.UIConfig identifiedForModel:stickerModel] forIndexPath:indexPath];

    cell.model = stickerModel;
    
    if ([self.delegate respondsToSelector:@selector(pickerCollectionViewCell:isSelected:)]) {
        [cell setStickerSelected:[self.delegate pickerCollectionViewCell:self isSelected:stickerModel] animated:NO];
    }
    [cell updateShowStatus];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DVEEffectValue* sticker = [self.categoryModel.models objectAtIndex:indexPath.item];
    DVEPickerBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self.UIConfig identifiedForModel:sticker] forIndexPath:indexPath];
    if ([cell isKindOfClass:DVEPickerBaseCell.class]) {
        [self updateIconImageIfNeededWithSticker:sticker forCell:cell atIndexPath:indexPath];
        if ([self.delegate respondsToSelector:@selector(pickerCollectionViewCell:didSelect:category:indexPath:)]) {
            [self.delegate pickerCollectionViewCell:self didSelect:sticker category:self.categoryModel indexPath:indexPath];
        }
    }else{
        NSAssert([cell isKindOfClass:DVEPickerBaseCell.class], @"cell must be kind of DVEPickerBaseCell !!!");
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < self.categoryModel.models.count) {
        DVEEffectValue* effect = self.categoryModel.models[indexPath.item];
        if ([self.delegate respondsToSelector:@selector(pickerCollectionViewCell:willDisplay:indexPath:)]) {
            [self.delegate pickerCollectionViewCell:self willDisplay:effect indexPath:indexPath];
        }
    }
}

#pragma mark - Tips

- (void)showLoadingView {
    if ([self.UIConfig respondsToSelector:@selector(effectListLoadingView)]) {
        self.loadingView = [self.UIConfig effectListLoadingView];
    }
    [self.loadingView showOnView:self];
}

- (void)hideLoadingView {
    [self.loadingView dismiss];
    self.loadingView = nil;
}

- (void)showErrorView {
    if ([self.UIConfig respondsToSelector:@selector(effectListErrorView)]) {
        self.errorView = [self.UIConfig effectListErrorView];
        self.errorViewContainer = [[UIView alloc] init];
        [self.errorView showOnView:self.errorViewContainer];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onErrorTap)];
        [self.errorViewContainer addGestureRecognizer:tap];
    }
    [self addSubview:self.errorViewContainer];
    [self.errorViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)hideErrorView {
    [self.errorView dismiss];
    self.errorView = nil;
    [self.errorViewContainer removeFromSuperview];
    self.errorViewContainer = nil;
}

- (void)onErrorTap {
    [self hideErrorView];
    [self.categoryModel loadModelListIfNeeded];
}

- (void)showEmptyView {
    if ([self.UIConfig respondsToSelector:@selector(effectListEmptyView)]) {
        self.emptyView = [self.UIConfig effectListEmptyView];
    }
    [self addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)hideEmptyView {
    [self.emptyView dismiss];
    self.emptyView = nil;
}

@end
