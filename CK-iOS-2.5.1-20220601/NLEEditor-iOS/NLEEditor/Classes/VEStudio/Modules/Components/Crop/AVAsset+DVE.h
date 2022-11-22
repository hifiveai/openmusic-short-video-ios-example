//
//  AVAsset+DVE.h
//  NLEEditor
//
//  Created by bytedance on 2021/4/11.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVAsset (DVE)

- (AVCaptureVideoOrientation)fixedOrientation;

@end

NS_ASSUME_NONNULL_END
