//
//  DVEUIHelper.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEUIHelper.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEMacros.h"

#define DT_IS_IPHONEX_XS   (VE_SCREEN_HEIGHT == 812.f)//是否是iPhoneX、iPhoneXS

#define DT_IS_IPHONEX_PRO   (VE_SCREEN_HEIGHT == 844.f)//是否是iPhoneXPro

#define DT_IS_IPHONEXR_XSMax   (VE_SCREEN_HEIGHT == 896.f)//是否是iPhoneXR、iPhoneX Max

#define IS_IPHONEX_SET  (DT_IS_IPHONEX_XS||DT_IS_IPHONEXR_XSMax||DT_IS_IPHONEX_PRO)//是否是iPhoneX系列手机

#define State_Bar_H ((![[UIApplication sharedApplication] isStatusBarHidden] ) ? [[UIApplication sharedApplication] statusBarFrame].size.height : (IS_IPHONEX_SET?44.f:20.f))


@interface DVEUIHelper ()

@property (nonatomic, strong) UINavigationController *vc;

@end

@implementation DVEUIHelper

+(CGFloat)topBarMargn {
    return [DVEUIHelper topBarMargn:[UIView currentViewController].navigationController];
}

+(CGFloat)topBarMargn:(UINavigationController*) nav {
    CGFloat topBarMargn = State_Bar_H;
    if(nav != nil && [nav.navigationBar isHidden] == NO){
        topBarMargn += nav.navigationBar.height;
    }
    return topBarMargn;
}

@end
