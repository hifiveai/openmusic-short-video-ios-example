//
//  VEWebViewController.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEWebViewController.h"
#import <WebKit/WebKit.h>
#import <sys/utsname.h>

@interface VEWebViewController ()<WKNavigationDelegate,WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIButton *rightButton;


@end

@implementation VEWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.webView];
    
    [self addRightBar];
}

- (void)addRightBar
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)didClickedRightButton:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- getter

- (UIButton *)rightButton
{
    if (!_rightButton) {
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [_rightButton setTitle:@"取消" forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(didClickedRightButton:) forControlEvents:UIControlEventTouchUpInside];
        if (@available(iOS 13.0, *)) {
            [_rightButton setTitleColor:[UIColor systemIndigoColor] forState:UIControlStateNormal];
        } else {
            [_rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    
    return _rightButton;
}

- (WKWebView *)webView
{
    if (!_webView) {
        //创建网页配置对象
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        
        // 创建设置对象
        WKPreferences *preference = [[WKPreferences alloc]init];
        //最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
        preference.minimumFontSize = 0;
        //设置是否支持javaScript 默认是支持的
        preference.javaScriptEnabled = YES;
        // 在iOS上默认为NO，表示是否允许不经过用户交互由javaScript自动打开窗口
        preference.javaScriptCanOpenWindowsAutomatically = YES;
        config.preferences = preference;
        
        // 是使用h5的视频播放器在线播放, 还是使用原生播放器全屏播放
        config.allowsInlineMediaPlayback = YES;
        //设置视频是否需要用户手动播放  设置为NO则会允许自动播放
        config.requiresUserActionForMediaPlayback = YES;
        //设置是否允许画中画技术 在特定设备上有效
        config.allowsPictureInPictureMediaPlayback = YES;
        //设置请求的User-Agent信息中应用程序名称 iOS9后可用
        config.applicationNameForUserAgent = @"ChinaDailyForiPad";
        //自定义的WKScriptMessageHandler 是为了解决内存不释放的问题
        
        //初始化
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, VE_SCREEN_HEIGHT) configuration:config];
        // UI代理
        _webView.UIDelegate = self;
        // 导航代理
        _webView.navigationDelegate = self;
        // 是否允许手势左滑返回上一级, 类似导航控制的左滑返回
        _webView.allowsBackForwardNavigationGestures = YES;
        
        
    }
    
    return _webView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_url) {
        [_webView loadRequest:[NSURLRequest requestWithURL:_url]];
    }
}

- (NSString*)deviceVersion
{
   
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //iPhone
    
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"51";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"52";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"53";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"54";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"61";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"62";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"71";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"72";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"81";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"82";
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"91";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"92";
    if([deviceString  isEqualToString:@"iPhone10,1"])   return @"101";
    if([deviceString  isEqualToString:@"iPhone10,4"])   return @"101";
    if([deviceString  isEqualToString:@"iPhone10,2"])   return @"101";
    if([deviceString  isEqualToString:@"iPhone10,5"])   return @"101";
    if([deviceString  isEqualToString:@"iPhone10,3"])   return @"101";
    if([deviceString  isEqualToString:@"iPhone10,6"])   return @"101";
    deviceString = @"100";
    
    return deviceString;
}

@end
