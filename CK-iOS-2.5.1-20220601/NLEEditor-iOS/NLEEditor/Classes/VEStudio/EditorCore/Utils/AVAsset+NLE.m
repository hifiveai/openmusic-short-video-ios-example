//
//  AVAsset+NLE.m
//  NLEPlatform
//
//  Created by bytedance on 2021/4/14.
//

#import "AVAsset+NLE.h"

@implementation AVAsset (NLE)

- (CGSize)nle_videoSize
{
    AVAssetTrack *track = [self tracksWithMediaType:AVMediaTypeVideo].firstObject;
    if (!track) {
        return CGSizeZero;
    }
    CGSize size = track.naturalSize;
    AVCaptureVideoOrientation orientation = [self nle_fixedOrientation];
    if (orientation != AVCaptureVideoOrientationPortrait
        && orientation != AVCaptureVideoOrientationPortraitUpsideDown) {
        size = CGSizeMake(size.height, size.width);
    }
    return size;
}

- (AVCaptureVideoOrientation)nle_fixedOrientation
{
    AVAssetTrack *track = [self tracksWithMediaType:AVMediaTypeVideo].firstObject;
    if (!track) {
        return AVCaptureVideoOrientationPortrait;
    }
    
    CGAffineTransform t = track.preferredTransform;
    if (t.a == 0 && t.b == 1.0 && t.c == -1.f && t.d == 0) {
        // Portrait
        return AVCaptureVideoOrientationLandscapeRight;
    } else if (t.a == 0 && t.b == -1.f && t.c == 1.f && t.d == 0) {
        // LandscapeLeft
        return AVCaptureVideoOrientationLandscapeLeft;
    } else if (t.a == -1.f && t.b == 0 && t.c == 0 && t.d == -1.f) {
        // PortraitUpsideDown
        return AVCaptureVideoOrientationPortraitUpsideDown;
    } else {
        return AVCaptureVideoOrientationPortrait;
    }
}

- (CMTime)nle_videoTrackDuration
{
    AVAssetTrack *track = [self tracksWithMediaType:AVMediaTypeVideo].firstObject;
    if (!track) {
        return kCMTimeZero;
    }
    return track.timeRange.duration;
}

@end
