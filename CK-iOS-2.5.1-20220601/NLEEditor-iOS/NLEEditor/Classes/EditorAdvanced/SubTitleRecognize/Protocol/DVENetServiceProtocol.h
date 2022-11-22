//
//  DVENetServiceProtocol.h
//  Pods
//
//  Created by bytedance on 2019/7/25.
//

#import <Foundation/Foundation.h>
#import "DVEUploadParametersResponseModel.h"
#import "DVERequestModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^DVERequestModelBlock)(DVERequestModel * _Nullable requestModel);
typedef void (^DVENetServiceCompletionBlock)(NSDictionary  * _Nullable jsonDic, NSError * _Nullable error);
typedef void (^DVENetworkServiceDownloadProgressBlock)(CGFloat progress);
typedef void (^DVENetworkServiceDownloadComletionBlock)(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error);


@protocol DVENetServiceProtocol <NSObject>

- (NSString *)defaultDomain;

#pragma mark - get/post

- (void)requestWithModel:(DVERequestModelBlock)requestModelBlock
              completion:(DVENetServiceCompletionBlock _Nullable)block;

- (void)requestUrlString:(nonnull NSString *)urlString method:(DVERequestType)method params:(NSDictionary *_Nullable)params completion:(DVENetServiceCompletionBlock _Nullable)block;

#pragma mark - upload

- (void)uploadWithModel:(DVERequestModelBlock)requestModelBlock
               progress:(NSProgress * _Nullable __autoreleasing *_Nullable)progress
             completion:(DVENetServiceCompletionBlock _Nullable)completion;

- (void)uploadWithURLString:(NSString *)URLString
               parameters:(_Nullable id)parameters
              headerField:(NSDictionary *_Nullable)headerField
                  fileURL:(NSURL *_Nonnull)fileURL
                 fileName:(NSString * _Nonnull)fileName
                 progress:(NSProgress * _Nullable __autoreleasing *_Nullable)progress
         needcommonParams:(BOOL)needCommonParams
               modelClass:(Class _Nullable)objectClass
                 callback:(DVENetServiceCompletionBlock)completion;

/*
*  获取上传需要的参数
*/
- (void)requestUploadParametersWithCompletion:(void (^)(DVEUploadParametersResponseModel * _Nullable model, NSError * _Nullable error))completion;

#pragma mark - download

- (void)downloadFileWithURLString:(NSString *)urlString
                     downloadPath:(NSURL *)path
                         progress:(DVENetworkServiceDownloadProgressBlock)progressHandler
                       completion:(void (^)(NSError *error, NSURL *fileURL))completion;

@end

NS_ASSUME_NONNULL_END
