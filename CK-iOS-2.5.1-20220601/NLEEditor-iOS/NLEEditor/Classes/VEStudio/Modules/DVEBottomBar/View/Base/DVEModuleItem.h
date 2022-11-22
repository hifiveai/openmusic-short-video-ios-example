//
//  DVEModuleItem.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VEVCModuleItemType) {
    VEVCModuleItemTypeNone = 0,
    VEVCModuleItemTypeCut,
    VEVCModuleItemTypeCanvase,
    VEVCModuleItemTypeAudio,
    VEVCModuleItemTypeSticker,
    VEVCModuleItemTypeText,
    VEVCModuleItemTypeFilter,
    VEVCModuleItemTypeTiaojie,
    VEVCModuleItemTypePicInPic,
    VEVCModuleItemTypeCover,
};

@interface DVEModuleItem : UICollectionViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) VEVCModuleItemType type;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLable;

- (void)setIndex:(NSIndexPath *)indexPath ForType:(VEVCModuleItemType)type;

@end

NS_ASSUME_NONNULL_END
