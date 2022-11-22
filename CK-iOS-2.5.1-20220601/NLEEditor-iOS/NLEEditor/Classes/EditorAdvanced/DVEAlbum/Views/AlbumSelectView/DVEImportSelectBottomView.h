//
//  DVEImportSelectBottomView.h
//  CutSameIF
//
//  Created by bytedance on 2020/3/13.
//

#import <UIKit/UIKit.h>
#import "DVESelectedAssetsBottomViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEImportSelectBottomView : UIView//<DVESelectedAssetsBottomViewProtocol>

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *nextButton;

- (void)updateNextButtonWithStatus:(BOOL)enable;

@end

@interface DVEImportMaterialSelectBottomView: DVEImportSelectBottomView

//@property (nonatomic, strong) UIButton *addButton;

@end

NS_ASSUME_NONNULL_END
