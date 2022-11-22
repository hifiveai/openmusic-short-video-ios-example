//
//  HFMusicListCellModel.h
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/15.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class HFOpenMusicModel;
@interface HFMusicListCellModel : NSObject

+ (HFMusicListCellModel *)configWith:(HFOpenMusicModel *)model;
@property (nonatomic ,strong) NSString *picUrl;
@property (nonatomic ,strong) NSString *songName;
@property (nonatomic ,strong) NSString *auth;
@property (nonatomic ,strong) NSArray *tags;
@property (nonatomic ,strong) NSString *totalTime;

@property (nonatomic ,strong) NSString *musicId;

@property (nonatomic ,strong) NSString *pathUrl;

@property (nonatomic ,assign) BOOL isDownloading;
@property (nonatomic ,assign) BOOL isPlaying;

@property (nonatomic ,assign) BOOL hasLocalData;

- (NSAttributedString *)nameLabelText;
- (NSAttributedString *)selelctNameLabelText;
- (NSString *)tagLabelText;
- (NSString *)timeLabelText;


- (void)downloadMusic:(void(^)(void))successBlock failed:(void(^)(NSError *error))failedBlock;
+ (NSString *)timeFormatWithTimeInterval:(NSTimeInterval)duration;
@end

NS_ASSUME_NONNULL_END
