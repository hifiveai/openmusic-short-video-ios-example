//
//   DVEExportService.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/23.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEExportService.h"
#import "DVEDataCache.h"
#import "DVEVCContext.h"
#import "DVECustomerHUD.h"
#import "DVELoggerImpl.h"
#import <mach/mach_time.h>
#import <TTVideoEditor/HTSVideoData.h>
#import <TTVideoEditor/IESMMTransProcessData.h>
#import <TTVideoEditor/VECompileTaskManagerSession.h>
#import <TTVideoEditor/VELVConcat.h>

@interface DVEExportService ()

@property (nonatomic, strong) VELVConcat *concat;
@property (nonatomic, weak) id<DVECoreCanvasProtocol> canvasEditor;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@end

@implementation DVEExportService

@synthesize vcContext;
@synthesize expotFps;
@synthesize exportResolution;

DVEAutoInject(self.vcContext.serviceProvider, canvasEditor, DVECoreCanvasProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if(self = [super init]) {
        self.vcContext = context;
    }
    return self;
}

-(void)setExportFPSSelectIndex:(NSInteger)index
{
    [DVEDataCache setExportFPSSelectIndex:index];
    switch (index) {
        case 0:
        {
            self.expotFps = DVEExportFPS25;
        }
            break;
        case 1:
        {
            self.expotFps = DVEExportFPS30;
        }
            break;
        case 2:
        {
            self.expotFps = DVEExportFPS50;
        }
            break;
        case 3:
        {
            self.expotFps = DVEExportFPS60;
        }
            break;
            
        default:
            break;
    }
}

-(void)setExportPresentSelectIndex:(NSInteger)index
{
    DVEExportResolution resolution = 0;
    switch (index) {
        case 0:
        {
            resolution = DVEExportResolutionP540;
        }
            break;
        case 1:
        {
            resolution = DVEExportResolutionP720;
        }
            break;
        case 2:
        {
            resolution = DVEExportResolutionP1080;
        }
            break;
        case 3:
        {
            resolution = DVEExportResolutionP4K;
        }
            break;
            
        default:
            break;
    }
    
    [DVEDataCache setExportPresentSelectIndex:index];
    [DVEDataCache setExportPresent:resolution];
    self.exportResolution = resolution;
}

- (void)exportVideoWithProgress:(void (^_Nullable )(CGFloat progress))progressBlock resultBlock:(void (^)(NSError *error,id result))exportBlock{
    HTSVideoData *videoData = [self.nle.videoData copy];
    videoData.transParam.allowFrameReordering = NO; // 建议设置为NO,否则很影响转码耗时
    videoData.transParam.bitrate = [self p_exportBitRateWithResolution:self.exportResolution fps:self.expotFps];
    videoData.canvasSize = [self.canvasEditor exportSizeForResolution:self.exportResolution];
    if (!self.nle.videoData.lvCompletionAsset) {
        [self.nle.videoData updateTimeLine];
    }
    videoData.isPlaying = NO;
    videoData.transParam.useVideoDataOutputSize = YES;
    videoData.transParam.videoSize = videoData.canvasSize;
    
    IESMMTransProcessData *config = [[IESMMTransProcessData alloc] init];
    config.useNewMudule           = YES;
    config.enableMultiTrack       = YES;
    config.exportFps = (int) (self.expotFps > 0 ? self.expotFps : DVEExportFPS30); // 导出帧率
    config.enableOptExportFps = YES;
    config.timeOutPeriod = 4;
    config.infoStickerForceAmazing = YES;
    config.disableEffectGroup = YES;
    config.enableKeyFrameFeature = YES;
    config.infostickerTextureRelease = YES;
    config.disableEffectProcess = NO;
    config.disableExtracFilter = YES;
    config.encodeUseFenceRender = YES;
    config.disableInfoSticker = NO;
    //水印
    //    [self addWaterMarkWithConfig:config];
    
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    
    uint64_t start = mach_absolute_time();
    
    videoData.transParam.useUserBitrate = YES;
    [[VECompileTaskManagerSession sharedInstance] transWithVideoData:videoData
                                                         transConfig:config
                                                        videoProcess:[self.nle getVideoProcess]
                                                       completeBlock:^(IESMMTranscodeRes *result) {
        DVELogDebug(@"------%@",result.mergeUrl);
        //这部分为需要统计时间的代码
        uint64_t end = mach_absolute_time();
        uint64_t cost = (end - start) * timebase.numer / timebase.denom;
        NSTimeInterval time = (CGFloat)cost / NSEC_PER_SEC;

        if (result.mergeUrl) {
            DVELogDebug(@"方法耗时: %f s",time);
            [self concatCoverWithVideo:result.mergeUrl
                             videoSize:videoData.transParam.videoSize
                            completion:exportBlock];
        } else {
            if (exportBlock) {
                exportBlock(result.error, nil);
            }
        }
    }];
    
    [[VECompileTaskManagerSession sharedInstance] setProgressBlock:^(CGFloat progress) {
        if (progressBlock) {
            progressBlock(progress);
        }
    }];
}

