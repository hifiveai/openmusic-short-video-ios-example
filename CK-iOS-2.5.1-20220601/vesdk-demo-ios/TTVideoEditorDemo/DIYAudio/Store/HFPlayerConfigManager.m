//
//  HFStoreManager.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/25.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "HFPlayerConfigManager.h"
#import <YYCache/YYCache.h>
#import <HFOpenApi/HFOpenApi.h>
#import "HFOpenModel.h"
#import <MJExtension/MJExtension.h>
#import "NSMutableDictionary+SafeAccess.h"
#import "NSMutableArray+SafeAccess.h"
#import "NSDictionary+SafeAccess.h"
#import "DVECustomerHUD.h"

@interface HFPlayerConfigManager ()

@property (nonatomic ,strong) YYCache *hfCache;
@property (nonatomic ,strong) NSString *path;
@end

@implementation HFPlayerConfigManager

+ (instancetype)shared {
    static HFPlayerConfigManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[HFPlayerConfigManager alloc] init];
            NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *path = [cacheFolder stringByAppendingPathComponent:@"hfStore"];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL isDir = NO;
            BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
            if(!(isDir && existed)){
                [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            }
            manager.path = path;
            
        }
    });
    return manager;
}

- (void)saveData:(NSData *)data name:(NSString *)name {
    [data writeToURL:[NSURL fileURLWithPath:[self.path stringByAppendingFormat:@"/%@",name]] atomically:YES];
//    [data writeToFile:[self.path stringByAppendingFormat:@"/%@",name] atomically:YES];
}

- (NSData *)getDataWith:(NSString *)name {
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[self.path stringByAppendingFormat:@"/%@",name]]];
    return data;
}

- (NSString *)getPathWith:(NSString *)name {
    NSString *path = [NSString stringWithFormat:@"%@/%@",self.path,name];
    return path;
}

- (void)refreshCollectedArray {
    
    [[HFOpenApiManager shared] fetchMemberSheetMusicWithSheetId:[HFPlayerConfigManager shared].sheetId page:@"1" pageSize:@"100" success:^(id  _Nullable response) {
        NSArray *tempArray = [HFOpenMusicModel mj_objectArrayWithKeyValuesArray:[response hfv_objectForKey_Safe:@"record"]];
        [[HFPlayerConfigManager shared].collectedArray setArray:tempArray];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HFRefreshCollected" object:nil];
    } fail:^(NSError * _Nullable error) {
        [DVECustomerHUD showMessage:error.localizedDescription];
    }];
}

- (BOOL)hasLocalDataWithName:(NSString *)name {
    NSString *path = [self.path stringByAppendingFormat:@"/%@",name];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (YYCache *)hfCache {
    if (!_hfCache) {
        _hfCache = [YYCache cacheWithName:@"hfStore"];
    }
    return _hfCache;
}

- (NSMutableArray *)collectedArray {
    if (!_collectedArray) {
        _collectedArray = [[NSMutableArray alloc] init];
    }
    return _collectedArray;
}

@end
