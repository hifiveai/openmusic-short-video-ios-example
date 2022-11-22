//
//  DVECanvasStyleBar.m
//  Pods
//
//  Created by bytedance on 2021/6/1.
//

#import "DVECanvasBackgroundBar.h"
#import "DVEEffectsBarBottomView.h"
#import "DVECanvasColorContentView.h"
#import "DVECanvasStyleContentView.h"
#import "DVECanvasBlurContentView.h"
#import "DVECustomerHUD.h"
#import <DVETrackKit/UIView+VEExt.h>
#import <Masonry/Masonry.h>

@interface DVECanvasBackgroundBar () <DVECanvasStyleApplyDelegate, DVECanvasColorApplyDelegate, DVECanvasBlurApplyDelegate>

@property (nonatomic, strong) DVEEffectsBarBottomView *bottomView;
@property (nonatomic, strong) UIButton *applyAllBtn;
@property (nonatomic, strong) DVECanvasBlurContentView *blurContentView;
@property (nonatomic, strong) DVECanvasStyleContentView *styleContentView;
@property (nonatomic, strong) DVECanvasColorContentView *colorContentView;

@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;

@end

@implementation DVECanvasBackgroundBar

DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)

- (DVEEffectsBarBottomView *)bottomView {
    if (!_bottomView) {
        @weakify(self);
        _bottomView = [DVEEffectsBarBottomView newActionBarWithTitle:[self bottomTitle]
                                                              action:^{
            @strongify(self);
            [self dismiss:YES];

        }];
        [_bottomView setResetButtonHidden:YES];
    }
    return _bottomView;
}

- (UIButton *)applyAllBtn {
    if (!_applyAllBtn) {
        _applyAllBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 80, 15, 68, 20)];
        [_applyAllBtn setImage:[@"icon_vevc_canvas_applyAll" dve_toImage] forState:UIControlStateNormal];
        [_applyAllBtn setTitle:NLELocalizedString(@"ck_apply_all",@"应用全部") forState:UIControlStateNormal];
        [_applyAllBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:12]];
        [_applyAllBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -4, 0, 0)];
        [_applyAllBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_applyAllBtn addTarget:self action:@selector(applyStyCanvasToAllTracks) forControlEvents:UIControlEventTouchUpInside];
    }
    return _applyAllBtn;
}

- (NSString *)bottomTitle {
    switch (self.canvasSubType) {
        case DVEModuleTypeBackgroundSubTypeCanvasColor:
            return NLELocalizedString(@"ck_canvas_color",@"画布颜色");
        case DVEModuleTypeBackgroundSubTypeCanvasStyle:
            return NLELocalizedString(@"ck_canvas_style",@"画布样式");
        case DVEModuleTypeBackgroundSubTypeCanvasBlur:
            return NLELocalizedString(@"ck_canvas_blur",@"画布模糊");
        default:
            NSAssert(NO, @"subType of canvas background invaild !!!");
            return nil;
    }
    
}

- (void)setUpLayout {
    [self addSubview:self.applyAllBtn];
    [self addSubview:self.bottomView];
    switch (self.canvasSubType) {
        case DVEModuleTypeBackgroundSubTypeCanvasColor: {
            self.colorContentView = [[DVECanvasColorContentView alloc] initWithFrame:CGRectMake(0, 50, self.bounds.size.width, 56)];
            self.colorContentView.delegate = self;
            self.colorContentView.vcContext = self.vcContext;
            [self addSubview:self.colorContentView];
            break;
        }
        case DVEModuleTypeBackgroundSubTypeCanvasStyle: {
            self.styleContentView = [[DVECanvasStyleContentView alloc] initWithFrame:CGRectMake(0, 50, self.bounds.size.width, 62)];
            self.styleContentView.delegate = self;
            self.styleContentView.vcContext = self.vcContext;
            [self addSubview:self.styleContentView];
            break;
        }
        case DVEModuleTypeBackgroundSubTypeCanvasBlur: {
            self.blurContentView = [[DVECanvasBlurContentView alloc] initWithFrame:CGRectMake(0, 50, self.bounds.size.width, 56)];
            self.blurContentView.delegate = self;
            self.blurContentView.vcContext = self.vcContext;
            [self addSubview:self.blurContentView];
            break;
        }
        default:
            NSAssert(NO, @"subType of canvas background invaild !!!");
            break;
    }
    
    self.bottomView.bottom = self.height - 34;
}

- (void)showInView:(UIView *)view animation:(BOOL)animation{
    [super showInView:view animation:(BOOL)animation];
    [self setUpLayout];
}

