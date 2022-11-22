//
//  DVETextTemplatePickerCell.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/28.
//

#import "DVETextTemplatePickerCell.h"
// model

// mgr
#import "DVETextTemplateInputManager.h"
// view

// support
#import "DVEMacros.h"
#import <DVETrackKit/UIView+VEExt.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface DVETextTemplatePickerCell ()
@property (nonatomic, strong) UIImageView *gifView;
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIView *blurView;
@end

@implementation DVETextTemplatePickerCell

static const int8_t kBtnHeight = 24;

// MARK: - Initialization
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.layer.cornerRadius = 2;
        [self.contentView addSubview:self.gifView];
        [self.contentView addSubview:self.blurView];
        [self.contentView addSubview:self.btn];
    }
    return self;
}

- (void)setStickerSelected:(BOOL)stickerSelected animated:(BOOL)animated {
    [super setStickerSelected:stickerSelected animated:animated];
    [self p_updateForSelected:stickerSelected];
}


- (void)setModel:(DVEEffectValue *)model {
    [super setModel:model];
    [self.gifView sd_setImageWithURL:model.imageURL placeholderImage:model.assetImage];
}

// MARK: - Event

- (void)clickBtn {
    [[DVETextTemplateInputManager sharedInstance] showWithTextIndex:0
                                                             source:DVETextTemplateInputManagerSourcePickerCell];
}

// MARK: - Private

- (void)p_updateForSelected:(BOOL)selected {
    self.contentView.layer.borderWidth = 1;
    UIColor *c = selected ? HEXRGBCOLOR(0xFE6646) : UIColor.clearColor;
    self.contentView.layer.borderColor = c.CGColor;
    self.btn.hidden = !selected;
    self.blurView.hidden = !selected;
}

// MARK: - Getters and setters

- (UIImageView *)gifView {
    if (!_gifView) {
        UIImageView *webView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        webView.backgroundColor = [UIColor clearColor];
        _gifView = webView;
    }
    return _gifView;
}

- (UIButton *)btn {
    if (!_btn) {
        _btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, kBtnHeight)];
        _btn.center = self.contentView.center;
        _btn.hidden = YES;
        _btn.titleLabel.font = SCRegularFont(10);
        [_btn setTitle:NLELocalizedString(@"ck_edit_image_cover", @"点击编辑") forState:UIControlStateNormal];
        [_btn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _btn;
}

- (UIView *)blurView {
    if (!_blurView) {
        _blurView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        _blurView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
        _blurView.hidden = YES;
    }
    return _blurView;
}

@end

