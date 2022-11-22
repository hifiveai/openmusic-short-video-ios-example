//
//  AppDelegate.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "AppDelegate.h"

#import <TTVideoEditor/IESMMParamModule.h>
#import <TTVideoEditor/VEPreloadModule.h>
#import <TTVideoEditor/VETobLicense.h>
#import <TTVideoEditor/IESMMLogger.h>
#import <TTVideoEditor/VEConfigCenter.h>
#import <TTVideoEditor/IESMMTrackerManager.h>

#import <NLEPlatform/NLELogger_OC.h>
#import "VEDebugWindow.h"
#import "NSDictionary+UIVEAdd.h"
#import "VERootVCManger.h"
#import "VECustomerHUD.h"
#import <NLEEditor/DVENotification.h>
#import "DVEAudioPlayer.h"


@interface AppDelegate () <IESEditorLoggerDelegate,NLELoggerDelegate>

@end

static NSMutableDictionary *modelNameDic;

@implementation AppDelegate

+ (AppDelegate *)sharAppDelegate
{

    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//#ifdef DEBUG
    VEDebugWindow *window = [[VEDebugWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.detectsShake = YES;
    self.window = window;
//#endif

    [[VERootVCManger shareManager] swichRootVC];
    [self initVESDK];
    
    ADLog(@"%0.3f----%0.3f",VETopMargn,VEBottomMargn);
    
    [self copyInfoStickerBundleToSandBox];
    
    return YES;
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[DVEAudioPlayer shareManager].player pause];
}
- (void)copyInfoStickerBundleToSandBox
{
    NSString *bundle = [[NSBundle mainBundle] pathForResource:@"sticker" ofType:@"bundle"];
    NSString *toPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/sticker.bundle"];
    NSFileManager *fileManager =  [NSFileManager defaultManager];
    //判断文件是否存在
    BOOL isExist = [fileManager fileExistsAtPath:toPath];
    if (isExist) {
        BOOL isSucess = [fileManager removeItemAtPath:toPath error:nil];
        ADLog(@"%@",isSucess ? @"删除成功" : @"删除失败");
    }
    
    BOOL isSuccess = [fileManager copyItemAtPath:bundle toPath:toPath error:nil];
    ADLog(@"%@",isSuccess ? @"移动成功" : @"移动失败");
}
- (void)showMessage:(NSString *)message {
    DVENotificationCloseView *closeView = [DVENotification showTitle:@"" message:message];
    closeView.closeBlock = ^(UIView * _Nonnull view) {
        
    };
}
//鉴权回调，获取异常日志，不一定在主线程
void licenseCheckerCallback(NSString *message, int code) {
    NSLog(@"licenseCheckerCallback：%@", message);
    NSString *showMSG = @"鉴权不通过，请联系技术支持";
    showMSG = [showMSG stringByAppendingString:[NSString stringWithFormat:@"，错误码：%d",code]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AppDelegate sharAppDelegate] showMessage:showMSG];
    });
    
}

- (void)initVESDK {
    NSString *bpath = [[NSBundle mainBundle] pathForResource:@"LicenseBag" ofType:@"bundle"];
    NSString *path = [bpath stringByAppendingString:@"/"];
//    path = [path stringByAppendingString:@"labcv_test_20211210_20220630_com.IESVideoEditor.demo.inhouse_4.0.4.0"];
    path = [path stringByAppendingString:@"Hifve_test_20221031_20221231_com.hfopen.videosdk_4.2.6.5"];
    
    path = [path stringByAppendingString:@".licbag"];
    
    NSString *testLocalPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/test.licbag"];
    
    NSFileManager *fileManager =  [NSFileManager defaultManager];
    //判断文件是否存在
    BOOL isExist = [fileManager fileExistsAtPath:testLocalPath];
    if (isExist) {
        path = testLocalPath;
    }
    
    //设置鉴权回调，获取异常日志
    VESetLicenseCheckerCallback(licenseCheckerCallback);
    
    if (VELicenseRegister(path)) {

    } else {
        [DVENotification showTitle:nil message:@"VE授权不正确，请检查"];
    }
    
    if (@available(iOS 14.2, *)) {
        [[VEConfigCenter sharedInstance] configVESDKABValue:@1 key:@"veabtest_VTEncodeMode" type:VEABKeyDataType_Int];
    }
    
    // 开启 composer 功能和 OpenGL ES 3.0
    [IESMMParamModule sharedInstance].composerMode  = 1;
    [IESMMParamModule sharedInstance].composerOrder = 0;
    [IESMMParamModule sharedInstance].infoStickerCanUseAmazing = YES;
    [IESMMParamModule sharedInstance].editorCanUseAmazing = YES;
    IESMMParamModule.sharedInstance.useNewAudioEditor = YES;
    IESMMParamModule.sharedInstance.useNewAudioAPI = YES;
    IESMMParamModule.sharedInstance.recordCanUseAmazing = YES;
    [self setResourceFinder];
    [VEPreloadModule prepareVEContext];
    

    [IESMMParamModule sharedInstance].capturePreviewUpTo1080P = YES;
    
    [[IESMMLogger sharedInstance] setLoggerDelegate:self];
    
    [[IESMMTrackerManager shareInstance] setAppLogCallback:@"" callback:^(NSString * _Nonnull event, NSDictionary * _Nonnull params, NSString * _Nonnull eventType) {
        
    }];
}

- (void)setResourceFinder
{
    [IESMMParamModule setResourceFinder:resource_finder];
}

char *resource_finder(__unused void *handle, __unused const char *dir, const char *name){
    //模型文件夹路径
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ModelResource" ofType:@"bundle"];
    path = [path stringByAppendingPathComponent:[NSString stringWithUTF8String:name]];
    path = [@"file://" stringByAppendingString:path];
    char *result_path = malloc(strlen(path.UTF8String) + 1);
    strcpy(result_path, path.UTF8String ?: "");
    result_path[strlen(path.UTF8String)] = '\0';
    return result_path;
}


- (void)IESEditorlogToLocal:(NSString *)logString andLevel:(IESMMlogLevel)level {
    NSLog(@"%@",logString);
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

#pragma mark - UISceneSession lifecycle

/*
- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}
*/

@end
