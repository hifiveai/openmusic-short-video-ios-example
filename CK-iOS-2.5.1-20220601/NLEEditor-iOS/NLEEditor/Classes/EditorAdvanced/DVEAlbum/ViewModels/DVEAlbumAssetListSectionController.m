//
//  DVEAlbumAssetListSectionController.m
//  CameraClient
//
//  Created by bytedance on 2020/6/23.
//

#import "DVEAlbumAssetListSectionController.h"
#import "DVEAlbumAssetListCell.h"
#import "DVEAlbumMacros.h"
#import "DVEAlbumResourceUnion.h"

static NSInteger const kHeaderViewTag = 1000;
static NSInteger const kDVEAlbumListColumnCount = 4;
static CGFloat const kDVEAlbumListControllerMidMargin = 5;
CGFloat kDVEAlbumListSectionHeaderHeight = 48;

@interface DVEAlbumAssetListSectionController()<IGListDisplayDelegate, IGListSupplementaryViewSource>

@property (nonatomic, assign) NSInteger colCount;
@property (nonatomic, assign) CGSize aspectRatio;
@property (nonatomic, assign, readwrite) CGSize itemSize;

@property (nonatomic, weak) DVEAlbumViewModel *viewModel;
@property (nonatomic, assign) DVEAlbumGetResourceType resourceType;
@property (nonatomic, strong) DVEAlbumSectionModel *sectionModel;

@end

@implementation DVEAlbumAssetListSectionController

