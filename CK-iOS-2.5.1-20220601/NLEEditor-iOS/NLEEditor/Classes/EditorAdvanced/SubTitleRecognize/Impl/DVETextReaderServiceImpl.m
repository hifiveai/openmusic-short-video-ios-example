//
//  DVETextReaderServiceImpl.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/27.
//

#import "DVETextReaderServiceImpl.h"
#import "DVELoggerImpl.h"
#import "DVETextReaderTask.h"
#import "NSString+DVE.h"
#import <SpeechEngineTts/SpeechEngine.h>

typedef NS_ENUM(NSUInteger, DVETextReaderServiceStatus) {
    DVETextReaderServiceStatusIdle,
    DVETextReaderServiceStatusRunning,
    DVETextReaderServiceStatusCanceling,
};

NSErrorDomain const DVETextReaderServiceErrorDomain = @"DVETextReaderServiceErrorDomain";

@interface DVETextReaderServiceImpl()<SpeechEngineDelegate>

@property (nonatomic, strong) SpeechEngine *speechEngine;
@property (nonatomic, copy) NSString *audioFolder;
@property (nonatomic, assign) BOOL isDownloadMode;
@property (nonatomic, assign) DVETextReaderServiceStatus status;
@property (nonatomic, strong) DVETextReaderTask *task;

@end

@implementation DVETextReaderServiceImpl

@synthesize delegate = _delegate;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _audioFolder = [NSTemporaryDirectory() stringByAppendingPathComponent:@"text2audio"];
        _appId = @"LV-IOS";
        _uid = @"388808087185088";
        _ttsAddress = @"wss://speech.bytedance.com";
        _ttsUri = @"/api/v1/tts/ws_binary";
        _ttsCluster = @"videocut_cpu";
        _captUri = @"/api/v1/mdd/ws";
    }
    return self;
}

- (void)setupSpeechEngine
{
    if (![NSFileManager.defaultManager fileExistsAtPath:_audioFolder]) {
        NSError *error = nil;
        [NSFileManager.defaultManager createDirectoryAtPath:_audioFolder withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            DVELogError(@"create text to audio folder fail: %@", _audioFolder);
        }
    }
    
    if (!_speechEngine) {
        _speechEngine = [[SpeechEngine alloc] init];
        [_speechEngine createEngineWithDelegate:self];
        [_speechEngine setStringParam:SE_LOG_LEVEL_TRACE forKey:SE_PARAMS_KEY_LOG_LEVEL_STRING];
        [_speechEngine setStringParam:self.appId forKey: SE_PARAMS_KEY_APP_ID_STRING];
        [_speechEngine setIntParam:1 forKey: SE_PARAMS_KEY_CHANNEL_NUM_INT];
        [_speechEngine setIntParam:1 forKey: SE_PARAMS_KEY_TTS_COMPRESSION_RATE_INT];
        [_speechEngine setStringParam:self.uid forKey: SE_PARAMS_KEY_UID_STRING];
        [_speechEngine setStringParam:self.ttsAddress forKey: SE_PARAMS_KEY_TTS_ADDRESS_STRING];
        
        [_speechEngine setIntParam:0 forKey: SE_PARAMS_KEY_TTS_ENABLE_CONCURRENCY_INT];
        [_speechEngine setStringParam:self.ttsUri forKey: SE_PARAMS_KEY_TTS_URI_STRING];
        [_speechEngine setStringParam:self.ttsCluster forKey: SE_PARAMS_KEY_TTS_CLUSTER_STRING];
        
        [_speechEngine setBoolParam:YES forKey: SE_PARAMS_KEY_TTS_ENABLE_PLAYER_BOOL];
        [_speechEngine setStringParam:self.captUri forKey: SE_PARAMS_KEY_CAPT_URI_STRING];
        [_speechEngine setStringParam:SE_TTS_ENGINE forKey: SE_PARAMS_KEY_ENGINE_NAME_STRING];
        [_speechEngine setStringParam:SE_CAPT_CORE_TYPE_EN_SENT_SCORE forKey:SE_PARAMS_KEY_CAPT_CORE_TYPE_STRING];
        [_speechEngine setStringParam:self.audioFolder forKey: SE_PARAMS_KEY_TTS_AUDIO_PATH_STRING];
        
        SEEngineErrorCode resultCode = [_speechEngine initEngine];
        if (resultCode != SENoError) {
            DVELogError(@"init speech engine error!!");
        }
    }
}

- (void)stopTask
{
    [self.speechEngine sendDirective:SEDirectiveFinishTalking];
    [self.speechEngine sendDirective:SEDirectiveStopEngine];
}

