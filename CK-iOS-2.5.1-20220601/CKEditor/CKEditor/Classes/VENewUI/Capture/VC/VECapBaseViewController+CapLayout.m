//
//  VECapBaseViewController+CapLayout.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECapBaseViewController+CapLayout.h"
#import "VECapBaseViewController+PrivateForCapVC.h"

@implementation VECapBaseViewController (CapLayout)

- (void)buildCapLayout
{
    [self.view addSubview:self.topBar];
//    [self.view addSubview:self.rightBar];
    [self.view addSubview:self.bottomBar];
    [self.view addSubview:self.statusView];
    
    
    [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topBar.height);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(self.statusView.height);
    }];

//    [self.rightBar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(VETopMargn + self.topBar.height + 20);
//        make.right.mas_equalTo(0);
//        make.width.mas_equalTo(self.rightBar.width);
//        make.bottom.mas_equalTo(- self.bottomBar.height - 30 - 20);
//    }];

    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-VEBottomMargn);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(self.bottomBar.height);
    }];
}


@end
