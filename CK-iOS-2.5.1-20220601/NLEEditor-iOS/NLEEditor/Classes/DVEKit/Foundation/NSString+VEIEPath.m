//
//  NSString+VEIEPath.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "NSString+VEIEPath.h"

static NSMutableDictionary *bundleDic;

@implementation NSString (VEIEPath)


- (NSString *)pathInBundle:(NSString *)bundle folder:(NSString *)folder module:(NSString *)module unit:(NSString *)unit
{
    NSString *resPath = self;
    if (unit) {
        resPath = [[unit stringByAppendingString:@"/"] stringByAppendingString:resPath];
    }
    if (module) {
        resPath = [[module stringByAppendingString:@"/"] stringByAppendingString:resPath];
    }
    if (folder) {
        resPath = [[folder stringByAppendingString:@"/"] stringByAppendingString:resPath];
    }
    
    bundle = [self pathForBundle:bundle];
//    if (bundle) {
        resPath = [[bundle stringByAppendingString:@"/"] stringByAppendingString:resPath];
//    }
    return resPath;
}
- (NSString *)pathInBundle:(NSString *)bundle module:(NSString *)module unit:(NSString *)unit
{
    return [self pathInBundle:bundle folder:nil module:module unit:unit];;
}
- (NSString *)pathInBundle:(NSString *)bundle unit:(NSString *)unit
{
    return [self pathInBundle:bundle module:nil unit:unit];
}
- (NSString *)pathInBundle:(NSString *)bundle
{
    return [self pathInBundle:bundle unit:nil];
}


- (NSString *)pathForBundle:(NSString *)bundle
{
    if (!bundle) {
        return nil;
    }
    NSString *path = nil;
    if (!bundleDic) {
        bundleDic = [NSMutableDictionary new];
    }
    
    path = [bundleDic valueForKey:bundle];
    
    if (!path) {
        path = [[NSBundle mainBundle] pathForResource:bundle ofType:@"bundle"];
        if (path) {
            [bundleDic setValue:path forKey:bundle];
        }
        
    } else {
        
    }
    
    return path;
}

+ (NSString *)VEUUIDString
{
    return [[NSUUID UUID] UUIDString];
}


@end
