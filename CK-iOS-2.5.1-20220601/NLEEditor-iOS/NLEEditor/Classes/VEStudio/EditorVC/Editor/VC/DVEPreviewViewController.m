//
//  DVEPreviewViewController.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/10.
//

#import "DVEPreviewViewController.h"
#import "NSString+VEToImage.h"
#import "DVEPreview.h"
#import <DVETrackKit/DVEUILayout.h>
#import "DVECanvasVideoBorderView.h"
#import "DVEMacros.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEUIHelper.h"
#import "DVEStepSlider.h"
#import "NSString+DVEToPinYin.h"
#import <DVETrackKit/UIColor+DVEStyle.h>
#import "DVEViewController.h"
#import <DVETrackKit/NLETrack_OC+NLE.h>
#import <DVETrackKit/DVEConfig.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface DVEPreviewViewController ()

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *durationStartLabel;
@property (nonatomic, strong) UILabel *durationEndLabel;
@property (nonatomic, strong) DVEStepSlider *slider;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, assign) BOOL canvasBorderHidden;
@property (nonatomic, weak) id<DVECoreCanvasProtocol> canvasEditor;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;

@end

@implementation DVEPreviewViewController

DVEAutoInject(self.vcContext.serviceProvider, canvasEditor, DVECoreCanvasProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)

- (instancetype)initWithContext:(DVEVCContext *)vcContext
                        preview:(DVEPreview *)preview
                       isPLayed:(BOOL)isPlayed
                       parentVC:(UIViewController *)parentVC
                     closeBlock:(dispatch_block_t)closeBlock
{
    self = [super init];
    if (self) {
        self.vcContext = vcContext;
        _preview = preview;
        _isPlayed = isPlayed;
        _parentVC = parentVC;
        _closeBlock = closeBlock;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildLayout];
    [self updatePreviewSize];
    [self updateVideoInfo];
    [self removeStickerEditBox];
    [self initSlider];
    //监听切换应用的操作，如果是本应用回到活跃状态，则触发监听。
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkAndChangePlayStatus) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)buildLayout
{
    self.view.backgroundColor = UIColor.blackColor;
    [self.view addSubview:self.preview];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.closeButton];
    
    [self.bottomView addSubview:self.playButton];
    [self.bottomView addSubview:self.durationStartLabel];
    [self.bottomView addSubview:self.durationEndLabel];
    [self.bottomView addSubview:self.slider];
    
    self.playButton.centerY = self.bottomView.height/2;
    self.durationStartLabel.centerY = self.playButton.centerY;
    self.durationEndLabel.centerY = self.playButton.centerY;
    self.slider.centerY = self.playButton.centerY;
    
    if ([DVEUILayout dve_alignmentWithName:DVEUILayoutFullScreenCloseButtonPosition] == DVEUILayoutAlignmentRight) {
        self.closeButton.centerX = MIN(VE_SCREEN_WIDTH - self.closeButton.width/2, VE_SCREEN_WIDTH - 30);
    } else {
        self.closeButton.centerX = MAX(self.closeButton.width/2, 30);
    }
        
    self.canvasBorderHidden = [self.preview.canvasBorderView isHidden];
    [self.preview hideCanvasBorder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isPlayed) {
        [self play];
    }
}

- (void)checkAndChangePlayStatus
{
    if (self.isPlayed) {
        [self play];
    }
}

#pragma mark - UI

- (UIView *)bottomView
{
    if(!_bottomView){
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, VE_SCREEN_HEIGHT - VEBottomMargn - 60, VE_SCREEN_HEIGHT, 60)];
    }
    return _bottomView;
}

