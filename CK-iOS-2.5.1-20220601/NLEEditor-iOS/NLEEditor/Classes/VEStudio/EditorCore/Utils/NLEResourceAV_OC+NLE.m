//
//  NLEResourceAV_OC+NLE.m
//  NLEPlatform
//
//  Created by bytedance on 2021/4/14.
//

#import "NLEResourceAV_OC+NLE.h"
#import "AVAsset+NLE.h"

@implementation NLEResourceAV_OC (NLE)

- (void)nle_setupForVideo:(AVURLAsset *)asset
{
    [self nle_setupForVideo:asset resourceFilePath:asset.URL.absoluteString];
}

- (void)nle_setupForVideo:(AVURLAsset *)asset
         resourceFilePath:(NSString *)resourceFilePath
{
    NSAssert([asset isKindOfClass:AVURLAsset.class], @"not AVURLAsset");
    self.resourceType = NLEResourceTypeVideo;
    self.resourceFile = resourceFilePath;

    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;

    self.hasAudio = audioTracks.count > 0;
    self.duration = (videoTrack != nil) ? videoTrack.timeRange.duration : asset.duration;
    self.width = (uint32_t)([asset nle_videoSize].width);
    self.height = (uint32_t)([asset nle_videoSize].height);
}

- (void)nle_setupForPhoto:(NSString *)photoPath
                 duration:(CMTime)duration
{
    UIImage *image = [UIImage imageWithContentsOfFile:photoPath];
    if (!image) {
        NSAssert(NO, @"could not create image from %@", photoPath);
        return;
    }
    [self nle_setupForPhoto:photoPath
                      width:(uint32_t)(image.size.width)
                     height:(uint32_t)(image.size.height)
                   duration:duration];
}

- (void)nle_setupForPhoto:(NSString *)photoPath
                    width:(uint32_t)width
                   height:(uint32_t)height
                 duration:(CMTime)duration
{
    self.resourceType = NLEResourceTypeImage;
    self.width = width;
    self.height = height;
    self.resourceFile = photoPath;
    self.duration = duration;
}

- (void)nle_setupForAudio:(AVURLAsset *)asset
{
    [self nle_setupForMedia:asset type:NLEResourceTypeAudio];
}

- (void)nle_setupForRecord:(AVURLAsset *)asset
{
    [self nle_setupForMedia:asset type:NLEResourceTypeRecord];
}

- (void)nle_setupForMedia:(AVURLAsset *)asset type:(NLEResourceType)type
{
    NSArray<AVAssetTrack *> *audioTracks = [asset.tracks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"mediaType=%d", AVMediaTypeAudio]];
    
    self.resourceType = type;
    self.duration = asset.duration;
    self.resourceFile = asset.URL.absoluteString;
    self.hasAudio = audioTracks.count > 0;
    self.width = 0;
    self.height = 0;
}


@end
