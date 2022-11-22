//
//  DVEAudioCell.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEAudioCell.h"
#import "DVEAudioPlayer.h"
#import "NSString+DVEToPinYin.h"
#import "NSString+VEIEPath.h"
#import "NSString+VEToImage.h"
#import "DVEMacros.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVELoggerImpl.h"
#import "NSBundle+DVE.h"
#import <DVETrackKit/DVECustomResourceProvider.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <Lottie/LOTAnimationView.h>
#import <SDWebImage/UIImageView+WebCache.h>

#define topMargn 15
#define leftMargn 15

@interface DVEAudioCell ()

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) BOOL isNeedUpdate;
@property (nonatomic, strong) UIView *useView;

@end

@implementation DVEAudioCell

- (void)dealloc

{
    [[DVEAudioPlayer shareManager] pause];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    if([self.audioSource status] != DVEResourceModelStatusDefault) return;
    
    if (selected) {
        [self play];
    } else {
        [self pause];
    }
    

    // Configure the view for the selected state
    
    self.slider.hidden = !self.selected;
    self.waveImage.hidden = !self.selected;
    
    if (self.isSound) {
        self.iconView.hidden = !self.waveImage.hidden;
    }
    
    self.timeLable.hidden = !self.slider.hidden;
}

- (void)play
{
    NSURL *url = [NSURL fileURLWithPath:self.audioSource.sourcePath];
    if ([url isEqual:[DVEAudioPlayer shareManager].curURL]) {
        [[DVEAudioPlayer shareManager] pause];
        [self setSelected:NO animated:YES];
    } else {
        [[DVEAudioPlayer shareManager] playWithURL:url];
        @weakify(self);
        [[DVEAudioPlayer shareManager] setCompletBlock:^{
            @strongify(self);
            [self setSelected:NO animated:YES];
        }];
        [[DVEAudioPlayer shareManager] setPlayingBlock:^(NSTimeInterval curSec, NSTimeInterval total) {
            @strongify(self);
            if (isnan(total)) {
                return;
            }
            self.duration = total;
            
            CGFloat value = (curSec / total);
            if (value < 0) {
                value = 0;
            }
            if (value > 1) {
                value = 1;
            }
            if (self.isNeedUpdate) {
                [self.slider setValue:value * 100] ;
            }
            
        }];
        self.isNeedUpdate = YES;
    }
    
}

- (void)pause
{
    [[DVEAudioPlayer shareManager] pause];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
        [self buildLayout];
        
    }
    
    return self;
}

- (void)buildLayout
{
    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.waveImage];
    [self.contentView addSubview:self.titleLable];
    [self.contentView addSubview:self.desLable];
    [self.contentView addSubview:self.timeLable];
    [self.contentView addSubview:self.useButton];
    [self.contentView addSubview:self.slider];
    
    self.useButton.right = VE_SCREEN_WIDTH - 15;
    self.useButton.top = 29;
    
    @weakify(self);
    [[[self.useButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        if([self.audioSource status] == DVEResourceModelStatusDefault){
            if (self.addBlock) {
                self.addBlock(self.indexPath);
            }
        }else if([self.audioSource status] == DVEResourceModelStatusNeedDownlod){
            @weakify(self);
            if([self.audioSource loadWithUserInfo:self.indexPath Handler:^(id  _Nonnull userInfo) {
                @strongify(self);
                @weakify(self);
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    NSIndexPath* indexPath = (NSIndexPath*)userInfo;
                    [[self tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                });
            }]){
                [self updateActionView];
            }
        }

    }];
    
    self.contentView.backgroundColor = [UIColor blackColor];
}

///获取依附tableView
-(UITableView*)tableView
{
    id view = [self superview];

    while (view && [view isKindOfClass:[UITableView class]] == NO) {
        view = [view superview];
    }

    return (UITableView *)view;
}

- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(leftMargn, topMargn, 55, 55)];
        _iconView.image = @"icon_vevc_auido_temp".dve_toImage;
    }
    
    return _iconView;
}