- (UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [[UIButton alloc] initWithFrame:CGRectMake(10, VE_SCREEN_HEIGHT - 80, 30, 30)];
        [_playButton setImage:@"icon_vevc_play".dve_toImage forState:UIControlStateNormal];
        [_playButton setImage:@"icon_vevc_pause".dve_toImage forState:UIControlStateSelected];
        @weakify(self);
        [[_playButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self actionMethod:x];
        }];
    }
    
    return _playButton;
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        CGSize size = [DVEUILayout dve_sizeWithName:DVEUILayoutTopBarCloseButtonSize];
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, VETopMargn, size.width, size.height)];
        [_closeButton setImage:@"icon_vevc_fullscreen_close".dve_toImage forState:UIControlStateNormal];
        @weakify(self);
        [[_closeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            CMTime time = CMTimeMake(self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC, USEC_PER_SEC);
            [self.vcContext.mediaContext updateTargetOffsetWithTime:time];
            if (!self.canvasBorderHidden) {
                [self.preview showCanvasBorderEnableGesture:YES];
            }
            [self dismissViewControllerAnimated:NO completion:^{
                if(self.closeBlock){
                    self.closeBlock();
                }
            }];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self restoreStickerEditBox];
        }];
    }
    
    return _closeButton;
}

- (UILabel *)durationStartLabel
{
    if (!_durationStartLabel) {
        _durationStartLabel = [[UILabel alloc] initWithFrame:CGRectMake(_playButton.right + 5, 0, 50, 30)];
        _durationStartLabel.textColor = [UIColor whiteColor];
        _durationStartLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        _durationStartLabel.textAlignment = NSTextAlignmentRight;
    }
    
    return _durationStartLabel;
}

- (UILabel *)durationEndLabel
{
    if (!_durationEndLabel) {
        _durationEndLabel = [[UILabel alloc] initWithFrame:CGRectMake(VE_SCREEN_WIDTH - 80, 0, 50, 30)];
        _durationEndLabel.textColor = [UIColor whiteColor];
        _durationEndLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        _durationEndLabel.textAlignment = NSTextAlignmentRight;
    }
    
    return _durationEndLabel;
}

- (DVEStepSlider *)slider
{
    if (!_slider) {
        _slider = [[DVEStepSlider alloc] initWithStep:1 defaultValue:0 frame:CGRectMake(_durationStartLabel.right + 10, 0, _durationEndLabel.left -  _durationStartLabel.right - 10, 30)];
        _slider.minimumValue = 0;
        _slider.maximumValue = 1;
        _slider.maximumTrackTintColor = [UIColor dve_colorWithName:DVEUIColorSliderBackground];
        _slider.minimumTrackTintColor = [UIColor dve_themeColor];
        _slider.value = self.vcContext.playerService.currentPlayerTime / self.vcContext.playerService.updateVideoDuration;// 设置初始值
        _slider.slider.label.hidden = YES;
    }
    return _slider;
}

- (void)setVcContext:(DVEVCContext *)vcContext
{
    _vcContext = vcContext;
    @weakify(self);
    //监听PreView的播放时间的变化
    [_vcContext.playerService setPlayerTimeChangBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self updateVideoInfo];
        });
        
    }];
    //监听PreView的播放状态
    [_vcContext.playerService setPlayerStatuseChangBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self updateVideoInfo];
        });
    }];
    //监听是否播放完成
    [_vcContext.playerService setPlayerCompleteBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            self.isPlayed = NO;
            [self updateVideoInfo];
            if ([DVEConfig dve_enableWithName:DVEConfigFullScreenLoopPlay] == YES) {
                [self replay];
            }
        });
    }];
}

#pragma mark - UI响应事件

- (void)initSlider
{
    @weakify(self);
    //拖动进度条时，松开手指的手势监听
    [[self.slider rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self sliderValueChanged];
        //如果之前处于播放状态，则继续播放。反之，则否。
        if (self.isPlayed) {
            [self play];
        }
    }];
    
    //拖动进度条时，进度条数值变化的监听
    [[self.slider rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self sliderValueChanged];
    }];
}

