//
//  VECPBottomBar.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECPBottomBar.h"
#import "VECircleProgressView.h"
#import "VEEFilterView.h"
#import "VEEStickerView.h"
#import "VEEBeautyView.h"
#import <AVFoundation/AVFoundation.h>
#import "VECPRecordParmView.h"
#import "VECPBottomBox.h"
#import <SGPagingView/SGPagingView.h>
#import "UIImage+Rotation.h"
#import "VEPhotoPreviewVC.h"
#import "DVEBundleLoader.h"
#import "UIView+VEExt.h"
#import "VECustomerHUD.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "VEResourceLoader.h"
#import "VEResourcePicker.h"
#import "VENLEEditorServiceContainer.h"
#import <NLEEditor/DVEUIFactory.h>
#import <SDWebImage/SDWebImage.h>
#import <NLEEditor/DVEViewController.h>

#define  itemW  60.0
#define focusebutton_W 32
#define focusebutton_H 32
#define button_W 50
#define button_H 50
#define VECap_capButton_normalW 68
#define VECap_capButton_normalH 68
#define VECap_capButton_lW 42
#define VECap_capButton_lH 42

#define VECap_recordButton_normalW 68
#define VECap_recordButton_normalH 68
#define VECap_recordButton_lW 42
#define VECap_recordButton_lH 42


#define button_centerY 122

#define DVE_IsExportBeforeEditor 0

@interface VECPBottomBar ()<SGPageTitleViewDelegate>

@property (nonatomic, strong) SGPageTitleView *titleView;
@property (nonatomic, strong) UIButton *focuseButton;
@property (nonatomic, strong) UIButton *duetButton;
@property (nonatomic, strong) UIButton *duetSwichButton;
@property (nonatomic, strong) VECPBottomBox *bottomBox;

#pragma mark pic
@property (nonatomic, strong) UIButton *picButton;

#pragma mark video
@property (nonatomic, strong) VECircleProgressView *progressView;
@property (nonatomic, strong) UIButton *actionButton;

@property (nonatomic, strong) UIButton *stickerButton;
@property (nonatomic, strong) UIButton *filterButton;
@property (nonatomic, strong) UIButton *beautyButton;

@property (nonatomic, strong) VEEFilterView *filterBox;
@property (nonatomic, strong) VEEStickerView *stickerBox;
@property (nonatomic, strong) VEEBeautyView *beautyBox;

@property (nonatomic, strong) VECPRecordParmView *parmView;

@property (nonatomic, assign) NSInteger curIndex;
@property (nonatomic, assign) NSTimeInterval lastDuration;

@property (nonatomic, strong) DVEEffectValue *lastDuetValue;

@property (nonatomic, weak) UIViewController *vc;

@end

@implementation VECPBottomBar

@synthesize viewType = _viewType;
@synthesize capManager = _capManager;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collecView.hidden = YES;
        self.curIndex = 0;
        [self buildLayout];
        
        @weakify(self);
        self.cpResultBlock = ^(VESourceValue * _Nonnull oneSource) {
            @strongify(self);
            if (oneSource.type == VESourceValueTypeImage && self.capManager.boxState == VECPBoxStateInprocess) {
                [self.bottomBox addOneSource:oneSource];
            } else if (oneSource.type == VESourceValueTypeVideo) {
                [self.bottomBox addOneSource:oneSource];
            }
        };
    }
    
    return self;
}


- (void)setViewType:(VECPViewType)viewType
{
    if (_viewType == VECPViewTypeDuet) {
        return;
    }
    _viewType = viewType;
        
    if (viewType == VECPViewTypePicture) {
        _picButton.hidden = NO;
        _actionButton.hidden = YES;
        _progressView.hidden = YES;
        _parmView.hidden = YES;
    } else {
        _picButton.hidden = YES;
        _actionButton.hidden = NO;
        _progressView.hidden = NO;
        
        if (self.bottomBox.hidden) {
            _parmView.hidden = NO;
        }
    }
    self.duetButton.hidden = YES;
    if (viewType == VECPViewTypeDuet) {
        self.duetButton.hidden = NO;
        _titleView.hidden = YES;
        [_titleView removeFromSuperview];
        self.parmView.timeButton.hidden = YES;
        self.parmView.timeControl.hidden = YES;
    }
}

