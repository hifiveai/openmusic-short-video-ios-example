//
//  DVEVideoToolBar.m
//  NLEEditor
//
//  Created by bytedance on 2021/4/14.
//

#import "DVEMacros.h"
#import "DVECropVideoToolBar.h"
#import "NSString+DVEToPinYin.h"
#import <DVETrackKit/UIView+VEExt.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface DVECropVideoToolBar ()

@property (nonatomic, assign) BOOL isPlayEnd;

@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, strong) UILabel *durationLabel;

@end

@implementation DVECropVideoToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self setUpLayout];
        _isPlayEnd = NO;
    }
    return self;
}

- (void)setVcContext:(DVEVCContext *)vcContext {
    _vcContext = vcContext;
}

- (void)setUpLayout {
    [self addSubview:self.durationLabel];
    [self addSubview:self.playButton];
    
    self.durationLabel.right = VE_SCREEN_WIDTH - 10;
    self.playButton.centerY = self.height * 0.5;
    self.durationLabel.centerY = self.playButton.centerY;
    self.playButton.centerX = self.width * 0.5;
    
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        [_playButton setImage:[@"icon_vevc_play" dve_toImage] forState:UIControlStateNormal];
        [_playButton setImage:[@"icon_vevc_pause" dve_toImage] forState:UIControlStateSelected];
        @weakify(self);
        [[_playButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self actionMethod:x];
        }];
    }
    
    return _playButton;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 25)];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.font = SCRegularFont(14);
        _durationLabel.textAlignment = NSTextAlignmentRight;
    }
    
    return _durationLabel;
}

- (void)actionMethod:(UIButton *)button {
    _playButton.selected = !button.selected;
    if (_playButton.selected) {
        [self play];
    } else {
        [self pause];
    }
}

- (void)setPlayToEnd {
    _isPlayEnd = YES;
    _playButton.selected = NO;
}

- (void)play {
    if (!self.delegate) {
        return;
    }
    if (_isPlayEnd) {
        [self.delegate videoRestartPlay];
        _isPlayEnd = NO;
    } else {
        [self.delegate videoPlay];
    }
}

- (void)pause {
    if (!self.delegate) {
        return;
    }
    [self.delegate videoPause];
}

- (void)updateVideoPlayTime:(NSTimeInterval)curTime duration:(NSTimeInterval)duration {
    self.durationLabel.text = [NSString stringWithFormat:@"%@ / %@",[NSString DVE_timeFormatWithTimeInterval:ceil(curTime)],[NSString DVE_timeFormatWithTimeInterval:ceil(duration)]];
    
}

@end
