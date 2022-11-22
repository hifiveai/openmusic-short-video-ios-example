//
//  DVEPreview.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEPreview.h"
#import "DVECanvasVideoBorderView.h"
#import "DVELoggerImpl.h"
#import <DVETrackKit/CMTime+NLE.h>
#import <DVETrackKit/DVECGUtilities.h>

@interface DVEPreview ()
<
UIGestureRecognizerDelegate,
NLEEditorDelegate,
DVECanvasKeyFrameProtocol
>

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint translation;
@property (nonatomic) CGFloat angle;

@property (nonatomic) UIGestureRecognizer *tapGR;
@property (nonatomic) UIGestureRecognizer *pinchGR;
@property (nonatomic) UIGestureRecognizer *rotateGR;
@property (nonatomic) UIGestureRecognizer *panGR;

@property (nonatomic, weak) id<DVECoreCanvasProtocol> canvasEditor;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@end

@implementation DVEPreview

DVEAutoInject(self.vcContext.serviceProvider, canvasEditor, DVECoreCanvasProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

- (void)dealloc
{
    DVELogInfo(@"VEVCPreview dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _canvasBorderView = [[DVECanvasVideoBorderView alloc] init];
        _canvasBorderView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _canvasBorderView.hidden = YES;
        [self addSubview:_canvasBorderView];
    }
    return self;
}

- (void)disableGesture:(BOOL)disable
{
    _tapGR.enabled = !disable;
    _pinchGR.enabled = !disable;
    _rotateGR.enabled = !disable;
    _panGR.enabled = !disable;
}

- (void)showCanvasBorderEnableGesture:(BOOL)enableGesture
{
    _canvasBorderView.hidden = NO;
    _tapGR.enabled = enableGesture;
    _pinchGR.enabled = enableGesture;
    _rotateGR.enabled = enableGesture;
    _panGR.enabled = enableGesture;
    
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentBlendVideoSlot];

    if (!slot &&
        !self.vcContext.mediaContext.enableCanvasBackgroundEdit) {
        _canvasBorderView.alpha = 0;
        _pinchGR.enabled = NO;
        _rotateGR.enabled = NO;
        _panGR.enabled = NO;
        return;
    }
    
    if (!slot && self.vcContext.mediaContext.enableCanvasBackgroundEdit) {
        slot = self.vcContext.mediaContext.mappingTimelineVideoSegment.slot;
    }
    
    [self updateCanvasBorderWithSlot:slot];
    
    if (self.vcContext.mediaContext.selectMainVideoSegment ||
        !self.vcContext.mediaContext.enableCanvasBackgroundEdit) {
        _canvasBorderView.alpha = 1;
    }
}

- (void)isShow {
    self.canvasBorderView.alpha =  [self needShow] ? 1 : 0;
}

- (BOOL)needShow {
    CMTime currentTime = self.vcContext.mediaContext.currentTime;
    if (self.vcContext.mediaContext.selectBlendVideoSegment &&
        NLE_CMTimeRangeContain(self.vcContext.mediaContext.selectBlendVideoSegment.nle_targetTimeRange, currentTime)){
        return true;
    } else if (self.vcContext.mediaContext.selectMainVideoSegment &&
               NLE_CMTimeRangeContain(self.vcContext.mediaContext.selectMainVideoSegment.nle_targetTimeRange, currentTime)) {
        return true;
    } else {
        return false;
    }
}

- (void)hideCanvasBorder {
    _canvasBorderView.hidden = YES;
    _tapGR.enabled = NO;
    _pinchGR.enabled = NO;
    _rotateGR.enabled = NO;
    _panGR.enabled = NO;
    _canvasBorderView.alpha = 0;
}
- (void)setVcContext:(DVEVCContext *)vcContext
{
    _vcContext = vcContext;
    [self setupCanvasGestures:vcContext];
    [DVEAutoInline(_vcContext.serviceProvider, DVECoreActionServiceProtocol) addUndoRedoListener:self];
    [self.nleEditor addDelegate:self];
    self.canvasEditor.keyFrameDelegate = self;
}

- (void)setupCanvasGestures:(DVEVCContext *)context {
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGR.enabled = NO;
    [self addGestureRecognizer:tapGR];
    self.tapGR = tapGR;
    
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGR.enabled = NO;
    [self addGestureRecognizer:panGR];
    self.panGR = panGR;


    UIPinchGestureRecognizer *pinchGR = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinchGR.enabled = NO;
    [self addGestureRecognizer:pinchGR];
    self.pinchGR = pinchGR;
    
    UIRotationGestureRecognizer *rotateGR = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotationGesture:)];
    rotateGR.enabled = NO;
    [self addGestureRecognizer:rotateGR];
    self.rotateGR = rotateGR;
    
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isEqual:gestureRecognizer.view] && ![touch.view isKindOfClass:[UISlider class]]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)pinch {
    if (self.vcContext.mediaContext.selectBlendVideoSegment) {
        [self handleScaleFotSlot:self.vcContext.mediaContext.selectBlendVideoSegment pinch:pinch];
    } else if (self.vcContext.mediaContext.mappingTimelineVideoSegment) {
        [self handleScaleFotSlot:self.vcContext.mediaContext.mappingTimelineVideoSegment.slot pinch:pinch];
    }
    pinch.scale = 1.f;
}

