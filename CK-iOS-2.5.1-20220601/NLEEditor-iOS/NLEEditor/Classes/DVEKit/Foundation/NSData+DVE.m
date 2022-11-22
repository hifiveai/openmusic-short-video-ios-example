//
//  NSData+DVE.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/25.
//

#import "NSData+DVE.h"
#import "DVELoggerImpl.h"

@implementation NSData (DVE)

- (id)dve_jsonValueDecoded
{
    NSError *error = nil;
    id value = [NSJSONSerialization JSONObjectWithData:self options:kNilOptions error:&error];
    if (error) {
        DVELogError(@"jsonValueDecoded error:%@", error);
    }
    return value;
}

- (BOOL)dve_isGIFImage {
    uint8_t bit;
    [self getBytes:&bit length:1];
    return bit == 0x47;
}

@end
