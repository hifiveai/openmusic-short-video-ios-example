//
//  DVEAlbumCornerBarNaviController.m
//  Aweme
//
//  Created by bytedance on 2017/3/23.
//  Copyright © 2017年 Bytedance. All rights reserved.
//

#import "DVEAlbumCornerBarNaviController.h"
#import "UIImage+DVEAlbumAdditions.h"
#import "DVEAlbumResourceUnion.h"

@interface DVEAlbumCornerBarNaviController ()

@end

@implementation DVEAlbumCornerBarNaviController

- (void)setBottomBorderColor:(UINavigationBar *)bar color:(UIColor *)color height:(CGFloat)height {
    CGRect bottomBorderRect = CGRectMake(0, CGRectGetHeight(bar.frame), CGRectGetWidth(bar.frame), height);
    UIView *bottomBorder = [[UIView alloc] initWithFrame:bottomBorderRect];
    [bottomBorder setBackgroundColor:color];
    [bar addSubview:bottomBorder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setValue:@(YES) forKey:@"hidesShadow"];
    [self setBottomBorderColor:self.navigationBar color:TOCResourceColor(TOCUIColorConstSDInverse) height:0.5];
    [self.navigationBar setBackgroundImage:[UIImage acc_imageWithColor:TOCResourceColor(TOCUIColorBGContainer) size:CGSizeMake(1, 1)]
                             forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:nil];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:TOCResourceColor(TOCUIColorConstTintPrimary)}];
    [self.navigationBar setTintColor:TOCResourceColor(TOCUIColorBGContainer6)];

    [self buildShapeLayer];
}

- (void)buildShapeLayer {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)].CGPath;
        self.view.layer.mask = shapeLayer;
    }
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self buildShapeLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
