//
//  DVEPickerBaseCell.h
//  CameraClient
//
//  Created by bytedance on 2020/7/26.
//

#import <UIKit/UIKit.h>
#import "DVEPickerViewModels.h"

NS_ASSUME_NONNULL_BEGIN

// The DVEPickerBaseCell class is provided as an abstract class for subclassing to define custom collection cell.
@interface DVEPickerBaseCell : UICollectionViewCell

// Override these methods to provide custom UI for a selected or highlighted state
@property (nonatomic, strong, nullable) DVEEffectValue* model;
@property (nonatomic, assign, readonly) BOOL stickerSelected;

- (void)setStickerSelected:(BOOL)stickerSelected animated:(BOOL)animated NS_REQUIRES_SUPER;

- (void)updateStickerIconImage;

- (void)updateShowStatus;

- (UIView *)downloadView;

- (UIView *)downloadingView;

- (UIView *)downloadFailView;


@end

NS_ASSUME_NONNULL_END
