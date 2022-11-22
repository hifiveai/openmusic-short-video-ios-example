//
//  DVEBDVideoUploadService.m
//  CameraClient-Pods-Aweme
//
//  Created by bytedance on 2020/12/21.
//

#import "DVEBDVideoUploadService.h"
#import "DVEFileUploadResponseInfoModel.h"
#import <BytedanceKit/BTDNetworkUtilities.h>

@interface DVEBDVideoUploadService() <BDVideoUploadClientDelegate>

@property (nonatomic, strong) BDVideoUploaderClient *videoUploadClient;
@property (nonatomic, strong) id<BDVideoUploadClientDelegate> videoUploadDelegate;

@end

@implementation DVEBDVideoUploadService

- (void)startUploading
{
    self.videoUploadClient = [[BDVideoUploaderClient alloc] initWithFilePath:self.filePath];
    [self.videoUploadClient setVideoHostName:self.videoUploadParameters.videoHostName];
    if (self.videoUploadDelegate) {
        [self.videoUploadClient setDelegate:self.videoUploadDelegate];
    } else {
        [self.videoUploadClient setDelegate:self];
    }
    
    // 设置上传参数
    NSDictionary *configDic = [self p_videoUploadConfigParams];
    // 设置请求参数
    NSDictionary *paramsDic = [self p_videoUploadRequestParams];
    //设置鉴权参数
    NSDictionary *authDic = [self p_videoUploadAuthParams];
    [self.videoUploadClient setUploadConfig:configDic];
    [self.videoUploadClient setRequestParameter:paramsDic];
    [self.videoUploadClient setAuthorizationParameter:authDic];
    
    [self.videoUploadClient start];
}

- (void)configVideoUploadDelegateWithDelegate:(id<BDVideoUploadClientDelegate>)delegate
{
    self.videoUploadDelegate = delegate;
}

#pragma mark - config params

- (NSDictionary *)p_videoUploadConfigParams
{
    // 设置上传参数
    NSDictionary *configDic = @{
            BDFileUploadSliceRetryCount:self.videoUploadParameters.sliceRetryCount ?: @(2),
            BDFileUploadFileRetryCount:self.videoUploadParameters.fileRetryCount ?: @(1),
            BDFileUploadRWTimeout:self.videoUploadParameters.sliceTimeout ?: @(40),
            BDFileUploadSliceSize:self.videoUploadParameters.sliceSize ?: @(524288),
            BDFileUploadSocketNum:self.videoUploadParameters.socketNumber ?: @(2),
            BDFileUploadMaxFailTimes:self.videoUploadParameters.maxFailTime ?: @(30),
            BDFileUploadAliveMaxFailTime:self.videoUploadParameters.aliveMaxFailTime ?: @(6),
            BDFileUploadTcpOpenTimeOutMilliSec:self.videoUploadParameters.openTimeOut ?: @(5000),
            BDFileUploadHttpsEnable:self.videoUploadParameters.enableHttps ?: @(1),
            
            BDFileUploadMainNetworkType:self.uploadParams.videoUploadParameters.mainNetworkType ?: @(BDNetworkTypeOwn),
            BDFileUploadBackUpNetworkType:self.uploadParams.videoUploadParameters.backupNetworkType ?: @(BDNetworkTypeOwn),
            
            BDFileUploadSnapshotTime:self.videoUploadParameters.coverTime  ?: @(0.1),
//            BDFileUploadExternDNSEnable:self.uploadParams.settingsParameters.dnsEnable ?: @(0),
            BDFileUploadEnableBOE:@(YES),
    };
    return configDic;
}

- (NSDictionary *)p_videoUploadRequestParams
{
    // 设置请求参数
    NSDictionary *paramsDic = @{
        BDFileUploadFileTypeStr:[self p_stringFromFileType:self.uploadFileType],
        BDFileUploadTraceId:@"",
    };
    return paramsDic;
}

- (NSDictionary *)p_videoUploadAuthParams
{
    //设置鉴权参数
    NSDictionary *authDic = @{
        BDFileUploadAccessKey:self.videoUploadParameters.authorization2[@"access_key_id"] ?: @"", // 设置accessKey
        BDFileUploadSecretKey:self.videoUploadParameters.authorization2[@"secret_access_key"] ?: @"",// 设置secretKey
        BDFileUploadSessionToken:self.videoUploadParameters.authorization2[@"session_token"] ?: @"", // 设置sessionTokey
        BDFileUploadSpace:self.videoUploadParameters.authorization2[@"space_name"] ?: @"", // 设置spaceName
    };
    return authDic;
}

#pragma mark - BDVideoUploadClientDelegate

- (void)videoUpload:(nonnull BDVideoUploaderClient*)uploadClient didFinish:(nullable BDVideoUploadInfo *)videoInfo error:(nullable NSError *)error
{
    [self.videoUploadClient stop];
    if (self.completion) {
        DVEFileUploadResponseInfoModel *uploadInfoModel = [[DVEFileUploadResponseInfoModel alloc] init];
        uploadInfoModel.materialId = videoInfo.vid;
        uploadInfoModel.tosKey = videoInfo.oid;
        uploadInfoModel.coverURI = videoInfo.coverURI;
        uploadInfoModel.videoMediaInfo = videoInfo.videoMetaInfo;
        self.completion(uploadInfoModel, error);
    }
}

- (void)videoUpload:(nonnull BDVideoUploaderClient*)uploadClient progressDidUpdate:(NSInteger)progress
{
    self.progress.completedUnitCount = progress;
}

- (BDNetWorkState)videoUploadGetNetState:(nonnull BDVideoUploaderClient*)uploadClient
{
    if (BTDNetworkConnected()) {
        return BDNetWorkStateIsAvailable;
    } else {
        return BDNetWorkStateIsNotReachable;
    }
}

- (NSString *)videoUploadGetMetaString:(nonnull BDVideoUploaderClient*)uploadClient
{
    return @"";
}

- (void)videoUpload:(nonnull BDVideoUploaderClient*)uploadClient onLogInfo:(NSString *)logInfo
{
}

- (void)videoUpload:(nonnull BDVideoUploaderClient *)uploadClient updateVideoStage:(BDVideoUploadStage)stage timestamp:(NSTimeInterval)timestamp {
}


#pragma mark - Utils

- (DVEVideoUploadParametersResponseModel *)videoUploadParameters
{
    return self.uploadParams.videoUploadParameters;
}

- (NSString *)p_stringFromFileType:(DVEBDUploadFileType)fileType
{
    switch (fileType) {
        case DVEBDUploadFileTypeVideo:
            return @"video";
        case DVEBDUploadFileTypeAudio:
            return @"audio";
        case DVEBDUploadFileTypeObject:
            return @"object";
        case DVEBDUploadFileTypeImage:
            return @"image";
    }
}

@end
