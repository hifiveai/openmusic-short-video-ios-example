//
//  DVETextReaderEffectCell.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/27.
//

#import "DVETextReaderEffectCell.h"
#import "DVEMacros.h"
#import "DVETextReaderModelProtocol.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>

@interface DVETextReaderEffectCell()

@property (nonatomic, strong) UIView *selectedIndicatorView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation DVETextReaderEffectCell

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
    _selectedIndicatorView = [[UIView alloc] init];
    _selectedIndicatorView.layer.borderColor = colorWithHex(0xE36E55).CGColor;
    _selectedIndicatorView.layer.borderWidth = 2.f;
    _selectedIndicatorView.layer.cornerRadius = 5.f;
    _selectedIndicatorView.hidden = YES;
    
    _backView = [[UIView alloc] init];
    _backView.backgroundColor = colorWithHex(0x2B2B2B);
    _backView.layer.masksToBounds = YES;
    _backView.layer.cornerRadius = 4;
    
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    _iconImageView.hidden = YES;
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    _nameLabel.font = SCRegularFont(13);
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.contentView addSubview:self.selectedIndicatorView];
    [self.contentView addSubview:self.backView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.iconImageView];
    
    [self.selectedIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(62);
        make.center.equalTo(self.contentView);
    }];
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(60);
        make.center.equalTo(self.contentView);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backView);
        make.left.right.equalTo(self.backView);
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.backView);
    }];
}

- (void)setModel:(DVEEffectValue*)model
{
    [super setModel:model];
    _nameLabel.text = model.name;
    id<DVETextReaderModelProtocol> readerModel = (id<DVETextReaderModelProtocol>)model;
    if (readerModel.isNone) {
        self.iconImageView.hidden = NO;
        self.nameLabel.hidden = YES;
        if (model.imageURL == nil) {
            if (model.assetImage) {
                self.iconImageView.image = model.assetImage;
            } else {
                self.nameLabel.hidden = NO;
                self.nameLabel.text = @"无";
                self.iconImageView.hidden = YES;
            }
        } else {
            [self.iconImageView sd_setImageWithURL:model.imageURL];
        }
    } else {
        self.nameLabel.hidden = NO;
        self.iconImageView.hidden = YES;
        self.iconImageView.image = nil;
    }
}

- (void)setStickerSelected:(BOOL)stickerSelected animated:(BOOL)animated
{
    [super setStickerSelected:stickerSelected animated:animated];
    
    if (stickerSelected) {
        self.selectedIndicatorView.hidden = NO;
    } else {
        self.selectedIndicatorView.hidden = YES;
    }
}


@end
