//
//  HFStoreManager.h
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/25.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HFMusicListCellModel;
NS_ASSUME_NONNULL_BEGIN

@interface HFPlayerConfigManager : NSObject

+ (instancetype)shared;
/// 是否登录
@property (nonatomic ,assign) BOOL isRegister;
/// 收藏歌单列表
@property (nonatomic ,strong) NSMutableArray *collectedArray;
/// 收藏歌单shheetId
@property (nonatomic ,strong) NSString *sheetId;
/// 当前播放器使用的model
@property (nonatomic ,strong) HFMusicListCellModel *currentPlayModel;

- (void)refreshCollectedArray;

- (void)saveData:(NSData *)data name:(NSString *)name;

- (NSData *)getDataWith:(NSString *)name;

- (NSString *)getPathWith:(NSString *)name;

- (BOOL)hasLocalDataWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