- (void)saveVideoToAlbum:(NSString *)path {
    
}


- (void)cancelExport{
    [[VECompileTaskManagerSession sharedInstance] cancelTranscode];
}

- (void)addWaterMarkWithConfig:(IESMMTransProcessData *)config{
    CGSize videoSize = [self.canvasEditor exportSizeForResolution:self.exportResolution];
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:10];
    UIImage *endingWatermark   = @"watermark".dve_toImage;
    UIImage *image             = @"watermark".dve_toImage;
    [imageArray addObject:image];
    
    IESWaterMarkData *waterMarkData = [[IESWaterMarkData alloc] init];
    waterMarkData.waterMark         = imageArray;
    waterMarkData.point             = CGPointZero;
    waterMarkData.targetVideoSize   = videoSize;
    waterMarkData.refreshInterval   = 24;
    waterMarkData.showTimeRange     = IESMediaTimeRangeMake(0,[self.nle.videoData totalDurationWithTimeMachine] / 2.);
    
    IESWaterMarkData *waterMarkData1 = [[IESWaterMarkData alloc] init];
    waterMarkData1.waterMark         = imageArray;
    image                            = (UIImage *)imageArray.firstObject;
    waterMarkData1.point             = CGPointMake(videoSize.width - image.size.width, videoSize.height - image.size.height);
    waterMarkData1.targetVideoSize   = videoSize;
    waterMarkData1.refreshInterval   = 3;
    waterMarkData1.showTimeRange     = IESMediaTimeRangeMake([self.nle.videoData totalDurationWithTimeMachine] / 2., [self.nle.videoData totalDurationWithTimeMachine] / 2.);
    
    NSArray<IESWaterMarkData *> *waterMarkArray = [NSArray arrayWithObjects:waterMarkData, waterMarkData1, nil];
    
    
    
    config.waterMarkDataArray                 = waterMarkArray;
    config.waterMarkUseCache                  = YES;
//    config.endingWaterMarkImage               = endingWatermark;
}

- (void)concatCoverWithVideo:(NSURL *)videoURL
                   videoSize:(CGSize)size
                  completion:(void (^)(NSError * _Nullable error, NSURL * _Nullable result))completion {
    NLEVideoFrameModel_OC *coverModel = self.nleEditor.nleModel.coverModel;
    if (!coverModel || !coverModel.snapshot) {
        if (completion) {
            completion(nil, videoURL);
        }
        return;
    }
    
    NSURL *coverURL = [NSURL fileURLWithPath:[self.nle getAbsolutePathWithResource:coverModel.snapshot]];
    if (!coverURL) {
        NSError *error = [NSError errorWithDomain:@"DVEExportService"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"cover url is nil!!!"}];
        if (completion) {
            completion(error, nil);
        }
        return;
    }
    
    VELVConcatConfig *config = [[VELVConcatConfig alloc] init];
    config.imageDuration = 1;                  
    config.videoSize = size;
    
    self.concat = [[VELVConcat alloc] initWithConfig:config];
    [self.concat concatVideoAndImage:coverURL
                       videoUrl:videoURL
                       progressBlock:^(CGFloat progress) {
    }
                  completeBlock:^(NSURL * _Nullable outputUrl, NSError * _Nullable error) {
        if (completion) {
            completion(error, outputUrl);
        }
    }];
}

// 导出码率配置
- (int)p_exportBitRateWithResolution:(DVEExportResolution)resolution fps:(DVEExportFPS)fps{
    CGFloat baseBitRate = 0;
    switch (resolution) {
        case DVEExportResolutionP540:
            baseBitRate = 4.5;
            break;
        case DVEExportResolutionP720:
            baseBitRate = 10.f;
            break;
        case DVEExportResolutionP1080:
            baseBitRate = 16.f;
            break;
        case DVEExportResolutionP4K:
            baseBitRate = 45.f;
            break;
        default:
            baseBitRate = 10.f;
            break;
    }
    
    CGFloat biteRate = baseBitRate * 1024.0 * 1024.0;
    biteRate = ((fps - 30) / 30.0 * 0.4 + 1.0) * biteRate;
    return (int)biteRate;
}

- (NSArray *)exportFPSTitleArr
{
    return @[
            @"25FPS",
            @"30FPS",
            @"50FPS",
            @"60FPS",
    ];
}

- (NSArray *)exportPresentTitleArr
{
    return @[
            @"540P",
            @"720P",
            @"1080P",
            @"4K",
    ];
}

@end
