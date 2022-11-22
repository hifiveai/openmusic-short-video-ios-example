//
//  DVESubtitleAlertView.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/18.
//

#import "DVESubtitleAlertView.h"
#import "UIImage+DVEStyle.h"
#import "UIImage+DVE.h"
#import "DVEMacros.h"
#import "UIColor+DVEStyle.h"
#import "DVEUILayout.h"
#import <Masonry/Masonry.h>

@interface DVESubtitleAlertView()

@property (nonatomic, strong, readwrite) DVESelectBox *clearSubtitleButton;
@property (nonatomic, strong, readwrite) UIButton *confirmButton;
@property (nonatomic, strong, readwrite) UIButton *cancelButton;

@end

@implementation DVESubtitleAlertView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = [DVEUILayout dve_sizeNumberWithName:DVEUILayoutButtonCornerRadius];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"自动识别字幕";
    _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:17];
    _titleLabel.textColor = colorWithHex(0x1D2129);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    
    _clearSubtitleButton = [[DVESelectBox alloc] init];
    _clearSubtitleButton.titleLabel.text = @"同时清空已有字幕";
    _clearSubtitleButton.titleLabel.textColor = colorWithHex(0x4E5969);
    _clearSubtitleButton.titleLabel.font = SCRegularFont(14);
    _clearSubtitleButton.normalImage = [UIImage dve_image:@"text_unselect"];
    _clearSubtitleButton.selectedImage = [UIImage dve_image:@"text_select"];
    
    _confirmButton = [[UIButton alloc] init];
    _confirmButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
    [_confirmButton setTitle:@"开始识别" forState:UIControlStateNormal];
    [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIColor *normalColor = [UIColor dve_themeColor];
    UIColor *highlightColor = [[UIColor dve_themeColor] colorWithAlphaComponent:0.3];
    UIImage *normalImage = [UIImage dev_image:normalColor size:CGSizeMake(10, 10)];
    UIImage *highlightImage = [UIImage dev_image:highlightColor size:CGSizeMake(10, 10)];
    [_confirmButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [_confirmButton setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    _confirmButton.layer.cornerRadius = [DVEUILayout dve_sizeNumberWithName:DVEUILayoutButtonCornerRadius];
    _confirmButton.layer.masksToBounds = YES;
    
    _cancelButton = [[UIButton alloc] init];
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = SCRegularFont(15);
    [_cancelButton setTitleColor:colorWithHex(0x4E5969) forState:UIControlStateNormal];
    
    [self addSubview:_titleLabel];
    [self addSubview:_clearSubtitleButton];
    [self addSubview:_confirmButton];
    [self addSubview:_cancelButton];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self).offset(32);
    }];
    
    [_clearSubtitleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
        make.centerX.equalTo(self);
    }];
    
    [_confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.clearSubtitleButton.mas_bottom).offset(24);
        make.left.right.equalTo(self).inset(20);
        make.height.mas_equalTo(44);
    }];
    
    [_cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.confirmButton.mas_bottom).offset(13);
        make.height.mas_equalTo(21);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self).offset(-14);
    }];
}

@end
