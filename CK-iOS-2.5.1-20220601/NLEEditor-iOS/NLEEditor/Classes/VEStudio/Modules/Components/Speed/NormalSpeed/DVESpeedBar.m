//
//  DVESpeedBar.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVESpeedBar.h"
#import "DVEScaleSlider.h"
#import "NSString+VEToImage.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEMacros.h"
#import "DVEUIHelper.h"
#import "DVEButton.h"
#import "DVELoggerImpl.h"
#import <DVETrackKit/UIColor+DVEStyle.h>
#import "DVEEffectsBarBottomView.h"
#import <Masonry/View+MASAdditions.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface DVESpeedBar ()

@property (nonatomic) float lastSpeed;
@property (nonatomic) float curSpeed;
@property (nonatomic) BOOL isValueChanged;

///底部区域
@property (nonatomic, strong) DVEEffectsBarBottomView *bottomView;

@property (nonatomic, strong) UIImageView *ruleView;
@property (nonatomic, strong) DVEScaleSlider *sliderView;
@property (nonatomic, strong) UILabel *speedLable;
@property (nonatomic, strong) DVEButton *soundButton;

@property (nonatomic, assign) BOOL isRewind;///是否倒放
@property (nonatomic, assign) float value;
@property (nonatomic, assign) float speedValue;

@property (nonatomic, weak) id<DVECoreVideoProtocol> videoEditor;
@property (nonatomic, weak) id<DVECoreAudioProtocol> audioEditor;

@end

@implementation DVESpeedBar

DVEAutoInject(self.vcContext.serviceProvider, videoEditor, DVECoreVideoProtocol)
DVEAutoInject(self.vcContext.serviceProvider, audioEditor, DVECoreAudioProtocol)

- (void)dealloc
{
    DVELogInfo(@"VEVCSpeedBar dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.lastSpeed = 1;
        self.curSpeed = 1;
        [self buildLayout];
        DVEScaleValue *value1 = [[DVEScaleValue alloc] initWithCount:9 title:@"0.1x"];
        DVEScaleValue *value2 = [[DVEScaleValue alloc] initWithCount:10 title:@"1x"];
        DVEScaleValue *value3 = [[DVEScaleValue alloc] initWithCount:10 title:@"2x"];
        DVEScaleValue *value4 = [[DVEScaleValue alloc] initWithCount:10 title:@"5x"];
        DVEScaleValue *value5 = [[DVEScaleValue alloc] initWithCount:10 title:@"10x"];
        DVEScaleValue *value6 = [[DVEScaleValue alloc] initWithCount:1 title:@"100x"];
        [_sliderView showScalesWithArr:@[value1,value2,value3,value4,value5,value6]];
        _sliderView.maximumTrackTintColor = RGBACOLOR(0, 0, 0, 0.0);
        _sliderView.minimumTrackTintColor = RGBACOLOR(0, 0, 0, 0.0);
        [_sliderView setMinimumValue:0.1];
        [_sliderView setMaximumValue:100];
        
        @weakify(self);
        [[self.sliderView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            DVELogInfo(@"-----------%@",x);
            [self changToSpeed];
            
        }];
    }
    
    return self;
}


- (void)changToSpeed
{
    if (self.sliderView.value != self.lastSpeed) {
        self.isValueChanged = YES;
        float speedValue = [self convertToSpeedValue:self.sliderView.value];
        self.speedValue = speedValue;
        [self dealSoundButtonWithSpeed:speedValue];
        if([self.editingSlot.segment isKindOfClass:NLESegmentVideo_OC.class]) {
        [self.videoEditor changeVideoSpeed:self.isRewind ? -self.speedValue : self.speedValue slot:self.editingSlot isMain:self.isMainTrack shouldKeepTone:!(self.soundButton.selected || !self.soundButton.enabled)];
        }else if([self.editingSlot.segment isKindOfClass:NLESegmentAudio_OC.class]) {
            [self.audioEditor changeAudioSpeed:self.isRewind ? -self.speedValue : self.speedValue slot:self.editingSlot  shouldKeepTone:!(self.soundButton.selected || !self.soundButton.enabled)];
        }
    }
    
    self.lastSpeed = self.sliderView.value;
    
}

