//
//   DVECanvasEditor.m
//   NLEEditor
//
//   Created  by bytedance on 2021/4/27.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVECanvasEditor.h"
#import "NSDictionary+DVE.h"
#import "DVECustomerHUD.h"
#import "NSString+DVE.h"
#import "DVEVCContext.h"
#import "DVECoreKeyFrameProtocol.h"
#import "DVECommonDefine.h"
#import <DVETrackKit/DVECGUtilities.h>
#import "CGRect+DVE.h"
#import <NLEPlatform/CGSize+NLE.h>
#import <NLEPlatform/NLEAllKeyFrameInfo.h>

#define VED_NLE_ExtKey_CanvasSize @"VED_NLE_ExtKey_CanvasSize"
#define VED_NLE_ExtKey_Ratio @"VED_NLE_ExtKey_Ratio"
#define VED_NLE_ExtKey_PreviewSize @"VED_NLE_ExtKey_PreviewSize"
#define VED_NLE_ExtKey_NatureSize @"VED_NLE_ExtKey_natureSize"

@interface DVECanvasEditor()
<
DVECoreActionNotifyProtocol,
NLEEditor_iOSListenerProtocol,
NLEKeyFrameCallbackProtocol
>

@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;

@property (nonatomic, weak) id<DVECoreKeyFrameProtocol> keyFrameEditor;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;
@property (nonatomic, strong) NLETrackSlot_OC *preKeyFrameListSlot;


@end

@implementation DVECanvasEditor

@synthesize vcContext;
@synthesize canvasSize;
@synthesize originRatioSize;
@synthesize ratio;
@synthesize keyFrameDelegate;

DVEAutoInject(self.vcContext.serviceProvider, keyFrameEditor, DVECoreKeyFrameProtocol)
DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if (self = [super init]) {
        self.vcContext = context;
        [self.actionService addUndoRedoListener:self];
        [self.nle addKeyFrameListener:self];
        [self.nleEditor addListener:self];
    }
    return self;
}

- (void)initCanvasWithResource:(id<DVEResourcePickerModel>)resourceModel {
    if (resourceModel.type == DVEResourceModelPickerTypeVideo) {
        AVAsset *asset = resourceModel.videoAsset;
        if (!asset) {
            NSAssert(NO, @"video asset is nil!");
        }
        AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        self.originRatioSize = track.naturalSize;
        
        CGAffineTransform t = track.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
            self.originRatioSize = CGSizeMake(track.naturalSize.height,track.naturalSize.width);;
        } else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {
            self.originRatioSize = CGSizeMake(track.naturalSize.height,track.naturalSize.width);;
        } else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
            
        } else {
            
        }
    } else if (resourceModel.type == DVEResourceModelPickerTypeImage) {
        if (resourceModel.image) {
            self.originRatioSize = resourceModel.image.size;
        } else if (resourceModel.URL) {
            UIImage *image = [UIImage imageWithContentsOfFile:resourceModel.URL.path];
            self.originRatioSize = image.size;
        }
    }
    self.originRatioSize = nle_CGSizeSafeValue(self.originRatioSize);
    if (originRatioSize.width > 0 && originRatioSize.height > 0) {
        CGSize canvasSize = DVECGSizeSacleAspectFitToMinSize(self.originRatioSize, CGSizeMake(720, 720));
        canvasSize = [self fitMaxSizeForResolution:720 originSize:canvasSize];
        self.canvasSize = canvasSize;
    } else {
        NSAssert(NO, @"invalid canvas size");
    }
    
}

- (void)saveCanvasSize
{
    [self.nleEditor.nleModel setExtra:NSStringFromCGSize(self.canvasSize) forKey:VED_NLE_ExtKey_CanvasSize];
    [self.nleEditor.nleModel setExtra:@(self.ratio).stringValue forKey:VED_NLE_ExtKey_Ratio];
    [self.nleEditor.nleModel setExtra:NSStringFromCGSize(self.originRatioSize) forKey:VED_NLE_ExtKey_NatureSize];
}

