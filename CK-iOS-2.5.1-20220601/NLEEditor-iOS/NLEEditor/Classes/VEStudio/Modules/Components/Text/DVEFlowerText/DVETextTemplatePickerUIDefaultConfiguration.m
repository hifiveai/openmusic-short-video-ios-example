//
//  DVETextTemplatePickerUIDefaultConfiguration.m
//  NLEEditor
//
//  Created by bytedance on 2021/4/9.
//

#import "DVETextTemplatePickerUIDefaultConfiguration.h"
#import "DVETextTemplatePickerCategoryCell.h"
#import "DVBTextTemplatePickerCell.h"
#import "DVEFlowerTextClearCell.h"
#import "NSString+VEToImage.h"

@implementation DVETextTemplatePickerUIDefaultCategoryConfiguration

/// 清除特效按钮右侧分割线颜色
- (UIColor *)clearButtonSeparatorColor {
    return [UIColor clearColor];
}

/// 道具分类列表背景颜色
- (UIColor *)categoryTabListBackgroundColor {
    return [UIColor colorWithWhite:0 alpha:0.6];
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
    return @"iconFilterwu".dve_toImage;
}

/// 分类列表 cell 类型，必须继承 DVEPickerCategoryBaseCell
- (Class)categoryItemCellClass {
    return DVETextTemplatePickerCategoryCell.class;
}

@end

@implementation DVETextTemplatePickerUIDefaultContentConfiguration

/// 道具列表背景颜色
- (UIColor *)effectListViewBackgroundColor {
    return [UIColor blackColor];
}

/// 道具列表视图高度
- (CGFloat)effectListViewHeight {
    return 253;
}

/// 道具item cell 的identified和类型, cell必须继承 DVEPickerBaseCell
- (NSDictionary<NSString*,Class> *)stickerItemCellKeyClass {
    return @{
        NSStringFromClass(DVBTextTemplatePickerCell.class) : DVBTextTemplatePickerCell.class,
        NSStringFromClass(DVEFlowerTextClearCell.class) : DVEFlowerTextClearCell.class
    };
}

- (NSString *_Nonnull)identifiedForModel:(DVEEffectValue* _Nonnull)model {

    if (model.valueState == VEEffectValueStateShuntDown) {
        return NSStringFromClass(DVEFlowerTextClearCell.class);;
    }
    return NSStringFromClass(DVBTextTemplatePickerCell.class);
}

/// 道具 cell 布局配置
- (UICollectionViewLayout *)stickerListViewLayout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(50, 50); // 74 for icon height, 14 for prop name label height;
    layout.sectionInset = UIEdgeInsetsMake(20, 20, 38, 20);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 32;
    layout.minimumInteritemSpacing = 32;
    return layout;
}


@end

@interface DVETextTemplatePickerUIDefaultConfiguration ()

@property (nonatomic, strong) id<DVEPickerCategoryUIConfigurationProtocol> categoryConfig;

@property (nonatomic, strong) id<DVEPickerEffectUIConfigurationProtocol> contentConfig;

@end

@implementation DVETextTemplatePickerUIDefaultConfiguration

- (id<DVEPickerCategoryUIConfigurationProtocol>)categoryUIConfig {
    if (!_categoryConfig) {
        _categoryConfig = [DVETextTemplatePickerUIDefaultCategoryConfiguration new];
    }
    return _categoryConfig;
}

- (id<DVEPickerEffectUIConfigurationProtocol>)effectUIConfig {
    if (!_contentConfig) {
        _contentConfig = [DVETextTemplatePickerUIDefaultContentConfiguration new];
    }
    return _contentConfig;
}

@end
