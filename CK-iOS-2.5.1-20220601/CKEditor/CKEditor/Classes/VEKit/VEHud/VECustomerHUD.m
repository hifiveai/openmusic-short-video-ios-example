//
//  VECustomerHUD.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECustomerHUD.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>
#import "VEHUDCustomerView.h"

static VEHUDCustomerView *customerView;

@interface VECustomerHUD ()

@property (nonatomic, strong) MBProgressHUD *hud;

@end


@implementation VECustomerHUD

+ (void)showMessage:(NSString *)msg
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [UIView currentViewController].view;
        [view makeToast:msg duration:3 position:CSToastPositionCenter];
    });
    
}

+ (void)showMessage:(NSString *)msg afterDele:(NSTimeInterval)seconds
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [UIView currentViewController].view;
        [view makeToast:msg duration:seconds position:CSToastPositionCenter];
    });
    
}

+ (VECustomerHUD *)showProgress
{
    
    VECustomerHUD *hud = [[VECustomerHUD alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [UIView currentViewController].view;
        
        if (!customerView) {
            customerView = [[VEHUDCustomerView alloc] initWithFrame:view.bounds];
            customerView.backgroundColor = RGBACOLOR(0, 0, 0, 0.2);
        }

        [view addSubview:customerView];
    });
    
    
    
    return hud;
}

- (void)setProgressLableWithText:(NSString *)text
{
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        customerView.showText = text;
    });
    
}

+ (void)hidProgress
{
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        UIView *view = [UIView currentViewController].view;
        [customerView removeFromSuperview];
        customerView.progressLable.hidden = YES;
    });
    
}


    


@end
