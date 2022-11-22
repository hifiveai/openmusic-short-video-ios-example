//
//  HFMusicListTableViewCell.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/14.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "HFMusicListTableViewCell.h"
#import "HFMusicListCellModel.h"
#import <SDWebImage/SDWebImage.h>
#import "HFConfigModel.h"
#import <Lottie/Lottie.h>

@interface HFMusicListTableViewCell ()

@property (nonatomic ,strong) HFMusicListCellModel *model;

@property (nonatomic ,strong) UIImageView *picImageView;
@property (nonatomic ,strong) UILabel *nameLabel;
@property (nonatomic ,strong) UILabel *tagLabel;
@property (nonatomic ,strong) UILabel *timeLabel;
@property (nonatomic ,strong) UIButton *downLoadButton;
@property (nonatomic ,strong) LOTAnimationView *loadingView;
@property (nonatomic ,strong) UIButton *canUseButton;

@property (nonatomic ,strong) UIButton *playButton;

@end

@implementation HFMusicListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubviews];
        [self makeLayoutSubviews];
        [self addActions];
        [self configCell];
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.nameLabel.attributedText = [self.model selelctNameLabelText];
        self.playButton.hidden = NO;
    }else {
        self.nameLabel.attributedText = [self.model nameLabelText];
        self.playButton.hidden = YES;
    }
}
- (void)addSubviews {
    [self.contentView addSubview:self.picImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.tagLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.downLoadButton];
    [self.contentView addSubview:self.loadingView];
    [self.contentView addSubview:self.canUseButton];
    [self.picImageView addSubview:self.playButton];
}
- (void)makeLayoutSubviews {
    [self.picImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(64, 64));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.picImageView.mas_trailing).offset(12);
        make.top.mas_equalTo(7);
        make.height.mas_equalTo(20);
        make.trailing.mas_equalTo(-56);
    }];
    
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.picImageView.mas_trailing).offset(12);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(2);
        make.height.mas_equalTo(16);
        make.trailing.mas_equalTo(-85);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.picImageView.mas_trailing).offset(12);
        make.bottom.mas_equalTo(-7);
        make.height.mas_equalTo(16);
        make.trailing.mas_equalTo(-56);
    }];
    
    [self.downLoadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-20);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-20);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [self.canUseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-20);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(62, 28));
    }];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(28, 28));
    }];
}


- (void)addActions {
    [self.canUseButton addTarget:self action:@selector(useAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)useAction:(UIButton *)btn {
    if (self.useActionBlock) {
        self.useActionBlock(self.model);
    }
}
- (void)configCell {
    self.contentView.backgroundColor = [UIColor blackColor];
    
    self.canUseButton.titleLabel.font = [HFConfigModel bodyFont];
    self.canUseButton.backgroundColor = [HFConfigModel usingBackColor];
    [self.canUseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.canUseButton.layer.cornerRadius = 14;
    self.canUseButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    self.canUseButton.layer.masksToBounds = YES;
    [self.canUseButton setTitle:@"使用" forState:UIControlStateNormal];
    
    [self.playButton setImage:@"icon_vevc_play".dve_toImage forState:UIControlStateNormal];
    [self.playButton setImage:@"icon_vevc_pause".dve_toImage forState:UIControlStateSelected];
}

- (void)configWith:(HFMusicListCellModel *)model {
    self.model = model;
    [self.picImageView sd_setImageWithURL:[NSURL URLWithString:model.picUrl]];
    self.nameLabel.attributedText = model.nameLabelText;
    self.tagLabel.text = model.tagLabelText;
    self.timeLabel.text = model.timeLabelText;
    if (model.hasLocalData) {
        self.canUseButton.hidden = NO;
        self.downLoadButton.hidden = YES;
        self.loadingView.hidden = YES;
        if (model.isPlaying) {
            self.playButton.selected = YES;
        }else {
            self.playButton.selected = NO;
        }
    }else {
        if (model.isDownloading) {
            [self beginLoading];
        }else {
            self.canUseButton.hidden = YES;
            self.downLoadButton.hidden = NO;
            self.loadingView.hidden = YES;
        }
        
    }
}

- (void)beginLoading {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.loadingView.hidden = NO;
        weakSelf.canUseButton.hidden = YES;
        weakSelf.downLoadButton.hidden = YES;
        [weakSelf.loadingView play];
    });
    
}
- (UIImageView *)picImageView {
    if (!_picImageView) {
        _picImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _picImageView.layer.cornerRadius = 4;
        _picImageView.layer.masksToBounds = YES;
    }
    return _picImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return _nameLabel;
}

- (UILabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tagLabel.textColor = [HFConfigModel subodyColor];
        _tagLabel.font = [HFConfigModel subBodyFont];
    }
    return _tagLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = [HFConfigModel subodyColor];
        _timeLabel.font = [HFConfigModel subBodyFont];
    }
    return _timeLabel;
}

- (UIButton *)downLoadButton {
    if (!_downLoadButton) {
        _downLoadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downLoadButton setImage:[UIImage imageNamed:@"down_icon"] forState:UIControlStateNormal];
    }
    return _downLoadButton;
}

- (UIButton *)canUseButton {
    if (!_canUseButton) {
        _canUseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _canUseButton.hidden = YES;
    }
    return _canUseButton;
}

- (LOTAnimationView *)loadingView
{
    if (!_loadingView) {
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"lv_loading_s_light" ofType:@"json"];
        LOTAnimationView * animationView = [LOTAnimationView animationWithFilePath:filePath];
        animationView.loopAnimation = YES;
        _loadingView = animationView;
        _loadingView.hidden = YES;
    }
    
    return _loadingView;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.hidden = YES;
    }
    return _playButton;
}

@end
