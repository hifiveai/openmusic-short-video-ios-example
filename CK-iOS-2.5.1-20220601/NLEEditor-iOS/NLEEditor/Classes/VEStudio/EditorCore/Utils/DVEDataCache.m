//
//  DVEDataCache.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEDataCache.h"


@implementation DVEDataCache

+ (void)setExportFPSSelectIndex:(NSInteger)index
{
    NSMutableDictionary *userParm = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kUserParmForVEVC]];
    if (!userParm) {
        userParm = [NSMutableDictionary new];
    }
    [userParm setObject:@(index) forKey:kUserParmForVEVCFPS];
    [[NSUserDefaults standardUserDefaults] setValue:userParm forKey:kUserParmForVEVC];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (NSInteger)getExportFPSIndex
{
    NSDictionary *userParm = [[NSUserDefaults standardUserDefaults] objectForKey:kUserParmForVEVC];
    if (!userParm) {
        return 1;;
    }
    NSNumber *fps = [userParm valueForKey:kUserParmForVEVCFPS];
    if (!fps) {
        return 1;
    }
    return fps.integerValue;
    
}

+ (void)setExportPresentSelectIndex:(NSInteger)index
{
    NSMutableDictionary *userParm = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kUserParmForVEVC]];;
    if (!userParm) {
        userParm = [NSMutableDictionary new];
    }
    [userParm setObject:@(index) forKey:kUserParmForVEVCPresentIndex];
    [[NSUserDefaults standardUserDefaults] setValue:userParm forKey:kUserParmForVEVC];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)getExportPresentIndex
{
    NSDictionary *userParm = [[NSUserDefaults standardUserDefaults] objectForKey:kUserParmForVEVC];
    if (!userParm) {
        return 1;;
    }
    NSNumber *fps = [userParm valueForKey:kUserParmForVEVCPresentIndex];
    if (!fps) {
        return 1;;
    }
    return fps.integerValue;
}

+ (void)setExportPresent:(NSInteger)index
{
    NSMutableDictionary *userParm = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kUserParmForVEVC]];;
    if (!userParm) {
        userParm = [NSMutableDictionary new];
    }
    [userParm setObject:@(index) forKey:kUserParmForVEVCPresent];
    [[NSUserDefaults standardUserDefaults] setValue:userParm forKey:kUserParmForVEVC];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSInteger)getExportPresent
{
    NSDictionary *userParm = [[NSUserDefaults standardUserDefaults] objectForKey:kUserParmForVEVC];
    if (!userParm) {
        return 1;;
    }
    NSNumber *fps = [userParm valueForKey:kUserParmForVEVCPresent];
    if (!fps) {
        return 1;;
    }
    return fps.integerValue;
}



@end