- (void)setCapManager:(id<VECapProtocol>)capManager
{
    _capManager = capManager;
    
    @weakify(self);
    [RACObserve(capManager, isShowEffectBox) subscribeNext:^(NSNumber *x) {
        @strongify(self);
        self.titleView.hidden = x.boolValue;
        self.focuseButton.hidden = x.boolValue;
    }];
    
    [RACObserve(capManager, curZoomScal) subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if (x.floatValue >= 1) {
            [self.focuseButton setTitle:[NSString stringWithFormat:@"%0.0fx",x.floatValue] forState:UIControlStateNormal];
        } else {
            [self.focuseButton setTitle:[NSString stringWithFormat:@"%0.1fx",x.floatValue] forState:UIControlStateNormal];
        }
        
        
    }];
    
    [RACObserve(capManager, boxState) subscribeNext:^(NSNumber *x) {
        @strongify(self);
        
        [self dealDuetButtonNeedShow];
    }];
    
    [RACObserve(capManager, isDuetComplet) subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if (x.boolValue) {
            [self completRecord:nil];
            self.capManager.isDuetComplet = NO;
        }
        
    }];
    
    [RACObserve(capManager, isRecordComplet) subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if (x.boolValue) {
            [self completRecord:nil];
            self.capManager.isRecordComplet = NO;
        }
        
    }];
    
    self.filterBox.capManager = capManager;
    self.stickerBox.capManager = capManager;
    self.beautyBox.capManager = capManager;
    _parmView.capManager = capManager;
    _bottomBox.capManager = capManager;
}

- (void)setDuration:(NSTimeInterval)duration
{
    _duration = duration;
    NSLog(@"-----------------%0.2f",duration);
    
    switch (self.capManager.durationType) {
        case VECPRecordDurationTypeFree:
        {
            self.progressView.progress = 0;
        }
            break;
        case VECPRecordDurationType15s:
        {
            self.progressView.progress = (duration ) /15.0;
        }
            break;
        case VECPRecordDurationType60s:
        {
            self.progressView.progress = (duration) /60.0;
        }
            break;
            
        default:
            break;
    }
    
    if (self.capManager.duetURL) {
        self.progressView.progress = self.capManager.duetPresent;
    }
}

- (void)setDisableTimer:(BOOL)disableTimer
{
    _disableTimer = disableTimer;
    if (disableTimer && !self.actionButton.hidden && self.actionButton.selected) {
        [self.actionButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}


- (void)buildLayout
{
    [self addSubview:self.titleView];
    [self addSubview:self.focuseButton];
    [self addSubview:self.duetButton];
    [self addSubview:self.duetSwichButton];
    [self addSubview:self.bottomBox];
    [self buildLayoutForVideo];
    [self buildLayoutForPic];
    [self buildLayoutForEffect];
    @weakify(self);
    [RACObserve(self.actionButton, selected) subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if (x) {
            self.filterButton.hidden = x.boolValue;
            self.stickerButton.hidden = x.boolValue;
            self.beautyButton.hidden = x.boolValue;
            self.focuseButton.hidden = x.boolValue;
            self.titleView.hidden = x.boolValue;
            if (self.bottomBox.dataSource.count > 0  ) {
                self.bottomBox.hidden = x.boolValue;
            }
            if (x.boolValue) {
                self.duetButton.hidden = YES;
            }
        }
        
    }];
    
    [[VEResourceLoader new] duetValueArr:^(NSArray<DVEEffectValue *> * _Nullable datas, NSString * _Nullable error) {
        NSArray *duetArr = datas;
        if (duetArr.count == 0) {
            return;
        }
        @strongify(self);
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            DVEEffectValue *value = duetArr[0];
            [self.duetButton sd_setImageWithURL:value.imageURL forState:UIControlStateNormal];
        });
    }];

    self.titleView.top = 45;
    self.titleView.centerX = VE_SCREEN_WIDTH * 0.5 + itemW * 0.5;
    
    self.bottomBox.bottom = self.height;
    
    [_duetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(focusebutton_W);
        make.height.mas_equalTo(focusebutton_H);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(0);
    }];
    
    [_duetSwichButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(focusebutton_W);
        make.height.mas_equalTo(focusebutton_H);
        make.right.mas_equalTo(-15 - focusebutton_W - 15);
        make.top.mas_equalTo(0);
    }];
    
    [_focuseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(focusebutton_W);
        make.height.mas_equalTo(focusebutton_H);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(focusebutton_H + 15);
    }];
    
}

