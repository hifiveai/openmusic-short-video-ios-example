//
//  DVETextTemplatePickerUIConfiguration.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/28.
//

#import "DVETextTemplatePickerUIConfiguration.h"
#import "DVETextTemplatePickerCell.h"
#import "DVETextTemplatePickerCategoryCell.h"
#import "DVEMacros.h"

@implementation DVETextTemplatePickerCategoryUIConfiguration

- (nonnull Class)categoryItemCellClass {
    return DVETextTemplatePickerCategoryCell.class;
}

- (nonnull UIColor *)categoryTabListBackgroundColor {
    return HEXRGBCOLOR(0x020503);
}

- (nonnull UIColor *)categoryTabListBottomBorderColor {
    return [UIColor clearColor];
}

- (CGFloat)categoryTabListViewHeight {
    return 40;
}

- (nonnull UIColor *)clearButtonSeparatorColor {
    return [UIColor whiteColor];
}

- (nonnull UIImage *)clearEffectButtonImage {
    return @"icon_sticker_clear".dve_toImage;
}

- (CGSize)stickerPickerCategoryTabView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
                sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(64, CGRectGetHeight(collectionView.frame));
}

@end

@implementation DVETextTemplatePickerEffectUIConfiguration

- (nonnull UIColor *)effectListViewBackgroundColor {
    return HEXRGBACOLOR(0x0, 0.95);
}

- (CGFloat)effectListViewHeight {
    return 214;
}

- (NSString * _Nonnull)identifiedForModel:(DVEEffectValue * _Nonnull)model {
    return NSStringFromClass(DVETextTemplatePickerCell.class);
}

- (nonnull NSDictionary<NSString *,Class> *)stickerItemCellKeyClass {
    return @{NSStringFromClass(DVETextTemplatePickerCell.class):DVETextTemplatePickerCell.class};
}

- (nonnull UICollectionViewLayout *)stickerListViewLayout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(56, 56);
    layout.sectionInset = UIEdgeInsetsMake(16, 20, 16, 20);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 40;
    layout.minimumInteritemSpacing = 20;
    return layout;
}

@end

@interface DVETextTemplatePickerUIConfiguration ()
@property (nonatomic, strong) id<DVEPickerCategoryUIConfigurationProtocol> categoryConfig;

@property (nonatomic, strong) id<DVEPickerEffectUIConfigurationProtocol> contentConfig;

@end

@implementation DVETextTemplatePickerUIConfiguration

- (id<DVEPickerCategoryUIConfigurationProtocol>)categoryUIConfig {
    if (!_categoryConfig) {
        _categoryConfig = [DVETextTemplatePickerCategoryUIConfiguration new];
    }
    return _categoryConfig;
}

- (id<DVEPickerEffectUIConfigurationProtocol>)effectUIConfig {
    if (!_contentConfig) {
        _contentConfig = [DVETextTemplatePickerEffectUIConfiguration new];
    }
    return _contentConfig;
}

@end
