//
//  HFPlayerView.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/18.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "HFPlayerView.h"
#import <SDWebImage/SDWebImage.h>
#import "HFMusicListCellModel.h"
#import "HFConfigModel.h"
#import "DVEAudioPlayer.h"
#import <HFOpenApi/HFOpenApi.h>
#import "HFPlayerConfigManager.h"
#import "SCWaveformView.h"
#import "NSString+VEToImage.h"
#import "DVECustomerHUD.h"


@interface HFPlayerView ()

@property (nonatomic ,strong) UIImageView *picImageView;
@property (nonatomic ,strong) UILabel *nameLabel;
@property (nonatomic ,strong) UIButton *collectButton;
@property (nonatomic ,strong) UILabel *currentTimeLabel;
@property (nonatomic ,strong) UILabel *totalTimeLabel;
@property (nonatomic ,strong) UIButton *downloadButton;


@property (nonatomic ,strong) HFMusicListCellModel *model;

@property (nonatomic ,assign) BOOL playing;

@property (nonatomic ,strong) SCScrollableWaveformView *waveView;

@property (nonatomic ,strong) UISlider *slider;
@end

@implementation HFPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
        [self makeLayoutSubviews];
        [self addActions];
        [self configViews];
    }
    return self;
}

- (void)addSubviews {
    [self addSubview:self.picImageView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.collectButton];
    [self addSubview:self.currentTimeLabel];
    [self addSubview:self.totalTimeLabel];
    [self addSubview:self.downloadButton];
    [self addSubview:self.waveView];
    [self addSubview:self.slider];
    [self.picImageView addSubview:self.playButton];
}

- (void)makeLayoutSubviews {
    [self.picImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.top.mas_equalTo(8);
        make.width.mas_equalTo(48);
        make.height.mas_equalTo(48);
    }];
    
    [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-20);
        make.centerY.equalTo(self.picImageView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.collectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.downloadButton.mas_leading).offset(-14);
        make.size.mas_equalTo(CGSizeMake(24, 24));
        make.centerY.equalTo(self.downloadButton);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.picImageView.mas_trailing).offset(12);
        make.centerY.equalTo(self.picImageView);
        make.height.mas_equalTo(25);
        make.trailing.equalTo(self.collectButton.mas_leading).offset(-12);
    }];
    
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.top.equalTo(self.picImageView.mas_bottom).offset(20);
//        make.width.mas_equalTo(40);
        make.height.mas_equalTo(15);
    }];
   
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-20);
        make.centerY.equalTo(self.currentTimeLabel);
//        make.width.mas_equalTo(40);
        make.height.mas_equalTo(15);
    }];
    
    [self.waveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(60);
        make.trailing.mas_equalTo(-60);
        make.height.mas_equalTo(30);
        make.centerY.equalTo(self.currentTimeLabel);
    }];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(60);
        make.trailing.mas_equalTo(-60);
        make.height.mas_equalTo(30);
        make.centerY.equalTo(self.currentTimeLabel);
    }];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(28, 28));
    }];
    
}

- (void)addActions {
    [self.collectButton addTarget:self action:@selector(collectBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    UITapGestureRecognizer *sliderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapAction:)];
    [self.slider addGestureRecognizer:sliderTap];
    [self.playButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configViews {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    self.waveView.waveformView.precision = 0.5;
    self.waveView.waveformView.lineWidthRatio = 0.4;
    self.waveView.waveformView.normalColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3200];
    self.waveView.waveformView.channelsPadding = 0;
    self.waveView.waveformView.progressColor = [UIColor colorWithRed:255/255.0 green:214/255.0 blue:0/255.0 alpha:1.0];
    self.waveView.alpha = 1;
    
    self.slider.maximumValue = 1;
    self.slider.minimumValue = 0;
    self.slider.thumbTintColor = [UIColor clearColor];
    self.slider.maximumTrackTintColor = [UIColor clearColor];
    self.slider.minimumTrackTintColor = [UIColor clearColor];
    
    [self.playButton setImage:@"icon_vevc_play".dve_toImage forState:UIControlStateNormal];
    [self.playButton setImage:@"icon_vevc_pause".dve_toImage forState:UIControlStateSelected];
}

- (void)configWithModel:(HFMusicListCellModel *)model {
    __weak typeof (self) weakSelf = self;
    
    NSLog(@"%@",[DVEAudioPlayer shareManager].curURL.absoluteString);
    if (self.model && [self.model.musicId isEqualToString:model.musicId] && [[DVEAudioPlayer shareManager].curURL.absoluteString isEqualToString:[NSURL fileURLWithPath:(self.model.pathUrl ? self.model.pathUrl : @"")].absoluteString] ) {
        /// 已经有在播放/下载的音频
        [self playAction];
        
    }else {
        /// 首次播放/下载音频
        self.model = model;
        [self.picImageView sd_setImageWithURL:[NSURL URLWithString:model.picUrl]];
        self.nameLabel.text = model.songName;
        self.currentTimeLabel.text = @"00:00";
        self.totalTimeLabel.text = model.totalTime;
        self.collectButton.selected = NO;
        for (HFMusicListCellModel *tempModel in [HFPlayerConfigManager shared].collectedArray) {
            if ([tempModel.musicId isEqualToString:model.musicId]) {
                self.collectButton.selected = YES;
                break;
            }
        }        
        self.playButton.hidden = YES;
        if (model.pathUrl) {
            self.playButton.hidden = NO;
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:model.pathUrl] options:nil];
            self.waveView.waveformView.asset = asset;
            self.waveView.waveformView.hidden = NO;
            self.waveView.waveformView.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
            self.downloadButton.hidden = YES;

            [[DVEAudioPlayer shareManager] playWithURL:[NSURL fileURLWithPath:model.pathUrl]];
            self.playing = YES;
            self.playButton.selected = YES;
            [DVEAudioPlayer shareManager].playingBlock = ^(NSTimeInterval curSec, NSTimeInterval total) {
                
                weakSelf.waveView.waveformView.progressTime =  CMTimeMakeWithSeconds(curSec, NSEC_PER_SEC);
                [weakSelf.slider setValue:curSec/total animated:YES];
                weakSelf.currentTimeLabel.text = [HFMusicListCellModel timeFormatWithTimeInterval:curSec];
                if (total - curSec < 1) {
                    [[DVEAudioPlayer shareManager] pause];
                    weakSelf.playing = NO;
                    weakSelf.currentTimeLabel.text = weakSelf.totalTimeLabel.text;
                }
            };
            [DVEAudioPlayer shareManager].completBlock = ^{
                [[DVEAudioPlayer shareManager] pause];
                weakSelf.playing = NO;
                weakSelf.currentTimeLabel.text = weakSelf.totalTimeLabel.text;
            };
        }else {
            [[DVEAudioPlayer shareManager] pause];
            self.downloadButton.hidden = NO;
            self.waveView.waveformView.hidden = YES;
        }
    }
    [HFPlayerConfigManager shared].currentPlayModel = model;
    [HFPlayerConfigManager shared].currentPlayModel.isPlaying = weakSelf.playing;
}