- (void)buildLayoutForPic
{
    
    [self addSubview:self.picButton];
}

- (void)buildLayoutForVideo
{
    [self addSubview:self.progressView];
    [self addSubview:self.actionButton];
    
    [self addSubview:self.parmView];
    
    self.parmView.bottom = self.height;
    
}

- (void)buildLayoutForEffect
{
    [self addSubview:self.beautyButton];
    [self addSubview:self.filterButton];
    [self addSubview:self.stickerButton];
    [self layoutSubviewFrame];
}

- (void)layoutSubviewFrame
{
    [self layoutDuetSubviews];
    [self layoutVideoSubviews];
    [self layoutPicSubviews];
    [self layoutEffectSubview];
}

- (void)layoutPicSubviews
{
    self.picButton.center = CGPointMake(VE_SCREEN_WIDTH * 0.5, button_centerY);
    
}

- (void)layoutVideoSubviews
{
    self.actionButton.center = CGPointMake(VE_SCREEN_WIDTH * 0.5, button_centerY);
    self.progressView.center = self.actionButton.center;
}

- (void)layoutDuetSubviews
{
    self.actionButton.center = CGPointMake(VE_SCREEN_WIDTH * 0.5, button_centerY);
    self.progressView.center = self.actionButton.center;
}

- (void)layoutEffectSubview
{
    CGFloat margn = (VE_SCREEN_WIDTH * 0.5 - VECap_capButton_normalW * 0.5 - button_W * 2) / 3;
    self.stickerButton.left = margn;
    self.stickerButton.centerY = button_centerY;
    
    self.filterButton.left = self.stickerButton.right + margn;
    self.filterButton.centerY = button_centerY;
    
    self.beautyButton.left = VE_SCREEN_WIDTH - self.filterButton.right;
    self.beautyButton.centerY = button_centerY;
    
}

#pragma mark -- getter

- (VECPRecordParmView *)parmView
{
    if (!_parmView) {
        _parmView = [[VECPRecordParmView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, 30)];
    }
    
    return _parmView;
}

#pragma mark -- pic getter

- (UIButton *)picButton
{
    if (!_picButton) {
        _picButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, VECap_capButton_normalW,VECap_capButton_normalH)];
        [_picButton setImage:@"icon_bottombar_capture".UI_VEToImage forState:UIControlStateNormal];
        [_picButton setImage:@"icon_bottombar_capture".UI_VEToImage forState:UIControlStateSelected];
        @weakify(self);
        [[_picButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            NSTimeInterval count = 0;
            x.enabled = NO;
            switch (self.capManager.capWaitTime.subTypeIndex) {
                case 0:
                {
                    count = 0;
                }
                    break;
                case 1:
                {
                    count = 3;
                }
                    break;
                case 2:
                {
                    count = 7;
                }
                    break;
                    
                default:
                    break;
            }
            [self showCoutWithSeconds:@(count)];
            if (count > 0) {
                self.firstAvailableUIViewController.view.userInteractionEnabled = NO;
            }
            //延时执行
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(count * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongify(self);
                x.enabled = YES;
                self.firstAvailableUIViewController.view.userInteractionEnabled = YES;
                if (self.disableTimer) {
                    return;
                }
                [self actionForPic:x];
            });
        }];
    }
    
    return _picButton;
}


#pragma mark -- record getter

- (VECircleProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[VECircleProgressView alloc] initWithFrame:CGRectMake(0, 0, VECap_recordButton_normalW, VECap_recordButton_normalH) lineWidth:3];
        _progressView.progress = 0.0;
    }
    
    return _progressView;
}


