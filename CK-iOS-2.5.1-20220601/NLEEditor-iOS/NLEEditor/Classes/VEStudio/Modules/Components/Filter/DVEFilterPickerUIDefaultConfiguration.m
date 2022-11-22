//
//   DVEFilterPickerUIDefaultConfiguration.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/8.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEFilterPickerUIDefaultConfiguration.h"
#import "DVEFilterItemCell.h"
#import "DVEPickerCategoryBaseCell.h"
#import "DVEMacros.h"

@interface DVEFilterPickerUIDefaultConfiguration()

@property (nonatomic, strong) id<DVEPickerCategoryUIConfigurationProtocol> categoryConfig;

@property (nonatomic, strong) id<DVEPickerEffectUIConfigurationProtocol> contentConfig;

@end

@implementation DVEFilterPickerUIDefaultConfiguration

- (id<DVEPickerCategoryUIConfigurationProtocol>)categoryUIConfig {
    if (!_categoryConfig) {
        _categoryConfig = [DVEFilterPickerUIDefaultCategoryConfiguration new];
    }
    return _categoryConfig;
}

- (id<DVEPickerEffectUIConfigurationProtocol>)effectUIConfig {
    if (!_contentConfig) {
        _contentConfig = [DVEFilterPickerUIDefaultContentConfiguration new];
    }
    return _contentConfig;
}

@end



@implementation DVEFilterPickerUIDefaultCategoryConfiguration


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

@implementation DVEFilterPickerUIDefaultContentConfiguration

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
    return @{NSStringFromClass(DVEFilterItemCell.class):DVEFilterItemCell.class};
}

///根据model返回Cell的identified
- (NSString *)identifiedForModel:(DVEEffectValue*)model {
    return NSStringFromClass(DVEFilterItemCell.class);
}

/// 道具 cell 布局配置
- (UICollectionViewLayout *)stickerListViewLayout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(50, 74);
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0,0);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 15;
    layout.minimumInteritemSpacing = 15;
    return layout;
}

@end
