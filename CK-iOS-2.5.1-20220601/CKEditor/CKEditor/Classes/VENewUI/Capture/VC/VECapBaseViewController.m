//
//  VECapBaseViewController.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECapBaseViewController.h"
#import "VECapBaseViewController+PrivateForCapVC.h"

@interface VECapBaseViewController ()

@end

@implementation VECapBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = false;
}

#pragma mark - getter

- (VECPStatusView *)statusView
{
    if (!_statusView) {
        _statusView = [[VECPStatusView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, 60)];
        _statusView.hidden = YES;
    }
    
    return _statusView;
}

- (VECPTopBar *)topBar
{
    if (!_topBar) {
        _topBar = [[VECPTopBar alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, VECPTopBarHeight)];
        _topBar.capManager = self.capManager;
        _topBar.backgroundColor = VEBarBackColor;
    }
    
    return _topBar;
}

- (VECPRightBar *)rightBar
{
    if (!_rightBar) {
        _rightBar = [[VECPRightBar alloc] initWithFrame:CGRectMake(0, 0, VECPRightBarWidth, VE_SCREEN_HEIGHT - 180)];
        _rightBar.capManager = self.capManager;
        _rightBar.backgroundColor = VEBarBackColor;
    }
    
    return _rightBar;
}

- (VECPBottomBar *)bottomBar
{
    if (!_bottomBar) {
        _bottomBar = [[VECPBottomBar alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, VECPBottomBarH)];
        _bottomBar.capManager = self.capManager;
        _bottomBar.backgroundColor = VEBarBackColor;
        _bottomBar.viewType = self.viewType;
        @weakify(self);
        _bottomBar.deletActionBlock = ^(NSIndexPath * _Nonnull indexPath) {
            @strongify(self);
            if (self.capManager.boxState == VECPBoxStateIdle) {
                self.statusView.hidden = YES;
            }
        };

        [RACObserve(_bottomBar, viewType) subscribeNext:^(NSNumber   *x) {
            @strongify(self);
            VECPViewType type = x.integerValue;
            if (type != self.viewType) {
                self->_viewType = type;
            }
        }];
    }
    
    return _bottomBar;
}

- (void)setCpResultBlock:(capsourceResultBlock)cpResultBlock
{
    self.bottomBar.cpResultBlock = cpResultBlock;
}

@end