- (UIButton *)actionButton
{
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, VECap_recordButton_normalW,VECap_recordButton_normalH)];
        [_actionButton setImage:@"icon_bottombar_record".UI_VEToImage forState:UIControlStateNormal];
        [_actionButton setImage:@"icon_bottombar_pause".UI_VEToImage forState:UIControlStateSelected];
        @weakify(self);
        [[_actionButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            
            if (self.capManager.durationType > 0 && self.capManager.durationType != VECPRecordDurationTypeDuet) {
                NSTimeInterval total = 0;
                if (self.capManager.durationType == VECPRecordDurationType15s) {
                    total = 15.0;
                } else if (self.capManager.durationType == VECPRecordDurationType60s) {
                    total = 60;
                }
                
                if (total - self.duration < kStopRecordDeviation) {
                    [VECustomerHUD showMessage:@"录制已经到达设定的最大时长" afterDele:3];
                    
                    return;
                }
            }
            
            
            
            x.enabled = NO;
            NSTimeInterval count = 0;
            
            switch (self.capManager.capWaitTime.subTypeIndex) {
                case 0:
                {
                    count = 0;
                }
                    break;
                case 1:
                {
                    count = 3;
                }
                    break;
                case 2:
                {
                    count = 7;
                }
                    break;
                    
                default:
                    break;
            }
            
            if (x.selected) {
                count = 0;
                x.enabled = YES;
                [self actionForVideo:x];
            } else {
                [self showCoutWithSeconds:@(count)];
                if (count > 0) {
                    self.firstAvailableUIViewController.view.userInteractionEnabled = NO;
                }
                //延时执行
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(count * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    @strongify(self);
                    x.enabled = YES;
                    self.firstAvailableUIViewController.view.userInteractionEnabled = YES;
                    if (self.disableTimer) {
                        return;
                    }
                    [self actionForVideo:x];
                });
            }
            
            
        }];
    }
    
    return _actionButton;
}

- (void)showCoutWithSeconds:(NSNumber *)countValue
{
    if (self.disableTimer) {
        return;
    }
    NSTimeInterval count = countValue.integerValue;
    if (count <= 0) {
        return;
    }
    [VECustomerHUD showMessage:[NSString stringWithFormat:@"%0.0fS",count] afterDele:1];
    
    if (count >= 1) {
        count = count -1;
    }
    [self performSelector:@selector(showCoutWithSeconds:) withObject:@(count) afterDelay:1];
}

#pragma mark -- effect getter

- (UIButton *)stickerButton
{
    if (!_stickerButton) {
        _stickerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, button_W, button_H)];
        [_stickerButton setImage:@"icon_bottombar_sticker".UI_VEToImage forState:UIControlStateNormal];
        [_stickerButton setTitle:CKEditorLocStringWithKey(@"ck_props", @"道具") forState:UIControlStateNormal];
        _stickerButton.titleLabel.textColor = [UIColor whiteColor];
        _stickerButton.titleLabel.font = SCRegularFont(12);
        [_stickerButton VElayoutWithType:VEButtonLayoutTypeImageTop space:3];
        
        @weakify(self);
        [[_stickerButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self stickerButtonDidClicked:x];
        }];
    }
    
    return _stickerButton;
}

- (UIButton *)filterButton
{
    if (!_filterButton) {
        _filterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, button_W, button_H)];
        [_filterButton setImage:@"icon_vevc_filter".UI_VEToImage forState:UIControlStateNormal];
        [_filterButton setTitle:CKEditorLocStringWithKey(@"ck_filter",@"滤镜") forState:UIControlStateNormal];
        _filterButton.titleLabel.textColor = [UIColor whiteColor];
        _filterButton.titleLabel.font = SCRegularFont(12);
        [_filterButton VElayoutWithType:VEButtonLayoutTypeImageTop space:3];
        
        @weakify(self);
        [[_filterButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self filterButtonDidClicked:x];
        }];
    }
    
    return _filterButton;
}

