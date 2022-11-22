//
//   DVETransitionUIConfiguration.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/25.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVETransitionPickerUIConfiguration.h"
#import "DVEPickerCategoryBaseCell.h"
#import "DVETransitionItem.h"
#import "DVEMacros.h"

@implementation DVETransitionPickerUIDefaultCategoryConfiguration
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

@implementation DVETransitionPickerUIDefaultContentConfiguration
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
    return @{NSStringFromClass([DVETransitionItem class]) : [DVETransitionItem class]};
}

///根据model返回Cell的identified
- (NSString *_Nonnull)identifiedForModel:(DVEEffectValue*_Nonnull)model {
    return NSStringFromClass([DVETransitionItem class]);
}

/// 道具 cell 布局配置
- (UICollectionViewLayout *)stickerListViewLayout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(60, 74);
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0,0);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 15;
    return layout;
}
@end

@interface DVETransitionPickerUIDefaultConfiguration()

@property (nonatomic, strong) id<DVEPickerEffectUIConfigurationProtocol> effectUIConfig;

@property (nonatomic, strong) id<DVEPickerCategoryUIConfigurationProtocol> categoryUIConfig;
@end

@implementation DVETransitionPickerUIDefaultConfiguration

- (id<DVEPickerEffectUIConfigurationProtocol>)effectUIConfig {
    if (!_effectUIConfig) {
        _effectUIConfig = [[DVETransitionPickerUIDefaultContentConfiguration alloc] init];
    }
    return _effectUIConfig;
}

- (id<DVEPickerCategoryUIConfigurationProtocol>)categoryUIConfig {
    if (!_categoryUIConfig) {
        _categoryUIConfig = [[DVETransitionPickerUIDefaultCategoryConfiguration alloc] init];
    }
    return _categoryUIConfig;
}

@end




