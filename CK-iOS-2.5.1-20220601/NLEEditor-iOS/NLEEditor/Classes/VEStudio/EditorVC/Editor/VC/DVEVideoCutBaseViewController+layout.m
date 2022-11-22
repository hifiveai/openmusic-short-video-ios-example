//
//  DVEVideoCutBaseViewController+layout.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEVideoCutBaseViewController+layout.h"
#import "DVEVideoCutBaseViewController+Private.h"
#import "DVEComponentViewManager.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEUIHelper.h"
#import <Masonry/Masonry.h>

#define TimeLineViewHeight (198)
#define TopBarViewHeight (50)
#define BottomBarHeight (65 + VEBottomMargn)

@implementation DVEVideoCutBaseViewController (layout)

- (void)buildVEVCLayout
{
    [DVEComponentViewManager sharedManager].componentViewBarHeight = BottomBarHeight;
    
    self.topBar.frame = CGRectMake(0, [DVEUIHelper topBarMargn:self.navigationController], VE_SCREEN_WIDTH, TopBarViewHeight);
    self.videoView.frame = CGRectMake(0, self.topBar.bottom , VE_SCREEN_WIDTH, VE_SCREEN_HEIGHT - [DVEComponentViewManager sharedManager].componentViewBarHeight - TimeLineViewHeight - self.topBar.bottom);
    self.timeLineView.frame = CGRectMake(0, self.videoView.bottom, VE_SCREEN_WIDTH, TimeLineViewHeight);
    self.addButton.center = CGPointMake( VE_SCREEN_WIDTH - 30, self.timeLineView.centerY);
    self.closeButton.center = CGPointMake(MAX(self.closeButton.width/2, 30), self.topBar.centerY);
    
    [self.view addSubview:self.topBar];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.videoView];
    [self.view addSubview:self.timeLineView];
    [self.view addSubview:self.playHead];
    [self.view addSubview:self.addButton];
    
    [[DVEComponentViewManager sharedManager] showComponentType:DVEBarComponentTypeRoot];
    [DVEComponentViewManager sharedManager].currentBar.top = self.timeLineView.bottom;
    

    [self.playHead mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@1);
        make.height.equalTo(@(self.timeLineView.height - 40));
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.timeLineView).offset(20);
    }];
}

@end
