//
//  DVECanvasUIConfiguration.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/1.
//

#import "DVECanvasUIConfiguration.h"
#import "DVEMacros.h"
#import "DVECanvasStyleItem.h"
#import "DVECanvasColorItem.h"
#import "DVECanvasBlurItem.h"
#import "DVEPickerCategoryBaseCell.h"
#import "DVELoadingView.h"

@implementation DVECanvasColorCategoryUIConfiguration

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

@implementation DVECanvasColorItemUIConfiguration

/// 道具列表背景颜色
- (UIColor *)effectListViewBackgroundColor {
    return HEXRGBCOLOR(0x181718);
}

/// 道具列表视图高度
- (CGFloat)effectListViewHeight {
    return 20;
}

/// 道具item cell 的identified和类型, cell必须继承 DVEPickerBaseCell
- (NSDictionary<NSString*,Class> *)stickerItemCellKeyClass {
    return @{NSStringFromClass([DVECanvasColorItem class]) : [DVECanvasColorItem class]};
}

///根据model返回Cell的identified
- (NSString *_Nonnull)identifiedForModel:(DVEEffectValue*_Nonnull)model {
    return NSStringFromClass([DVECanvasColorItem class]);
}

/// 道具 cell 布局配置
- (UICollectionViewLayout *)stickerListViewLayout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(20, 20);
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    layout.minimumInteritemSpacing = 20;
    layout.minimumLineSpacing = 20;
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

@interface DVECanvasColorUIConfiguration ()

@property (nonatomic, strong) id<DVEPickerEffectUIConfigurationProtocol> effectUIConfig;

@property (nonatomic, strong) id<DVEPickerCategoryUIConfigurationProtocol> categoryUIConfig;

@end

@implementation DVECanvasColorUIConfiguration

- (id<DVEPickerEffectUIConfigurationProtocol>)effectUIConfig {
    if (!_effectUIConfig) {
        _effectUIConfig = [[DVECanvasColorItemUIConfiguration alloc] init];
    }
    return _effectUIConfig;
}

- (id<DVEPickerCategoryUIConfigurationProtocol>)categoryUIConfig {
    if (!_categoryUIConfig) {
        _categoryUIConfig = [[DVECanvasColorCategoryUIConfiguration alloc] init];
    }
    return _categoryUIConfig;
}

@end


@implementation DVECanvasStyleCategoryUIConfiguration

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

@implementation DVECanvasStyleItemUIConfiguration

/// 道具列表背景颜色
- (UIColor *)effectListViewBackgroundColor {
    return HEXRGBCOLOR(0x181718);
}

/// 道具列表视图高度
- (CGFloat)effectListViewHeight {
    return 62;
}

/// 道具item cell 的identified和类型, cell必须继承 DVEPickerBaseCell
- (NSDictionary<NSString*,Class> *)stickerItemCellKeyClass {
    return @{NSStringFromClass([DVECanvasStyleItem class]) : [DVECanvasStyleItem class]};
}

///根据model返回Cell的identified
- (NSString *_Nonnull)identifiedForModel:(DVEEffectValue*_Nonnull)model {
    return NSStringFromClass([DVECanvasStyleItem class]);
}

/// 道具 cell 布局配置
- (UICollectionViewLayout *)stickerListViewLayout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(56, 56);
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

@interface DVECanvasStyleUIConfiguration ()

@property (nonatomic, strong) id<DVEPickerEffectUIConfigurationProtocol> effectUIConfig;

@property (nonatomic, strong) id<DVEPickerCategoryUIConfigurationProtocol> categoryUIConfig;

@property (nonatomic, strong) DVELoadingView *loadingView;

@end

@implementation DVECanvasStyleUIConfiguration

- (id<DVEPickerEffectUIConfigurationProtocol>)effectUIConfig {
    if (!_effectUIConfig) {
        _effectUIConfig = [[DVECanvasStyleItemUIConfiguration alloc] init];
    }
    return _effectUIConfig;
}

- (id<DVEPickerCategoryUIConfigurationProtocol>)categoryUIConfig {
    if (!_categoryUIConfig) {
        _categoryUIConfig = [[DVECanvasStyleCategoryUIConfiguration alloc] init];
    }
    return _categoryUIConfig;
}

- (UIView<DVEPickerEffectOverlayProtocol> *)panelLoadingView {
    if (!_loadingView) {
        _loadingView = [[DVELoadingView alloc] init];
    }
    return _loadingView;
}


@end

@implementation DVECanvasBlurCategoryUIConfiguration

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

@implementation DVECanvasBlurItemUIConfiguration

/// 道具列表背景颜色
- (UIColor *)effectListViewBackgroundColor {
    return HEXRGBCOLOR(0x181718);
}

/// 道具列表视图高度
- (CGFloat)effectListViewHeight {
    return 56;
}

/// 道具item cell 的identified和类型, cell必须继承 DVEPickerBaseCell
- (NSDictionary<NSString*,Class> *)stickerItemCellKeyClass {
    return @{NSStringFromClass([DVECanvasBlurItem class]) : [DVECanvasBlurItem class]};
}

///根据model返回Cell的identified
- (NSString *_Nonnull)identifiedForModel:(DVEEffectValue*_Nonnull)model {
    return NSStringFromClass([DVECanvasBlurItem class]);
}

/// 道具 cell 布局配置
- (UICollectionViewLayout *)stickerListViewLayout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(56, 56);
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

@interface DVECanvasBlurUIConfiguration ()

@property (nonatomic, strong) id<DVEPickerEffectUIConfigurationProtocol> effectUIConfig;

@property (nonatomic, strong) id<DVEPickerCategoryUIConfigurationProtocol> categoryUIConfig;

@end

@implementation DVECanvasBlurUIConfiguration

- (id<DVEPickerEffectUIConfigurationProtocol>)effectUIConfig {
    if (!_effectUIConfig) {
        _effectUIConfig = [[DVECanvasBlurItemUIConfiguration alloc] init];
    }
    return _effectUIConfig;
}

- (id<DVEPickerCategoryUIConfigurationProtocol>)categoryUIConfig {
    if (!_categoryUIConfig) {
        _categoryUIConfig = [[DVECanvasBlurCategoryUIConfiguration alloc] init];
    }
    return _categoryUIConfig;
}

@end
