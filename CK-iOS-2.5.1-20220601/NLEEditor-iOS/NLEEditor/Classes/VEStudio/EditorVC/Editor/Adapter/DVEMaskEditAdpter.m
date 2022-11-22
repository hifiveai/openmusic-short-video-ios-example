//
//  DVEMaskEditAdpter.m
//  NLEEditor
//
//  Created by bytedance on 2021/4/8.
//

#import "DVEMaskEditAdpter.h"
#import "DVEMacros.h"
#import "DVEMaskConfigModel.h"
#import "DVEPreview.h"
#import "DVELoggerImpl.h"
#import "DVEMaskBar.h"
#import "DVECanvasVideoBorderView.h"
#import <DVETrackKit/VEDMaskEditView.h>
#import <DVETrackKit/VEDGeometricDrawView.h>

@interface DVEMaskEditAdpter ()<VEDMaskEditViewProtocol,DVEMaskKeyFrameProtocol>

@property (nonatomic, strong) VEDMaskEditView *maskEditView;
@property (nonatomic, strong) VEDMaskEditViewConfig *maskConfig;
@property (nonatomic, strong) DVEMaskConfigModel *vcConfigModel;

@property (nonatomic, strong) VEDMaskDataModel *data;

@property (nonatomic, strong) VEDMaskUIModel *ui;

@property (nonatomic, weak) DVEPreview *parentView;
@property (nonatomic, weak) DVEMaskBar *maskBar;

@property (nonatomic, weak) id<DVECoreMaskProtocol> maskEditor;
@property (nonatomic, weak) id<DVECoreKeyFrameProtocol> keyframeEditor;
//@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end

@implementation DVEMaskEditAdpter

DVEAutoInject(self.vcContext.serviceProvider, maskEditor, DVECoreMaskProtocol)
DVEAutoInject(self.vcContext.serviceProvider, keyframeEditor, DVECoreKeyFrameProtocol)

- (void)dealloc
{
    DVELogInfo(@"VEMaskEditAdpter dealloc");
}

//- (CGSize)curBorderSize
//{
//    CGSize curBorderSize = CGSizeZero;
//
//    CGFloat curW = 0;
//    CGFloat curH = 0;
//
//    CGFloat rotation = -[self.vcContext.mediaContext currentBlendVideoSlot].rotation;
//
//    if (rotation == 0) {
//        curW = _vcConfigModel.borderSize.width;
//        curH = _vcConfigModel.borderSize.height;
//    } else if (rotation == 90) {
//        curW = _vcConfigModel.borderSize.height;
//        curH = _vcConfigModel.borderSize.width;
//    } else if (rotation == 180) {
//        curW = _vcConfigModel.borderSize.width;
//        curH = _vcConfigModel.borderSize.height;
//    } else if (rotation == 270) {
//        curW = _vcConfigModel.borderSize.height;
//        curH = _vcConfigModel.borderSize.width;
//    } else {
//        curW = _vcConfigModel.borderSize.width;
//        curH = _vcConfigModel.borderSize.height;
//    }
//
//    curBorderSize = CGSizeMake(curW, curH);
//
//    return curBorderSize;
//}

- (VEDMaskDataModel *)data
{
    if (!_data) {
        CGFloat rotation = -[self.vcContext.mediaContext currentBlendVideoSlot].rotation;
        
        CGSize curBorderSize = _vcConfigModel.borderSize;
        
        _data = [[VEDMaskDataModel alloc] initWithType:VEDMaskShapeTypeLine width:_vcConfigModel.width * curBorderSize.width  height:_vcConfigModel.height * curBorderSize.height  center:[self veCenterToUICenter] rotation:_vcConfigModel.rotation + rotation roundCorner:_vcConfigModel.roundCorner * self.ui.roundCornerMaxSpace feather:_vcConfigModel.feather svgFilePath:_vcConfigModel.svgFilePath];
    }
    return _data;
}