- (void)applyStyCanvasToAllTracks {
    [DVECustomerHUD showMessage:NLELocalizedString(@"ck_has_apply_all",@"已应用到全部") afterDele:1];
    NLETrack_OC *mainTrack = [self.nleEditor.nleModel nle_getMainVideoTrack];
    
    NSArray<NLETrackSlot_OC *> *slots = [mainTrack slots];
    for (NLETrackSlot_OC *slot in slots) {
        NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)slot.segment;
        switch (self.canvasSubType) {
            case DVEModuleTypeBackgroundSubTypeCanvasColor: {
                [self p_applyCanvasColorWithSegment:segment value:[self.colorContentView currentSelectedColorValue]];
                break;
            }
            case DVEModuleTypeBackgroundSubTypeCanvasStyle: {
                [self p_applyCanvasStyleWithSegment:segment value:[self.styleContentView currentSelectedValue]];
                break;
            }
            case DVEModuleTypeBackgroundSubTypeCanvasBlur: {
                float blurValue = [self.blurContentView currentSelectedBlurRadius];
                if (DVE_FLOAT_GREATER_THAN(blurValue, 0.0f)) {
                    [self p_applyCanvasBlurWithSegment:segment blurRadius:[self.blurContentView currentSelectedBlurRadius]];
                }
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - DVECanvasColorApplyDelegate

- (void)applyCanvasColorWithValue:(NSNumber *)value {
    NLETrackSlot_OC *slot = self.vcContext.mediaContext.mappingTimelineVideoSegment.slot;
    NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)slot.segment;
    [self p_applyCanvasColorWithSegment:segment value:value];
}

- (void)p_applyCanvasColorWithSegment:(NLESegmentVideo_OC *)segment
                                value:(NSNumber *)value {
    if (!segment.canvasStyle) {
        segment.canvasStyle = [[NLEStyCanvas_OC alloc] init];
    }
    
    segment.canvasStyle.canvasType = NLECanvasColor;
    segment.canvasStyle.color = [value unsignedIntValue];
    [self.actionService commitNLE:YES];
}

#pragma mark - DVECanvasStyleApplyDelegate

- (void)applyCanvasStyleWithValue:(DVEEffectValue *)value {
    NLETrackSlot_OC *slot = self.vcContext.mediaContext.mappingTimelineVideoSegment.slot;
    NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)slot.segment;
    [self p_applyCanvasStyleWithSegment:segment value:value];
}

- (void)cancelApplyCanvasStyleIfNeed {
    [self p_cancelApplyCanvas];
}

- (void)p_applyCanvasStyleWithSegment:(NLESegmentVideo_OC *)segment
                                value:(DVEEffectValue *)value {
    if (!segment.canvasStyle) {
        segment.canvasStyle = [[NLEStyCanvas_OC alloc] init];
    }
    
    segment.canvasStyle.canvasType = NLECanvasImage;
    if (!segment.canvasStyle.imageSource) {
        segment.canvasStyle.imageSource = [[NLEResourceNode_OC alloc] init];
    }
    segment.canvasStyle.imageSource.resourceId = value.identifier;
    segment.canvasStyle.imageSource.resourceName = value.name;
    segment.canvasStyle.imageSource.resourceFile = value.sourcePath;
    [self.actionService commitNLE:YES];
}

#pragma mark - DVECanvasBlurApplyDelegate

- (void)applyCanvasBlurWithBlurRadius:(float)blurRadius {
    NLETrackSlot_OC *slot = self.vcContext.mediaContext.mappingTimelineVideoSegment.slot;
    NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)slot.segment;
    [self p_applyCanvasBlurWithSegment:segment blurRadius:blurRadius];
}

- (void)cancelApplyCanvasBlurIfNeed {
    [self p_cancelApplyCanvas];
}

- (void)p_applyCanvasBlurWithSegment:(NLESegmentVideo_OC *)segment
                          blurRadius:(float)blurRadius {
    if (!segment.canvasStyle) {
        segment.canvasStyle = [[NLEStyCanvas_OC alloc] init];
    }
    
    segment.canvasStyle.canvasType = NLECanvasVideoFrame;
    segment.canvasStyle.blurRadius = blurRadius;
    [self.actionService commitNLE:YES];
}

- (void)p_cancelApplyCanvas {
    NLETrackSlot_OC *slot = self.vcContext.mediaContext.mappingTimelineVideoSegment.slot;
    NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)slot.segment;
    if (segment) {
        //取消画布操作，这里重新设置一个新的默认的canvasStyle
        segment.canvasStyle = [[NLEStyCanvas_OC alloc] init];
    }
    [self.actionService commitNLE:YES];
}

@end
