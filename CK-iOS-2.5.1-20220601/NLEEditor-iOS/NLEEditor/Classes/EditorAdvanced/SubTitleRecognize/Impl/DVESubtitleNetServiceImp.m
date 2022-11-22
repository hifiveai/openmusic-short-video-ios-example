//
//  DVESubtitleNetServiceImp.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/5/23.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "DVESubtitleNetServiceImp.h"
#import "DVESubtitleRequestSerializer.h"
#import "DVENetServiceImpl.h"

@implementation DVESubtitleNetServiceImp

- (instancetype)init
{
    self = [super init];
    if (self) {
        _appid = @"lv";
        _token = @"lv_token";
        _language = @"zh-CN";
        _baseUrlStr = @"https://speech.bytedance.com/api/v1/vc";
    }
    return self;
}

- (void)commitAudioWithMaterialId:(nonnull NSString *)materialId
                         maxLines:(nonnull NSNumber *)maxLine
                     wordsPerLine:(nonnull NSNumber *)wordsPerLine
                       completion:(nonnull DVESubtitleNetCompletionBlock)completion {
    
}

- (void)commitAudioWithUrl:(nonnull NSURL *)audioUrl
                  maxLines:(nonnull NSNumber *)maxLine
              wordsPerLine:(nonnull NSNumber *)wordsPerLine
                completion:(nonnull DVESubtitleNetCompletionBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"audioUrl"] = audioUrl;
    
    NSMutableDictionary *queryDic = [NSMutableDictionary dictionary];
    queryDic[@"max_lines"] = maxLine;
    queryDic[@"words_per_line"] = wordsPerLine;
    queryDic[@"appid"] = self.appid;
    queryDic[@"token"] = self.token;
    queryDic[@"language"] = self.language;
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in queryDic) {
        id value = [queryDic objectForKey: key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", key, value];
        [parts addObject: part];
    }
    NSString *queryStr = [parts componentsJoinedByString: @"&"];
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@?%@", self.baseUrlStr, @"submit", queryStr];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"Content-Type"] = @"audio/m4a";
    
    [[DVENetServiceImpl new] requestWithModel:^(DVERequestModel * _Nullable requestModel) {
        requestModel.requestType = DVERequestTypePOST;
        requestModel.urlString = urlStr;
        requestModel.fileURL = audioUrl;
        requestModel.fileName = audioUrl.lastPathComponent;
        requestModel.params = params;
        requestModel.headerField = headers;
        requestModel.requestSerializer = DVESubtitleRequestSerializer.class;
    } completion:^(NSDictionary * _Nullable jsonDic, NSError * _Nullable error) {
        DVESubtitleQueryModel *result = nil;
        if (!error && jsonDic) {
            result = [[DVESubtitleQueryModel alloc] init];
            result.captionId = jsonDic[@"id"];
        }
        
        completion(result, error);
    }];
}

- (void)feedbackCaptionWithAwemeId:(nonnull NSString *)awemeId
                            taskID:(nonnull NSString *)taskId
                               vid:(nonnull NSString *)vid
                        utterances:(nonnull NSArray *)captionsArr {
    NSAssert(NO, @"not implement");
}

- (void)queryCaptionWithTaskId:(nonnull NSString *)taskId
                    completion:(nonnull DVESubtitleNetCompletionBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"id"] = taskId ?: @"";
    params[@"token"] = self.token;
    params[@"appid"] = self.appid;
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@", self.baseUrlStr, @"query"];
    [[DVENetServiceImpl new] requestWithModel:^(DVERequestModel * _Nullable requestModel) {
        requestModel.requestType = DVERequestTypeGET;
        requestModel.urlString = urlStr;
        requestModel.params = params;
    } completion:^(NSDictionary * _Nullable jsonDic, NSError * _Nullable error) {
        DVESubtitleQueryModel *result = nil;
         
        if (!error && jsonDic) {
            __autoreleasing NSError *mappingError = nil;
            id response = [MTLJSONAdapter modelOfClass:DVESubtitleQueryModel.class
                                     fromJSONDictionary:jsonDic
                                                  error:&mappingError];
            result = (DVESubtitleQueryModel *)response;
        }
         
        completion(result, error);
    }];
}

@end
