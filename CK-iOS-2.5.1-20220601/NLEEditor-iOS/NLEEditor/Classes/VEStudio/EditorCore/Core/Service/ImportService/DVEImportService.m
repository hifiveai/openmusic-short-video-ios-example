//
//  DVEImportService.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/23.
//

#import "DVEImportService.h"
#import "DVECustomerHUD.h"
#import "DVEVCContext.h"
#import "DVEVideoEditorWrapper.h"

@interface DVEImportService ()

@property (nonatomic, weak) id<DVECoreDraftServiceProtocol> draftService;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@end

@implementation DVEImportService

@synthesize vcContext = _vcContext;

DVEAutoInject(self.vcContext.serviceProvider, draftService, DVECoreDraftServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if (self = [super init]) {
        _vcContext = context;
    }
    return self;
}

#pragma mark - Public

- (void)addResources:(NSArray<id<DVEResourcePickerModel>> *)resources
          completion:(dispatch_block_t)completion
{
    [resources enumerateObjectsUsingBlock:^(id<DVEResourcePickerModel>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self p_addAssetForResource:obj];
    }];
    [self addNLEMainVideoWithResources:resources completion:completion];
    
    ///如果没编辑过封面，则替换主轨第一个素材的时候，需要刷新封面按钮
    ///这里简单处理，不管什么素材都刷一下
    if(!self.nleEditor.nleModel.coverModel.snapshot){
        ///临时处理方式：发通知，合并模板分支后需要改
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CoverSnapshotSave"
                                                            object:nil];
    }
}

