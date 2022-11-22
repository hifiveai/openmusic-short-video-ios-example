//
//  DVEAudioFadeInOutBar.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/28.
//

#import "DVEAudioFadeInOutBar.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEUIHelper.h"
#import "NSString+VEToImage.h"
#import "DVELoggerImpl.h"
#import "DVEEffectsBarBottomView.h"
#import <NLEPlatform/NLETrackSlot+iOS.h>
#import <NLEPlatform/NLESegmentAudio+iOS.h>
#import <NLEPlatform/NLESegmentVideo+iOS.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>
#import "DVENormalSliderView.h"
#import "DVEVCContext.h"

@interface DVEAudioFadeInOutBar ()<NLEEditorDelegate>

///底部区域
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UILabel *fadeInLabel;
@property (nonatomic, strong) UILabel *fadeOutLabel;

@property (nonatomic, strong) DVENormalSliderView *fadeInSlider;
@property (nonatomic, strong) DVENormalSliderView *fadeOutSlider;

@property (nonatomic, weak) NLETrackSlot_OC *curSlot;
@property (nonatomic) BOOL isValueChanged;

@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;

@end

@implementation DVEAudioFadeInOutBar

DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)

- (void)dealloc
{
    DVELogInfo(@"DVEAudioFadeInOutBar dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self buildLayout];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
   
}

- (void)buildLayout
{
    [self addSubview:self.fadeInLabel];
    [self addSubview:self.fadeOutLabel];
    
    [self addSubview:self.fadeInSlider];
    [self addSubview:self.fadeOutSlider];
    
    self.fadeInLabel.left = 36;
    self.fadeInLabel.top = 20;
    
    self.fadeOutLabel.left = self.fadeInLabel.left;
    self.fadeOutLabel.top = self.fadeInLabel.bottom + 20;
    
    self.fadeInSlider.left = 100;
    self.fadeOutSlider.left = self.fadeInSlider.left;
    
    self.fadeInSlider.centerY = self.fadeInLabel.centerY;
    self.fadeOutSlider.centerY = self.fadeOutLabel.centerY;
    
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
}

- (UIView*)bottomView
{
    if(!_bottomView) {
        @weakify(self);
        _bottomView = [DVEEffectsBarBottomView newActionBarWithTitle:@"淡化" action:^{
            @strongify(self);
            if (self.isValueChanged) {
                
            }

            [self dismiss:YES];

        }];
    }
    return _bottomView;
}

- (UILabel *)fadeInLabel
{
    if (!_fadeInLabel) {
        _fadeInLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 48, 20)];
        _fadeInLabel.textColor = [UIColor whiteColor];
        _fadeInLabel.font = SCRegularFont(12);
        _fadeInLabel.textAlignment = NSTextAlignmentCenter;
        _fadeInLabel.text = NLELocalizedString(@"ck_audio_fade_in", @"淡入时长") ;
    }
    
    return _fadeInLabel;
}

- (UILabel *)fadeOutLabel
{
    if (!_fadeOutLabel) {
        _fadeOutLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 48, 20)];
        _fadeOutLabel.textColor = [UIColor whiteColor];
        _fadeOutLabel.font = SCRegularFont(12);
        _fadeOutLabel.textAlignment = NSTextAlignmentCenter;
        _fadeOutLabel.text = NLELocalizedString(@"ck_audio_fade_out", @"淡出时长");
    }
    
    return _fadeOutLabel;
}


- (DVENormalSliderView *)fadeInSlider
{
    if (!_fadeInSlider) {
        _fadeInSlider = [[DVENormalSliderView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH - 100 - 46, 30)];
        [_fadeInSlider.slider addTarget:self action:@selector(fadeInSliderChanged:) forControlEvents:UIControlEventTouchUpInside];// 针对值变化添加响应方法
        _fadeInSlider.value = 0.8;
       
    }
    
    return _fadeInSlider;
}

- (DVENormalSliderView *)fadeOutSlider
{
    if (!_fadeOutSlider) {
        _fadeOutSlider = [[DVENormalSliderView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH - 100 - 46, 30)];
        
        [_fadeOutSlider.slider addTarget:self action:@selector(fadeOutSliderChanged:) forControlEvents:UIControlEventTouchUpInside];// 针对值变化添加响应方法
        _fadeOutSlider.value = 0.8;
    }
    
    return _fadeOutSlider;
}

- (void)setVcContext:(DVEVCContext *)vcContext
{
    [super setVcContext:vcContext];
    
    [self.nleEditor addDelegate:self];
}

