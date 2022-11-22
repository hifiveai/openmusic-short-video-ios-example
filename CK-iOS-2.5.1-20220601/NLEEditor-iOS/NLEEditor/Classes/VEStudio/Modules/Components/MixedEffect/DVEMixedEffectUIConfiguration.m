//
//  DVEMixedEffectUIConfiguration.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/8.
//

#import "DVEMixedEffectUIConfiguration.h"
#import "DVEMixedEffectItem.h"
#import "DVEPickerCategoryBaseCell.h"
#import "DVEMacros.h"

@implementation DVEMixedEffectCategoryUIConfiguration

/// 清除特效按钮右侧分割线颜色
- (UIColor *)clearButtonSeparatorColor {
    return [UIColor clearColor];
}

/// 道具分类列表背景颜色
- (UIColor *)categoryTabListBackgroundColor {
    return [UIColor clearColor];
}

/// 分类底部分割线颜色
- (UIColor *)categoryTabListBottomBorderColor {
    return [UIColor clearColor];
}

/// 道具分类列表视图高度
- (CGFloat)categoryTabListViewHeight {
    return 0;
}

- (UIImage *)clearEffectButtonImage {
    return nil;
}

/// 分类列表 cell 类型，必须继承 DVEPickerCategoryBaseCell
- (Class)categoryItemCellClass {
    return [DVEPickerCategoryBaseCell class];
}

@end

@implementation DVEMixedEffectPickerUIConfiguration

/// 道具列表背景颜色
- (UIColor *)effectListViewBackgroundColor {
    return HEXRGBCOLOR(0x181718);
}

/// 道具列表视图高度
- (CGFloat)effectListViewHeight {
    return 75;
}

/// 道具item cell 的identified和类型, cell必须继承 DVEPickerBaseCell
- (NSDictionary<NSString*,Class> *)stickerItemCellKeyClass {
    return @{NSStringFromClass([DVEMixedEffectItem class]) : [DVEMixedEffectItem class]};
}

///根据model返回Cell的identified
- (NSString *_Nonnull)identifiedForModel:(DVEEffectValue*_Nonnull)model {
    return NSStringFromClass([DVEMixedEffectItem class]);
}

/// 道具 cell 布局配置
- (UICollectionViewLayout *)stickerListViewLayout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(52, 75);
    layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
    layout.minimumInteritemSpacing = 15;
    layout.minimumLineSpacing = 15;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    return layout;
}

/// 道具列表 loading 视图
- (nullable UIView<DVEPickerEffectOverlayProtocol> *)effectListLoadingView {
    return nil;
}

/// 道具列表错误提醒视图
- (nullable UIView<DVEPickerEffectErrorViewProtocol> *)effectListErrorView {
    return nil;
}
/// 道具空视图
- (nullable UIView<DVEPickerEffectOverlayProtocol> *)effectListEmptyView {
    return nil;
}

@end

@interface DVEMixedEffectUIConfiguration ()

@property (nonatomic, strong) id<DVEPickerEffectUIConfigurationProtocol> effectUIConfig;

@property (nonatomic, strong) id<DVEPickerCategoryUIConfigurationProtocol> categoryUIConfig;

@end

@implementation DVEMixedEffectUIConfiguration

- (id<DVEPickerEffectUIConfigurationProtocol>)effectUIConfig {
    if (!_effectUIConfig) {
        _effectUIConfig = [[DVEMixedEffectPickerUIConfiguration alloc] init];
    }
    return _effectUIConfig;
}

- (id<DVEPickerCategoryUIConfigurationProtocol>)categoryUIConfig {
    if (!_categoryUIConfig) {
        _categoryUIConfig = [[DVEMixedEffectCategoryUIConfiguration alloc] init];
    }
    return _categoryUIConfig;
}

@end
