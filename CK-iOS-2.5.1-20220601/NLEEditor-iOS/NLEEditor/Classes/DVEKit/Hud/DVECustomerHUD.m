//
//  DVECustomerHUD.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVECustomerHUD.h"
#import "DVEHUDCustomerView.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEMacros.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <Lottie/LOTAnimationView.h>

#define DVECustomerHUDTag (76452)

@interface DVECustomerHUD ()

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation DVECustomerHUD

+ (void)showMessage:(NSString *)msg
{
    [self showMessage:msg afterDele:3];
}

+ (void)showMessage:(NSString *)msg afterDele:(NSTimeInterval)seconds
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [UIView currentWindow];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.bezelView.color = RGBACOLOR(24, 23, 24, 0.9);
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.layer.borderColor = HEXRGBCOLOR(0xE36E55).CGColor;
        hud.bezelView.layer.borderWidth = 1;
        hud.label.textColor = UIColor.whiteColor;
        hud.label.font = SCRegularFont(12);
        hud.label.text = msg;
        [hud hideAnimated:NO afterDelay:seconds];
    });
}

+ (void)showProgress
{
    [DVECustomerHUD showProgressInView:[UIView currentWindow]];
}

+ (void)setProgressLableWithText:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [[UIView currentWindow] viewWithTag:DVECustomerHUDTag];
        if(view != nil && [view isKindOfClass:[DVEHUDCustomerView class]]){
            DVEHUDCustomerView* customerView = (DVEHUDCustomerView*)view;
            customerView.showText = text;
        }
    });
}

+ (void)hidProgress
{
    [DVECustomerHUD hidProgressInView:[UIView currentWindow]];
}


+ (void)showProgressInView:(UIView*)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        DVEHUDCustomerView* customerView = [[DVEHUDCustomerView alloc] initWithFrame:view.bounds];
        customerView.backgroundColor = RGBACOLOR(0, 0, 0, 0.2);
        customerView.tag = DVECustomerHUDTag;
        [customerView.gifView  play];
        [view addSubview:customerView];
    });
}

+ (void)hidProgressInView:(UIView*)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *customer = [view viewWithTag:DVECustomerHUDTag];
        if(customer != nil && [customer isKindOfClass:[DVEHUDCustomerView class]]){
            DVEHUDCustomerView* customerView = (DVEHUDCustomerView*)customer;
            [customerView.gifView stop];
            customerView.progressLable.hidden = YES;
            [customerView removeFromSuperview];

        }
    });
}



@end
