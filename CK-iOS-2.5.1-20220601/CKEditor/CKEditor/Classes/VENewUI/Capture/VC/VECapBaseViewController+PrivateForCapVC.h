//
//  VECapBaseViewController+PrivateForCapVC.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECapBaseViewController.h"
#import "VECPTopBar.h"
#import "VECPRightBar.h"
#import "VECPBottomBar.h"
#import "VECPStatusView.h"

#define VEBarBackColor  RGBACOLOR(0, 0, 0, 0.0)
#define VECPTopBarHeight 90

#define VECPRightBarWidth 100
NS_ASSUME_NONNULL_BEGIN

@interface VECapBaseViewController ()

@property (nonatomic, strong) VECPStatusView *statusView;
@property (nonatomic, strong) VECPTopBar *topBar;
@property (nonatomic, strong) VECPRightBar *rightBar;
@property (nonatomic, strong) VECPBottomBar *bottomBar;
@property (nonatomic, assign) VECPViewType viewType;

@end

NS_ASSUME_NONNULL_END