- (void)dealSoundButtonWithSpeed:(float)speedValue
{
    if (speedValue > 5.0) {
        self.soundButton.enabled = NO;
    } else {
        self.soundButton.enabled = YES;
    }
}

- (void)buildLayout
{
    
    [self addSubview:self.ruleView];
    [self.ruleView addSubview:self.sliderView];
    [self.ruleView addSubview:self.speedLable];
    self.speedLable.centerY = 0;
    self.ruleView.bottom = self.height - (50 - VEBottomMargnValue + VEBottomMargn) - 70;
    
    [self addSubview:self.soundButton];
    self.soundButton.top = 20;
    self.soundButton.right = VE_SCREEN_WIDTH - 25;
    
    @weakify(self);
    [[self.soundButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        x.selected = !x.selected;
        [self toggleIsNeedUpdateSound:x.selected];
            
    }];
    
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ruleView.mas_bottom).offset(40);
        make.left.right.bottom.equalTo(self);
    }];
    
}

- (void)toggleIsNeedUpdateSound:(BOOL)isneed
{
    if([self.editingSlot.segment isKindOfClass:NLESegmentVideo_OC.class]) {
        [self.videoEditor changeVideoSpeed:self.isRewind ? -self.speedValue : self.speedValue slot:self.editingSlot isMain:self.isMainTrack shouldKeepTone:!(self.soundButton.selected || !self.soundButton.enabled)];
    }else if([self.editingSlot.segment isKindOfClass:NLESegmentAudio_OC.class]) {
        [self.audioEditor changeAudioSpeed:self.isRewind ? -self.speedValue : self.speedValue slot:self.editingSlot  shouldKeepTone:!(self.soundButton.selected || !self.soundButton.enabled)];
    }
}

- (UIButton *)soundButton
{
    if (!_soundButton) {
        _soundButton = [[DVEButton alloc] initWithFrame:CGRectMake(0, 0, 67, 20)];
        [_soundButton setImage:@"icon_vevc_speed_withoutsound".dve_toImage forState:UIControlStateNormal];
        [_soundButton setImage:@"icon_vevc_speed_withsound".dve_toImage forState:UIControlStateSelected];
        [_soundButton setImage:@"icon_vevc_speed_withsound".dve_toImage forState:UIControlStateDisabled];
        [_soundButton setImage:@"icon_vevc_speed_withsound".dve_toImage forState:UIControlStateDisabled | UIControlStateSelected];
        [_soundButton setTitle:NLELocalizedString(@"ck_tone_change_speed", @"声调变速") forState:UIControlStateNormal];
        [_soundButton dve_layoutWithType:DVEButtonLayoutTypeImageLeft space:7];
        _soundButton.titleLabel.font = SCRegularFont(12);
    }
    
    return _soundButton;
}

- (UIView*)bottomView
{
    if(!_bottomView) {
        @weakify(self);
        _bottomView = [DVEEffectsBarBottomView newActionBarWithTitle:NLELocalizedString(@"ck_speed",@"速度" )  action:^{
            @strongify(self);
            if (self.isValueChanged) {
                self.isValueChanged = NO;
            }

            [self dismiss:YES];
            [DVEAutoInline(self.vcContext.serviceProvider, DVECoreActionServiceProtocol) refreshUndoRedo];
        }];

        [_bottomView setupResetBlock:^{
                    @strongify(self);
            self.value = [self convertToSliderValue:1];
            self.soundButton.selected = NO;
            [self changToSpeed];
        }];
        [_bottomView setResetButtonHidden:YES];
    }
    return _bottomView;
}


- (DVEScaleSlider *)sliderView
{
    if (!_sliderView) {
        _sliderView = [[DVEScaleSlider alloc] initWithStep:0.1 defaultValue:0.1 frame:CGRectMake(0, 0, self.width - 60, 30)];
        _sliderView.horizontalInset = 0;
        [_sliderView addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _sliderView.slider.label.hidden = YES;
    }
    
    return _sliderView;
}

- (UILabel *)speedLable
{
    if (!_speedLable) {
        _speedLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
        _speedLable.font = SCRegularFont(10);
        _speedLable.textColor = [UIColor whiteColor];
        _speedLable.textAlignment = NSTextAlignmentCenter;
    }
    
    return _speedLable;
}

- (UIImageView *)ruleView
{
    if (!_ruleView) {
        _ruleView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, VE_SCREEN_WIDTH - 60, 30)];
//        _ruleView.image = @"icon_vevc_ruler".dve_toImage;
        _ruleView.userInteractionEnabled = YES;
    }
    
    return _ruleView;
}