- (void)sliderValueChanged
{
    float sliderPercent = self.slider.value;
    CMTime time = CMTimeMake(self.vcContext.playerService.updateVideoDuration * sliderPercent * 1000, 1000);
    //预览界面seek到指定时间
    [self.vcContext.playerService seekToTime:time isSmooth:NO];
    //主视频轨道seek到指定位置
    [self.vcContext.mediaContext updateTargetOffsetWithTime:time];
    //播放状态下，如果slider滑块接近最左侧
    if (self.isPlayed && fabs(CMTimeGetSeconds(time) - 0) < 0.01) {
        [self play];
    //播放状态下，如果slider滑块接近最右侧
    } else if (self.isPlayed && fabs(CMTimeGetSeconds(time) - self.vcContext.playerService.updateVideoDuration) < 0.01) {
        _isPlayed = NO;
    }
}

- (void)updateVideoInfo
{
    NSTimeInterval duration = [self.vcContext.playerService updateVideoDuration];
    NSTimeInterval curTime = self.vcContext.playerService.currentPlayerTime;
    self.durationStartLabel.text = [NSString stringWithFormat:@"%@", [NSString DVE_timeFormatWithTimeInterval:ceil(curTime)]];
    self.durationEndLabel.text = [NSString stringWithFormat:@"%@", [NSString DVE_timeFormatWithTimeInterval:ceil(duration)]];
    self.slider.value = curTime / duration;
    self.playButton.selected = (self.vcContext.playerService.status == DVEPlayerStatusPlaying) & _isPlayed;
}

- (void)updatePreviewSize
{
    self.preview.frame = [self.canvasEditor subViewScaleAspectFit:CGRectMake(0, 0, VE_SCREEN_WIDTH, VE_SCREEN_HEIGHT)];
    [self.canvasEditor setCanvasRatio:self.canvasEditor.ratio inPreviewView:self.preview needCommit:NO];
    [self.preview refresh];
}

- (void)actionMethod:(UIButton *)button
{
    _playButton.selected = !button.selected;
    if (_playButton.selected) {
        self.isPlayed = YES;
        [self play];
    } else {
        self.isPlayed = NO;
        [self pause];
    }
}

- (void)play
{
    [self.vcContext.playerService play];
}

- (void)pause
{
    [self.vcContext.playerService pause];
}

- (void)replay
{
    CMTime time = CMTimeMake(0, 1000);
    [self.vcContext.playerService seekToTime:time isSmooth:NO];
    self.isPlayed = YES;
    [self play];
}

#pragma mark - StickerEditBox

- (void)removeStickerEditBox {
    NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel getTracks];
    DVEViewController *vc = (DVEViewController *)self.parentVC;
    //遍历全部的贴纸轨道
    for (NLETrack_OC *track in tracks) {
        if (track.extraTrackType != NLETrackSTICKER) {
            continue;
        }
        //将贴纸轨道中全部的贴纸slot，移除贴纸可编辑框
        NSArray<NLETrackSlot_OC *> *slots = [track slots];
        for (NLETrackSlot_OC *slot in slots) {
            [vc.stickerEditAdatper removeStickerBox:slot.nle_nodeId];
        }
    }
}

- (void)restoreStickerEditBox {
    NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel getTracks];
    DVEViewController *vc = (DVEViewController *)self.parentVC;
    //遍历全部的贴纸轨道
    for (NLETrack_OC *track in tracks) {
        if (track.extraTrackType != NLETrackSTICKER) {
            continue;
        }
        //将贴纸轨道中全部的贴纸slot，添加贴纸可编辑框
        NSArray<NLETrackSlot_OC *> *slots = [track slots];
        for (NLETrackSlot_OC *slot in slots) {
            [vc.stickerEditAdatper addEditBoxForSticker:slot.nle_nodeId];
        }
    }
    //处于活跃状态的编辑框设置为nil
    [vc.stickerEditAdatper activeEditBox:nil];
    //将selectTextSlot设置为nil
    [vc.stickerEditAdatper changeSelectTextSlot:nil];
}

@end
