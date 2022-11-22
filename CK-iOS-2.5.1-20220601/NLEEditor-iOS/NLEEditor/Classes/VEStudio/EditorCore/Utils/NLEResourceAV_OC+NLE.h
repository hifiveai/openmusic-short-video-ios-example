//
//  NLEResourceAV_OC+NLE.h
//  NLEPlatform
//
//  Created by bytedance on 2021/4/14.
//

#import <NLEPlatform/NLEResourceAV+iOS.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLEResourceAV_OC (NLE)

- (void)nle_setupForVideo:(AVURLAsset *)asset;

- (void)nle_setupForVideo:(AVURLAsset *)asset
         resourceFilePath:(NSString *)resourceFilePath;

- (void)nle_setupForPhoto:(NSString *)photoPath
                 duration:(CMTime)duration;

- (void)nle_setupForPhoto:(NSString *)photoPath
                    width:(uint32_t)width
                   height:(uint32_t)height
                 duration:(CMTime)duration;

- (void)nle_setupForAudio:(AVURLAsset *)asset;

- (void)nle_setupForRecord:(AVURLAsset *)asset;

@end

NS_ASSUME_NONNULL_END
