//
//  DVEVideoPlayer.h
//  NLEEditor
//
//  Created by bytedance on 2021/4/9.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "DVECropDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class DVECropVideoPlayer;
@protocol DVECropVideoPlayerDelegate <NSObject>

@optional
- (void)videoPlayerReadyToPlay:(DVECropVideoPlayer *)videoPlayer;
- (void)videoPlayer:(DVECropVideoPlayer *)videoPlayer error:(NSError *)error;
- (void)videoPlayCurrentTime:(CMTime)time;
- (void)videoPlayToEnd;

@end

@interface DVECropVideoPlayerState : NSObject

@property (nonatomic, assign) DVECropVideoPlayState playState;

@property (nonatomic, assign, readonly, getter=isPlayable) BOOL playable;

- (instancetype)initWithPlayState:(DVECropVideoPlayState)state;

@end

@interface DVECropVideoPlayerRateMode : NSObject

@property (nonatomic, assign) DVECropVideoRateMode playRateMode;

@property (nonatomic, assign) float value;

- (instancetype)initWithRateMode:(DVECropVideoRateMode)mode value:(float)value;

- (void)modifyRateMode:(DVECropVideoRateMode)mode value:(float)value;

@end

@interface DVECropVideoPlayerView : UIView

@property (nonatomic, strong) AVLayerVideoGravity videoGravity;

@end

@interface DVECropVideoPlayer : NSObject

@property (nonatomic, strong, readonly) NSURL *assetURL;

@property (nonatomic, strong, readonly) DVECropVideoPlayerView *playerView;

@property (nonatomic, strong, readonly) AVAsset *asset;

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, weak) id<DVECropVideoPlayerDelegate> delegate;

@property (nonatomic, assign) CGFloat volume;

@property (nonatomic, assign) BOOL loop;

@property (nonatomic, assign) BOOL mute;

@property (nonatomic, strong) id timeObserver;

@property (nonatomic, assign) BOOL isAssetLoaded;

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, assign) BOOL isObserving;

@property (nonatomic, assign) BOOL isUserPaused;

@property (nonatomic, strong) DVECropVideoPlayerRateMode *rate; //rate

@property (nonatomic, strong) AVLayerVideoGravity videoGravity; //videoGravity
 
@property (nonatomic, strong) DVECropVideoPlayerState *state; //autoPlayState

@property (nonatomic, assign) CMTime playTimeEnd;

- (void)loadVideoURL:(NSURL *)url
                rate:(CGFloat)rate
            seekTime:(CMTime)seekTime
  seekTimeCompletion:(void(^_Nullable)(BOOL))completion;

- (void)loadVideoAsset:(AVAsset *)asset
                  rate:(CGFloat)rate
              seekTime:(CMTime)seekTime
    seekTimeCompletion:(void(^_Nullable)(BOOL))completion;

- (void)play;

- (void)playImmediatelyWithRate:(CGFloat)rate;

- (void)pause;

- (void)stop;

- (void)seekToTime:(CMTime)time;

- (void)seekToTime:(CMTime)time completion:(void(^)(BOOL))completion;

- (CMTime)currentTime;

- (NSTimeInterval)assetDuration;

- (CGFloat)playProgress;

- (void)resetPlay;

@end

NS_ASSUME_NONNULL_END
