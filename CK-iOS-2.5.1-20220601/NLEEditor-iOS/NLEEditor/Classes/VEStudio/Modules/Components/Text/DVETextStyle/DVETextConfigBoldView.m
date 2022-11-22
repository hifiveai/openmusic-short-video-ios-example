//
//  DVETextConfigBoldView.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/22.
//
//  改用 btn 的方案
#import "DVETextConfigBoldView.h"
// view controller

// model

// mgr

// view
#import "DVETextCommonItem.h"
// view model

// support
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEMacros.h"
#import "NSString+VEIEPath.h"
#import <ReactiveObjC/ReactiveObjC.h>
 
@interface DVETextConfigBoldView ()
@property (nonatomic, strong) UIButton *blodBtn;
@property (nonatomic, strong) UIButton *italicBtn;
@property (nonatomic, strong) UIButton *underlineBtn;
@end

@implementation DVETextConfigBoldView
static const int8_t kBtnWH = 30;
static const int8_t kBtnSpacing = 43;

// MARK: - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        @weakify(self);
        _blodBtn = [self p_createBtnWithImgName:@"text_nobold" clickBlock:^(UIButton *btn) {
            @strongify(self);
            self.boldWidth = btn.isSelected ? 0.008f : 0.0f;
        }];
        
        _italicBtn = [self p_createBtnWithImgName:@"text_noitalic" clickBlock:^(UIButton *btn) {
            @strongify(self);
            self.italicDegree = btn.isSelected ? 10.0f : 0.0f;
        }];
        
        _underlineBtn = [self p_createBtnWithImgName:@"text_nounderline" clickBlock:^(UIButton *btn) {
            @strongify(self);
            self.underline = btn.isSelected;
        }];
        
        _italicBtn.centerX = self.centerX;
        _blodBtn.right = _italicBtn.left - kBtnSpacing;
        _underlineBtn.left = _italicBtn.right + kBtnSpacing;
    }
    return self;
}

// MARK: - Event


// MARK: - Private
- (UIButton *)p_createBtnWithImgName:(NSString *)imgName clickBlock:(void (^)(UIButton *btn))block {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, (kBtnWH-8)/2, kBtnWH, kBtnWH)];
    btn.backgroundColor = HEXRGBCOLOR(0x434242);
    
    [btn setImage:imgName.dve_toImage forState:UIControlStateNormal];
    btn.layer.cornerRadius = 2;
    btn.layer.masksToBounds = YES;
    
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        btn.selected = !btn.isSelected;
        !block ? : block(btn);
    }];
    
    [RACObserve(btn, selected) subscribeNext:^(NSNumber *x) {
        if (x) {
            BOOL selected = x.boolValue;
            UIColor *c = selected ? HEXRGBCOLOR(0xFE6646) : UIColor.clearColor;
            btn.layer.borderColor = c.CGColor;
            btn.layer.borderWidth = 1;
        }
    }];
    
    [self addSubview:btn];
    return btn;
}

// MARK: - Getters and setters

- (void)setItalicDegree:(float)italicDegree {
    _italicDegree = italicDegree;
    _italicBtn.selected = italicDegree > 0.0f;
}

- (void)setBoldWidth:(float)boldWidth {
    _boldWidth = boldWidth;
    _blodBtn.selected = boldWidth > 0.0f;
}

- (void)setUnderline:(BOOL)underline {
    _underline = underline;
    _underlineBtn.selected = underline;
}

@end