- (void)handleScaleFotSlot:(NLETrackSlot_OC *)slot pinch:(UIPinchGestureRecognizer *)pinch {
    if (!slot) return;
    BOOL isEnd = (pinch.state == UIGestureRecognizerStateCancelled) ||
    (pinch.state == UIGestureRecognizerStateFailed) ||
    (pinch.state == UIGestureRecognizerStateEnded);
    
    if (pinch.state == UIGestureRecognizerStateBegan) {
        [self.vcContext.playerService pause];
        _scale = slot.scale;
    }
    _scale = _scale * pinch.scale;
    
    [self.canvasEditor updateVideoClipScale:_scale forSlot:slot isCommit:isEnd];
    NLESegmentVideo_OC *videoSeg = (NLESegmentVideo_OC *)slot.segment;
    NLEResourceAV_OC *resAV = (NLEResourceAV_OC *)[videoSeg getResNode];
    [self.canvasBorderView updateScale:_scale forSize:CGSizeMake(resAV.width, resAV.height)];
    if (isEnd) {
        _scale = 0.f;
    }
         
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan {
    UIView *view = pan.view;
    if (self.vcContext.mediaContext.selectBlendVideoSegment) {
        [self handleTranslation:self.vcContext.mediaContext.selectBlendVideoSegment view:view pan:pan];
    } else if (self.vcContext.mediaContext.mappingTimelineVideoSegment  ) {
        [self handleTranslation:self.vcContext.mediaContext.mappingTimelineVideoSegment.slot view:view pan:pan];
    }
}

- (void)handleTranslation:(NLETrackSlot_OC *)slot view:(UIView *)view pan:(UIPanGestureRecognizer *)pan {
    if (!slot) return;
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        [self.vcContext.playerService pause];
        _translation = CGPointMake(slot.transformX, slot.transformY);
    }
    
    BOOL isEnd = (pan.state == UIGestureRecognizerStateCancelled) ||
    (pan.state == UIGestureRecognizerStateFailed) ||
    (pan.state == UIGestureRecognizerStateEnded);
    
    CGPoint point = [pan translationInView:view];
    [pan setTranslation:CGPointZero inView:view];
    
    _translation.x += point.x / view.bounds.size.width;
    _translation.y += point.y / view.bounds.size.height;
    
    
    [self.canvasEditor updateVideoClipTranslation:_translation forSlot:slot isCommit:isEnd];
    
    [self.canvasBorderView updateTranslation:_translation];
    
    if (isEnd) {
        _translation = CGPointZero;
    }
    

}

