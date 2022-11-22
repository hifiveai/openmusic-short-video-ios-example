//
//  HFNetWorkUtil.h
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/25.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HFNetWorkUtil : NSObject

// get 请求
+ (void)getWithUrlString:(NSString *)url params:(NSDictionary *)params success:(void(^)(NSData *data))successBlock error:(void(^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
