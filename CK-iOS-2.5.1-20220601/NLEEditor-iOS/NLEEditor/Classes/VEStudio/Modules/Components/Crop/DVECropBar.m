//
//  DVECropBar.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/4/1.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "DVECropBar.h"
#import "DVECropVideoToolBar.h"
#import "DVECropRulerView.h"
#import "DVECropDefines.h"
#import "DVECropPreview.h"
#import "DVELoggerImpl.h"
#import <DVETrackKit/UIView+VEExt.h>
#import <NLEPlatform/NLETrackSlot+iOS.h>
#import <NLEEditor/NSString+VEToImage.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>
#import "DVEEffectsBarBottomView.h"

@interface DVECropBar () <DVECropRulerViewDelegate, DVECropPreviewDelegate, DVECropVideoToolBarDelegate>

@property (nonatomic, strong) DVECropPreview *preview;//图片或视频预览视图
@property (nonatomic, strong) DVECropVideoToolBar *videoToolBar; //播放栏
@property (nonatomic, strong) DVECropRulerView *rulerView;//角度旋转栏
@property (nonatomic, strong) DVEEffectsBarBottomView *bottomView;
@property (nonatomic, strong) NLETrackSlot_OC *slot;
@property (nonatomic, strong) DVECropResource *previewResource;
@property (nonatomic, assign) BOOL isOriginCrop;

@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@end

@implementation DVECropBar {
    DVEResourceCropPointInfo _resourceInfo;
}

DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)showInView:(UIView *)view animation:(BOOL)animation{
    [super showInView:view animation:(BOOL)animation];
    [self setMainEditVideoPauseIfNeeded];
    [self getResource];
    [self setUpLayout];
    //根据上次编辑效果重新刷新UI
    [self refreshLayout];
}

- (void)getResource {
    _slot = [self.vcContext.mediaContext selectMainVideoSegment];
    if (!_slot) {
        _slot = [self.vcContext.mediaContext selectBlendVideoSegment];
    }
    NLEResourceType resourceType = [self.slot.segment getResNode].resourceType;
    NSAssert(resourceType == NLEResourceTypeImage || resourceType == NLEResourceTypeVideo, @"resouce in crop bar should be image or video");
    DVECropResourceType previewResourceType = (resourceType == NLEResourceTypeImage ? DVECropResourceImage : DVECropResourceVideo);
    NSString *resourcePath = [self.nle getAbsolutePathWithResource:[self.slot.segment getResNode]];
    switch (previewResourceType) {
        case DVECropResourceImage: {
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:resourcePath];
            self.previewResource = [[DVECropResource alloc] initWithResouceType:previewResourceType image:image video:nil];
        }
            break;
        case DVECropResourceVideo: {
            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:resourcePath]];
            self.previewResource = [[DVECropResource alloc] initWithResouceType:previewResourceType image:nil video:asset];
        }
            break;
        default:
            NSAssert(NO, @"previewResouceType shoube be valid!!!");
            break;
    }
}

- (void)setUpLayout {
    self.backgroundColor = colorWithHex(0x101010);
    self.rulerView.backgroundColor = colorWithHex(0x101010);
    self.preview.backgroundColor = colorWithHex(0x101010);

    [self addSubview:self.bottomView];
//    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(self.bottomView.frame.size.height);
//        make.left.right.equalTo(self);
//        make.top.equalTo(self.rulerView.mas_bottom).offset(80);
//        make.bottom.equalTo(self).offset(-VEBottomMargn);
//    }];
    
    self.bottomView.width = self.width;
    self.bottomView.bottom = self.bottom - VEBottomMargn;
    
    [self addSubview:self.rulerView];
    CGFloat rulerInset = 37 - [self.rulerView inset];
//    [self.rulerView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).mas_offset(rulerInset);
//        make.right.equalTo(self).mas_offset(-rulerInset);
//        make.height.mas_equalTo(78);
//    }];
    self.rulerView.width = self.width - 2 * rulerInset;
    self.rulerView.left = self.left + rulerInset;
    self.rulerView.right = self.right - rulerInset;
    self.rulerView.height = 78;
    self.rulerView.bottom = self.bottomView.top - 40;
    
    if (self.previewResource.resouceType == DVECropResourceVideo) {
        self.videoToolBar.backgroundColor = colorWithHex(0x101010);
        [self addSubview:self.videoToolBar];
        _videoToolBar.bottom = _rulerView.top - 50;
        _videoToolBar.delegate = self;
    }
    
    if (self.previewResource.resouceType == DVECropResourceImage) {
        self.preview.height = self.height - 78 - 50 - 50 - 49 - 40 - 92;
        self.preview.width = self.width;
        self.preview.bottom = self.rulerView.top;
        self.preview.top = self.top + 92;
    } else {
        self.preview.height = self.height - _videoToolBar.height - 78 - 50 - 50 - 49 - 40 - 92;
        self.preview.width = self.width;
        self.preview.bottom = self.videoToolBar.top;
        self.preview.top = self.top + 92;
    }
    DVELogDebug(@"crop bar's width:%.10f %.10f", self.bounds.size.width, self.bounds.size.height);
    DVELogDebug(@"crop bar preview's point:%.10f %.10f and size:%.10f %.10f", _preview.frame.origin.x, _preview.frame.origin.y,  _preview.frame.size.width, _preview.frame.size.height);
    [self addSubview:self.preview];
}