- (UIButton *)beautyButton
{
    if (!_beautyButton) {
        _beautyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, button_W, button_H)];
        [_beautyButton setImage:@"icon_bottombar_beauty".UI_VEToImage forState:UIControlStateNormal];
        [_beautyButton setTitle:CKEditorLocStringWithKey(@"ck_beautify",@"美颜") forState:UIControlStateNormal];
        _beautyButton.titleLabel.textColor = [UIColor whiteColor];
        _beautyButton.titleLabel.font = SCRegularFont(12);
        [_beautyButton VElayoutWithType:VEButtonLayoutTypeImageTop space:3];

        
        @weakify(self);
        [[_beautyButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self beautyButtonDidClicked:x];
        }];
    }
    
    return _beautyButton;
}


- (VEEFilterView *)filterBox
{
    if (!_filterBox) {
        @weakify(self);
        _filterBox = [[VEEFilterView alloc] initWithFrame:CGRectMake(0, 90, VE_SCREEN_WIDTH, VE_SCREEN_HEIGHT - 90) Type:VEEffectToolViewTypeFilter DismisBlock:^{
            @strongify(self);
            self.hidden = NO;
            self.capManager.isShowEffectBox = NO;
        }];
        
        [self addBoxBarActionBlock:_filterBox];
    }
    
    if (self.curIndex == 0) {
        _filterBox.type = VEEBottomBarTypePicture;
    } else {
        _filterBox.type = VEEBottomBarTypeVideo;

    }
    
    
    return _filterBox;
}

- (VEEStickerView *)stickerBox
{
    if (!_stickerBox) {
        @weakify(self);
        _stickerBox = [[VEEStickerView alloc] initWithFrame:CGRectMake(0, 90, VE_SCREEN_WIDTH, VE_SCREEN_HEIGHT - 90) Type:VEEffectToolViewTypeSticker DismisBlock:^{
            @strongify(self);
            self.hidden = NO;
            self.capManager.isShowEffectBox = NO;
        }];
        
        [self addBoxBarActionBlock:_stickerBox];
    }
    
    if (self.curIndex == 0) {
        _stickerBox.type = VEEBottomBarTypePicture;
    } else {
        _stickerBox.type = VEEBottomBarTypeVideo;

    }
    
    return _stickerBox;
}

- (VEEBeautyView *)beautyBox
{
    if (!_beautyBox) {
        @weakify(self);
        _beautyBox = [[VEEBeautyView alloc] initWithFrame:CGRectMake(0, 90, VE_SCREEN_WIDTH, VE_SCREEN_HEIGHT - 90) Type:VEEffectToolViewTypeBeauty DismisBlock:^{
            @strongify(self);
            self.hidden = NO;
            self.capManager.isShowEffectBox = NO;
        }];
        
        [self addBoxBarActionBlock:_beautyBox];
    }
    
    if (self.curIndex == 0) {
        _beautyBox.type = VEEBottomBarTypePicture;
    } else {
        _beautyBox.type = VEEBottomBarTypeVideo;

    }
    
    return _beautyBox;
}

