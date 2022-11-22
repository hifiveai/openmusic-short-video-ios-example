//
//  NSObject+VEAdd.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "NSObject+VEAdd.h"
#import <YYModel/NSObject+YYModel.h>

@implementation NSObject (VEAdd)

- (id)VEToJSONObject
{
    return self.yy_modelToJSONObject;
}

- (NSData *)VEToJSONData
{
    id jsonObject = [self VEToJSONObject];
    if (!jsonObject) return nil;
    return [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:NULL];
}

- (NSString *)VEToJSONString
{
    NSData *jsonData = [self VEToJSONData];
    if (jsonData.length == 0) return nil;
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
