//
//  DVESubtitleAlertView.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/18.
//

#import <UIKit/UIKit.h>
#import "DVESelectBox.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVESubtitleAlertView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong, readonly) DVESelectBox *clearSubtitleButton;
@property (nonatomic, strong, readonly) UIButton *confirmButton;
@property (nonatomic, strong, readonly) UIButton *cancelButton;

@end

NS_ASSUME_NONNULL_END
