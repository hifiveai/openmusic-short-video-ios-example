//
//  DVEUIHelper.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//判断是否为iPhone X
#define DVEIPHONE_X \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

#define VETopMargn ([DVEUIHelper topBarMargn] + 10)
#define VEBottomMargn (DVEIPHONE_X?(34):(0))
#define VETopMargnValue 28.0
#define VEBottomMargnValue 34.0


@interface DVEUIHelper : NSObject


+(CGFloat)topBarMargn;

+(CGFloat)topBarMargn:(UINavigationController*) nav ;

@end

NS_ASSUME_NONNULL_END