- (void)addBoxBarActionBlock:(VEEBaseView *)box
{
    @weakify(self);
    box.actionButtonBlock = ^(VEEffectToolViewType toolType, VEEBottomBarType barType, UIButton * _Nonnull btn) {
        @strongify(self);
        self.hidden = NO;
        self.capManager.isShowEffectBox = NO;
        [self.actionButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    };
    box.capButtonBlock = ^(VEEffectToolViewType toolType, VEEBottomBarType barType, UIButton * _Nonnull btn) {
        @strongify(self);
        self.hidden = NO;
        self.capManager.isShowEffectBox = NO;
        [self.picButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    };

    box.resetButtonBlock = ^(VEEffectToolViewType toolType, VEEBottomBarType barType, UIButton * _Nonnull btn) {
        @strongify(self);
        [self showAlert];
    };
    
}

- (void)showAlert
{
    
    [self.beautyBox reset];
    
}

- (SGPageTitleView *)titleView
{
    if (!_titleView) {
        SGPageTitleViewConfigure *config = [SGPageTitleViewConfigure pageTitleViewConfigure];
        config.showBottomSeparator = NO;
        config.titleAdditionalWidth = 0;
        config.titleColor = [UIColor whiteColor];
        config.titleSelectedColor = [UIColor whiteColor];
        config.indicatorColor = HEXRGBCOLOR(0xFE6646);
        config.titleFont = SCRegularFont(14);
        _titleView = [[SGPageTitleView alloc] initWithFrame:CGRectMake(0, 0, itemW * 2, 30) delegate:self titleNames:@[CKEditorLocStringWithKey(@"ck_record_photo",@"拍照"),CKEditorLocStringWithKey(@"ck_record_video",@"摄像")] configure:config];
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.selectedIndex = self.curIndex;
    }
    
    
    return _titleView;
}

-(UIButton *)focuseButton
{
    if (!_focuseButton) {
        _focuseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, focusebutton_W,focusebutton_H)];
        _focuseButton.layer.cornerRadius = focusebutton_W * 0.5;
        _focuseButton.clipsToBounds = YES;
        _focuseButton.layer.borderWidth = 1;
        _focuseButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _focuseButton.backgroundColor = RGBACOLOR(0, 0, 0, 0.6);
        [_focuseButton setTitle:@"1x" forState:UIControlStateNormal];
        _focuseButton.titleLabel.font = SCRegularFont(12);
        @weakify(self);
        [[_focuseButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self focusButtonDidClicked:x];
        }];
    }
    
    return _focuseButton;
}

-(UIButton *)duetButton
{
    if (!_duetButton) {
        _duetButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, focusebutton_W,focusebutton_H)];
        _duetButton.layer.cornerRadius = focusebutton_W * 0.5;
        _duetButton.clipsToBounds = YES;
        _duetButton.layer.borderWidth = 1;
        _duetButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _duetButton.backgroundColor = RGBACOLOR(0, 0, 0, 0.6);
        
        _duetButton.titleLabel.font = SCRegularFont(12);
        @weakify(self);
        [[_duetButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self duetButtonDidClicked:x];
        }];
    }
    
    return _duetButton;
}

-(UIButton *)duetSwichButton
{
    if (!_duetSwichButton) {
        _duetSwichButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, focusebutton_W,focusebutton_H)];
        _duetSwichButton.layer.cornerRadius = focusebutton_W * 0.5;
        _duetSwichButton.clipsToBounds = YES;
        _duetSwichButton.hidden = YES;
        _duetSwichButton.layer.borderWidth = 1;
        _duetSwichButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _duetSwichButton.backgroundColor = RGBACOLOR(0, 0, 0, 0.6);
        [_duetSwichButton setTitle:@"切换" forState:UIControlStateNormal];
        _duetSwichButton.titleLabel.font = SCRegularFont(12);
        @weakify(self);
        [[_duetSwichButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self duetSwichButtonDidClicked:x];
        }];
    }
    
    return _duetSwichButton;
}

- (VECPBottomBox *)bottomBox
{
    if (!_bottomBox) {
        _bottomBox = [[VECPBottomBox alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, 60)];
        @weakify(self);
        _bottomBox.nextActionBlock = ^(UIButton * _Nonnull button) {
            @strongify(self);
            [self completRecord:button];
        };
        
        _bottomBox.deletActionBlock = ^(NSIndexPath * _Nonnull indexPath) {
            @strongify(self);
            
            if (self.capManager.boxState == VECPBoxStateIdle && self.viewType != VECPViewTypePicture) {
                self.parmView.hidden = NO;
            }
            
            if (self.deletActionBlock) {
                self.deletActionBlock(indexPath);
            }
        } ;
    }
    
    return _bottomBox;
}


#pragma mark - delegate
- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex
{
    self.curIndex = selectedIndex;
    pageTitleView.selectedIndex = selectedIndex;
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 0);
    switch (selectedIndex) {
        case 0:
        {
            transform = CGAffineTransformMakeTranslation(0, 0);
            self.viewType = VECPViewTypePicture;
        }
            break;
        case 1:
        {
            transform = CGAffineTransformMakeTranslation( -itemW,0);
            self.viewType = VECPViewTypeVideo;
        }
            break;
            
        default:
            break;
    }
    
    [UIView animateWithDuration:0.35 animations:^{
        pageTitleView.transform = transform;
        
    }];
}


