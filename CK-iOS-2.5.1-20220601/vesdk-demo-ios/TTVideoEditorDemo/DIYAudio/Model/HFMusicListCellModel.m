//
//  HFMusicListCellModel.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/15.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "HFMusicListCellModel.h"
#import "HFConfigModel.h"
#import "HFOpenModel.h"
#import <MJExtension/MJExtension.h>
#import <HFOpenApi/HFOpenApi.h>
#import <DoraemonKit/DoraemonNetworkUtil.h>
#import "HFPlayerConfigManager.h"
#import "HFNetWorkUtil.h"


@implementation HFMusicListCellModel

+ (HFMusicListCellModel *)configWith:(HFOpenMusicModel *)model {
    HFMusicListCellModel *cellModel = [[HFMusicListCellModel alloc] init];
    HFOpenMusicCoverModel *coverModel = model.cover.firstObject;
    cellModel.picUrl =coverModel.url;
    cellModel.songName = model.musicName;
    
    if (model.artist.count != 0) {
        NSArray *artistArray = [HFOpenMusicArtistModel mj_objectArrayWithKeyValuesArray:model.artist];
        HFOpenMusicArtistModel *artistModel = artistArray.firstObject;
        cellModel.auth = artistModel.name;
    }
    if (model.tag.count != 0) {
        NSMutableArray *tags = [[NSMutableArray alloc] init];
        for (HFOpenChannelSheetTagModel *tagModel in model.tag) {
            [tags addObject:tagModel.tagName];
        }
        cellModel.tags = tags;
    }
    cellModel.totalTime =  [self timeFormatWithTimeInterval:model.duration.longLongValue];
    cellModel.musicId = model.musicId;
    cellModel.isDownloading = model.isDownloading;
    cellModel.isPlaying = model.isPlaying;
    return cellModel;
}

- (NSAttributedString *)nameLabelText {
    NSString *text = [NSString stringWithFormat:@"%@ %@",self.songName,self.auth];
    NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:text];
    [name addAttribute:NSForegroundColorAttributeName value:[HFConfigModel mainTitleColor] range:[text rangeOfString:self.songName]];
    [name addAttribute:NSFontAttributeName value:[HFConfigModel bodyFont] range:[text rangeOfString:self.songName]];
    
    if (self.auth.length != 0) {
        [name addAttribute:NSForegroundColorAttributeName value:[HFConfigModel subodyColor] range:[text rangeOfString:self.auth]];
        [name addAttribute:NSFontAttributeName value:[HFConfigModel subBodyFont] range:[text rangeOfString:self.auth]];
    }
    
    
    return name;
}
- (NSAttributedString *)selelctNameLabelText {
    NSString *text = [NSString stringWithFormat:@"%@ %@",self.songName,self.auth];
    NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:text];
    [name addAttribute:NSForegroundColorAttributeName value:[HFConfigModel usingBackColor] range:[text rangeOfString:self.songName]];
    [name addAttribute:NSFontAttributeName value:[HFConfigModel bodyFont] range:[text rangeOfString:self.songName]];
    
    if (self.auth.length != 0) {
        [name addAttribute:NSForegroundColorAttributeName value:[HFConfigModel subodyColor] range:[text rangeOfString:self.auth]];
        [name addAttribute:NSFontAttributeName value:[HFConfigModel subBodyFont] range:[text rangeOfString:self.auth]];
    }
    
    return name;
}
- (NSString *)tagLabelText {
    NSMutableString *tagsString = [[NSMutableString alloc] init];
    for (NSString *tag in self.tags) {
        if (tagsString.length == 0) {
            [tagsString appendString:tag];
        }else {
            [tagsString appendFormat:@" %@",tag];
        }
    }
    return tagsString;
}


- (NSString *)timeLabelText {
    return self.totalTime;
}

- (void)downloadMusic:(void(^)(void))successBlock failed:(void(^)(NSError *error))failedBlock {
    
    __weak typeof(self) weakSelf = self;
    [[HFOpenApiManager shared] ugcHQListenWithMusicId:self.musicId audioFormat:@"mp3" audioRate:@"320" success:^(id  _Nullable response) {
//        HFOpenCurrentPlayListViewController *vc = self.controllerArray[0];
        HFOpenMusicDetailInfoModel *detailModel = [HFOpenMusicDetailInfoModel mj_objectWithKeyValues:response];
        [HFNetWorkUtil getWithUrlString:detailModel.fileUrl params:nil success:^(NSData * _Nonnull data) {
            if ([[HFPlayerConfigManager shared] hasLocalDataWithName:[detailModel.musicId stringByAppendingString:@".mp3"]]) {
                [[HFPlayerConfigManager shared] saveData:data name:[detailModel.musicId stringByAppendingString:@".mp3"]];
                weakSelf.hasLocalData = YES;
            }else {
                [[HFPlayerConfigManager shared] saveData:data name:[detailModel.musicId stringByAppendingString:@".mp3"]];
                weakSelf.hasLocalData = YES;
                if (successBlock) {
                    successBlock();
                }
            }
            
            
            
        } error:^(NSError * _Nonnull error) {
            if (failedBlock) {
                failedBlock(error);
            }
        }];

    } fail:^(NSError * _Nullable error) {
        if (failedBlock) {
            failedBlock(error);
        }
    }];
}

+ (NSString *)timeFormatWithTimeInterval:(NSTimeInterval)duration
{
    if (duration < 60) {
        return [NSString stringWithFormat:@"00:%02d",(int)duration];
    } else if (duration < 3600) {
        int minute = (int)duration / 60;
        int second = (int)duration % 60;
        return [NSString stringWithFormat:@"%02d:%02d",minute,second];
    } else {
        int hour = duration / 3600;
        int seconds = hour % 3600;
        int minute = seconds / 60;
        int second = seconds % 60;
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hour,minute,second];
    }
}

- (BOOL)hasLocalData {
    if (self.pathUrl) {
        return YES;
    }else {
        return NO;
    }
}

- (NSString *)pathUrl {
    if (!_pathUrl) {
        NSData *data = [[HFPlayerConfigManager shared] getDataWith:[self.musicId stringByAppendingString:@".mp3"]];
        if (data) {
            _pathUrl = [[HFPlayerConfigManager shared] getPathWith:[self.musicId stringByAppendingString:@".mp3"]];
        }
    }
    return _pathUrl;
}

@end
