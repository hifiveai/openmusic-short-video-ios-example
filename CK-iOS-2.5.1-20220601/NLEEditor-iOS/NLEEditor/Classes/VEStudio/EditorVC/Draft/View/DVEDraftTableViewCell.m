//
//  DVEDraftTableViewCell.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/2/28.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "DVEDraftTableViewCell.h"
#import "DVEDraftModel.h"
#import "DVEMacros.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "NSString+VEToImage.h"
#import "NSString+DVEToPinYin.h"
#import <DVETrackKit/DVECustomResourceProvider.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface DVEDraftTableViewCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *durationLable;
@property (nonatomic, strong) UILabel *dateLable;
@property (nonatomic, strong) UIButton *deletButton ;

@end

@implementation DVEDraftTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildLayout];
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}
- (void)buildLayout
{
    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.durationLable];
    [self.contentView addSubview:self.dateLable];
    [self.contentView addSubview:self.deletButton];
    
    
}

- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 18, 65, 65)];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.clipsToBounds = YES;
    }
    
    return _iconView;
}


- (UILabel *)durationLable
{
    if (!_durationLable) {
        _durationLable = [[UILabel alloc] initWithFrame:CGRectMake(_iconView.right + 18, _iconView.top, 150, 24)];
        _durationLable.font = SCRegularFont(12);
        _durationLable.textAlignment = NSTextAlignmentLeft;
        _durationLable.textColor = HEXRGBCOLOR(0x181718);
         
    }
    
    return _durationLable;
}

- (UILabel *)dateLable
{
    if (!_dateLable) {
        _dateLable = [[UILabel alloc] initWithFrame:CGRectMake(_durationLable.left, _durationLable.bottom, 150, 24)];
        _dateLable.font = SCRegularFont(12);
        _dateLable.textAlignment = NSTextAlignmentLeft;
        _dateLable.textColor = HEXRGBCOLOR(0x181718);
    }
    
    return _dateLable;
}

- (UIButton *)deletButton
{
    if (!_deletButton) {
        _deletButton = [[UIButton alloc] initWithFrame:CGRectMake(VE_SCREEN_WIDTH - 65, 30, 50, 30)];
        [_deletButton setBackgroundImage:@"bg_vevc_done".dve_toImage forState:UIControlStateNormal];
        [_deletButton setTitle:NLELocalizedString(@"ck_remove", @"删除") forState:UIControlStateNormal];
        [_deletButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _deletButton.titleLabel.font = SCRegularFont(12);
        @weakify(self);
        [[[_deletButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            if (self.deletDraftBlock) {
                self.deletDraftBlock();
            }
            
        }];
    }
    
    return _deletButton;
}


- (void)setModel:(DVEDraftModel *)model
{
    _model = model;
    NSString *iconPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:model.iconFileUrl];
    _iconView.image = [UIImage imageWithContentsOfFile:iconPath];
    _durationLable.text = [NSString stringWithFormat:@"%@",[NSString DVE_timeFormatWithTimeInterval:ceil(model.duration)]];;
    _dateLable.text = model.date;
}



@end
