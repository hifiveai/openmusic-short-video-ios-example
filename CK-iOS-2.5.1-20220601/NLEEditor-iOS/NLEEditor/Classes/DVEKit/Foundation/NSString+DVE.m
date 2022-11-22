//
//  NSString+DVE.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "NSString+DVE.h"
#import "NSData+DVE.h"

@implementation NSString (DVE)

- (NSDictionary *)dve_ToDic
{
    return [[self dve_dataValue] dve_jsonValueDecoded];
}

- (NSArray *)dve_ToArr
{
    return  [[self dve_dataValue] dve_jsonValueDecoded];
}

- (NSData *)dve_dataValue
{
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)dve_pathName {
    return [[self componentsSeparatedByString:@"/"] lastObject];
}

- (NSString *)dve_lowercasePathName {
    return [[self dve_pathName] lowercaseString];
}
@end