- (CGPoint)veCenterToUICenter
{
    CGPoint veCenter = CGPointZero;
    
    CGFloat curX = 0;
    CGFloat curY = 0;
    
    CGFloat rotation = -[self.vcContext.mediaContext currentBlendVideoSlot].rotation;
    CGSize curBorderSize = _vcConfigModel.borderSize;
    
    if (rotation == 0) {
        curX = curBorderSize.width * 0.5 * (1 + _vcConfigModel.center.x);
        curY = (1 - _vcConfigModel.center.y) * curBorderSize.height * 0.5;
    } else if (rotation == 90) {
        curX = curBorderSize.width * 0.5 * (1 + _vcConfigModel.center.x);
        curY = (1 - _vcConfigModel.center.y) * curBorderSize.height * 0.5;
    } else if (rotation == 180) {
        curX = curBorderSize.width * 0.5 * (1 + _vcConfigModel.center.x);
        curY = (1 - _vcConfigModel.center.y) * curBorderSize.height * 0.5;
    } else if (rotation == 270) {
        curX = curBorderSize.width * 0.5 * (1 + _vcConfigModel.center.x);
        curY = (1 - _vcConfigModel.center.y) * curBorderSize.height * 0.5;
    } else {
        curX = curBorderSize.width * 0.5 * (1 + _vcConfigModel.center.x);
        curY = (1 - _vcConfigModel.center.y) * curBorderSize.height * 0.5;
    }
    
    veCenter = CGPointMake(curX, curY);
    
    return veCenter;
}

- (VEDMaskUIModel *)ui
{
    if (!_ui) {
        _ui = [[VEDMaskUIModel alloc] init];
        _ui.minWidth = 0;
        _ui.minHeight = 0;
        _ui.minIconSpace = 0;
    }
    
    return _ui;
}
- (VEDMaskEditViewConfig *)maskConfig
{
    if (!_maskConfig) {
        _maskConfig = [[VEDMaskEditViewConfig alloc] initWithDataModel:self.data UIModel:self.ui];
    }
    
    return _maskConfig;
}

//- (dispatch_queue_t)serialQueue
//{
//    if(!_serialQueue) {
//        _serialQueue = dispatch_queue_create("DVEMaskEditAdpter", DISPATCH_QUEUE_SERIAL);
//    }
//    return _serialQueue;
//}

- (void)showInPreview:(UIView *)view withConfigModel:(DVEMaskConfigModel *)model
{
    self.parentView = (DVEPreview *)view;
    self.vcConfigModel = model;
    self.curType = model.type;
    UIView *tview = [view viewWithTag:9797979];
    if (tview) {
        [tview removeFromSuperview];
    }
    [self editViewWithType:model.type];
    self.maskEditView.tag = 9797979;
    [view addSubview:self.maskEditView];
    self.maskEditView.bounds = view.bounds;
    
    [self.maskEditView setBorderView:(UIView*)self.parentView.canvasBorderView];
    [self.maskEditView configDrawViewWithConfig:self.maskConfig];
    self.maskEditor.keyFrameDelegate = self;
}

- (void)setupMaskBar:(DVEMaskBar*)bar
{
    self.maskBar = bar;
}

- (void)editViewWithType:(VEMaskEditType)type
{
    switch (type) {
        case VEMaskEditTypeNone:
        {
            
        }
            break;
        case VEMaskEditTypeLine:
        {
            self.maskConfig.data.type = VEDMaskShapeTypeLine;
        }
            break;
        case VEMaskEditTypeMirror:
        {
            self.maskConfig.data.type = VEDMaskShapeTypeMirror;
        }
            break;
        case VEMaskEditTypeRoundShape:
        {
            self.maskConfig.data.type = VEDMaskShapeTypeCircle;
        }
            break;
        case VEMaskEditTypeRectangle:
        {
            self.maskConfig.data.type = VEDMaskShapeTypeRectangle;
        }
            break;
        case VEMaskEditTypeStarShape:
        {
            self.maskConfig.data.type = VEDMaskShapeTypeGeometric;
        }
            break;
        case VEMaskEditTypeHeartShape:
        {
            self.maskConfig.data.type = VEDMaskShapeTypeGeometric;
        }
            break;
            
        default:
            break;
    }
    
    self.maskConfig.data.svgFilePath = _vcConfigModel.svgFilePath;
}


