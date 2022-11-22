//
//  DVEUploadParametersResponseModel.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/19.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVEVideoUploadParametersResponseModel : MTLModel<MTLJSONSerializing>
@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *captionAppKey;
@property (nonatomic, strong) NSString *videoHostName;
@property (nonatomic, strong) NSNumber *sliceTimeout; // 新sdk -> RWTimeout
@property (nonatomic, strong) NSNumber *sliceRetryCount;
@property (nonatomic, strong) NSNumber *fileRetryCount;
@property (nonatomic, strong) NSNumber *sliceSize;
@property (nonatomic, strong) NSNumber *coverTime; // 新sdk -> SnapshotTime
@property (nonatomic, strong) NSNumber *maxFailTime;
@property (nonatomic, strong) NSNumber *maxFailTimeEnabled; // 新sdk -> 没有了
@property (nonatomic, strong) NSNumber *socketNumber;
@property (nonatomic, strong) NSNumber *enableHttps;
@property (nonatomic, strong) NSNumber *fileTryHttpsEnable; // 新sdk -> 没有了
@property (nonatomic, strong) NSNumber *aliveMaxFailTime;
@property (nonatomic, strong) NSNumber *enablePostMethod; // 新sdk -> 没有了
@property (nonatomic, strong) NSNumber *openTimeOut;
@property (nonatomic, strong) NSNumber *mainNetworkType; // 新sdk -> 设置主网络
@property (nonatomic, strong) NSNumber *backupNetworkType; // 新sdk -> 设置备选网络

@property (nonatomic, strong) NSDictionary *authorization2; // 新sdk -> 鉴权参数
@property (nonatomic, strong) NSDictionary *captionAuthorization2; // 新sdk -> 鉴权参数
@end

@interface DVEUploadParametersResponseModel : NSObject

@property (nonatomic, strong) DVEVideoUploadParametersResponseModel *videoUploadParameters;

@end

NS_ASSUME_NONNULL_END