- (void)nleEditorDidChange:(NLEEditor_OC *)editor
{
    self.curSlot = nil;
    NLETrackSlot_OC *curSlot = [self updateCurSlot];
    
    CGFloat fadeInLenth = 0;
    CGFloat fadeOutLenth = 0;
    CGFloat duration = 1;
    if ([curSlot.segment isKindOfClass:[NLESegmentAudio_OC class]]) {
        NLESegmentAudio_OC *segment = (NLESegmentAudio_OC *)(curSlot.segment);
        fadeInLenth = CMTimeGetSeconds(segment.fadeInLength);
        fadeOutLenth = CMTimeGetSeconds(segment.fadeOutLength);
        duration = CMTimeGetSeconds(segment.duration);
        
        float max = 10;
        if (duration < 10) {
            max = duration;
        }
        
        [self.fadeInSlider setValueRange:DVEMakeFloatRang(0, max) defaultProgress:fadeInLenth];
        [self.fadeOutSlider setValueRange:DVEMakeFloatRang(0, max) defaultProgress:fadeOutLenth];
        
        self.curSlot = curSlot;
    } else {
        [self.fadeInSlider setValueRange:DVEMakeFloatRang(0, 1) defaultProgress:0];
        [self.fadeOutSlider setValueRange:DVEMakeFloatRang(0, 1) defaultProgress:0];
        
        self.curSlot = nil;
    }
}

- (void)showInView:(UIView *)view animation:(BOOL)animation
{
    [super showInView:view animation:animation];
    self.curSlot = nil;
    NLETrackSlot_OC *curSlot = [self updateCurSlot];
    
    CGFloat fadeInLenth = 0;
    CGFloat fadeOutLenth = 0;
    CGFloat duration = 1;
    if ([curSlot.segment isKindOfClass:[NLESegmentAudio_OC class]]) {
        NLESegmentAudio_OC *segment = (NLESegmentAudio_OC *)(curSlot.segment);
        fadeInLenth = CMTimeGetSeconds(segment.fadeInLength);
        fadeOutLenth = CMTimeGetSeconds(segment.fadeOutLength);
        duration = CMTimeGetSeconds(segment.duration);
        
        float max = 10;
        if (duration < 10) {
            max = duration;
        }
        
        [self.fadeInSlider setValueRange:DVEMakeFloatRang(0, max) defaultProgress:fadeInLenth];
        [self.fadeOutSlider setValueRange:DVEMakeFloatRang(0, max) defaultProgress:fadeOutLenth];
        
        self.curSlot = curSlot;
    } else {
        [self.fadeInSlider setValueRange:DVEMakeFloatRang(0, 1) defaultProgress:0];
        [self.fadeOutSlider setValueRange:DVEMakeFloatRang(0, 1) defaultProgress:0];
        
        self.curSlot = nil;
    }
}


- (void)undoRedoWillClikeByUser
{
    if (self.isValueChanged) {
        
        [self.actionService commitNLE:YES];
    }
}

- (void)undoRedoClikedByUser
{
    self.curSlot = nil;
    NLETrackSlot_OC *curSlot = [self updateCurSlot];
    
    CGFloat fadeInLenth = 0;
    CGFloat fadeOutLenth = 0;
    CGFloat duration = 1;
    if ([curSlot.segment isKindOfClass:[NLESegmentAudio_OC class]]) {
        NLESegmentAudio_OC *segment = (NLESegmentAudio_OC *)(curSlot.segment);
        fadeInLenth = CMTimeGetSeconds(segment.fadeInLength);
        fadeOutLenth = CMTimeGetSeconds(segment.fadeOutLength);
        duration = CMTimeGetSeconds(segment.duration);
        
        float max = 10;
        if (duration < 10) {
            max = duration;
        }
        
        [self.fadeInSlider setValueRange:DVEMakeFloatRang(0, max) defaultProgress:fadeInLenth];
        [self.fadeOutSlider setValueRange:DVEMakeFloatRang(0, max) defaultProgress:fadeOutLenth];
        
        self.curSlot = curSlot;
    } else {
        [self.fadeInSlider setValueRange:DVEMakeFloatRang(0, 1) defaultProgress:0];
        [self.fadeOutSlider setValueRange:DVEMakeFloatRang(0, 1) defaultProgress:0];
        
        self.curSlot = nil;
    }
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

- (void)fadeInSliderChanged:(id)slider
{
    NLETrackSlot_OC *curSlot = [self updateCurSlot];
    
    
    if ([curSlot.segment isKindOfClass:[NLESegmentAudio_OC class]]) {
        NLESegmentAudio_OC *segment = (NLESegmentAudio_OC *)(curSlot.segment);
        [segment setFadeInLength:CMTimeMake(self.fadeInSlider.value * 1000, 1000)];
        [self.actionService commitNLE:YES];
        
        [self.vcContext.playerService playFrom:curSlot.startTime duration:CMTimeGetSeconds(curSlot.duration) completeBlock:nil];
    }
}

- (void)fadeOutSliderChanged:(id)slider
{
    NLETrackSlot_OC *curSlot = [self updateCurSlot];
    
    
    if ([curSlot.segment isKindOfClass:[NLESegmentAudio_OC class]]) {
        NLESegmentAudio_OC *segment = (NLESegmentAudio_OC *)(curSlot.segment);
        [segment setFadeOutLength:CMTimeMake(self.fadeOutSlider.value * 1000, 1000)];
        [self.actionService commitNLE:YES];
        
        [self.vcContext.playerService playFrom:curSlot.startTime duration:CMTimeGetSeconds(curSlot.duration) completeBlock:nil];
    }
}

@end
