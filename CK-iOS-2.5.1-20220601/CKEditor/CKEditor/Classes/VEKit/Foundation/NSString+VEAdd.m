//
//  NSString+VEAdd.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "NSString+VEAdd.h"
#import <NLEEditor/NSString+DVE.h>

@implementation NSString (VEAdd)

- (NSDictionary *)VEToDic
{
    return [self dve_ToDic];
}
- (NSArray *)VEToArr
{
    return  [self dve_ToArr];
}

@end