- (void)hideFromPreview
{
    self.maskEditor.keyFrameDelegate = nil;
    [self.maskEditView removeFromSuperview];
}

- (VEDMaskEditView  *)maskEditView
{
    if (!_maskEditView) {
        _maskEditView = [[VEDMaskEditView alloc] initWithFrame:self.parentView.bounds];
        _maskEditView.tag = 9797979;
        _maskEditView.delegate = self;
    }
    
    return _maskEditView;
}


- (void)dealLineShape
{
    
}

- (void)dealMirrorShape
{
    
}
- (void)dealRoundShape
{
    
}

- (void)dealRectShape
{
    
}

- (void)dealHeartShape
{
    
}

- (void)dealStarShape
{
    
}


- (CGPoint)fixBorderPanMoveInMaskEditView:(VEDMaskEditView *)maskDrawView toPoint:(CGPoint)point
{
    UIView *borderView = (UIView*)self.parentView.canvasBorderView;
    
    CGRect bounds = borderView.bounds;
    CGPoint toPoint = [maskDrawView convertPoint:point toView:borderView];
    
    if (toPoint.x < 0) {
        toPoint.x = 0;
    } else if (toPoint.x > bounds.size.width) {
        toPoint.x = bounds.size.width;
    }
    
    if (toPoint.y < 0) {
        toPoint.y = 0;
    } else if (toPoint.y > bounds.size.height) {
        toPoint.y = bounds.size.height;
    }
    return [borderView convertPoint:toPoint toView:maskDrawView];
}

- (void)didBeganMaskDrawEditInMaskEditView:(VEDMaskEditView *) maskDrawView
{
    DVELogInfo(@"didBeganMaskDrawEditInMaskEditView");
    self.disableKeyframeUpdate = YES;
    
}

- (void)didMaskDrawEditingInMaskEditView:(VEDMaskEditView *) maskDrawView
{
    DVELogInfo(@"didMaskDrawEditingInMaskEditView");
    [self syncUIDataWithView:maskDrawView];
    [self.maskEditor updateOneMaskWithEffectValue:self.vcConfigModel needCommit:NO];
}

- (void)didEndedMaskDrawEditInMaskEditView:(VEDMaskEditView *) maskDrawView
{
    DVELogInfo(@"didEndedMaskDrawEditInMaskEditView");
    [self syncUIDataWithView:maskDrawView];
    [self.maskEditor updateOneMaskWithEffectValue:self.vcConfigModel needCommit:YES];
    self.disableKeyframeUpdate = NO;
}

- (void)syncUIDataWithView:(VEDMaskEditView *) maskDrawView
{
    self.vcConfigModel.center = [self UICenterToVECenterWithView:maskDrawView];

    self.vcConfigModel.width = maskDrawView.config.data.width/self.vcConfigModel.borderSize.width;
    self.vcConfigModel.height = maskDrawView.config.data.height/self.vcConfigModel.borderSize.height;
    
    self.vcConfigModel.roundCorner = maskDrawView.config.data.roundCorner / maskDrawView.config.ui.roundCornerMaxSpace;
}

- (void)maskDrawViewWillBeginRotateWithMaskEditView:(VEDMaskEditView *) maskDrawView
{

}

- (void)maskDrawViewDidChangeRotateWithMaskEditView:(VEDMaskEditView *) maskDrawView
{
    [self syncRotateDataWithView:maskDrawView];
    [self.maskEditor updateOneMaskWithEffectValue:self.vcConfigModel needCommit:NO];
}

- (void)maskDrawViewDidEndRotateWithMaskEditView:(VEDMaskEditView *) maskDrawView
{
    [self syncRotateDataWithView:maskDrawView];
    [self.maskEditor updateOneMaskWithEffectValue:self.vcConfigModel needCommit:YES];
}

- (void)syncRotateDataWithView:(VEDMaskEditView *) maskDrawView
{
    self.vcConfigModel.rotation = maskDrawView.config.data.rotation + [self.vcContext.mediaContext currentBlendVideoSlot].rotation;
    [self.maskEditView updateLabel];
}

- (void)reloadConfigModel
{
    self.data = nil;
    self.ui = nil;
    self.maskConfig = nil;
    [self editViewWithType:self.vcConfigModel.type];
    [self.maskEditView configDrawViewWithConfig:self.maskConfig];
}

