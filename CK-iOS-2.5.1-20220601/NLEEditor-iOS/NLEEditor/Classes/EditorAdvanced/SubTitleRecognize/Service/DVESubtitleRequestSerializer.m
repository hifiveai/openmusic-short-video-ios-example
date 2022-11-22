//
//  DVESubtitleRequestSerializer.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/5/23.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "DVESubtitleRequestSerializer.h"

@implementation DVESubtitleRequestSerializer

- (TTHttpRequest *)URLRequestWithRequestModel:(TTRequestModel *)requestModel commonParams:(NSDictionary *)commonParam {
    TTHttpRequest *request = [super URLRequestWithRequestModel:requestModel commonParams:commonParam];
    return request;
}

- (TTHttpRequest *)URLRequestWithURL:(NSString *)URL headerField:(NSDictionary *)headField params:(NSDictionary *)params method:(NSString *)method constructingBodyBlock:(TTConstructingBodyBlock)bodyBlock commonParams:(NSDictionary *)commonParam {
    TTHttpRequest *request = [super URLRequestWithURL:URL headerField:headField params:nil method:method constructingBodyBlock:bodyBlock commonParams:commonParam];
    NSURL *audioUrl = params[@"audioUrl"];
    NSData *data = [NSData dataWithContentsOfURL:audioUrl];
    if (data) {
        request.HTTPBody = data;
    }
    return request;
}

- (TTHttpRequest *)URLRequestWithURL:(NSString *)URL params:(id)params method:(NSString *)method constructingBodyBlock:(TTConstructingBodyBlock)bodyBlock commonParams:(NSDictionary *)commonParam {
    return [self URLRequestWithURL:URL
                       headerField:nil
                            params:params
                            method:method
             constructingBodyBlock:bodyBlock
                      commonParams:commonParam];
}

+ (NSObject<TTHTTPRequestSerializerProtocol> *)serializer {
    return [[self alloc] init];
}


@end
