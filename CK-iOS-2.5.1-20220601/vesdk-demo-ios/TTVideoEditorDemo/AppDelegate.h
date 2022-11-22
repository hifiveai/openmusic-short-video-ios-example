//
//  AppDelegate.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

#define VETobMode 1

#define VEAppDelegate  ((AppDelegate *)[UIApplication sharedApplication].delegate)
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIViewController *rootVC;

+ (AppDelegate *)sharAppDelegate;

- (void)showMessage:(NSString *)message;

@end

