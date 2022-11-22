//
//  DemoTool.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#ifndef VEDemoTool_h
#define vEDemoTool_h


#define iPhoneX ({\
BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
    if (!UIEdgeInsetsEqualToEdgeInsets([UIApplication sharedApplication].delegate.window.safeAreaInsets, UIEdgeInsetsZero)) {\
    isPhoneX = YES;\
    }\
}\
isPhoneX;\
})

#define kSafeAreaHeight  (iPhoneX ? 24 : 0)
#define kStatusBarHeight (kSafeAreaHeight + 20)
#define kNaviBarHeight   (kStatusBarHeight + 44)
#define kHomeIndicator   (iPhoneX ? 34 : 0)
#define kTabBarHeigth    (49 + kHomeIndicator)


#define kScreenWidth  UIScreen.mainScreen.bounds.size.width
#define kScreenHeight UIScreen.mainScreen.bounds.size.height

#endif /* DemoTool_h */
