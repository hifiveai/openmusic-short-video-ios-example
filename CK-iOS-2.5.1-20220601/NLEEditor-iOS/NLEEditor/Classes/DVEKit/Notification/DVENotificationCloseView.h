//
//  DVENotificationCloseView.h
//  NLEEditor
//
//  Created by bytedance on 2021/8/9.
//

#import <UIKit/UIKit.h>
#import "DVENotificationView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVENotificationCloseView : DVENotificationView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, copy) DVEActionBlock closeBlock;

@end

NS_ASSUME_NONNULL_END
