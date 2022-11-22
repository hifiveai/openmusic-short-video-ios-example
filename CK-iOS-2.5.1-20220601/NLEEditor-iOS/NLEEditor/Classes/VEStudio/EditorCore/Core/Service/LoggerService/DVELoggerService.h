//
//   DVELoggerService.h
//   NLEEditor
//
//   Created  by ByteDance on 2021/8/20.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    
 
#import <Foundation/Foundation.h>
#import "DVELoggerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVELoggerService : NSObject

+ (instancetype)shareManager;

@property(nonatomic,weak)id<DVELoggerProtocol> logger;

@end

FOUNDATION_STATIC_INLINE id<DVELoggerProtocol> DVELoggerProtocol() {
    return [[DVELoggerService shareManager] logger];
}

NS_ASSUME_NONNULL_END