- (void)handleTapGesture:(UITapGestureRecognizer *)tap {
    
    CMTime current = self.vcContext.mediaContext.currentTime;
    NSArray <NLETrackSlot_OC *>* videoSlots = [self.nleEditor.nleModel nle_videoSlotsAtTime:current];

    NSMutableArray *slots = [videoSlots mutableCopy];
    [slots sortUsingComparator:^NSComparisonResult(NLETrackSlot_OC *  _Nonnull obj1, NLETrackSlot_OC *   _Nonnull obj2) {
        if ([obj1 getLayer] > [obj2 getLayer]) {
            return NSOrderedAscending;
        } else if ([obj1 getLayer] < [obj2 getLayer]) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    UIView *preView = tap.view;
    CGPoint location = [tap locationInView:preView];
    [self selectSegment:slots touchPoint:location inView:preView];
    
    
}

- (void)selectSegment:(NSArray <NLETrackSlot_OC *>*)trackSlots touchPoint:(CGPoint)point inView:(UIView *)view {
    CGRect bounds = view.bounds;
    for (NLETrackSlot_OC *slot in trackSlots) {
        CGRect frame = [self calculateFrame:slot inBounds:bounds];
        if (CGRectContainsPoint(frame, point)) {
            NSString *mappingSlot = [self.vcContext.mediaContext.mappingTimelineVideoSegment.slot nle_nodeId];
            if ([slot.nle_nodeId isEqualToString:mappingSlot]) {
                if (self.vcContext.mediaContext.selectBlendVideoSegment != nil) {
                    self.vcContext.mediaContext.selectBlendVideoSegment = nil;
                }
                if ([slot.nle_nodeId isEqualToString:self.vcContext.mediaContext.selectMainVideoSegment.nle_nodeId]) {
                    self.vcContext.mediaContext.selectMainVideoSegment = nil;
                } else {
                    self.vcContext.mediaContext.selectMainVideoSegment = slot;
                }
            } else {
                if (self.vcContext.mediaContext.selectMainVideoSegment != nil) {
                    self.vcContext.mediaContext.selectMainVideoSegment = nil;
                }
                if ([self.vcContext.mediaContext.selectBlendVideoSegment.nle_nodeId isEqualToString:slot.nle_nodeId]) {
                    self.vcContext.mediaContext.selectBlendVideoSegment = nil;
                } else {
                    self.vcContext.mediaContext.selectBlendVideoSegment = slot;
                }
            }
            break;
        }
        
    }
}

- (CGRect)calculateFrame:(NLETrackSlot_OC *)slot inBounds:(CGRect)bounds {
    if (slot && [slot.segment isKindOfClass:[NLESegmentVideo_OC class]]) {
        CGSize maxSize = CGSizeMake(bounds.size.width * slot.scale, bounds.size.height * slot.scale);
        NLESegmentVideo_OC *videoSegment = (NLESegmentVideo_OC *)slot.segment;
        NLEResourceAV_OC *resource =  (NLEResourceAV_OC *)[videoSegment getResNode];
        CGSize payloadSize = CGSizeMake(resource.width, resource.height);
        CGSize size = DVECGSizeLimitMaxSize(payloadSize, maxSize);
        size = DVECGSizeSacleAspectFitToMaxSize(size, maxSize);
        CGFloat x = bounds.size.width * 0.5 + (slot.transformX * bounds.size.width) - size.width * 0.5; // 先算中心，再算x
        CGFloat y = bounds.size.height * 0.5 + (slot.transformY * bounds.size.height) - size.height * 0.5;
        return CGRectMake(x, y, size.width, size.height);
    } else  {
        return CGRectZero;
    }


}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

// MARK: Rotation
- (void)handleRotationGesture:(UIRotationGestureRecognizer *)rotation {
    UIView *view = rotation.view;
    if (self.vcContext.mediaContext.selectBlendVideoSegment) {
        [self handleRotationForSlot:self.vcContext.mediaContext.selectBlendVideoSegment view:view rotation:rotation];
    } else if (self.vcContext.mediaContext.mappingTimelineVideoSegment) {
        [self handleRotationForSlot:self.vcContext.mediaContext.mappingTimelineVideoSegment.slot view:view rotation:rotation];
    }
}

- (void)handleRotationForSlot:(NLETrackSlot_OC *)slot view:(UIView *)view rotation:(UIRotationGestureRecognizer *)rotation {
    if (!slot) return;
    if (rotation.state == UIGestureRecognizerStateBegan) {
        _angle = slot.rotation;
    }
    
    BOOL isEnd = (rotation.state == UIGestureRecognizerStateCancelled) ||
    (rotation.state == UIGestureRecognizerStateFailed) ||
    (rotation.state == UIGestureRecognizerStateEnded);
    
    CGFloat radian = (rotation.rotation * 180.0 / M_PI);
    _angle += radian;
    
    [self.canvasEditor updateVideoClipRotation:_angle forSlot:slot isCommit:isEnd];
    [self.canvasBorderView updateRoation:_angle];
    rotation.rotation = 0;
    if (isEnd) {
        _angle = 0.f;
    }
}

- (void)refresh
{
    [self isShow];
    
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentBlendVideoSlot];
    
    if (!slot) {
        return;
    }
    
    [self updateCanvasBorderWithSlot:slot];
}

- (void)updateCanvasBorderWithSlot:(NLETrackSlot_OC *)slot {
    [self.canvasBorderView updateTranslation:CGPointMake(slot.transformX, slot.transformY)];
    [self.canvasBorderView updateRoation:-slot.rotation];
    NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)slot.segment;
    NLEResourceNode_OC *resource = [segment getResNode];
    [self.canvasBorderView updateScale:slot.scale forSize:CGSizeMake(resource.width, resource.height)];
    [self.canvasBorderView updateCrop:segment.crop scale:slot.scale maxBounds:self.bounds];
}

#pragma mark - VEVCUndoRedoNotifyProtocol

- (void)undoRedoClikedByUser
{
    [self refresh];
}

#pragma mark - NLEEditorDelegate

- (void)nleEditorDidChange:(NLEEditor_OC *)editor
{
    [self refresh];
}

#pragma mark - DVECanvasKeyFrameProtocol

- (void)canvasKeyFrameDidChangedWithSlot:(NLETrackSlot_OC *)slot {
    if (!slot) {
        return;
    }
    
    if (CMTimeCompare(slot.startTime, self.vcContext.mediaContext.currentTime) > 0 ||
        CMTimeCompare(slot.endTime, self.vcContext.mediaContext.currentTime) < 0) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateCanvasBorderWithSlot:slot];
    });
}

//- (BOOL)canKeyFrameCallback {
//    return self.tapGR.enabled && self.pinchGR.enabled && self.rotateGR.enabled && self.panGR.enabled;
//}

@end