- (void)restoreCanvasSize
{
    NSString *canvasSize = [self.nleEditor.nleModel getExtraForKey:VED_NLE_ExtKey_CanvasSize];
    NSString *ratio = [self.nleEditor.nleModel getExtraForKey:VED_NLE_ExtKey_Ratio];
    NSString *originRatioSize = [self.nleEditor.nleModel getExtraForKey:VED_NLE_ExtKey_NatureSize];
    self.canvasSize = CGSizeFromString(canvasSize);
    self.ratio = ratio.integerValue;
    self.originRatioSize = CGSizeFromString(originRatioSize);
}

- (void)setCanvasRatio:(DVECanvasRatio)ratio inPreviewView:(UIView *)view needCommit:(BOOL)isneed{
    self.ratio = ratio;
    if (isneed) {
        NLEModel_OC *model = self.nleEditor.nleModel;
        float r = 0.f;
        switch (ratio) {
            case DVECanvasRatioOriginal:
                r = self.originRatioSize.width / self.originRatioSize.height;
                break;
            case DVECanvasRatio1_1:
                r = 1.f;
                break;
            case DVECanvasRatio3_4:
                r = 3 /4.f;
                break;
            case DVECanvasRatio4_3:
                r = 4/ 3.f;
                break;
            case DVECanvasRatio16_9:
                r = 16/9.f;
                break;
            case DVECanvasRatio9_16:
                r = 9 /16.f;
                break;
            default:
                break;
        }
        [model setCanvasRatio:r];
        [self.actionService commitNLE:YES];
        [self.vcContext.mediaContext seekToCurrentTime];
    }
    
    [self.nle resetPlayerWithViews:@[view]];
}

// 位移画布资源
- (void)updateVideoClipTranslation:(CGPoint)translation forSlot:(NLETrackSlot_OC *)slot isCommit:(BOOL)commit{
    if (!slot) {
        return;
    }
    
    slot.transformX = translation.x;
    slot.transformY = translation.y;
    
    [slot addOrUpdateKeyframe:CMTimeMake(self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC, USEC_PER_SEC)
                   timeRange:[self.keyFrameEditor currentKeyframeTimeRange] forceAdd:NO];
    [self.actionService commitNLE:commit];
}

// 缩放画布资源
- (void)updateVideoClipScale:(CGFloat)scale forSlot:(NLETrackSlot_OC *)slot isCommit:(BOOL)commit  {
    if (!slot) {
        return;
    }
    
    slot.scale = scale;
    
    [slot addOrUpdateKeyframe:CMTimeMake(self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC, USEC_PER_SEC)
                   timeRange:[self.keyFrameEditor currentKeyframeTimeRange] forceAdd:NO];
    
    [self.actionService commitNLE:commit];
}

// 旋转
- (void)updateVideoClipRotation:(CGFloat)rotation forSlot:(NLETrackSlot_OC *)slot isCommit:(BOOL)commit {
    if (!slot) {
        return;
    }
    
    slot.rotation = -rotation;
    
    [slot addOrUpdateKeyframe:CMTimeMake(self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC, USEC_PER_SEC)
                   timeRange:[self.keyFrameEditor currentKeyframeTimeRange] forceAdd:NO];
    [self.actionService commitNLE:commit];
}


/**
 尺寸修剪
*/
- (CGSize)fitMaxSizeForResolution:(CGFloat)resolution originSize:(CGSize)originSize  {
    CGFloat maxValue = resolution * 16.0 / 9.0;
    if(originSize.width > originSize.height) {
        if(originSize.width > maxValue) {
            return CGSizeMake(maxValue, originSize.height / originSize.width * maxValue);
        }
    } else {
        if(originSize.height > maxValue) {
            return CGSizeMake(originSize.width / originSize.height * maxValue, maxValue);
        }
    }
    return originSize;
}

