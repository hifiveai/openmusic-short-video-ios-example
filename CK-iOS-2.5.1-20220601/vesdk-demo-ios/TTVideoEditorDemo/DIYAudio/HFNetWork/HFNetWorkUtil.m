//
//  HFNetWorkUtil.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/25.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "HFNetWorkUtil.h"

@interface HFNetWorkUtil ()<NSURLSessionDelegate>

@end

@implementation HFNetWorkUtil

+ (nonnull HFNetWorkUtil *)shareInstance{
    static dispatch_once_t once;
    static HFNetWorkUtil *instance;
    dispatch_once(&once, ^{
        instance = [[HFNetWorkUtil alloc] init];
    });
    return instance;
}

// get 请求
+ (void)getWithUrlString:(NSString *)url params:(NSDictionary *)params success:(void(^)(NSData *data))successBlock error:(void(^)(NSError *error))failedBlock{
    NSMutableString *mutableUrl = [[NSMutableString alloc] initWithString:url];
    if ([params allKeys].count>0) {
        [mutableUrl appendString:@"?"];
        for (id key in params) {
            NSString *value = [[params objectForKey:key] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [mutableUrl appendString:[NSString stringWithFormat:@"%@=%@&", key, value]];
        }
        mutableUrl = [[mutableUrl substringToIndex:mutableUrl.length - 1] mutableCopy];
    }
    NSString *urlEnCode = [mutableUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlEnCode]];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:[self shareInstance] delegateQueue:queue];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                failedBlock(error);
            } else {
                successBlock(data);
            }
        });
    }];
    [dataTask resume];
}

//主要就是处理HTTPS请求的
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    NSURLProtectionSpace *protectionSpace = challenge.protectionSpace;
    if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        SecTrustRef serverTrust = protectionSpace.serverTrust;
        completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:serverTrust]);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}
@end
