//
//   DVEAnimationPickerUIDefaultConfiguration.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/12.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEAnimationPickerUIDefaultConfiguration.h"
#import "DVETextTemplatePickerCategoryCell.h"
#import "DVEAnimationItemCell.h"
#import "DVEMacros.h"

@interface DVEAnimationPickerUIDefaultConfiguration()

@property (nonatomic, strong) id<DVEPickerCategoryUIConfigurationProtocol> categoryConfig;

@property (nonatomic, strong) id<DVEPickerEffectUIConfigurationProtocol> contentConfig;

@end

@implementation DVEAnimationPickerUIDefaultConfiguration

- (id<DVEPickerCategoryUIConfigurationProtocol>)categoryUIConfig {
    if (!_categoryConfig) {
        _categoryConfig = [DVEAnimationPickerUIDefaultCategoryConfiguration new];
    }
    return _categoryConfig;
}

- (id<DVEPickerEffectUIConfigurationProtocol>)effectUIConfig {
    if (!_contentConfig) {
        _contentConfig = [DVEAnimationPickerUIDefaultContentConfiguration new];
    }
    return _contentConfig;
}

@end


@implementation DVEAnimationPickerUIDefaultCategoryConfiguration

/// 清除特效按钮右侧分割线颜色
- (UIColor *)clearButtonSeparatorColor {
    return [UIColor whiteColor];
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
    return DVEPickerCategoryBaseCell.class;
}

- (CGSize)stickerPickerCategoryTabView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
                sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeZero;
}

@end

@implementation DVEAnimationPickerUIDefaultContentConfiguration

/// 道具列表背景颜色
- (UIColor *)effectListViewBackgroundColor {
    return [UIColor clearColor];
}

/// 道具列表视图高度
- (CGFloat)effectListViewHeight {
    return 74;
}

/// 道具item cell 的identified和类型, cell必须继承 DVEPickerBaseCell
- (NSDictionary<NSString*,Class> *)stickerItemCellKeyClass {
    return @{NSStringFromClass(DVEAnimationItemCell.class):DVEAnimationItemCell.class};
}

///根据model返回Cell的identified
- (NSString *)identifiedForModel:(DVEEffectValue*)model {
    return NSStringFromClass(DVEAnimationItemCell.class);
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