- (void)setEditingSlot:(NLETrackSlot_OC *)editingSlot {
    _editingSlot = editingSlot;
    float speed = 1;
    BOOL  keepTon = YES;
    if ([editingSlot.segment isKindOfClass:[NLESegmentVideo_OC class]]) {
        speed = [(NLESegmentVideo_OC *)editingSlot.segment absSpeed];
        keepTon = [(NLESegmentVideo_OC *)editingSlot.segment keepTone];
        self.isRewind = [(NLESegmentVideo_OC *)editingSlot.segment rewind];
    }
    if ([editingSlot.segment isKindOfClass:[NLESegmentAudio_OC class]]) {
        speed = [(NLESegmentAudio_OC *)editingSlot.segment absSpeed];
        keepTon = [(NLESegmentAudio_OC *)editingSlot.segment keepTone];
        self.isRewind = [(NLESegmentAudio_OC *)editingSlot.segment rewind];
    }
    self.speedValue = speed;

    if (speed > 5) {
        self.soundButton.enabled = NO;
    } else {
        self.soundButton.enabled = YES;
        if (keepTon) {

            self.soundButton.selected = NO;
        } else {
            self.soundButton.selected = YES;
        }
    }
    self.value =  [self convertToSliderValue:speed];
    [self dealSoundButtonWithSpeed:speed];
}

- (void)sliderValueChanged:(UISlider *)slider
{
    self.value = slider.value;
    
}

- (float)convertToSpeedValue:(float)sliderValue
{
    float ratio = sliderValue;
    if (sliderValue >= 0 && sliderValue < 18) {
        ratio = ((sliderValue - 0) / 18) * 0.9 + 0.1;
    } else if (sliderValue >= 18 && sliderValue < 38.5) {
        ratio = ((sliderValue - 18) / 20.5) * 1 + 1;
    } else if (sliderValue >= 38.5 && sliderValue < 59) {
        ratio = ((sliderValue - 38.5) / 20.5) * 3 + 2;
    } else if (sliderValue >= 59 && sliderValue < 79.5) {
        ratio = ((sliderValue - 59) / 20.5) * 5 + 5;
    } else if (sliderValue >= 79.5 && sliderValue < 100) {
        ratio = ((sliderValue - 79.5) / 20.5) * 90 + 10;
    }
    
    ;
    if (ratio > 100) {
        ratio = 100;
    }
    ratio = roundf(ratio * 10) / 10;
    return MAX(ratio, 0.1);
}

- (float)convertToSliderValue:(float)ratio
{
    float value = ratio;
    if (ratio >= 0.01 && ratio < 1) {
        value = ((ratio - 0.1) / 0.9) * 18;
    } else if (ratio >= 1 && ratio < 2) {
        value = ((ratio - 1) / 1) * 20.5 + 18;
    } else if (ratio >= 2 && ratio < 5) {
        value = ((ratio - 2) / 3) * 20.5 + 38.5;
    } else if (ratio >= 5 && ratio < 10) {
        value = ((ratio - 5) / 5) * 20.5 + 59;
    } else if (ratio >= 10 && ratio < 100) {
        value = ((ratio - 10) / 90) * 20.5 + 79.5;
    }
        
    return value;
}

- (void)setValue:(float)value
{
    _value = value;
    [_sliderView setValue:value];
    self.speedLable.centerX = _sliderView.left + ((self.value - self.sliderView.minimumValue)/(self.sliderView.maximumValue - self.sliderView.minimumValue)) * _sliderView.width;
    self.speedLable.text = [NSString stringWithFormat:@"%0.1fx",[self convertToSpeedValue:value]];
}

- (void)setVcContext:(DVEVCContext *)vcContext
{
    [super setVcContext:vcContext];
    [DVEAutoInline(vcContext.serviceProvider, DVECoreActionServiceProtocol) addUndoRedoListener:self];
}

- (void)undoRedoClikedByUser
{
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentBlendVideoSlot];
    [self setEditingSlot:slot];
}

@end
