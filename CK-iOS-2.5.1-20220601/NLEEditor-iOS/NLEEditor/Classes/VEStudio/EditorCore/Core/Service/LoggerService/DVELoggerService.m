//
//   DVELoggerService.m
//   NLEEditor
//
//   Created  by ByteDance on 2021/8/20.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVELoggerService.h"

@implementation DVELoggerService

+ (instancetype)shareManager {
    static DVELoggerService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:nil] init];
    });
    return instance;
}

+(id)allocWithZone:(NSZone *)zone{
    return [self shareManager];
}
-(id)copyWithZone:(NSZone *)zone{
    
    return [[self class] shareManager];
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return [[self class] shareManager];
}


- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}


@end
