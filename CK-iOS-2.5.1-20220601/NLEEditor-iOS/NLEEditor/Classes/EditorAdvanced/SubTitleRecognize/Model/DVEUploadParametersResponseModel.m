//
//  DVEUploadParametersResponseModel.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/19.
//

#import "DVEUploadParametersResponseModel.h"

@implementation DVEVideoUploadParametersResponseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"appKey" : @"appKey",
             @"captionAppKey" : @"captionAppKey",
             @"authorization2" : @"authorization2",
             @"sliceTimeout" : @"sliceTimeout",
             @"sliceRetryCount" : @"sliceRetryCount",
             @"fileRetryCount" : @"fileRetryCount",
             @"sliceSize" : @"sliceSize",
             @"coverTime" : @"coverTime",
             @"maxFailTime" : @"maxFailTime",
             @"maxFailTimeEnabled" : @"maxFailTimeEnabled",
             @"socketNumber" : @"socketNumber",
             @"fileTryHttpsEnable" : @"fileTryHttpsEnable",
             @"enableHttps" : @"enableHttps",
             @"aliveMaxFailTime" : @"aliveMaxFailTime",
             @"enablePostMethod" : @"enablePostMethod",
             @"openTimeOut" : @"openTimeOut",
             @"mainNetworkType" : @"upload_main_network_type",
             @"backupNetworkType" : @"upload_backup_network_type",
             @"videoHostName" : @"videoHostName",
             @"captionAuthorization2" : @"captionAuthorization2",
             };
}

@end

@implementation DVEUploadParametersResponseModel

@end