#pragma mark -- pic action

- (void)actionForPic:(UIButton *)button
{
    @weakify(self);
    [self.capManager captureStillImageByUser:YES completion:^(UIImage * _Nullable processedImage, NSError * _Nullable error) {
        @strongify(self);
        if (!error) {
            switch (self.capManager.preDeviceOrientation) {
                case UIDeviceOrientationLandscapeLeft:
                    processedImage = [processedImage RotationOrientationLeft];
                    break;
                case UIDeviceOrientationLandscapeRight:
                    processedImage = [processedImage RotationOrientationRight];
                    break;
                case UIDeviceOrientationPortraitUpsideDown:
                    processedImage = [processedImage RotationOrientationUpDown];
                    break;
                    
                default:
                    break;
            }
            
            [self dealWithImage:processedImage];
        }
        
    }];
}

- (void)dealWithImage:(UIImage *)processedImage
{
    NSLog(@"%@",[NSThread currentThread]);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.capManager.boxState == VECPBoxStateIdle) {
                VEPhotoPreviewVC *vc = [[VEPhotoPreviewVC alloc] init];
                vc.image = processedImage;
                vc.modalPresentationStyle = UIModalPresentationFullScreen;
//                [self.firstAvailableUIViewController presentViewController:vc animated:YES completion:nil];
                [self.firstAvailableUIViewController.navigationController pushViewController:vc animated:YES];

            }
            
            if (self.cpResultBlock && self.capManager.boxState == VECPBoxStateInprocess) {
                VESourceValue *oneSource = [VESourceValue new];
                oneSource.type = VESourceValueTypeImage;
                oneSource.image = processedImage;
                self.cpResultBlock(oneSource);
                [self.capManager addOneImageVideo:processedImage];
            } else {
                
            }
        });
    });
    
}

- (void)preViewLastImage:(UIButton *)button
{
    
}


#pragma mark -- record action

- (void)actionForVideo:(UIButton *)button
{
    [button setImage:@"icon_bottombar_continu".UI_VEToImage forState:UIControlStateNormal];
    self.actionButton.selected = !button.selected;
    if (self.recordAction) {
        self.recordAction(button);
    }
    if (self.actionButton.selected) {
        [self startRecord:button];
    } else {
        [self pauseReord:button];
    }
}

- (void)startRecord:(UIButton *)button
{
    self.parmView.hidden = YES;
    @weakify(self);
    [self.capManager startVideoRecordWithRate:self.capManager.recordRate WithResult:^(NSArray<AVURLAsset *> * _Nonnull assets) {
        @strongify(self);
        
        if (self.capManager.durationType != 0) {
            button.selected = NO;
            self.lastDuration = self.duration;
            if (self.recordAction) {
                self.recordAction(button);
            }
        }
        
        if (self.bottomBox.dataSource.count + 1 == assets.count) {
            AVURLAsset *asset = assets.lastObject;
            
            if (self.cpResultBlock) {
                VESourceValue *oneSource = [VESourceValue new];
                oneSource.type = VESourceValueTypeVideo;
                oneSource.asset = asset;
                self.cpResultBlock(oneSource);
            }
        }
        
        if (assets.count == 0) {
            self.bottomBox.deletActionBlock([NSIndexPath indexPathWithIndex:0]);
        }
        
    }];
}

- (void)pauseReord:(UIButton *)button
{
    [self.capManager pauseVideoRecord];
}