- (void)addNLEMainVideoWithResources:(NSArray<id<DVEResourcePickerModel>> *)resources
                          completion:(dispatch_block_t)completion
{
    NSTimeInterval startTime = 0;
    NSMutableArray *trackSlotArray = [NSMutableArray array];
    for (NSInteger i = 0; i < resources.count; i ++) {
        id<DVEResourcePickerModel> res = resources[i];
        if (res.type == DVEResourceModelPickerTypeVideo) {
            // copy resource
            NSString *relativePath = [self.draftService copyResourceToDraft:res.videoAsset.URL resourceType:NLEResourceTypeVideo];

            NLEResourceAV_OC *videoResource = [[NLEResourceAV_OC alloc] init];
            [videoResource nle_setupForVideo:res.videoAsset];
            videoResource.resourceFile = relativePath;

            CMTime duration = videoResource.duration;

            NLESegmentVideo_OC *videoSegment = [[NLESegmentVideo_OC alloc] init];
            videoSegment.videoFile = videoResource;
            videoSegment.timeClipStart = CMTimeMake(0 * USEC_PER_SEC, USEC_PER_SEC);
            videoSegment.timeClipEnd = duration;
            [videoSegment setVolume:1];
            videoSegment.canvasStyle = [[NLEStyCanvas_OC alloc] init];
            if (res.videoSpeed > 0 ) {
                [videoSegment setSpeed:res.videoSpeed];
            }

            NLETrackSlot_OC *trackSlot = [[NLETrackSlot_OC alloc] init];
            [trackSlot setSegmentVideo:videoSegment];
            trackSlot.startTime = CMTimeMake(startTime * USEC_PER_SEC, USEC_PER_SEC);
            [trackSlot setLayer:0];

            startTime += CMTimeGetSeconds(duration);
            [trackSlotArray addObject:trackSlot];
        } else if (res.type == DVEResourceModelPickerTypeImage) {
            NSURL *filePath = res.URL;

            // copy resource
            NSString *relativePath = [self.draftService copyResourceToDraft:filePath resourceType:NLEResourceTypeVideo];

            CMTime duration = res.imageDuration;
            if (CMTimeCompare(res.imageDuration, kCMTimeZero) <= 0) {
                duration = CMTimeMakeWithSeconds(3, USEC_PER_SEC);
            }

            NLEResourceAV_OC *videoResource = [[NLEResourceAV_OC alloc] init];

            videoResource.resourceType = NLEResourceTypeImage;
            UIImage *image = res.image;
            if (!image) {
                image = [UIImage imageWithContentsOfFile:filePath.path];
            }
            videoResource.width = image.size.width;
            videoResource.height = image.size.height;
            videoResource.resourceFile = relativePath;
            videoResource.duration = DVEVideoEditorWrapper.kDefaultPhotoResourceDuration;

            NLESegmentVideo_OC *videoSegment = [[NLESegmentVideo_OC alloc] init];
            videoSegment.videoFile = videoResource;
            videoSegment.timeClipStart = CMTimeMake(0 * USEC_PER_SEC, USEC_PER_SEC);
            videoSegment.timeClipEnd = duration;
            videoSegment.canvasStyle = [[NLEStyCanvas_OC alloc] init];

            NLETrackSlot_OC *trackSlot = [[NLETrackSlot_OC alloc] init];
            [trackSlot setSegmentVideo:videoSegment];
            trackSlot.startTime = CMTimeMake(startTime * USEC_PER_SEC, USEC_PER_SEC);
            [trackSlot setLayer:0];

            startTime += CMTimeGetSeconds(duration);
            [trackSlotArray addObject:trackSlot];
        }
    }

    [self.nleEditor.nleModel nle_addSlotsToMainTrack:trackSlotArray
                                              atTime:self.vcContext.mediaContext.currentTime];
    [self.actionService commitNLE:YES];
    [self.vcContext.playerService seekToTime:self.vcContext.mediaContext.currentTime isSmooth:NO completionHandler:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

// 目前画中画只支持添加一个视频
- (void)addSubTrackResource:(id<DVEResourcePickerModel>)resource
                 completion:(void(^)(NLETrackSlot_OC *slot))completion
{
    NSInteger maxLayer = [self p_getMaxLayerForSubVideo];
    if (maxLayer >= 2) {
        [DVECustomerHUD showMessage:@"继续添加画中画可能影响预览体验" afterDele:2];
    }
    maxLayer += 1;

    [self p_addAssetForResource:resource];

    [self p_addNLESubVideoWithResources:@[resource] targetStartTime:self.vcContext.mediaContext.currentTime layer:(int)maxLayer completion:completion];
}

- (void)replaceResourceForSlot:(NLETrackSlot_OC *)slot
                 albumResource:(id<DVEResourcePickerModel>)albumResource
{
    NLEResourceAV_OC *slotResource = [[NLEResourceAV_OC alloc] init];
    if (albumResource.type == DVEResourceModelPickerTypeImage) {
        NSString *imagePath = [self.draftService copyResourceToDraft:albumResource.URL resourceType:NLEResourceTypeImage];
        UIImage *image = albumResource.image;
        if (!image) {
            image = [UIImage imageWithContentsOfFile:albumResource.URL.path];
        }
        
        [slotResource nle_setupForPhoto:imagePath
                                  width:image.size.width
                                 height:image.size.height
                               duration:slot.duration];
    } else {
        NSString *videoPath = [self.draftService copyResourceToDraft:albumResource.videoAsset.URL resourceType:NLEResourceTypeVideo];

        [slotResource nle_setupForVideo:albumResource.videoAsset
                       resourceFilePath:videoPath];
    }
    
    NLESegmentVideo_OC *videoSegment = (NLESegmentVideo_OC*)[slot.segment deepClone:YES];
    videoSegment.videoFile = slotResource;
    videoSegment.timeClipStart = CMTimeMake(0 * USEC_PER_SEC, USEC_PER_SEC);
    videoSegment.timeClipEnd = slot.getDuration;
    videoSegment.canvasStyle = [[NLEStyCanvas_OC alloc] init];
    ///这里要取消倒放状态，否则替换倒放素材的水货，还是展示上一次倒放的素材
    videoSegment.reversedAVFile = nil;
    videoSegment.rewind = NO;

    [slot setSegmentVideo:videoSegment];

    [self.actionService commitNLE:YES];
    [self.vcContext.mediaContext seekToCurrentTime];
    ///如果没编辑过封面，则替换主轨第一个素材的时候，需要刷新封面按钮
    ///这里简单处理，不管什么素材都刷一下
    if(!self.nleEditor.nleModel.coverModel.snapshot){
        ///临时处理方式：发通知，合并模板分支后需要改
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CoverSnapshotSave"
                                                            object:nil];
    }
}

#pragma mark - Private

- (void)p_addAssetForResource:(id<DVEResourcePickerModel>)model
{
    AVAsset *asset = nil;
    if (model.type == DVEResourceModelPickerTypeImage) {
        if (!model.isGIFImage && model.image && !model.URL) {
            NSString *filePath = [self.nle.draftFolder stringByAppendingPathComponent:[NSString VEUUIDString]];
            [UIImageJPEGRepresentation(model.image, 1) writeToFile:filePath atomically:YES];
            NSURL *picURL = [NSURL fileURLWithPath:filePath];
            model.URL = picURL;
        }
    } else if (model.type == DVEResourceModelPickerTypeVideo) {
        asset = [AVURLAsset URLAssetWithURL:model.URL options:@{
            AVURLAssetPreferPreciseDurationAndTimingKey: @(YES)}];
        model.videoAsset = (AVURLAsset *)asset;
    }
}

- (void)p_addNLESubVideoWithResources:(NSArray<id<DVEResourcePickerModel>> *)resources
                      targetStartTime:(CMTime)targetStartTime
                                layer:(int)layer
                           completion:(void(^)(NLETrackSlot_OC *slot))completion
{
    NSTimeInterval startTime = CMTimeGetSeconds(targetStartTime);
    NSMutableArray *trackSlotArray = [NSMutableArray array];
    for (NSInteger i = 0; i < resources.count; i ++) {
        id<DVEResourcePickerModel> res = resources[i];
        if (res.type == DVEResourceModelPickerTypeVideo ) {
            CMTime duration = res.videoAsset.duration;

            // copy resource
            NSString *relativePath = [self.draftService copyResourceToDraft:res.videoAsset.URL resourceType:NLEResourceTypeVideo];

            NLEResourceAV_OC *videoResource = [[NLEResourceAV_OC alloc] init];
            [videoResource nle_setupForVideo:res.videoAsset];
            videoResource.resourceType = NLEResourceTypeVideo;
            videoResource.resourceFile = relativePath;
            videoResource.duration = duration;

            NLESegmentVideo_OC *videoSegment = [[NLESegmentVideo_OC alloc] init];
            videoSegment.videoFile = videoResource;
            videoSegment.timeClipStart = CMTimeMake(0 * USEC_PER_SEC, USEC_PER_SEC);
            videoSegment.timeClipEnd = duration;
            videoSegment.canvasStyle = [[NLEStyCanvas_OC alloc] init];
            [videoSegment setVolume:1];

            NLETrackSlot_OC *trackSlot = [[NLETrackSlot_OC alloc] init];
            [trackSlot setSegmentVideo:videoSegment];
            [trackSlot setScale:0.7];
            trackSlot.startTime = CMTimeMake(startTime * USEC_PER_SEC, USEC_PER_SEC);
            [trackSlot setLayer:layer];
            startTime += CMTimeGetSeconds(duration);
            [trackSlotArray addObject:trackSlot];

        } else if (res.type == DVEResourceModelPickerTypeImage) {
            NSURL *filePath = res.URL;

            // copy resource
            NSString *relativePath = [self.draftService copyResourceToDraft:filePath resourceType:NLEResourceTypeVideo];

            CMTime duration = res.imageDuration;

            NLEResourceAV_OC *videoResource = [[NLEResourceAV_OC alloc] init];
            
            UIImage *image = res.image;
            if (!image) {
                image = [UIImage imageWithContentsOfFile:[filePath path]];
            }

            videoResource.resourceType = NLEResourceTypeImage;
            videoResource.width = image.size.width;
            videoResource.height = image.size.height;
            videoResource.resourceFile = relativePath;
            videoResource.duration = DVEVideoEditorWrapper.kDefaultPhotoResourceDuration;

            NLESegmentVideo_OC *videoSegment = [[NLESegmentVideo_OC alloc] init];
            videoSegment.videoFile = videoResource;
            videoSegment.timeClipStart = CMTimeMake(0 * USEC_PER_SEC, USEC_PER_SEC);
            videoSegment.timeClipEnd = duration;
            videoSegment.canvasStyle = [[NLEStyCanvas_OC alloc] init];

            NLETrackSlot_OC *trackSlot = [[NLETrackSlot_OC alloc] init];
            [trackSlot setSegmentVideo:videoSegment];
            [trackSlot setScale:0.7];
            [trackSlot setLayer:layer];
            trackSlot.startTime = CMTimeMake(startTime * USEC_PER_SEC, USEC_PER_SEC);
            startTime += CMTimeGetSeconds(duration);
            [trackSlotArray addObject:trackSlot];

        }
    }

    NLETrack_OC *track = [[NLETrack_OC alloc] init];
    [track setLayer:layer];
    track.extraTrackType = NLETrackVIDEO;
    for (NLETrackSlot_OC *slot in trackSlotArray) {
        [track addSlot:slot];
    }
    [self.nleEditor.nleModel addTrack:track];

    [self.actionService commitNLE:YES];
    [self.vcContext.playerService seekToTime:targetStartTime isSmooth:NO completionHandler:^(BOOL finished) {
        if (completion) {
            completion([track.slots firstObject]);
        }
    }];
}

- (NSInteger)p_getMaxLayerForSubVideo
{
    NLEModel_OC *model = self.nleEditor.nleModel;
    NSInteger maxLayer = -1;
    NSArray<NLETrack_OC*> *tracks = [model getTracks];
    for (NLETrack_OC *track in tracks) {
        if (![track isMainTrack] && track.extraTrackType == NLETrackVIDEO) {
            NSInteger layer =  [track getLayer];
            maxLayer = MAX(maxLayer, layer);
        }
    }
    return maxLayer > 0 ? maxLayer : [model nle_getMainVideoTrack].layer;
}

@end
