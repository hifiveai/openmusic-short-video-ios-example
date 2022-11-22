//
//  DVENetServiceImpl.m
//  Pods
//
//  Created by bytedance on 2019/7/22.
//

#import "DVENetServiceImpl.h"
#import "DVEMacros.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import <KVOController/KVOController.h>

@implementation DVENetServiceImpl

- (NSErrorDomain)apiErrorDomain
{
    return @"DavinciEditor";
}

- (NSErrorDomain)networkErrorDomain
{
    return @"DavinciEditor";
}

- (NSString *)defaultDomain
{
    return @"DavinciEditor";
}

- (BOOL)needShowAWEApiErrorDescriptionWithError:(NSError *)error
{
    return NO;
}

#pragma mark - get/post

- (void)requestWithModel:(DVERequestModelBlock)requestModelBlock
              completion:(DVENetServiceCompletionBlock _Nullable)block
{
    DVERequestModel *requestModel = [[DVERequestModel alloc] init];
    requestModelBlock(requestModel);
    NSAssert(requestModel.urlString, @"urlString should not be empty");
    NSString *methodStr = @"GET";
    if (requestModel.requestType == DVERequestTypePOST) {
        methodStr = @"POST";
    }
    __block dispatch_queue_t callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [[TTNetworkManager shareInstance] requestForJSONWithResponse:requestModel.urlString
                                                          params:requestModel.params
                                                         method:methodStr
                                               needCommonParams:requestModel.needCommonParams
                                                    headerField:requestModel.headerField
                                              requestSerializer:requestModel.requestSerializer
                                             responseSerializer:nil
                                                     autoResume:YES
                                                  verifyRequest:NO
                                             isCustomizedCookie:NO
                                                       callback:^(NSError *error, id jsonObj, TTHttpResponse *response) {
        !block ?: block(jsonObj, error);
                                                       } callbackQueue:callbackQueue];
}

- (void)requestUrlString:(nonnull NSString *)urlString
                  method:(DVERequestType)method
                  params:(NSDictionary *_Nullable)params
              completion:(DVENetServiceCompletionBlock _Nullable)block
{
    NSAssert(urlString, @"urlString should not be empty");
    NSString *methodStr = @"GET";
    if (method == DVERequestTypePOST) {
        methodStr = @"POST";
    }
    __block dispatch_queue_t callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [[TTNetworkManager shareInstance] requestForJSONWithResponse:urlString
                                                          params:params
                                                         method:methodStr
                                               needCommonParams:YES
                                                    headerField:nil
                                              requestSerializer:nil
                                             responseSerializer:nil
                                                     autoResume:YES
                                                  verifyRequest:NO
                                             isCustomizedCookie:NO
                                                       callback:^(NSError *error, id jsonObj, TTHttpResponse *response) {
        !block ?: block(jsonObj, error);
                                                       } callbackQueue:callbackQueue];
}

#pragma mark - upload

- (void)uploadWithModel:(DVERequestModelBlock)requestModelBlock
               progress:(NSProgress * _Nullable __autoreleasing *_Nullable)progress
             completion:(DVENetServiceCompletionBlock _Nullable)completion
{
    DVERequestModel *requestModel = [[DVERequestModel alloc] init];
    requestModelBlock(requestModel);
    NSAssert(requestModel.urlString, @"urlString should not be empty");
    TTConstructingBodyBlock bodyBlock = requestModel.bodyBlock;
    if (!bodyBlock) {
        bodyBlock = (^(id<TTMultipartFormData> formData) {
            NSData *data = [NSData dataWithContentsOfURL:requestModel.fileURL];
            if (data) {
                [formData appendPartWithFormData:data name:requestModel.fileName];
            }
        });
    }
    
    [[TTNetworkManager shareInstance] uploadWithURL:requestModel.urlString
                                         parameters:requestModel.params
                                     headerField:requestModel.headerField
                       constructingBodyWithBlock:bodyBlock
                                        progress:progress
                                needcommonParams:requestModel.needCommonParams
                               requestSerializer:requestModel.requestSerializer
                              responseSerializer:nil
                                      autoResume:YES
                                        callback:^(NSError *error, id jsonObj) {
        !completion ?: completion(jsonObj, error);
                                        }];
}

- (void)uploadWithURLString:(NSString *)URLString
               parameters:(_Nullable id)parameters
              headerField:(NSDictionary *_Nullable)headerField
                  fileURL:(NSURL *_Nonnull)fileURL
                 fileName:(NSString * _Nonnull)fileName
                 progress:(NSProgress * _Nullable __autoreleasing *_Nullable)progress
         needcommonParams:(BOOL)needCommonParams
               modelClass:(Class _Nullable)objectClass
                 callback:(DVENetServiceCompletionBlock)completion
{
    TTConstructingBodyBlock bodyBlock = (^(id<TTMultipartFormData> formData) {
        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        if (data) {
            [formData appendPartWithFormData:data name:fileName];
        }
    });
    
    [[TTNetworkManager shareInstance] uploadWithURL:URLString
                                         parameters:parameters
                                     headerField:headerField
                       constructingBodyWithBlock:bodyBlock
                                        progress:progress
                                needcommonParams:needCommonParams
                               requestSerializer:nil
                              responseSerializer:nil
                                      autoResume:YES
                                        callback:^(NSError *error, id jsonObj) {
        !completion ?: completion(jsonObj, error);
                                        }];
}

#pragma mark - download

- (void)downloadFileWithURLString:(NSString *)urlString
                     downloadPath:(NSURL *)path
                         progress:(DVENetworkServiceDownloadProgressBlock)progressHandler
                       completion:(void (^)(NSError *error, NSURL *fileURL))completion
{
    NSAssert(path.isFileURL, @"destination must be a file NSURL!");
    NSProgress *progress = nil;
    TTHttpTask *task = [[TTNetworkManager shareInstance] downloadTaskWithRequest:urlString
                                                   parameters:nil
                                                  headerField:nil
                                             needCommonParams:NO
                                                     progress:&progress
                                                  destination:path
                                            completionHandler:^(TTHttpResponse *response, NSURL *filePath, NSError *error) {

        if (completion) {
            completion(error, filePath);
        }
    }];
    
    if (task && progressHandler) {
        @weakify(self);
        @weakify(progress);
        [self.KVOController observe:progress
                            keyPath:@"completedUnitCount"
                            options:NSKeyValueObservingOptionNew
                              block:^(id observer, id object, NSDictionary<NSString *,id> *change) {
                                  @strongify(self);
                                  @strongify(progress);
                                  
                                  if (progress.completedUnitCount == progress.totalUnitCount) {
                                      [self.KVOController unobserve:self];
                                  }
                                  
                                  long long newValue = [change[NSKeyValueChangeNewKey] longLongValue];
                                  CGFloat curProgress = (1.0f * newValue) / progress.totalUnitCount;
                                  
                                  progressHandler(curProgress);
                              }];
    }
}

- (void)requestUploadParametersWithCompletion:(nonnull void (^)(DVEUploadParametersResponseModel * _Nullable, NSError * _Nullable))completion {
    DVEUploadParametersResponseModel *uploadParam = [[DVEUploadParametersResponseModel alloc] init];
    uploadParam.videoUploadParameters.videoHostName = @"https://speech.bytedance.net/api_test/v1/vc/";
    completion(uploadParam, nil);
}



@end
