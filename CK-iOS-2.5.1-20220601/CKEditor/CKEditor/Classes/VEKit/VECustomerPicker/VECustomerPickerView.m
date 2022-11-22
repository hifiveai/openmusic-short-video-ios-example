//
//  VECustomerPickerView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "VECustomerPickerView.h"
#import <SGPagingView/SGPagingView.h>

@interface VECustomerPickerView ()<SGPageTitleViewDelegate>

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) SGPageTitleView *functionView;

@property (nonatomic, assign) BOOL isFirstAppear;



@end

@implementation VECustomerPickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildLayout];
    }
    
    return self;
}

- (void)buildLayout
{
    [self addSubview:self.functionView];
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 54, 54)];
        [_closeButton setImage:@"icon_close".UI_VEToImage forState:UIControlStateNormal];
        @weakify(self);
        [[_closeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self removeFromSuperview];
        }];
    }
    
    return _closeButton;
}

- (SGPageTitleView *)functionView
{
    if (!_functionView) {
        SGPageTitleViewConfigure *config = [SGPageTitleViewConfigure pageTitleViewConfigure];
        config.showBottomSeparator = NO;
        config.titleAdditionalWidth = 0;
        config.titleColor = [UIColor lightGrayColor];
        config.titleSelectedColor = [UIColor whiteColor];
        config.indicatorColor = [UIColor clearColor];
        config.titleFont = SCRegularFont(14);
        _functionView = [[SGPageTitleView alloc] initWithFrame:CGRectMake(70, 20, 232, 24) delegate:self titleNames:@[ @"所有内容",@"图片",@"视频",] configure:config];
        
        _functionView.backgroundColor = [UIColor clearColor];
        _functionView.selectedIndex = 0;
    }
    
    return _functionView;
}

- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex
{
    pageTitleView.selectedIndex = selectedIndex;
    
    
}


@end