- (CGSize)exportSizeForResolution:(DVEExportResolution)resolution {
    CGSize exportSize = CGSizeZero;
    switch (self.ratio) {
            case DVECanvasRatio16_9:
                exportSize = CGSizeMake(resolution * 16.0 / 9.0, resolution);
                break;
            case DVECanvasRatio4_3:
                exportSize = CGSizeMake(resolution * 4.0 / 3.0, resolution);
                break;
            case DVECanvasRatio1_1:
                exportSize = CGSizeMake(resolution, resolution);
                break;
            case DVECanvasRatio9_16:
                exportSize = CGSizeMake(resolution, resolution * 16.0 / 9.0);
                break;
            case DVECanvasRatio3_4:
                exportSize = CGSizeMake(resolution, resolution * 4.0 / 3.0);
                break;
            case DVECanvasRatioOriginal: {
                CGFloat _originWidth = self.originRatioSize.width;
                CGFloat _originHeight = self.originRatioSize.height;
                if (_originWidth <= 0 || _originHeight <= 0) {
                    exportSize = CGSizeMake(resolution, resolution * 16.0 / 9.0);
                } else {
                    if (_originWidth > _originHeight) {
                        exportSize = CGSizeMake(resolution * _originWidth / _originHeight, resolution);
                    } else {
                        exportSize = CGSizeMake(resolution, resolution * _originHeight / _originWidth);
                    }
                }
                break;
            }
        default:
            break;
    }
    
    exportSize = [self fitMaxSizeForResolution:resolution originSize:exportSize];
    return CGSizeMake(roundf(exportSize.width / 2.0) * 2.0, roundf(exportSize.height / 2.0) * 2.0);
}


- (CGSize)exportSizeForRation:(DVECanvasRatio)ratio Resolution:(DVEExportResolution)resolution {
    CGSize exportSize = CGSizeZero;
    switch (ratio) {
            case DVECanvasRatio16_9:
                exportSize = CGSizeMake(resolution * 16.0 / 9.0, resolution);
                break;
            case DVECanvasRatio4_3:
                exportSize = CGSizeMake(resolution * 4.0 / 3.0, resolution);
                break;
            case DVECanvasRatio1_1:
                exportSize = CGSizeMake(resolution, resolution);
                break;
            case DVECanvasRatio9_16:
                exportSize = CGSizeMake(resolution, resolution * 16.0 / 9.0);
                break;
            case DVECanvasRatio3_4:
                exportSize = CGSizeMake(resolution, resolution * 4.0 / 3.0);
                break;
        default:
            break;
    }
    
    exportSize = [self fitMaxSizeForResolution:resolution originSize:exportSize];
    return CGSizeMake(roundf(exportSize.width / 2.0) * 2.0, roundf(exportSize.height / 2.0) * 2.0);
}


- (void)updateCanvasRatio:(NSInteger)ratio size:(CGSize)size
{
    self.ratio = ratio;
    self.canvasSize = size;
}

- (CGRect)subViewScaleAspectFit:(CGRect)rect
{
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    
    switch (self.ratio) {
        case DVECanvasRatio16_9:
            h = w * 9.0 / 16.0;
            break;
        case DVECanvasRatio9_16:
            w = h * 9.0 / 16.0;
            break;
        case DVECanvasRatio4_3:
            h = w * 3.0 / 4.0;
            break;
        case DVECanvasRatio3_4:
            w = h * 3.0 / 4.0;
            break;
        case DVECanvasRatio1_1: {
            w = w < h ? w : h;
            h = w;
            break;
        }
        case DVECanvasRatioOriginal: {
            if (self.originRatioSize.width <= 0.0 || self.originRatioSize.height <= 0.0) {
                h = rect.size.height;
                w = h * 9.0 / 16.0;
            } else {
                CGSize size = nle_limitMinSize(self.originRatioSize, rect.size);
                w = size.width;
                h = size.height;
            }
            break;
        }
        default:
            break;
    }
    
    CGSize minSize = CGSizeMake(720.0, 720.0);
    CGSize canvasSize = nle_limitMinSize(CGSizeMake(w, h), minSize);
    canvasSize = [self fitMaxSizeForResolution:720 originSize:canvasSize];
    canvasSize.width = round(canvasSize.width / 2.0) * 2.0;
    canvasSize.height = round(canvasSize.height / 2.0) * 2.0;
    //改变尺寸需要更新canvasSize
    self.canvasSize = canvasSize;
    return dve_scaleAspectFit(canvasSize, rect);
}

