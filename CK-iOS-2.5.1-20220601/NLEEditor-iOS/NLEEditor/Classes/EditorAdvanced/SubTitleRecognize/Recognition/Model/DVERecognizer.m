//
//  DVERecognizer.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/18.
//

#import "DVERecognizer.h"
#import "DVEVCContext.h"
#import "DVEFileUploadServiceBuilder.h"
#import "DVEFileUploadResponseInfoModel.h"
#import "DVEFileUploadServiceProtocol.h"
#import "DVESubtitleNetServiceProtocol.h"
#import "DVELoggerImpl.h"
#import "DVENetServiceImpl.h"
#import "DVESubtitleNetServiceImp.h"
#import <TTVideoEditor/HTSAudioExport.h>
#import <TTVideoEditor/IESMMMediaExporter.h>

static NSInteger const kCaptionWordsPerLine = 20;
static NSInteger const kCaptionMaxLines = 1;

@interface DVERecognizer()

@property (nonatomic, strong) DVEVCContext *context;
@property (nonatomic, strong) HTSAudioExport *audioExport;
@property (nonatomic, strong) IESMMMediaExporter *mediaExporter;
@property (nonatomic, strong) id<DVEFileUploadServiceProtocol> videoUploadService;
@property (nonatomic, strong) id<DVESubtitleNetServiceProtocol> captionsNetService;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;
@property (nonatomic, copy) NSString *taskId;
@property (nonatomic, copy) NSString *materialId;
@property (nonatomic, strong) NSURL *audioUrl;
@end

@implementation DVERecognizer

DVEAutoInject(self.context.serviceProvider, nle, DVENLEInterfaceProtocol)

- (instancetype)initWithContext:(DVEVCContext *)context
{
    self = [super init];
    if (self) {
        _context = context;
        _captionsNetService = DVEAutoInline(context.serviceProvider, DVESubtitleNetServiceProtocol);
        if(_captionsNetService == nil){
            _captionsNetService = [DVESubtitleNetServiceImp new];
        }
    }
    return self;
}

- (RACSignal<DVESubtitleQueryModel *> *)recognizeAudioText
{
    return [[[self exportAudio] then:^RACSignal * _Nonnull{
        return [self commitAudio];
    }] then:^RACSignal * _Nonnull{
        return [self querySubtitle];
    }];
}

#pragma mark - Export

