//
//  DVEDataStore.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/2/28.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "DVEDataStore.h"
#import "DVEDraftModel.h"
#import "DVELoggerImpl.h"
#import <MJExtension/MJExtension.h>

@interface DVEDataStore ()

@property (nonatomic, strong) NSString *cacheFile;

@property (nonatomic, strong) NSMutableArray <DVEDraftModel *>*drafts;

@end

@implementation DVEDataStore

+ (instancetype)shareDataStore {
    static DVEDataStore *DataStoreInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DataStoreInstance = [[super allocWithZone:nil] init];
    });
    return DataStoreInstance;
}

+(id)allocWithZone:(NSZone *)zone{
    return [self shareDataStore];
}
-(id)copyWithZone:(NSZone *)zone{
    return [[self class] shareDataStore];
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return [[self class] shareDataStore];
}


- (instancetype)init
{
    if (self = [super init]) {
        NSError *error;
        NSString *strArr = [NSString stringWithContentsOfFile:self.cacheFile encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            DVELogError(@"---------%@",error.localizedDescription);
        }
        self.drafts = [DVEDraftModel mj_objectArrayWithKeyValuesArray:strArr.mj_JSONObject];
        if (!_drafts) {
            _drafts = [NSMutableArray new];
        }
    }
    
    return self;
}

- (NSArray <DVEDraftModel *>*)getAllDrafts
{
    return [self.drafts copy];
}

- (void)addOneDarftWithModel:(DVEDraftModel *)draft
{
    __block BOOL isNewModel = YES;
    __block NSInteger targetIndex = -1;
    [self.drafts enumerateObjectsUsingBlock:^(DVEDraftModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.draftID isEqualToString:draft.draftID]) {
            isNewModel = NO;
            targetIndex = idx;
            *stop = YES;
        }
    }];
    
    if (isNewModel) {
        [self.drafts insertObject:draft atIndex:0];
    } else {
        [self.drafts removeObjectAtIndex:targetIndex];
        [self.drafts insertObject:draft atIndex:0];
    }
    
    [self syncFile];
}

- (void)removeOneDraftModel:(DVEDraftModel *)draft
{
    [self.drafts removeObject:draft];
    [self syncFile];
}

- (NSString *)cacheFile
{
    // 获取Documents目录
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

    _cacheFile = [docPath stringByAppendingString:@"/draft.data"];
    
    return _cacheFile;
}

- (void)syncFile
{
    NSArray  *strArr = [DVEDraftModel mj_keyValuesArrayWithObjectArray:self.drafts ignoredKeys:nil];
    NSError *error;
    [strArr.mj_JSONString writeToFile:self.cacheFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        DVELogError(@"---------%@",error.localizedDescription);
    }
}


@end
