//
//   DVEStickerPickerUIDefaultConfiguration.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/20.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEStickerPickerUIDefaultConfiguration.h"
#import "DVEStickerCategoryCell.h"
#import "DVEStickerItem.h"
#import "DVEMacros.h"
#import <DVETrackKit/DVEUILayout.h>
#import "DVEModuleBaseErrorView.h"
#import "DVEModuleBaseOverlayView.h"

@implementation DVEStickerPickerUIDefaultCategoryConfiguration

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
    return 0;
}

- (UIImage *)clearEffectButtonImage {
    return nil;
}

/// 分类列表 cell 类型，必须继承 DVEPickerCategoryBaseCell
- (Class)categoryItemCellClass {
    return DVEPickerCategoryBaseCell.class;
}

- (CGSize)stickerPickerCategoryTabView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
                sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeZero;
}
@end

@implementation DVEStickerPickerUIDefaultContentConfiguration


/// 道具列表背景颜色
- (UIColor *)effectListViewBackgroundColor {
    return HEXRGBACOLOR(0x0, 0.95);
}

/// 道具列表视图高度
- (CGFloat)effectListViewHeight {
    return 253;
}

/// 道具item cell 的identified和类型, cell必须继承 DVEPickerBaseCell
- (NSDictionary<NSString*,Class> *)stickerItemCellKeyClass {
    return @{NSStringFromClass(DVEStickerItem.class):DVEStickerItem.class};
}

///根据model返回Cell的identified
- (NSString *)identifiedForModel:(DVEEffectValue*)model {
    return NSStringFromClass(DVEStickerItem.class);
}

/// 道具 cell 布局配置
- (UICollectionViewLayout *)stickerListViewLayout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = [DVEUILayout dve_sizeWithName:DVEUILayoutStickerItemSize];
    layout.sectionInset = [DVEUILayout dve_edgeInsetsWithName:DVEUILayoutStickerListPadding];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = [DVEUILayout dve_sizeNumberWithName:DVEUILayoutStickerListLineSpace];
    layout.minimumLineSpacing = layout.minimumInteritemSpacing;
    return layout;
}


/// 道具列表 loading 视图
- (nullable UIView<DVEPickerEffectOverlayProtocol> *)effectListLoadingView {

    return [DVEModuleBaseOverlayView new];
}

/// 道具列表错误提醒视图
- (nullable UIView<DVEPickerEffectErrorViewProtocol> *)effectListErrorView {
    return [DVEModuleBaseErrorView new];
}

/// 道具空视图
- (nullable UIView<DVEPickerEffectOverlayProtocol> *)effectListEmptyView {
    return [DVEModuleBaseOverlayView new];
}

@end

@interface DVEStickerPickerUIDefaultConfiguration()

@property (nonatomic, strong) id<DVEPickerCategoryUIConfigurationProtocol> categoryConfig;

@property (nonatomic, strong) id<DVEPickerEffectUIConfigurationProtocol> contentConfig;

@end

@implementation DVEStickerPickerUIDefaultConfiguration

- (id<DVEPickerCategoryUIConfigurationProtocol>)categoryUIConfig {
    if (!_categoryConfig) {
        _categoryConfig = [DVEStickerPickerUIDefaultCategoryConfiguration new];
    }
    return _categoryConfig;
}

- (id<DVEPickerEffectUIConfigurationProtocol>)effectUIConfig {
    if (!_contentConfig) {
        _contentConfig = [DVEStickerPickerUIDefaultContentConfiguration new];
    }
    return _contentConfig;
}

/// 道具面板的loading视图（覆盖分类、道具2个列表）
- (nullable UIView<DVEPickerEffectOverlayProtocol> *)panelLoadingView {
    return [DVEModuleBaseOverlayView new];
}

- (nullable UIView<DVEPickerEffectErrorViewProtocol> *)panelErrorView {
    return [DVEModuleBaseErrorView new];
}

- (nullable UIView<DVEPickerEffectOverlayProtocol> *)panelEmptyView {
    return [DVEModuleBaseOverlayView new];
}

@end
