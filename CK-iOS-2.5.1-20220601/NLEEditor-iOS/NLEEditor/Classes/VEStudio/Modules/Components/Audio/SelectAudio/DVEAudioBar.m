//
//  DVEAudioBar.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEAudioBar.h"
#import <DVETrackKit/UIView+VEExt.h>
#import <DVETrackKit/DVECustomResourceProvider.h>
#import "DVEUIHelper.h"
#import "NSString+VEToImage.h"
#import "DVELoggerImpl.h"
#import "DVEEffectsBarBottomView.h"
#import <NLEPlatform/NLETrackSlot+iOS.h>
#import <NLEPlatform/NLESegmentAudio+iOS.h>
#import <NLEPlatform/NLESegmentVideo+iOS.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>

@interface DVEAudioBar () <DVEVideoKeyFrameProtocol>

@property (nonatomic) float lastSpeed;
@property (nonatomic) float curSpeed;
@property (nonatomic) BOOL isValueChanged;

///底部区域
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UISlider *sliderView;
@property (nonatomic, strong) UILabel *speedLable;

@property (nonatomic, assign) float value;

@property (nonatomic, weak) NLETrackSlot_OC *curSlot;

@property (nonatomic, weak) id<DVECoreVideoProtocol> videoEditor;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;

@end

@implementation DVEAudioBar

DVEAutoInject(self.vcContext.serviceProvider, videoEditor, DVECoreVideoProtocol)
DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)

- (void)dealloc
{
    DVELogInfo(@"VEVCAudioBar dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.lastSpeed = 100;
        self.curSpeed = 100;
        [self buildLayout];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateSpeedLabel:self.value];
}

- (void)buildLayout
{

    [self addSubview:self.speedLable];
    
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    [self addSubview:self.sliderView];
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(30);
        make.right.equalTo(self).offset(-30);
        make.bottom.equalTo(self.bottomView.mas_top).offset(-30);
        make.height.mas_equalTo(30);
    }];
}

- (UIView*)bottomView
{
    if(!_bottomView) {
        @weakify(self);
        _bottomView = [DVEEffectsBarBottomView newActionBarWithTitle:NLELocalizedString(@"ck_volume", @"音量") action:^{
            @strongify(self);
            [self.actionService commitNLE:YES];
            [self dismiss:YES];

        }];
    }
    return _bottomView;
}

- (UISlider *)sliderView
{
    if (!_sliderView) {
        _sliderView = [UISlider new];
        [_sliderView setThumbImage:@"btn_slidebar_gray".dve_toImage forState:UIControlStateNormal];
        _sliderView.maximumTrackTintColor = RGBACOLOR(0, 0, 0, 0.6);
        _sliderView.minimumTrackTintColor = [UIColor dve_themeColor];
        [_sliderView setMinimumValue:0];
        [_sliderView setMaximumValue:200];
        [_sliderView addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];// 针对值变化添加响应方法
        [_sliderView addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
    }
    
    return _sliderView;
}

- (UILabel *)speedLable
{
    if (!_speedLable) {
        _speedLable = [UILabel new];
        _speedLable.font = SCRegularFont(10);
        _speedLable.textColor = [UIColor whiteColor];
        _speedLable.textAlignment = NSTextAlignmentCenter;
    }
    
    return _speedLable;
}


- (void)sliderValueChanged:(UISlider *)slider
{
    self.value = slider.value;
    self.isValueChanged = YES;
    
    if (self.value > 0) {
        NLETrackSlot_OC *curSlot = [self updateCurSlot];
        if ([curSlot.segment isKindOfClass:[NLESegmentVideo_OC class]]) {
            NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)(curSlot.segment);
            //当有关键帧时不设置开启原声
            if ([curSlot getKeyframe].count <= 0) {
                [segment setEnableAudio:YES];
            }
        }
    } else {
        NLETrackSlot_OC *curSlot = [self updateCurSlot];
        if ([curSlot.segment isKindOfClass:[NLESegmentVideo_OC class]]) {
            NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)(curSlot.segment);
            //当有关键帧时不设置关闭原声
            if ([curSlot getKeyframe].count <= 0) {
                [segment setEnableAudio:NO];
            }
        }
    }
    
}

- (void)setValue:(float)value
{
    [self updateSliderAndLabelWithValue:value];
    if (self.curSlot) {
        [self.videoEditor changeVideoVolume:value * 0.01 slot:self.editingSlot isMain:self.isMainTrack];
    }
}

- (void)updateSliderAndLabelWithValue:(float)value {
    _value = value;
    [_sliderView setValue:value];
    [self updateSpeedLabel:value];
}

