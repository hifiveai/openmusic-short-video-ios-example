//
//  AVAsset+NLE.h
//  NLEPlatform
//
//  Created by bytedance on 2021/4/14.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVAsset (NLE)

- (CGSize)nle_videoSize;

- (AVCaptureVideoOrientation)nle_fixedOrientation;

- (CMTime)nle_videoTrackDuration;

@end

NS_ASSUME_NONNULL_END
