//
//  DVEAlbumAssetModel.m
//  VideoTemplate
//
//  Created by bytedance on 2021/4/22.
//

#import "DVEAlbumAssetModel.h"


@implementation DVEAlbumAssetModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _canSelect = YES;
    }
    return self;
}

- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    if (asset.mediaType == PHAssetMediaTypeImage &&
        [[asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
        self.mediaSubType = DVEAlbumAssetModelMediaSubTypePhotoGif;
    }
}

+ (instancetype)createWithPHAsset:(PHAsset *)asset
{
    DVEAlbumAssetModel *model = [[DVEAlbumAssetModel alloc] init];
    DVEAlbumAssetModelMediaType type = DVEAlbumAssetModelMediaTypeUnknow;
    DVEAlbumAssetModelMediaSubType subType = DVEAlbumAssetModelMediaSubTypeUnknow;
    switch (asset.mediaType) {
        case PHAssetMediaTypeVideo:
            type = DVEAlbumAssetModelMediaTypeVideo;
            if (asset.mediaSubtypes == PHAssetMediaSubtypeVideoHighFrameRate) {
                subType = DVEAlbumAssetModelMediaSubTypeVideoHighFrameRate;
            }
            break;
        case PHAssetMediaTypeAudio:
            type = DVEAlbumAssetModelMediaTypeAudio;
        case PHAssetMediaTypeImage: {
            type = DVEAlbumAssetModelMediaTypePhoto;
            if (@available(iOS 9.1, *)) {
                if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                    subType = DVEAlbumAssetModelMediaSubTypePhotoLive;
                }
                break;
            }
            if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
                subType = DVEAlbumAssetModelMediaSubTypePhotoGif;
            }
        }
            break;
        default:
            break;
    }

    model.mediaType = type;
    model.mediaSubType = subType;
    model.asset = asset;
//    if (type == DVEAlbumAssetModelMediaTypeVideo) {
//        NSTimeInterval duration = asset.duration;
//        NSInteger seconds = (NSInteger)round(duration);
//        NSInteger second = seconds % 60;
//        NSInteger minute = seconds / 60;
//        model.videoDuration = [NSString stringWithFormat:@"%02ld:%02ld", (long)minute, (long)second];
////        model.videoDuration = [self timeStringWithDuration:asset.duration];
//    }

    return model;
}

- (NSDate *)creationDate
{
    return self.asset.creationDate;
}


- (BOOL)isEqualToAssetModel:(DVEAlbumAssetModel *)model identity:(BOOL)identity {
    if ([self.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
        return YES;
    }
    return NO;
}

- (DVEAlbumAssetModel *)copyWithZone:(NSZone *)zone {
    DVEAlbumAssetModel *model = [DVEAlbumAssetModel new];

    model.asset = self.asset;
    model.videoDuration = self.videoDuration;
    model.mediaType = self.mediaType;
    model.mediaSubType =  self.mediaSubType;
    model.selectedNum = self.selectedNum;
    model.selectedAmount = self.selectedAmount;
//    model.creationDate = self.creationDate;
    model.coverImage = self.coverImage;
    model.avAsset = self.avAsset;
    model.info = self.info;
    model.isDegraded = self.isDegraded;
    model.iCloudSyncProgress = self.iCloudSyncProgress;
    model.cellIndex = self.cellIndex;
    model.dateFormatStr = self.dateFormatStr;

    return model;
}

@end

@implementation DVEAlbumModel


@end