- (CGPoint)UICenterToVECenterWithView:(VEDMaskEditView *) maskDrawView
{
    CGPoint veCenter = CGPointZero;
    
    CGFloat curX = 0;
    CGFloat curY = 0;
    
    CGFloat rotation = -[self.vcContext.mediaContext currentBlendVideoSlot].rotation;
    CGSize curBorderSize = _vcConfigModel.borderSize;
    
    if (rotation == 0) {
        curX = (maskDrawView.config.data.center.x - curBorderSize.width * 0.5)/(curBorderSize.width * 0.5);
        curY = -(maskDrawView.config.data.center.y - curBorderSize.height * 0.5)/(curBorderSize.height * 0.5);
    } else if (rotation == 90) {
        curX = (maskDrawView.config.data.center.x - curBorderSize.width * 0.5)/(curBorderSize.width * 0.5);
        curY = -(maskDrawView.config.data.center.y - curBorderSize.height * 0.5)/(curBorderSize.height * 0.5);
    } else if (rotation == 180) {
        curX = (maskDrawView.config.data.center.x - curBorderSize.width * 0.5)/(curBorderSize.width * 0.5);
        curY = -(maskDrawView.config.data.center.y - curBorderSize.height * 0.5)/(curBorderSize.height * 0.5);
    } else if (rotation == 270) {
        curX = (maskDrawView.config.data.center.x - curBorderSize.width * 0.5)/(curBorderSize.width * 0.5);
        curY = -(maskDrawView.config.data.center.y - curBorderSize.height * 0.5)/(curBorderSize.height * 0.5);
    } else {
        curX = (maskDrawView.config.data.center.x - curBorderSize.width * 0.5)/(curBorderSize.width * 0.5);
        curY = -(maskDrawView.config.data.center.y - curBorderSize.height * 0.5)/(curBorderSize.height * 0.5);
    }
    
    veCenter = CGPointMake(curX, curY);
    
    return veCenter;
}

- (CGSize)curBorderSize
{
    CGSize curBorderSize = CGSizeZero;
    
    CGFloat curW = 0;
    CGFloat curH = 0;
    
    CGSize normalBorderSize = self.parentView.canvasBorderView.bounds.size;
    
    CGFloat rotation = -[self.vcContext.mediaContext currentBlendVideoSlot].rotation;
    
    if (rotation == 0) {
        curW = normalBorderSize.width;
        curH = normalBorderSize.height;
    } else if (rotation == 90) {
        curW = normalBorderSize.height;
        curH = normalBorderSize.width;
    } else if (rotation == 180) {
        curW = normalBorderSize.width;
        curH = normalBorderSize.height;
    } else if (rotation == 270) {
        curW = normalBorderSize.height;
        curH = normalBorderSize.width;
    } else {
        curW = normalBorderSize.width;
        curH = normalBorderSize.height;
    }
    
    curBorderSize = CGSizeMake(curW, curH);
    
    return curBorderSize;
}

#pragma mark --DVEMaskKeyFrameProtocol---

- (void)maskKeyFrameDidChanged:(NLETrackSlot_OC *)slot
{
    if(self.disableKeyframeUpdate)return;//拖动过程中禁止刷新，防止编辑框或者ve重演效果跳动
    if(slot.getKeyframe.count > 0) {
        NLEMask_OC *mask = [slot getMask].firstObject;
        if(mask){
            NLESegmentMask_OC *maskSegment = mask.segmentMask;
            @weakify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                self.vcConfigModel.width = maskSegment.width;
                self.vcConfigModel.height = maskSegment.height;
                self.vcConfigModel.feather = maskSegment.feather;
                self.vcConfigModel.center = CGPointMake(maskSegment.centerX, maskSegment.centerY);
                self.vcConfigModel.roundCorner = maskSegment.roundCorner;
                self.vcConfigModel.rotation = maskSegment.rotation;
                self.vcConfigModel.borderSize = [self curBorderSize];
                [self reloadConfigModel];
                [self.maskBar refreshBar];
            });
        }
    }
}


@end