- (DVECropPreview *)preview {
    if (!_preview) {
        if (_previewResource.resouceType == DVECropResourceVideo) {
            _previewResource.startTime = [self.slot startTime];
            NLESegmentVideo_OC *videoSegment = (NLESegmentVideo_OC *)self.slot.segment;
            if (videoSegment) {
                //获取时间轴杆当前处于选中的slot的时间
                //时间轴杆对应的全局时间减去副轨slot的开始时间，然后再加上副轨视频的开始部分被折叠的时间
                _previewResource.startTime = CMTimeAdd(CMTimeSubtract(self.vcContext.mediaContext.currentTime, self.slot.startTime), videoSegment.timeClipStart);
                //轨道开始部分被折叠的时间
                _previewResource.timeClip = videoSegment.timeClipStart;
                //轨道折叠后的播放时长
                _previewResource.duration = self.slot.duration;
                DVELogDebug(@"crop preview resource startTime:%.10f timeClip:%.10f duration:%.10f", CMTimeGetSeconds(_previewResource.startTime), CMTimeGetSeconds(_previewResource.timeClip), CMTimeGetSeconds(_previewResource.duration));
            }
        }
        _preview = [[DVECropPreview alloc] initWithResouce:_previewResource];
        _preview.delegate = self;
    }
    return _preview;
}

- (DVECropVideoToolBar *)videoToolBar {
    if (!_videoToolBar) {
        _videoToolBar = [[DVECropVideoToolBar alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, 50)];
        [_videoToolBar setVcContext:self.vcContext];
    }
    return _videoToolBar;
}

- (DVECropRulerView *)rulerView {
    if (!_rulerView) {
        _rulerView = [[DVECropRulerView alloc] initWithDefaultValue:0.0 minimumValue:-45.0 maximumValue:45.0 precisonValue:3.0];
        _rulerView.delegate = self;
    }
    return _rulerView;
}
- (DVEEffectsBarBottomView *)bottomView {
    if(!_bottomView) {
        @weakify(self);
        _bottomView = [DVEEffectsBarBottomView newActionBarWithTitle:NLELocalizedString(@"ck_crop",@"裁剪")  action:^{
            @strongify(self);
            [self updateResourceInfo];
            [self saveResourceInfo];
            [self dismiss:YES];
            [self.actionService refreshUndoRedo];

        }];
        
        _bottomView.backgroundColor = [UIColor clearColor];
        [RACObserve(self, isOriginCrop) subscribeNext:^(NSNumber *x) {
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.bottomView setResetButtonEnable:!x.boolValue];
            });
        }];
        
        [_bottomView setupResetBlock:^{
            @strongify(self);
            [self resetVideoCrop];
        }];
        
    }
    return _bottomView;
}

- (void)updateResourceInfo {
    [self.preview calculateResourceInfoUpperLeftPoint:&(self->_resourceInfo.upperLeft)
                                      upperRightPoint:&(self->_resourceInfo.upperRight)
                                       lowerLeftPoint:&(self->_resourceInfo.lowerLeft)
                                      lowerRightPoint:&(self->_resourceInfo.lowerRight)];
}

