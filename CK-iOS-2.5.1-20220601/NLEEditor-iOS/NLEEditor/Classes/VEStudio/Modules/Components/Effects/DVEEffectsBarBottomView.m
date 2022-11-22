//
//   DVEEffectsBarBottomView.m
//   NLEEditor
//
//   Created  by bytedance on 2021/4/19.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEEffectsBarBottomView.h"
#import "DVEMacros.h"
#import "NSString+VEToImage.h"
#import <DVETrackKit/DVECustomResourceProvider.h>
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface DVEEffectsBarBottomView()

///标题
@property (nonatomic, strong) UILabel *titileLable;
///关闭按钮
@property (nonatomic, strong) UIButton *dismissButton;
///重制按钮
@property (nonatomic, strong) UIButton *resetButton;
///点击事件响应
@property (nonatomic, copy) dispatch_block_t dismissBlcok;
///重制事件响应
@property (nonatomic, copy) dispatch_block_t resetBlcok;
@end

@implementation DVEEffectsBarBottomView

+(instancetype)newActionBarWithTitle:(NSString*)title action:(dispatch_block_t) block {
    DVEEffectsBarBottomView* bar = [[DVEEffectsBarBottomView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, 50)];
    bar.titileLable.text = title;
    bar.dismissBlcok = block;
    [bar setupResetBlock:nil];
    bar.backgroundColor = HEXRGBCOLOR(0x181718);
    return bar;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]){
        [self addSubview:self.titileLable];
        [self.titileLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        [self addSubview:self.resetButton];
        [self.resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(44);
            make.left.equalTo(self).offset(16);
            make.centerY.equalTo(self);
        }];
        [self addSubview:self.dismissButton];
        [self.dismissButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(44);
            make.right.equalTo(self).offset(-8);
            make.centerY.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - public Method
-(void)setTitleText:(NSString*)text
{
    self.titileLable.text = text;
}

- (NSString *)titleText
{
    return self.titileLable.text;
}

-(void)setActionBlcok:(dispatch_block_t)actionBlcok
{
    ///如果不设置点击事件则隐藏按钮
    _dismissBlcok = [actionBlcok copy];
    self.dismissButton.hidden = actionBlcok == nil;
}

-(void)setupResetBlock:(dispatch_block_t)actionBlcok {
    _resetBlcok = [actionBlcok copy];
    self.resetButton.hidden = actionBlcok == nil;
}

-(void)setResetButtonEnable:(BOOL)enable
{
    self.resetButton.enabled = enable;
    if (!enable) {
        self.resetButton.alpha = 0.4;
    } else {
        self.resetButton.alpha = 1.0;
    }
}
- (void)setResetButtonHidden:(BOOL)isHidden {
    [_resetButton setHidden:isHidden];
}

#pragma mark - layz Method

- (UILabel *)titileLable
{
    if (!_titileLable) {
        _titileLable = [UILabel new];
        _titileLable.font = [UIFont dve_styleWithName:DVEUIFontStyleRegular sizeName:DVEUIFontSizeComponentBarTitle];
        _titileLable.textColor = [UIColor whiteColor];
        _titileLable.textAlignment = NSTextAlignmentCenter;
    }
    
    return _titileLable;
}

- (UIButton *)dismissButton
{
    if (!_dismissButton) {
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dismissButton setImage:@"icon_bottonbar_dismiss".dve_toImage forState:UIControlStateNormal];
        @weakify(self);
        [[_dismissButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            if(self.dismissBlcok){
                self.dismissBlcok();
            }
        }];
    }
    
    return _dismissButton;
}

-(UIButton *)resetButton
{
    if(!_resetButton){
        _resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_resetButton setImage:@"icon_dvecrop_reset".dve_toImage forState:UIControlStateNormal];
        [_resetButton setTitle:NLELocalizedString(@"ck_reset",@"重置" )  forState:UIControlStateNormal];
        [_resetButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:12]];
        [_resetButton setImageEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
        [_resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        @weakify(self);
        [[_resetButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            if(self.resetBlcok){
                self.resetBlcok();
            }
        }];
        
    }
    return _resetButton;
}

- (void)setResetTitle:(NSString *)title
{
    [self.resetButton setTitle:title forState:UIControlStateNormal];
}

- (void)setResetIcon:(UIImage*)image
{
    if(image){
        [self.resetButton setImage:image forState:UIControlStateNormal];
        [self.resetButton setImageEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    }else{
        [self.resetButton setImage:nil forState:UIControlStateNormal];
        [self.resetButton setImageEdgeInsets:UIEdgeInsetsZero];
    }
}

@end