- (LOTAnimationView *)waveImage
{
    if (!_waveImage) {
        LOTAnimationView * animationView = [LOTAnimationView animationNamed:@"music(old)" inBundle:[NSBundle dve_mainBundle]];
        animationView.loopAnimation = YES;
        animationView.frame = _iconView.frame;
        
        [animationView play];
        _waveImage = animationView;
        _waveImage.hidden = YES;
    }
    
    return _waveImage;
}

- (UILabel *)titleLable
{
    if (!_titleLable) {
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(_iconView.right + 14, 17 , VE_SCREEN_WIDTH - _iconView.right - 14 - 90, 18)];
        _titleLable.font = SCRegularFont(14);
        _titleLable.textColor = [UIColor whiteColor];
    }
    
    return _titleLable;
}

- (UILabel *)desLable
{
    if (!_desLable) {
        _desLable = [[UILabel alloc] initWithFrame:CGRectMake(_titleLable.left, _titleLable.bottom + 4, _titleLable.width, 14)];
        _desLable.font = SCRegularFont(12);
        _desLable.textColor = RGBACOLOR(255, 255, 255, 0.5);
    }
    
    return _desLable;
}

- (UILabel *)timeLable
{
    if (!_timeLable) {
        _timeLable = [[UILabel alloc] initWithFrame:CGRectMake(_titleLable.left, _desLable.bottom + 3,_titleLable.width , 14)];
        _timeLable.font = SCRegularFont(12);
        _timeLable.textColor = RGBACOLOR(255, 255, 255, 0.5);
    }
    
    return _timeLable;
}

- (DVEStepSlider *)slider
{
    if (!_slider) {
        _slider = [[DVEStepSlider alloc] initWithStep:1 defaultValue:0 frame:CGRectMake(_titleLable.left, _timeLable.top , _timeLable.width, _timeLable.height)];
        _slider.slider.label.hidden = YES;
        _slider.maximumTrackTintColor = RGBACOLOR(255, 255, 255, 100);
        _slider.minimumTrackTintColor = [UIColor dve_themeColor];
        [_slider.slider setImageCursor:@"icon_slider_dot_yellow".dve_toImage];
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];// 针对值变化添加响应方法
        @weakify(self);
        [[_slider rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            self.isNeedUpdate = NO;
            
        }];
        
        [_slider setMinimumValue:0];
        [_slider setMaximumValue:100];
        _slider.hidden = YES;
    }
    
    return _slider;
}

- (UIButton *)useButton
{
    if (!_useButton) {
        _useButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 27)];
    }
    
    return _useButton;
}

- (void)sliderValueChanged:(UIControl *)value
{
    self.isNeedUpdate = YES;
    DVELogInfo(@"now should seek to here value: %0.2f",self.slider.value);
    NSTimeInterval t = self.slider.value * self.duration * 0.01;
    [[DVEAudioPlayer shareManager].player seekToTime:CMTimeMake(t * 10, 10)];
}


- (void)setAudioSource:(id<DVEResourceMusicModelProtocol>)audioSource
{
    _audioSource = audioSource;

    self.titleLable.text = audioSource.name;
    _desLable.text = audioSource.singer;

    [self updateActionView];
    
    _timeLable.text = [NSString DVE_timeFormatWithTimeInterval:[DVEAudioPlayer durationWithPath:audioSource.sourcePath]];
    [_iconView sd_setImageWithURL:audioSource.imageURL placeholderImage:audioSource.assetImage];
}

-(void)updateActionView
{
    UIView* actionView = [self.audioSource actionView:self.useView];
    if(actionView != self.useView){
        [self.useView removeFromSuperview];
        self.useView = actionView;
        actionView.userInteractionEnabled = NO;
        
        CGPoint center = self.useButton.center;
        CGRect frame = CGRectMake(0, 0, actionView.width, actionView.height);
        actionView.frame = frame;
        
        self.useButton.frame = frame;
        self.useButton.center = center;
        [self.useButton addSubview:actionView];
    }
}

@end