- (void)saveResourceInfo {
    //TODO:Android端要加上以下字段存储，iOS端需要写入以下字段
    //旋转角度；缩放比例；X轴偏移量；Y轴偏移量
    NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)self.slot.segment;
    if (!segment.crop) {
        segment.crop = [[NLEStyCrop_OC alloc] init];
    }
    
    segment.crop.upperLeftX = self->_resourceInfo.upperLeft.x;
    segment.crop.upperLeftY = self->_resourceInfo.upperLeft.y;
    segment.crop.upperRightX = self->_resourceInfo.upperRight.x;
    segment.crop.upperRightY = self->_resourceInfo.upperRight.y;
    segment.crop.lowerLeftX = self->_resourceInfo.lowerLeft.x;
    segment.crop.lowerLeftY = self->_resourceInfo.lowerLeft.y;
    segment.crop.lowerRightX = self->_resourceInfo.lowerRight.x;
    segment.crop.lowerRightY = self->_resourceInfo.lowerRight.y;
    
    [self.actionService commitNLE:YES];
    
    self.isOriginCrop = DVE_isDefaultCropPoint(self->_resourceInfo);
}

- (void)loadResourceInfo {
    NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)self.slot.segment;
    if (!segment.crop) {
        segment.crop = [[NLEStyCrop_OC alloc] init];
    }
    
    DVELogDebug(@"loadResourceInfo upperLeftX:%.10f upperLeftY:%.10f", segment.crop.upperLeftX, segment.crop.upperLeftX);
    DVELogDebug(@"loadResourceInfo upperRightX:%.10f upperRightY:%.10f", segment.crop.upperRightX, segment.crop.upperRightY);
    DVELogDebug(@"loadResourceInfo lowerLeftX:%.10f lowerLeftY:%.10f", segment.crop.lowerLeftX, segment.crop.lowerLeftY);
    DVELogDebug(@"loadResourceInfo lowerRightX:%.10f lowerRightY:%.10f", segment.crop.lowerRightX, segment.crop.lowerRightY);
    
    self->_resourceInfo.upperLeft = CGPointMake(segment.crop.upperLeftX, segment.crop.upperLeftY);
    self->_resourceInfo.upperRight = CGPointMake(segment.crop.upperRightX, segment.crop.upperRightY);
    self->_resourceInfo.lowerLeft = CGPointMake(segment.crop.lowerLeftX, segment.crop.lowerLeftY);
    self->_resourceInfo.lowerRight = CGPointMake(segment.crop.lowerRightX, segment.crop.lowerRightY);
    
    self.isOriginCrop = DVE_isDefaultCropPoint(self->_resourceInfo);
}

- (void)refreshLayout {
    [self loadResourceInfo];
    [self.preview refreshLayoutWithCropInfo:_resourceInfo];
}

#pragma mark - Delegate

- (void)rulerDidMove:(DVECropRulerView *)rulerView changAngle:(CGFloat)angle {
    [self.preview updateWithNewAngleValue:DVE_angleToValue(angle)];
    DVELogInfo(@"ruler did move with angel:%.10f", angle);
}

- (void)rotateCropPreview:(DVECropPreview *)preview rotateValue:(CGFloat)value {
    [self.rulerView updateAngle:DVE_valueToAngle(value)];
}

- (void)videoPlay {
    [self.preview videoPlayIfNeed];
}

- (void)videoPause {
    [self.preview videoPauseIfNeed];
}

- (void)videoPlayTime:(NSTimeInterval)time duration:(NSTimeInterval)duration {
    [self.videoToolBar updateVideoPlayTime:time duration:duration];
}

- (void)videoPlayToEnd {
    [self.videoToolBar setPlayToEnd];
}

- (void)videoRestartPlay {
    [self.preview videoRestartIfNeed];
}

- (void)resetVideoCrop {
    self->_resourceInfo = DVE_defaultCropPointInfo();
    [self saveResourceInfo];
    [self refreshLayout];
}

- (void)cropDidEnd {
    [self updateResourceInfo];
    self.isOriginCrop = DVE_isDefaultCropPoint(self->_resourceInfo);
}

- (void)rulerDidEnd {
    [self updateResourceInfo];
    self.isOriginCrop = DVE_isDefaultCropPoint(self->_resourceInfo);
}

- (void)setMainEditVideoPauseIfNeeded {
    [self.vcContext.playerService pause];
}

@end
