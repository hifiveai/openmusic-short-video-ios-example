//
//   DVEEffectsPickerUIDefaultConfiguration.m
//   NLEEditor
//
//   Created  by bytedance on 2021/4/12.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEEffectsPickerUIDefaultConfiguration.h"
#import "DVETextTemplatePickerCategoryCell.h"
#import "DVEEffectsItemCell.h"
#import "DVEMacros.h"

@implementation DVEEffectsPickerUIDefaultCategoryConfiguration

/// 清除特效按钮右侧分割线颜色
- (UIColor *)clearButtonSeparatorColor {
    return [UIColor whiteColor];
}

/// 道具分类列表背景颜色
- (UIColor *)categoryTabListBackgroundColor {
    return HEXRGBCOLOR(0x020503);
}

/// 分类底部分割线颜色
- (UIColor *)categoryTabListBottomBorderColor {
    return [UIColor clearColor];
}

/// 道具分类列表视图高度
- (CGFloat)categoryTabListViewHeight {
    return 40;
}

- (UIImage *)clearEffectButtonImage {
    return @"icon_sticker_clear".dve_toImage;
}

/// 分类列表 cell 类型，必须继承 DVEPickerCategoryBaseCell
- (Class)categoryItemCellClass {
    return DVETextTemplatePickerCategoryCell.class;
}

- (CGSize)stickerPickerCategoryTabView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
                sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(64, CGRectGetHeight(collectionView.frame));
}

@end

@implementation DVEEffectsPickerUIDefaultContentConfiguration

/// 道具列表背景颜色
- (UIColor *)effectListViewBackgroundColor {
    return HEXRGBACOLOR(0x0, 0.95);
}

/// 道具列表视图高度
- (CGFloat)effectListViewHeight {
    return 214;
}

/// 道具item cell 的identified和类型, cell必须继承 DVEPickerBaseCell
- (NSDictionary<NSString*,Class> *)stickerItemCellKeyClass {
    return @{NSStringFromClass(DVEEffectsItemCell.class):DVEEffectsItemCell.class};
}

///根据model返回Cell的identified
- (NSString *)identifiedForModel:(DVEEffectValue*)model {
    return NSStringFromClass(DVEEffectsItemCell.class);
}

/// 道具 cell 布局配置
- (UICollectionViewLayout *)stickerListViewLayout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(51, 67);
    layout.sectionInset = UIEdgeInsetsMake(16, 16, 16,16);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 25;
    return layout;
}
@end

@interface DVEEffectsPickerUIDefaultConfiguration()

@property (nonatomic, strong) id<DVEPickerCategoryUIConfigurationProtocol> categoryConfig;

@property (nonatomic, strong) id<DVEPickerEffectUIConfigurationProtocol> contentConfig;

@end

@implementation DVEEffectsPickerUIDefaultConfiguration

- (id<DVEPickerCategoryUIConfigurationProtocol>)categoryUIConfig {
    if (!_categoryConfig) {
        _categoryConfig = [DVEEffectsPickerUIDefaultCategoryConfiguration new];
    }
    return _categoryConfig;
}

- (id<DVEPickerEffectUIConfigurationProtocol>)effectUIConfig {
    if (!_contentConfig) {
        _contentConfig = [DVEEffectsPickerUIDefaultContentConfiguration new];
    }
    return _contentConfig;
}
@end
