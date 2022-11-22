//
//  DVENotificationAlertView.h
//  NLEEditor
//
//  Created by bytedance on 2021/8/9.
//

#import <UIKit/UIKit.h>
#import "DVENotificationView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVENotificationAlertView : DVENotificationView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) DVENotificationAction *leftAction;
@property (nonatomic, strong) DVENotificationAction *rightAction;

@property (nonatomic, copy) DVEActionBlock leftActionBlock;
@property (nonatomic, copy) DVEActionBlock rightActionBlock;

@end

NS_ASSUME_NONNULL_END