- (void)updateSpeedLabel:(float)value
{
    self.speedLable.text = [NSString stringWithFormat:@"%0.1f",value];
    [self.speedLable sizeToFit];
    CGRect rect = [self sliderValueThumbPosition:value];
    self.speedLable.center = CGPointMake(CGRectGetMidX(rect) + 30, self.sliderView.bottom + 10);
}

-(CGRect)sliderValueThumbPosition:(NSInteger)value{
    CGRect trackRect = [self.sliderView trackRectForBounds:self.sliderView.bounds];
    return [self.sliderView thumbRectForBounds:self.sliderView.bounds
                               trackRect:trackRect
                                   value:value];
}

- (void)setVcContext:(DVEVCContext *)vcContext {
    [super setVcContext:vcContext];
    self.videoEditor.keyFrameDeleagte = self;
}

- (void)showInView:(UIView *)view animation:(BOOL)animation
{
    if (view) {
        [view addSubview:self];
    }
    self.curSlot = nil;
    NLETrackSlot_OC *curSlot = [self updateCurSlot];
    float volum = 1;
    if ([curSlot.segment isKindOfClass:[NLESegmentVideo_OC class]]) {
        NLESegmentVideo_OC *slot = (NLESegmentVideo_OC *)(curSlot.segment);
        volum = slot.volume;
        if (![slot hasEnableAudio]) {
            volum = 0;
        }
    } else if ([curSlot.segment isKindOfClass:[NLESegmentAudio_OC class]]) {
        NLESegmentAudio_OC *slot = (NLESegmentAudio_OC *)(curSlot.segment);
        volum = slot.volume;
    } else {
        volum = 1;
    }
    
    self.value = volum * 100;
    self.curSlot = curSlot;
}

- (void)undoRedoWillClikeByUser
{
    if (self.isValueChanged) {
        [self.videoEditor changeVideoVolume:self.value*0.01 slot:self.editingSlot isMain:self.isMainTrack];

        [self dismiss:YES];
        [self.actionService refreshUndoRedo];
        [self.actionService commitNLE:YES];
    }
}

- (void)undoRedoClikedByUser
{
    self.curSlot = nil;
    NLETrackSlot_OC *curSlot = [self updateCurSlot];
    float volum = 1;
    if ([curSlot.segment isKindOfClass:[NLESegmentVideo_OC class]]) {
        NLESegmentVideo_OC *slot = (NLESegmentVideo_OC *)(curSlot.segment);
        volum = slot.volume;
        if (![slot hasEnableAudio]) {
            volum = 0;
        }
    } else if ([curSlot.segment isKindOfClass:[NLESegmentAudio_OC class]]) {
        NLESegmentAudio_OC *slot = (NLESegmentAudio_OC *)(curSlot.segment);
        volum = slot.volume;
    } else {
        volum = 1;
    }
    
    self.value = volum * 100;
    self.curSlot = curSlot;
}

- (NLETrackSlot_OC *)updateCurSlot
{
    NLETrackSlot_OC *curSlot = nil;
    self.isMainTrack = NO;
    if (self.vcContext.mediaContext.selectAudioSegment) {
        curSlot = self.vcContext.mediaContext.selectAudioSegment;
    } else {
        if (self.vcContext.mediaContext.selectMainVideoSegment) {
            self.isMainTrack = YES;
            curSlot = self.vcContext.mediaContext.selectMainVideoSegment;
        } else if (self.vcContext.mediaContext.selectBlendVideoSegment) {
            curSlot = self.vcContext.mediaContext.selectBlendVideoSegment;
        }
    }
    
    return curSlot;
}

#pragma mark - DVEVideoKeyFrameProtocol

- (void)videoKeyFrameDidChangedWithSlot:(NLETrackSlot_OC *)slot {
    if (!slot) {
        return;
    }
    
    if (CMTimeCompare(self.vcContext.mediaContext.currentTime, slot.startTime) < 0 || CMTimeCompare(self.vcContext.mediaContext.currentTime, slot.endTime) > 0) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //关闭原声时不响应关键帧回调参数，当且仅当打开面板没有操作滑杆时更改滑杆值为0
        NLESegmentVideo_OC *videoSegment = (NLESegmentVideo_OC *)slot.segment;
        BOOL disableAudio = videoSegment && [slot.segment isKindOfClass:[NLESegmentVideo_OC class]] &&
        ![videoSegment hasEnableAudio];
        if (disableAudio && !DVE_FLOAT_EQUAL_TO(self.value, 0.0f)) {
            [self updateSliderAndLabelWithValue:0.0f];
            return;
        }
        
        NLESegmentAudio_OC *audioSegment = (NLESegmentAudio_OC *)slot.segment;
        if (audioSegment && fabs(self.value - audioSegment.volume * 100) >= 0.1) {
            [self updateSliderAndLabelWithValue:audioSegment.volume * 100];
        }
    });
}

@end
