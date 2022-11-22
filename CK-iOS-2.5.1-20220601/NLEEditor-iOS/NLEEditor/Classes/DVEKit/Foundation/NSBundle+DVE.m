//
//  NSBundle+DVE.m
//  NLEEditor-iOS
//
//  Created by bytedance on 2021/4/2.
//

#import "NSBundle+DVE.h"

@implementation NSBundle (DVE)

+ (NSBundle *)dve_bundleWithName:(NSString *)name
{
    NSString *bundleName = [NSString stringWithFormat:@"%@.bundle", name];
    NSString *path = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:bundleName];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    return bundle;
}

+ (NSBundle *)dve_mainBundle
{
    return [self dve_bundleWithName:@"NLEEditor"];
}


@end