- (RACSignal<NSURL *> *)exportAudio
{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [self exportAudioWithCompletion:^(NSURL * _Nonnull url, NSError * _Nonnull error, AVAssetExportSessionStatus status) {
            if (error) {
                [subscriber sendError:error];
            } else {
                [subscriber sendNext:url];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

// 这部分是视频自动字幕抽音的逻辑
- (void)exportAudioWithCompletion:(DVEExportCompletion _Nullable)completion
{
    void (^processExportBlock)(NSURL *_Nonnull, NSError *_Nonnull, AVAssetExportSessionStatus) = ^(NSURL * _Nonnull url, NSError * _Nonnull error, AVAssetExportSessionStatus status) {
        if (!url || error) {
            !completion ?: completion(url, error, status);
        } else {
            self.audioUrl = url;
            if (!url) {
                DVELogError(@"export Audio url fail!!");
            }
            !completion ?: completion(url, error, status);
        }
    };
    
    // lv音频框架需要自己处理音乐和变声移除的操作，自动字幕的话需要视频原声+配音+配乐去做识别
    HTSVideoData *newVideoData = self.nle.videoData.copy;
    newVideoData = [self removePitchFilterAndBGMForVideoData:newVideoData removeTextRead:YES];
    
    // 导出并重采样
    self.mediaExporter = [[IESMMMediaExporter alloc] init];
    AudioResampleConfig *config = [[AudioResampleConfig alloc] init];
    config.useSampleRateFromBusiness = YES;
    config.sampelRate = 22050;
    [self.mediaExporter exportAllAudioSoundInVideoData:newVideoData resampleConfig:config completion:^(NSURL * _Nullable outputUrl, NSError * _Nullable error) {
        AVAssetExportSessionStatus status = AVAssetExportSessionStatusCompleted;
        if (!outputUrl || error) {
            status = AVAssetExportSessionStatusFailed;
        }
        !processExportBlock ?: processExportBlock(outputUrl, error, status);
    }];
}

/// 移除video中的变声效果以及背景音乐
/// @param newVideoData 传入的video
- (HTSVideoData *)removePitchFilterAndBGMForVideoData:(HTSVideoData *)newVideoData
                                       removeTextRead:(BOOL)removeTextRead
{
    NSMutableDictionary<AVAsset *, NSMutableArray<IESMMAudioFilter *> *> *newAudioSoundFilterInfo = newVideoData.audioSoundFilterInfo.copy;
    // 1. 针对每个audioAssets应用的变声filter都予以移除
    [newAudioSoundFilterInfo enumerateKeysAndObjectsUsingBlock:^(AVAsset * _Nonnull key, NSMutableArray<IESMMAudioFilter *> * _Nonnull obj, BOOL * _Nonnull stop) {
        NSArray<IESMMAudioFilter *> *audioFilters = obj.copy;
        [audioFilters enumerateObjectsUsingBlock:^(IESMMAudioFilter * _Nonnull innerObj, NSUInteger innerIdx, BOOL * _Nonnull innerStop) {
            // 变声filter
            if (innerObj.type == IESAudioFilterTypePitch) {
                [newVideoData.audioSoundFilterInfo[key] removeObject:innerObj];
            }
        }];
    }];

    // 2. 针对每个videoAssets应用的变声filter都予以移除
    NSMutableDictionary<AVAsset *, NSMutableArray<IESMMAudioFilter *> *> *newVideoSoundFilterInfo = newVideoData.videoSoundFilterInfo.copy;
    [newVideoSoundFilterInfo enumerateKeysAndObjectsUsingBlock:^(AVAsset * _Nonnull key, NSMutableArray<IESMMAudioFilter *> * _Nonnull obj, BOOL * _Nonnull stop) {
        NSArray<IESMMAudioFilter *> *audioFilters = obj.copy;
        [audioFilters enumerateObjectsUsingBlock:^(IESMMAudioFilter * _Nonnull innerObj, NSUInteger innerIdx, BOOL * _Nonnull innerStop) {
            // 变声filter
            if (innerObj.type == IESAudioFilterTypePitch) {
                [newVideoData.videoSoundFilterInfo[key] removeObject:innerObj];
            }
        }];
    }];

    // 4. remove Text Readings
    if(removeTextRead) {
        NSMutableArray<AVAsset *> *assetsToRemoved = @[].mutableCopy;
        [newVideoData.audioAssets enumerateObjectsUsingBlock:^(AVAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[AVURLAsset class]]) {
                BOOL isTextReadAsset = [((AVURLAsset *)obj).URL.path.lastPathComponent hasSuffix:@"readtext.mp3"];
                if (isTextReadAsset) {
                    [assetsToRemoved addObject:obj];
                    [newVideoData.audioTimeClipInfo removeObjectForKey:obj];
                }
            }
        }];
        [newVideoData.audioAssets removeObjectsInArray:assetsToRemoved];
    }

    return newVideoData;
}


#pragma mark - Upload

- (RACSignal<DVEFileUploadResponseInfoModel *> *)uploadAudioWithUrl:(NSURL *)audioUrl
{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [self uploadAudioWithUrl:audioUrl completion:^(DVEFileUploadResponseInfoModel * _Nullable uploadInfoModel, NSError * _Nullable error) {
            if (error) {
                [subscriber sendError:error];
            } else {
                [subscriber sendNext:uploadInfoModel];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

// 上传音频
- (void)uploadAudioWithUrl:(NSURL *)audioUrl completion:(DVEFileUploadCompletion)completion
{
    @weakify(self);
    [[DVENetServiceImpl new] requestUploadParametersWithCompletion:^(DVEUploadParametersResponseModel * _Nullable response, NSError * _Nullable error) {
        @strongify(self);

        if (!error && audioUrl) {
            // 获取字幕使用字幕的tos
            if (response.videoUploadParameters.captionAppKey.length > 0
                && response.videoUploadParameters.captionAuthorization2) {
                response.videoUploadParameters.appKey = response.videoUploadParameters.captionAppKey;
                response.videoUploadParameters.authorization2 = response.videoUploadParameters.captionAuthorization2;
            }

            DVEFileUploadServiceBuilder *uploadBuilder = [[DVEFileUploadServiceBuilder alloc] init];
            self.videoUploadService = [uploadBuilder createUploadServiceWithParams:response filePath:[audioUrl path] fileType:DVEUploadFileTypeAudio];
            NSProgress *progress = nil;

            [self.videoUploadService uploadFileWithProgress:&progress completion:^(DVEFileUploadResponseInfoModel *uploadInfoModel, NSError * _Nullable error) {
                @strongify(self);
                self.videoUploadService = nil;
                self.materialId = uploadInfoModel.materialId;
                !completion ?: completion(uploadInfoModel, error);
            }];
        } else {
            !completion ?: completion(nil, error ?: [NSError new]);
        }
    }];
}

- (RACSignal<NSString *> *)commitAudio
{
    if (self.materialId.length > 0) {
        return [self commitAudioWithMaterialId:self.materialId];
    } else {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [self commitAudioWithUrl:self.audioUrl completion:^(DVESubtitleQueryModel * _Nullable model, NSError * _Nullable error) {
                if (error) {
                    [subscriber sendError:error];
                } else {
                    [subscriber sendNext:model.captionId];
                    [subscriber sendCompleted];
                }
            }];
            return nil;
        }];
    }
}

- (RACSignal<NSString *> *)commitAudioWithMaterialId:(NSString *)materialId
{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [self commitAudioWithMaterialId:materialId completion:^(DVESubtitleQueryModel * _Nullable model, NSError * _Nullable error) {
            if (error) {
                [subscriber sendError:error];
            } else {
                [subscriber sendNext:model.captionId];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

/// 通过音频的materialId 来生成识别ID，需要先把音频上传到TOS
- (void)commitAudioWithMaterialId:(NSString *)materialId
                       completion:(DVESubtitleNetCompletionBlock)completion
{
    if(self.captionsNetService){
        [self.captionsNetService commitAudioWithMaterialId:materialId maxLines:@(kCaptionMaxLines) wordsPerLine:@(kCaptionWordsPerLine) completion:^(DVESubtitleQueryModel * _Nullable model, NSError * _Nullable error) {
            if (!error) {
               self.taskId = model.captionId;
            }
            !completion ?: completion(model, error);
        }];
    }else{
        !completion ?: completion(nil, [NSError errorWithDomain:@"识别失败" code:-1 userInfo:nil]);
    }

}

/// 直接上传音频二进制数据生成识别ID
- (void)commitAudioWithUrl:(NSURL *)audioUrl
                completion:(DVESubtitleNetCompletionBlock)completion
{
    if(self.captionsNetService){
        [self.captionsNetService commitAudioWithUrl:audioUrl maxLines:@(kCaptionMaxLines) wordsPerLine:@(kCaptionWordsPerLine) completion:^(DVESubtitleQueryModel * _Nullable model, NSError * _Nullable error) {
            if (!error) {
               self.taskId = model.captionId;
            }
            !completion ?: completion(model, error);
        }];
    } else{
        !completion ?: completion(nil, [NSError errorWithDomain:@"识别失败" code:-2 userInfo:nil]);
    }
}

- (RACSignal<DVESubtitleQueryModel *> *)querySubtitle
{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [self queryCaptionWithTaskId:self.taskId completion:^(DVESubtitleQueryModel * _Nullable model, NSError * _Nullable error) {
            if (error) {
                [subscriber sendError:error];
            } else {
                [subscriber sendNext:model];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

// 查询字幕
- (void)queryCaptionWithTaskId:(NSString *)taskId
                    completion:(DVESubtitleNetCompletionBlock)completion
{
    if(self.captionsNetService){
        [self.captionsNetService queryCaptionWithTaskId:taskId completion:^(DVESubtitleQueryModel * _Nullable model, NSError * _Nullable error) {
            !completion ?: completion(model, nil);
        }];
    }else{
        !completion ?: completion(nil, [NSError errorWithDomain:@"查询字幕失败" code:-1 userInfo:nil]);
    }
}

@end