- (CGSize)canvasSizeScaleAspectFitInRect:(CGRect)rect
{
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    
    switch (self.ratio) {
        case DVECanvasRatio16_9:
            h = w * 9.0 / 16.0;
            break;
        case DVECanvasRatio9_16:
            w = h * 9.0 / 16.0;
            break;
        case DVECanvasRatio4_3:
            h = w * 3.0 / 4.0;
            break;
        case DVECanvasRatio3_4:
            w = h * 3.0 / 4.0;
            break;
        case DVECanvasRatio1_1: {
            w = w < h ? w : h;
            h = w;
            break;
        }
        case DVECanvasRatioOriginal: {
            if (self.originRatioSize.width <= 0.0 || self.originRatioSize.height <= 0.0) {
                h = rect.size.height;
                w = h * 9.0 / 16.0;
            } else {
                CGSize size = nle_limitMinSize(self.originRatioSize, rect.size);
                w = size.width;
                h = size.height;
            }
            break;
        }
        default:
            break;
    }
    
    CGSize minSize = CGSizeMake(720.0, 720.0);
    CGSize canvasSize = nle_limitMinSize(CGSizeMake(w, h), minSize);
    canvasSize = [self fitMaxSizeForResolution:720 originSize:canvasSize];
    canvasSize.width = round(canvasSize.width / 2.0) * 2.0;
    canvasSize.height = round(canvasSize.height / 2.0) * 2.0;
    return canvasSize;
}

#pragma mark - KeyFrame

- (void)nleDidChangedWithPTS:(CMTime)time
                keyFrameInfo:(NLEAllKeyFrameInfo *)info
{
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentMainVideoSlotWithTimelineMapping];
    
    if (!slot) {
        return;
    }
    
//    if (!self.canKeyFrameCallback ||
//        ([self.keyFrameDelegate respondsToSelector:@selector(canKeyFrameCallback)] && ![self.keyFrameDelegate canKeyFrameCallback])) {
//        return;
//    }
    
    NLETrackSlot_OC *resultSlot = [self.nle refreshAllKeyFrameInfo:info pts:self.vcContext.playerService.currentPlayerTime * USEC_PER_SEC inSlot:slot];

    if (resultSlot && [self.keyFrameDelegate respondsToSelector:@selector(canvasKeyFrameDidChangedWithSlot:)]) {
        [self.keyFrameDelegate canvasKeyFrameDidChangedWithSlot:resultSlot];
    }
}

- (void)nleModelChanged:(NLEModel_OC *)model withResultCode:(int)resultCode {

    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentMainVideoSlotWithTimelineMapping];
    if (!slot) {
        return;
    }
    
    //slot已经变了或者关键帧的数量减少了的时候需要重置关键帧回调
//    if (![slot.nle_nodeId isEqualToString:self.preKeyFrameListSlot.nle_nodeId] || [slot getKeyframe].count < [self.preKeyFrameListSlot getKeyframe].count) {
//        self.canKeyFrameCallback = YES;
//    }
    if (![slot.nle_nodeId isEqualToString:self.preKeyFrameListSlot.nle_nodeId]) {
        self.preKeyFrameListSlot = [slot deepClone];
    }
}

#pragma mark --DVECoreActionNotifyProtocol

- (void)undoRedoClikedByUser
{
    //undo需要重置关键帧回调标志位
//    self.canKeyFrameCallback = YES;
    [self restoreCanvasSize];
}

- (void)undoRedoWillClikeByUser
{
    //redo需要重置关键帧回调标志位
//    self.canKeyFrameCallback = YES;
    [self restoreCanvasSize];
}

@end
