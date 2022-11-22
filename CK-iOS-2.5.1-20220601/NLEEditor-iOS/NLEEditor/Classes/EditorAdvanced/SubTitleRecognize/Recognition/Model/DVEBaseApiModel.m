//
//  DVEBaseApiModel.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/18.
//

#import "DVEBaseApiModel.h"

@implementation DVEBaseApiModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"statusCode"  : @"code",
             @"statusMsg"   : @"message",
             @"requestID"   : @"id",
             @"timestamp"   : @"duration",
             };
}

@end