- (void)collectBtnAction {
    
    __weak typeof(self)weakSelf = self;
    if (self.collectButton.selected) {
        [[HFOpenApiManager shared] removeSheetMusicWithSheetId:[HFPlayerConfigManager shared].sheetId musicId:self.model.musicId success:^(id  _Nullable response) {
            weakSelf.collectButton.selected = NO;
            [[HFPlayerConfigManager shared] refreshCollectedArray];
        } fail:^(NSError * _Nullable error) {
            [DVECustomerHUD showMessage:error.localizedDescription];
        }];
    }else {
        [[HFOpenApiManager shared] addSheetMusicWithSheetId:[HFPlayerConfigManager shared].sheetId musicId:self.model.musicId success:^(id  _Nullable response) {
            weakSelf.collectButton.selected = YES;
            [[HFPlayerConfigManager shared] refreshCollectedArray];
        } fail:^(NSError * _Nullable error) {
            [DVECustomerHUD showMessage:error.localizedDescription];
        }];
    }
}

- (void)sliderAction:(UISlider *)sender {
    
    [[DVEAudioPlayer shareManager].player seekToTime:CMTimeMakeWithSeconds(sender.value * CMTimeGetSeconds(self.waveView.waveformView.actualAssetDuration) , NSEC_PER_SEC)];
}
- (void)sliderTapAction:(UITapGestureRecognizer *)sender {
    CGPoint touchPoint = [sender locationInView:self.slider];
    CGFloat value = (self.slider.maximumValue - self.slider.minimumValue) * (touchPoint.x / self.slider.frame.size.width );
    [[DVEAudioPlayer shareManager].player seekToTime:CMTimeMakeWithSeconds(value * CMTimeGetSeconds(self.waveView.waveformView.actualAssetDuration) , NSEC_PER_SEC)];
    [self.slider setValue:value animated:YES];
}


- (void)playAction {
    if (self.playing) {
        [[DVEAudioPlayer shareManager].player pause];
        self.playButton.selected = NO;
        self.playing = NO;
    }else {
        [[DVEAudioPlayer shareManager].player play];
        self.playButton.selected = YES;
        self.playing = YES;
    }
    
}

- (void)play {
    self.playing = YES;
    self.playButton.selected = YES;
}
- (void)pause {
    self.playing = NO;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.playButton.selected = NO;
    });
    
}

- (UIImageView *)picImageView {
    if (!_picImageView) {
        _picImageView = [[UIImageView alloc] init];
        _picImageView.userInteractionEnabled = YES;
    }
    return _picImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [HFConfigModel mainTitleColor];
        _nameLabel.font = [HFConfigModel palyViewNameFont];
    }
    return _nameLabel;
}

- (UIButton *)collectButton {
    if (!_collectButton) {
        _collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_collectButton setImage:[UIImage imageNamed:@"collected_nomarl"] forState:UIControlStateNormal];
        [_collectButton setImage:[UIImage imageNamed:@"collected_selected"] forState:UIControlStateSelected];
    }
    return _collectButton;
}

- (UIButton *)downloadButton {
    if (!_downloadButton) {
        _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downloadButton setImage:[UIImage imageNamed:@"down_icon"] forState:UIControlStateNormal];
    }
    return _downloadButton;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = [HFConfigModel timeColor];
        _currentTimeLabel.font = [HFConfigModel timeFont];
    }
    return _currentTimeLabel;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.textColor = [HFConfigModel timeColor];
        _totalTimeLabel.font = [HFConfigModel timeFont];
    }
    return _totalTimeLabel;
}


- (SCScrollableWaveformView *)waveView {
    if (!_waveView) {
        _waveView = [[SCScrollableWaveformView alloc] init];
       
    }
    return _waveView;
}
- (UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] init];
    }
    return _slider;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.hidden = YES;
    }
    return _playButton;
}

- (NSMutableArray *)collectedArray {
    if (!_collectedArray) {
        _collectedArray = [[NSMutableArray alloc] init];
    }
    return _collectedArray;
}


@end
