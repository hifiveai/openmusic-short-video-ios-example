//
//  VEEBaseView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEEBaseView.h"


@interface VEEBaseView ()

@property (nonatomic, strong) UIButton *backButton;

@end

@implementation VEEBaseView

- (instancetype)initWithFrame:(CGRect)frame Type:(VEEffectToolViewType)type DismisBlock:(VEEVoidBlock)dismissBlock
{
    if (self = [self initWithFrame:frame]) {
        
        self.effectType = type;
        [self buildlayout];
        self.dismissBlock = dismissBlock;
        
        
        @weakify(self);
        [[self.actionButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self dismiss];
            if (self.actionButtonBlock) {
                @strongify(self);
                self.actionButtonBlock(self.effectType, self.type, x);
            }
        }];
        
        [[self.capButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self dismiss];
            if (self.capButtonBlock) {
                self.capButtonBlock(self.effectType, self.type, x);
            }
        }];
        
        [[self.resetButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
//            [self dismiss];
            if (self.resetButtonBlock) {
                self.resetButtonBlock(self.effectType, self.type, x);
            }
        }];
    }
    
    return self;
}

- (void)buildlayout
{
    [self addSubview:self.backButton];
    [self addSubview:self.bottomBar];
    
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.bottomBar.bottom = self.height;
    
    
    [self.bottomBar addSubview:self.resetButton];
    [self.bottomBar addSubview:self.actionButton];
    [self.bottomBar addSubview:self.capButton];
    [self.bottomBar addSubview:self.dismissButton];
    
    switch (self.effectType) {
        case VEEffectToolViewTypeFilter:
            self.resetButton.hidden = YES;
            break;
        case VEEffectToolViewTypeSticker:
            self.resetButton.hidden = YES;
            break;
        case VEEffectToolViewTypeBeauty:
            
            break;
            
        default:
            break;
    }
    
    
    self.actionButton.center = CGPointMake(self.width * 0.5, 22);
    self.capButton.center = CGPointMake(self.width * 0.5, 22);
    self.resetButton.left = 10;
    self.resetButton.centerY = self.actionButton.centerY;
    
    self.dismissButton.right = self.width - 10;
    self.dismissButton.centerY = self.actionButton.centerY;
    
}


- (UIView *)bottomBar
{
    if (!_bottomBar) {
        _bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 44 + 34)];
        _bottomBar.backgroundColor = [UIColor blackColor];
    }
    
    return _bottomBar;
}

- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [UIButton new];
        @weakify(self);
        [[_backButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self dismiss];
        }];
    }
    
    return _backButton;
}


- (UIButton *)resetButton
{
    if (!_resetButton) {
        _resetButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
        [_resetButton setTitle:CKEditorLocStringWithKey(@"ck_reset", @"重置")  forState:UIControlStateNormal];
        [_resetButton setImage:@"icon_bottombar_reset".UI_VEToImage forState:UIControlStateNormal];
        _resetButton.titleLabel.textColor = [UIColor whiteColor];
        _resetButton.titleLabel.font = SCRegularFont(12);
        [_resetButton VElayoutWithType:VEButtonLayoutTypeImageLeft space:7];
    }
    
    return _resetButton;
}

- (UIButton *)actionButton

{
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 42)];
        [_actionButton setImage:@"icon_bottombar_record".UI_VEToImage forState:UIControlStateNormal];
//        [[_actionButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
//            @strongify(self);
//            [self dismiss];
//        }];
       
    }
    
    return _actionButton;
}

- (UIButton *)capButton
{
    if (!_capButton) {
        _capButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 42)];
        [_capButton setImage:@"icon_bottombar_capture".UI_VEToImage forState:UIControlStateNormal];
    }
    
    return _capButton;
}

- (UIButton *)dismissButton
{
    if (!_dismissButton) {
        _dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [_dismissButton setImage:@"icon_bottonbar_dismiss".UI_VEToImage forState:UIControlStateNormal];
        @weakify(self);
        [[_dismissButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self dismiss];
        }];
    }
    
    return _dismissButton;
}


- (void)dismiss
{
    self.isShow = NO;
    if (self.dismissBlock) {
        self.dismissBlock();
    }
    [self removeFromSuperview];
}

- (void)showInView:(UIView *)view
{
    self.isShow = YES;
    [view addSubview:self];
}

- (void)setType:(VEEBottomBarType)type
{
    _type = type;
    
    self.capButton.hidden = !(type == VEEBottomBarTypePicture);
    self.actionButton.hidden = !self.capButton.hidden;
}

- (void)reset
{
    
}

@end