- (void)completRecord:(UIButton *)button
{
    @weakify(self);
    
    if (DVE_IsExportBeforeEditor) {
        [self.capManager stopVideoRecordWithVideoData:^(id  _Nonnull videoURL, NSError * _Nullable error) {
            @strongify(self);
            if ([videoURL isKindOfClass:[NSURL class]]) {
                VEResourcePickerModel *model = [[VEResourcePickerModel alloc] initWithURL:videoURL];
                UIViewController* editorVC = [DVEUIFactory createDVEViewControllerWithResources:@[model] injectService:[VENLEEditorServiceContainer new]];
                editorVC.modalPresentationStyle = UIModalPresentationFullScreen;
                [self.firstAvailableUIViewController dismissViewControllerAnimated:NO completion:^{
                    
                }];
                UIWindow *window = [UIApplication sharedApplication].delegate.window;
                [window.rootViewController presentViewController:editorVC animated:YES completion:^{

                }];
               
            } else {
                
            }
            
        }];
    } else {
        [self.capManager stopVideoRecordWithVideoFragments:^(NSArray * _Nonnull videoFragments, NSError * _Nullable error) {
            
            if (!error) {
                if (videoFragments.count < 1) {
                    NSLog(@"stopVideoRecordWithVideoFragments with Error:videoFragments count == 0");
                    return;
                }
                UIViewController* editorVC = [DVEUIFactory createDVEViewControllerWithResources:videoFragments injectService:[VENLEEditorServiceContainer new]];
                editorVC.modalPresentationStyle = UIModalPresentationFullScreen;
                [self.firstAvailableUIViewController dismissViewControllerAnimated:NO completion:^{
                    
                }];
                UIWindow *window = [UIApplication sharedApplication].delegate.window;
                [window.rootViewController presentViewController:editorVC animated:YES completion:^{

                }];
            } else {
                NSLog(@"stopVideoRecordWithVideoFragments with Error:%@",error.localizedDescription);
                [VECustomerHUD showMessage:error.localizedDescription];
            }
        }];
    }
    
}

- (void)stickerButtonDidClicked:(UIButton *)button
{
    [self.stickerBox showInView:self.superview];
    self.hidden = YES;
    self.capManager.isShowEffectBox = YES;
}

- (void)filterButtonDidClicked:(UIButton *)button
{
    [self.filterBox showInView:self.superview];
    self.hidden = YES;
    self.capManager.isShowEffectBox = YES;
}

- (void)beautyButtonDidClicked:(UIButton *)button
{
    [self.beautyBox showInView:self.superview];
    self.hidden = YES;
    self.capManager.isShowEffectBox = YES;
}

- (void)focusButtonDidClicked:(UIButton *)button
{
    
    float scal = self.capManager.curZoomScal;
    NSLog(@"focusButtonDidClicked1----%0.2f",scal);
    NSInteger target = ((NSInteger)scal + 1 ) % 6;
    if (target == 0) {
        target = 6;;
    }
    
    NSLog(@"focusButtonDidClicked2----%zd",target);
    
    [self.capManager cameraRampToZoomFactor:target withRate:3];
    
    [button setTitle:[NSString stringWithFormat:@"%zdx",target] forState:UIControlStateNormal];
}

- (void)duetButtonDidClicked:(UIButton *)button
{
    static NSInteger index = 1;
    @weakify(self);
    [[VEResourceLoader new] duetValueArr:^(NSArray<DVEEffectValue *> * _Nullable datas, NSString * _Nullable error) {
        NSArray *duetArr = datas;
        if (duetArr.count == 0) {
            return;
        }
        @strongify(self);
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            NSInteger i = index % duetArr.count;
            DVEEffectValue *value = duetArr[i];
            [button sd_setImageWithURL:value.imageURL forState:UIControlStateNormal];
            
            [self.capManager setDuetValue:value];
            self.capManager.currentDuetLayoutType = i;
            index += 1;
            self.lastDuetValue = value;
        });
    }];
    
}

- (void)dealDuetButtonNeedShow
{
    if (self.viewType != VECPViewTypeDuet) {
        return;
    }
    if (self.capManager.boxState == VECPBoxStateIdle) {
        self.duetButton.hidden = NO;
    } else {
        self.duetButton.hidden = YES;
    }
}

- (void)duetSwichButtonDidClicked:(UIButton *)button
{
    if (self.lastDuetValue.indesty > 0) {
        self.lastDuetValue.indesty = 0;
    } else {
        self.lastDuetValue.indesty = 1;
    }
    [self.capManager updateDuetValue:self.lastDuetValue];
}


@end
