//
//  DVETextReaderPickerUIDefaultConfiguration.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/27.
//

#import "DVETextReaderPickerUIDefaultConfiguration.h"
#import "DVETextReaderEffectCell.h"
#import "DVEPickerCategoryBaseCell.h"
#import "DVEMacros.h"

@interface DVETextReaderPickerUIDefaultConfiguration()

@property (nonatomic, strong) id<DVEPickerCategoryUIConfigurationProtocol> categoryConfig;

@property (nonatomic, strong) id<DVEPickerEffectUIConfigurationProtocol> contentConfig;

@end

@implementation DVETextReaderPickerUIDefaultConfiguration

- (id<DVEPickerCategoryUIConfigurationProtocol>)categoryUIConfig {
    if (!_categoryConfig) {
        _categoryConfig = [DVETextReaderPickerUIDefaultCategoryConfiguration new];
    }
    return _categoryConfig;
}

- (id<DVEPickerEffectUIConfigurationProtocol>)effectUIConfig {
    if (!_contentConfig) {
        _contentConfig = [DVETextReaderPickerUIDefaultContentConfiguration new];
    }
    return _contentConfig;
}

@end



@implementation DVETextReaderPickerUIDefaultCategoryConfiguration


/// 清除特效按钮右侧分割线颜色
- (UIColor *)clearButtonSeparatorColor {
    return [UIColor clearColor];
}

/// 道具分类列表背景颜色
- (UIColor *)categoryTabListBackgroundColor {
    return colorWithHex(0x181718);
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

@implementation DVETextReaderPickerUIDefaultContentConfiguration

/// 道具列表背景颜色
- (UIColor *)effectListViewBackgroundColor {
    return colorWithHex(0x181718);
}

/// 道具列表视图高度
- (CGFloat)effectListViewHeight {
    return 80;
}

/// 道具item cell 的identified和类型, cell必须继承 DVEPickerBaseCell
- (NSDictionary<NSString*,Class> *)stickerItemCellKeyClass {
    return @{NSStringFromClass(DVETextReaderEffectCell.class):DVETextReaderEffectCell.class};
}

///根据model返回Cell的identified
- (NSString *)identifiedForModel:(DVEEffectValue*)model {
    return NSStringFromClass(DVETextReaderEffectCell.class);
}

/// 道具 cell 布局配置
- (UICollectionViewLayout *)stickerListViewLayout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(62, 62);
    layout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    return layout;
}

@end
