//
//  AVAsset+DVE.m
//  NLEEditor
//
//  Created by bytedance on 2021/4/11.
//

#import "AVAsset+DVE.h"

@implementation AVAsset (DVE)

- (AVCaptureVideoOrientation)fixedOrientation {
    NSArray<AVAssetTrack *> *tracks = [self tracksWithMediaType:AVMediaTypeVideo];
    if (tracks.count == 0 || ![tracks firstObject]) {
        return AVCaptureVideoOrientationPortrait;
    }
    
    CGAffineTransform transform = [tracks firstObject].preferredTransform;
    if (transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0) {
        return AVCaptureVideoOrientationLandscapeRight;
    } else if (transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0) {
        return AVCaptureVideoOrientationLandscapeLeft;
    } else if (transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0) {
        return AVCaptureVideoOrientationPortraitUpsideDown;
    } else {
        return AVCaptureVideoOrientationPortrait;
    }
    
}

@end
