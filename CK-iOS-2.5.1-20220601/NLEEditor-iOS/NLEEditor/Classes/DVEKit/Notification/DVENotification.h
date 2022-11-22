//
//  DVENotification.h
//  NLEEditor
//
//  Created by bytedance on 2021/8/9.
//

#import <Foundation/Foundation.h>
#import "DVENotificationAlertView.h"
#import "DVENotificationCloseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVENotification : NSObject

+ (DVENotificationCloseView *)showTitle:(NSString *_Nullable)title message:(NSString *)message;

+ (DVENotificationAlertView *)showTitle:(NSString *_Nullable)title message:(NSString *)message leftAction:(NSString *)leftAction rightAction:(NSString *)rightAction;

@end

NS_ASSUME_NONNULL_END