- (void)createTask:(id<DVETextReaderModelProtocol>)voiceInfo
             texts:(NSArray<NSString *> *)texts
              type:(DVETextReaderTaskType)type
{
    self.task = [[DVETextReaderTask alloc] initWithVoiceInfo:voiceInfo texts:texts type:type];
    switch (self.status) {
        case DVETextReaderServiceStatusRunning:
        {
            self.status = DVETextReaderServiceStatusCanceling;
            [self stopTask];
        }
            break;
        case DVETextReaderServiceStatusCanceling:
            break;
        case DVETextReaderServiceStatusIdle:
            [self beginTask];
            break;
        default:
            break;
    }
}

- (void)beginTask
{
    if (!self.task) {
        return;
    }
    [self stopTask];
    [self setupSpeechEngine];
    
    if (!self.speechEngine) {
        return;
    }
    
    BOOL startFlag = self.task.type == DVETextReaderTaskTypeDownload;
    BOOL endFlag = !startFlag;
    NSInteger rate = self.task.voiceInfo.rate > 0 ? self.task.voiceInfo.rate : 2400;
    NSString *text = [self.task.texts componentsJoinedByString:@""];
    self.isDownloadMode = self.task.type == DVETextReaderTaskTypeDownload;
    [self.speechEngine setBoolParam:startFlag forKey: SE_PARAMS_KEY_TTS_ENABLE_DUMP_BOOL];
    [self.speechEngine setStringParam:self.task.voiceInfo.type forKey: SE_PARAMS_KEY_TTS_VOICE_TYPE_STRING];
    [self.speechEngine setStringParam:text forKey: SE_PARAMS_KEY_TTS_TEXT_STRING];
    [self.speechEngine setBoolParam:endFlag forKey: SE_PARAMS_KEY_TTS_ENABLE_PLAYER_BOOL];
    [self.speechEngine setIntParam:rate forKey: SE_PARAMS_KEY_TTS_SAMPLE_RATE_INT];
    [self.speechEngine sendDirective:SEDirectiveStartEngine];
    
    self.task = nil;
}

#pragma mark - DVETextReaderServiceProtocol

- (void)beginDownloadVoice:(nonnull NSArray<NSString *> *)texts
                 voiceInfo:(nonnull id<DVETextReaderModelProtocol>)voiceInfo
{
    [self createTask:voiceInfo texts:texts type:DVETextReaderTaskTypeDownload];
}

- (void)beginPlayDemo:(nonnull NSArray<NSString *> *)texts
            voiceInfo:(nonnull id<DVETextReaderModelProtocol>)voiceInfo
{
    [self createTask:voiceInfo texts:texts type:DVETextReaderTaskTypePlayDemo];
}

- (void)stopPlayDemo
{
    self.task = nil;
    [self stopTask];
}

#pragma mark - SpeechEngineDelegate

- (void)onMessageWithType:(SEMessageType)type andData:(NSData *)data
{
    NSString *resultStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    switch (type) {
        case SEEngineStart:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.status = DVETextReaderServiceStatusRunning;
            });
        }
            break;
        case SEEngineStop:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.isDownloadMode && self.status != DVETextReaderServiceStatusCanceling) {
                    self.isDownloadMode = NO;
                    NSString *fileExtension = [NSString stringWithFormat:@"tts_%@.wav", resultStr];
                    NSString *fileUrl = [self.audioFolder stringByAppendingPathComponent:fileExtension];
                    
                    if (fileUrl.length > 0
                        && [self.delegate respondsToSelector:@selector(textReaderDidDownload:)]) {
                        [self.delegate textReaderDidDownload:@[fileUrl]];
                    }
                }
                self.status = DVETextReaderServiceStatusIdle;
                [self beginTask];
            });
        }
            break;
        case SEEngineError:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *json = [resultStr dve_ToDic];
                NSError *error = [NSError errorWithDomain:DVETextReaderServiceErrorDomain code:-1 userInfo:nil];
                if ([json[@"err_code"] isKindOfClass:NSNumber.class]) {
                    NSNumber *errorCode = (NSNumber *)json[@"err_code"];
                    error = [NSError errorWithDomain:DVETextReaderServiceErrorDomain code:errorCode.integerValue userInfo:nil];
                }
                self.status = DVETextReaderServiceStatusIdle;
                if ([self.delegate respondsToSelector:@selector(textReaderFailAnalysis:)]) {
                    [self.delegate textReaderFailAnalysis:error];
                }
            });
        }
            break;
        default:
            break;
    }
}


@end
