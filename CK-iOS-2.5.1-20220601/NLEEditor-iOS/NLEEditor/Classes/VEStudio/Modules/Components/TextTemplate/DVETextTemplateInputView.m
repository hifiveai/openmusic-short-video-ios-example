//
//  DVETextTemplateInputView.m
//  NLEEditor
//
//  Created by bytedance on 2021/7/2.
//

#import "DVETextTemplateInputView.h"
// model

// mgr

// view

// support
#import <Masonry/Masonry.h>
#import "DVEMacros.h"
#import "NSString+VEToImage.h"

@interface DVETextTemplateInputView ()<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *textView;
@property (nonatomic, strong) UIButton *btn;
@end

@implementation DVETextTemplateInputView

static const int8_t kBtnWidth = 54;
static const int8_t kTextFieldHeight = 34;
static const int8_t kBtnHeight = kTextFieldHeight;

// MARK: - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.blackColor;
        [self addSubview:self.textView];
        [self addSubview:self.btn];
    }
    return self;
}

// MARK: - Override

// MARK: - Public
- (void)showWithText:(NSString *)text {
    self.textView.text = text;
    [self.textView becomeFirstResponder];
}

- (void)dismiss {
    [self.textView resignFirstResponder];
    [self removeFromSuperview];
}

// MARK: - Event

// MARK: - Private

// MARK: - Getters and setters
- (UITextField *)textView
{
    if (!_textView) {
        _textView = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, VE_SCREEN_WIDTH - kBtnWidth, kTextFieldHeight)];
        _textView.font = SCRegularFont(12);
        _textView.delegate = self;
        _textView.backgroundColor = HEXRGBCOLOR(0x181718);
        _textView.layer.cornerRadius = 8;
        _textView.clipsToBounds = YES;
        _textView.textColor = UIColor.whiteColor;
        
        UIView *left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 30)];
        _textView.leftViewMode = UITextFieldViewModeAlways;
        [_textView setLeftView:left];
    }
    
    return _textView;
}

- (UIButton *)btn {
    if (!_btn) {
        _btn = [[UIButton alloc] initWithFrame:CGRectMake(VE_SCREEN_WIDTH - kBtnWidth, 10, kBtnWidth, kBtnHeight)];
        [_btn setImage:@"icon_bottonbar_dismiss".dve_toImage forState:UIControlStateNormal];
    }
    return _btn;
}

@end