- (instancetype)initWithAlbumViewModel:(DVEAlbumViewModel *)viewModel resourceType:(DVEAlbumGetResourceType)resourceType
{
    self = [super init];
    if (self) {
        self.colCount = kDVEAlbumListColumnCount;
        if (viewModel.albumViewUIConfig.columnNumber > 0) {
            self.colCount = viewModel.albumViewUIConfig.columnNumber;
        }
        self.aspectRatio = CGSizeZero;
        self.viewModel = viewModel;
        self.resourceType = resourceType;
        self.displayDelegate = self;
        self.supplementaryViewSource = self;
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    CGFloat width = floor(([self contentWidth] - (self.colCount - 1) * kDVEAlbumListControllerMidMargin) / self.colCount);
    CGFloat height = width;
    if (!CGSizeEqualToSize(self.aspectRatio, CGSizeZero) && self.aspectRatio.width > 0.0 && self.aspectRatio.height > 0.0) {
        height = width * self.aspectRatio.height / self.aspectRatio.width;
    }
    
    self.itemSize = CGSizeMake(width, height);
    self.minimumLineSpacing = ([self contentWidth] - width * self.colCount) / (self.colCount - 1);
    self.minimumInteritemSpacing = self.minimumLineSpacing;
}

- (CGFloat)contentWidth
{
    CGFloat contentWidth = TOC_SCREEN_WIDTH;
    if (self.viewModel.albumViewUIConfig) {
        contentWidth -= 2 * self.viewModel.albumViewUIConfig.horizontalInset;
    }
    return contentWidth;
}

- (NSInteger)itemsCount
{
    if (NO) {
        return [self.sectionModel.assetDataModel numberOfObject];
    } else {
        return self.sectionModel.assetsModels.count;
    }
}

- (DVEAlbumAssetModel *)assetModelForIndex:(NSInteger)index
{
    if (NO) {
        return [self.sectionModel.assetDataModel objectIndex:index];
    } else {
        if (index < self.sectionModel.assetsModels.count) {
            return [self.sectionModel.assetsModels objectAtIndex:index];
        } else {
            return nil;
        }
    }
}

#pragma mark - override

- (NSInteger)numberOfItems
{
    return [self itemsCount];
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index
{
    return self.itemSize;
}

- (DVEAlbumAssetListCell *)cellForItemAtIndex:(NSInteger)index
{
    DVEAlbumAssetListCell *cell = [self.collectionContext dequeueReusableCellOfClass:[DVEAlbumAssetListCell class] forSectionController:self atIndex:index];
    [cell updateSelectedButtonWithStatus:self.viewModel.inputData.maxPictureSelectionCount <= 1];
    cell.checkMarkSelectedStyle = self.viewModel.isCutSame || self.viewModel.isCutSameChangeMaterial;
    @weakify(self);
    cell.didSelectedAssetBlock = ^(DVEAlbumAssetListCell *selectedCell, BOOL isSelected) {
        @strongify(self);
        TOCBLOCK_INVOKE(self.didSelectedAssetBlock, selectedCell, isSelected);
    };
    cell.limitDuration = self.viewModel.inputData.cutSameTemplateModel.duration;
    
    if (index < [self itemsCount]) {
        DVEAlbumAssetModel *asset = [self assetModelForIndex:index];
        BOOL exceedMaxDuration = [self.viewModel isExceedMaxDurationForAIVideoClip:asset.asset.duration resourceType:self.resourceType];
        BOOL greyMode = self.viewModel.hasSelectedMaxCount || exceedMaxDuration;
        
        BOOL isSelected = [self isSelectedAsset:asset];

        [cell configureCellWithAsset:asset greyMode:greyMode showRightTopIcon:[self.viewModel canMutilSelectedWithResourceType:self.resourceType] alreadySelect:isSelected];
        
        if ((self.viewModel.inputData.defaultResourceType == DVEAlbumGetResourceTypeImage && asset.mediaType == DVEAlbumAssetModelMediaTypeVideo) || (self.viewModel.inputData.defaultResourceType == DVEAlbumGetResourceTypeVideo && asset.mediaType == DVEAlbumAssetModelMediaTypePhoto )) {
            asset.canSelect = NO;
        }
    }
    

    return cell;
}

- (void)didUpdateToObject:(id)object
{
    if ([object isKindOfClass:[DVEAlbumSectionModel class]]) {
        self.sectionModel = (DVEAlbumSectionModel *)object;
    }
}

- (void)didSelectItemAtIndex:(NSInteger)index
{
    if (index >= [self itemsCount]) {
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:self.section];
    DVEAlbumAssetListCell *cell = [self.collectionContext cellForItemAtIndex:index sectionController:self];
    cell.assetModel.cellIndex = index;
    if (!cell.assetModel.canSelect || ![cell isAssetsMatchLimitDurationWithAssetModel:cell.assetModel]) {
        return;
    }
    TOCBLOCK_INVOKE(self.didSelectedToPreviewBlock, cell.assetModel, [cell thumbnailImage]);
}

- (BOOL)isSelectedAsset:(DVEAlbumAssetModel *)asset
{
    for (DVEAlbumAssetModel *model in self.viewModel.inputData.initialSelectedAssetModelArray) {
        if ([model isEqualToAssetModel:asset identity:NO]) {
            asset.selectedAmount = model.selectedAmount;
            return YES;
        }
    }
    return NO;
}

#pragma mark - IGListDisplayDelegate

- (void)listAdapter:(nonnull IGListAdapter *)listAdapter didEndDisplayingSectionController:(nonnull IGListSectionController *)sectionController {
    
}

- (void)listAdapter:(nonnull IGListAdapter *)listAdapter didEndDisplayingSectionController:(nonnull IGListSectionController *)sectionController cell:(nonnull DVEAlbumAssetListCell *)cell atIndex:(NSInteger)index {

}

- (void)listAdapter:(nonnull IGListAdapter *)listAdapter willDisplaySectionController:(nonnull IGListSectionController *)sectionController {
    
}

- (void)listAdapter:(nonnull IGListAdapter *)listAdapter willDisplaySectionController:(nonnull IGListSectionController *)sectionController cell:(nonnull DVEAlbumAssetListCell *)cell atIndex:(NSInteger)index {
    if (index >= [self itemsCount]) {
        return;
    }
    
    DVEAlbumAssetModel *asset = [self assetModelForIndex:index];
    if (!asset.coverImage || asset.isDegraded) {
        BOOL exceedMaxDuration = [self.viewModel isExceedMaxDurationForAIVideoClip:asset.asset.duration resourceType:self.resourceType];
        BOOL greyMode = self.viewModel.hasSelectedMaxCount || exceedMaxDuration;
        BOOL isSelected = [self isSelectedAsset:asset];

        [cell configureCellWithAsset:asset greyMode:greyMode showRightTopIcon:[self.viewModel canMutilSelectedWithResourceType:self.resourceType] alreadySelect:isSelected];
    }

    [self.viewModel updateAssetModel:cell.assetModel];
    [cell updateSelectStatus];
}

#pragma mark - IGListSupplementaryViewSource

- (CGSize)sizeForSupplementaryViewOfKind:(nonnull NSString *)elementKind atIndex:(NSInteger)index
{
    if (self.viewModel.configViewModel.newStyle == DVEAlbumNewStyleTime ||
        self.viewModel.configViewModel.newStyle == DVEAlbumNewStyleTimeAndInteraction) {
        return CGSizeMake([self contentWidth], kDVEAlbumListSectionHeaderHeight);
    }
    
    return CGSizeZero;
}

- (nonnull NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}

- (nonnull __kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(nonnull NSString *)elementKind atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        Class headerClass = [UICollectionReusableView class];
        UICollectionReusableView *headerView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:headerClass atIndex:index];
        UILabel *timeLabel = [headerView viewWithTag:kHeaderViewTag];
        if (index < [self itemsCount]) {
            if (timeLabel) {
                timeLabel.text = @"";//[self assetModelForIndex:index].dateFormatStr;
            } else {
                timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 19, headerView.bounds.size.width - 30, 21)];
                timeLabel.tag = 1000;
                [headerView addSubview:timeLabel];
                timeLabel.text = @"";//[self assetModelForIndex:index].dateFormatStr;
                timeLabel.font = [UIFont systemFontOfSize:15.0];
                timeLabel.textColor = TOCResourceColor(TOCUIColorConstTextPrimary);//UIColorFromRGBA(0x222435, 1);
                if (@available(iOS 13.0, *)) {
                    timeLabel.textColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                        if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                            return TOCResourceColor(TOCUIColorConstTextInverse2);
                        } else {
                            return TOCResourceColor(TOCUIColorConstTextPrimary);
                        }
                    }];
                }
                
            }
        }
        return headerView;
    }
    return [[UICollectionReusableView alloc] init];
}

@end
