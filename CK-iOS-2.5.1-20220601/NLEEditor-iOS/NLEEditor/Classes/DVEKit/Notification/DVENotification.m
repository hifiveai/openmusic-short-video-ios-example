//
//  DVENotification.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/9.
//

#import "DVENotification.h"
#import <Masonry/Masonry.h>

@implementation DVENotification

+ (DVENotificationCloseView *)showTitle:(NSString *_Nullable)title message:(NSString *)message {
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if ([self isView:window containsSubview:DVENotificationCloseView.class]) {
        return nil;
    }
    DVENotificationCloseView *view = [DVENotificationCloseView new];
    view.titleLabel.text = title;
    view.messageLabel.text = message;
    [window addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(window);
    }];
    return view;
}

+ (DVENotificationAlertView *)showTitle:(NSString *_Nullable)title message:(NSString *)message leftAction:(NSString *)leftAction rightAction:(NSString *)rightAction {
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if ([self isView:window containsSubview:DVENotificationAlertView.class]) {
        return nil;
    }
    DVENotificationAlertView *view = [DVENotificationAlertView new];
    view.titleLabel.text = title;
    view.messageLabel.text = message;
    view.leftAction.titleLabel.text = leftAction;
    view.rightAction.titleLabel.text = rightAction;
    [window addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(window);
    }];
    return view;
}
+ (BOOL)isView:(UIView *)view containsSubview:(Class)aClass {
    for (UIView *sub in view.subviews) {
        if ([sub isKindOfClass:aClass]) {
            return YES;
        }
    }
    return NO;
}
@end
