//
//  DVEVideoPlayer.m
//  NLEEditor
//
//  Created by bytedance on 2021/4/9.
//
#import "DVEMacros.h"
#import "DVECropVideoPlayer.h"
#import "DVELoggerImpl.h"

@implementation DVECropVideoPlayerState

- (instancetype)initWithPlayState:(DVECropVideoPlayState)state {
    if (self = [super init]) {
        _playState = state;
    }
    return self;
}

- (BOOL)isPlayable {
    return self.playState == DVECropVideoPlayStateAuto;
}

@end

@implementation DVECropVideoPlayerRateMode

- (instancetype)initWithRateMode:(DVECropVideoRateMode)mode value:(float)value {
    if (self = [super init]) {
        _playRateMode = mode;
        _value = value;
    }
    return self;
}

- (void)modifyRateMode:(DVECropVideoRateMode)mode value:(float)value {
    _playRateMode = mode;
    _value = value;
}

- (float)value {
    switch (self.playRateMode) {
        case DVECropVideoRateInitSet:
        case DVECropVideoRatePlaySet:
            return _value;
        default:
            return 1.0;
    }
    
}

@end

@interface DVECropVideoPlayerView ()

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

- (void)addPlayer:(AVPlayer *)player;

- (void)removePlayer;

@end

@implementation DVECropVideoPlayerView


- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.playerLayer.backgroundColor = [UIColor clearColor].CGColor;
        self.playerLayer.needsDisplayOnBoundsChange = YES;
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.playerLayer.frame = frame;
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    self.playerLayer.videoGravity = videoGravity;
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

- (void)addPlayer:(AVPlayer *)player {
    [self removePlayer];
    self.playerLayer.player = player;
}

- (void)removePlayer {
    self.playerLayer.player = nil;
}

#pragma mark - Override

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

@end


@interface DVECropVideoPlayer ()

@property (nonatomic, strong, readwrite) NSURL *assetURL;

@property (nonatomic, strong, readwrite) AVAsset *asset;

@property (nonatomic, strong, readwrite) DVECropVideoPlayerView *playerView;

@end

@implementation DVECropVideoPlayer

- (instancetype)init {
    self = [super init];
    if (self) {
        [self p_addNotifications];
        _isUserPaused = NO;
        _isObserving = NO;
        _isAssetLoaded = NO;
        _isPlaying = NO;
        _playerView = [[DVECropVideoPlayerView alloc] init];
        _player = [[AVPlayer alloc] init];
        _videoGravity = AVLayerVideoGravityResizeAspect;
        _rate = [[DVECropVideoPlayerRateMode alloc] initWithRateMode:DVECropVideoRateInitSet value:1.0];
        _state = [[DVECropVideoPlayerState alloc] initWithPlayState:DVECropVideoPlayStateNone];
    }
    return self;
}

- (void)dealloc {
    [self p_reset];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setMute:(BOOL)mute {
    self.player.muted = mute;
}

- (void)setVolume:(CGFloat)volume {
    self.player.volume = volume;
}

- (CGFloat)volume {
    return self.player.volume;
}

- (void)loadVideoURL:(NSURL *)url
                rate:(CGFloat)rate
            seekTime:(CMTime)seekTime
  seekTimeCompletion:(void (^)(BOOL))completion{
    self.assetURL = url;
    AVURLAsset *urlAsset = [AVURLAsset assetWithURL:url];
    [self loadVideoAsset:urlAsset rate:rate seekTime:seekTime seekTimeCompletion:completion];
}

- (void)loadVideoAsset:(AVAsset *)asset
                  rate:(CGFloat)rate
              seekTime:(CMTime)seekTime
    seekTimeCompletion:(void (^)(BOOL))completion {
    [self p_reset];
    if (rate <= 0.0 || rate > 4.0) {
        [self.rate modifyRateMode:DVECropVideoRateInitSet value:1.0];
    }
    [asset loadValuesAsynchronouslyForKeys:@[@"playable", @"tracks", @"duration"] completionHandler:^{
        @weakify(self);
        if (!self) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *durationError = nil;
            NSError *trackError = nil;
            NSError *playableError = nil;
            AVKeyValueStatus durationStatus = [asset statusOfValueForKey:@"duration" error:&durationError];
            AVKeyValueStatus trackStatus = [asset statusOfValueForKey:@"tracks" error:&trackError];
            AVKeyValueStatus playableStatus = [asset statusOfValueForKey:@"playable" error:&playableError];
            
            if (durationStatus == AVKeyValueStatusLoaded
                && trackStatus == AVKeyValueStatusLoaded
                && playableStatus == AVKeyValueStatusLoaded) {
                [self p_loadVideoAsset:asset rate:rate seekTime:seekTime seekTimeCompletion:completion];
            } else {
                
            }
        });
    }];
}

- (void)play {
    self.state.playState = DVECropVideoPlayStateAuto;
    _isUserPaused = false;
    [self p_play];
}

- (void)playImmediatelyWithRate:(CGFloat)rateValue {
    if ([self.rate value] != rateValue) {
        [self p_pause];
    }
    [self.rate modifyRateMode:DVECropVideoRatePlaySet value:rateValue];
    self.state.playState = DVECropVideoPlayStateNone;
    _isUserPaused = false;
    [self p_play];
}

- (void)pause {
    [self p_pause];
    self.state.playState = DVECropVideoPlayStateNone;
    _isUserPaused = YES;
}

- (void)stop {
    [self p_reset];
    _asset = nil;
    _assetURL = nil;
    self.state.playState = DVECropVideoPlayStateNone;
}

- (void)seekToTime:(CMTime)time {
    [self.playerItem seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil];
}

- (void)seekToTime:(CMTime)time completion:(void (^)(BOOL))completion {
    [self.playerItem seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:completion];
}

- (CMTime)currentTime {
    return [self.playerItem currentTime];
}

- (NSTimeInterval)assetDuration {
    NSAssert(_isAssetLoaded, @"shoule be load asset first.");
    return CMTimeGetSeconds(self.playerItem.asset.duration);
}

- (CGFloat)playProgress {
    if (_isAssetLoaded) {
        CGFloat currentDuration = CMTimeGetSeconds([self currentTime]);
        CGFloat totalDuration = self.assetDuration;
        if (totalDuration <= 0) {
            return 0;
        }
        return currentDuration / totalDuration;
    } else {
        return 0;
    }
}

- (void)resetPlay {
    [self.playerItem seekToTime:kCMTimeZero completionHandler:nil];
    [self p_pause];
}

#pragma mark - Override

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (![object isEqual: self.playerItem]) {
        return;
    }
    
    if (!self) {
        return;
    }
    
    if ([keyPath isEqualToString:@"status"]) {
        if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
            CGFloat time = self.playerItem.duration.value / (CGFloat)self.playerItem.duration.timescale;
            if (time == 0.0) {
                DVELogError(@"load video error");
            }
        } else if (self.playerItem.status == AVPlayerStatusFailed) {
            
        }
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        if (self.playerItem.isPlaybackBufferEmpty) {
            
        }
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        if (self.playerItem.isPlaybackLikelyToKeepUp) {
            
        }
    }
}

- (void)handleEnteredBackground:(NSNotification *)notification {
    BOOL isAutoPlayable = [self.state isPlayable];
    if (_isPlaying || isAutoPlayable) {
        if (isAutoPlayable) {
            self.state.playState = DVECropVideoPlayStateInterrupt;
        }
        [self p_pause];
        
    }
}

- (void)handleBecomeActive:(NSNotification *)notification {
    BOOL isAutoPlayInterrupt = [self.state isPlayable];
    if (_isPlaying || isAutoPlayInterrupt) {
        if (isAutoPlayInterrupt) {
            self.state.playState = DVECropVideoPlayStateAuto;
        }
        
        [self p_play];
        
    }
}

- (void)playerItemDidPlayToEndTime:(NSNotification *)notification {
    if (_loop && _isPlaying) {
        [self p_restartPlay];
    } else {
        
    }
}

- (void)onAudioInterrupted:(NSNotification *)notification {
    if (_isUserPaused) {
        return;
    }
    
    NSDictionary *userInfo = notification.userInfo;
    if (![userInfo objectForKey:AVAudioSessionInterruptionTypeKey]) {
        return;
    }
    AVAudioSessionInterruptionType type = userInfo[AVAudioSessionInterruptionTypeKey];
    if (type == AVAudioSessionInterruptionTypeEnded &&
        [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self p_resumePlay];
    }
    
}

- (void)onAudioRouteChanged:(NSNotification *)notification {
    if (_isUserPaused) {
        return;
    }
    
    NSDictionary *userInfo = notification.userInfo;
    if (!userInfo[AVAudioSessionRouteChangeReasonKey]) {
        return;
    }
    AVAudioSessionRouteChangeReason reason = userInfo[AVAudioSessionRouteChangeReasonKey];
    if ([NSThread isMainThread]) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [self p_resumePlay];
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            @weakify(self);
            if (!self) {
                return;
            }
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                [self p_resumePlay];
            }
        });
    }
}


#pragma mark - Private


- (void)p_loadVideoAsset:(AVAsset *)asset
                    rate:(CGFloat)rate
                seekTime:(CMTime)seekTime
      seekTimeCompletion:(void(^)(BOOL))completion {
    AVAsset *localAsset = nil;
    if (rate != 1.0) {
        AVMutableComposition *composition = [[AVMutableComposition alloc] init];
        [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofAsset:asset atTime:kCMTimeZero error:nil];
        CMTime toDuration = CMTimeMultiplyByFloat64(asset.duration, 1.0 / rate);
        [composition scaleTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) toDuration:toDuration];
        localAsset = composition;
    } else {
        localAsset = asset;
    }
    self.asset = localAsset;
    self.isAssetLoaded = YES;
    [self p_stopObservers];
    self.playerItem = [[AVPlayerItem alloc] initWithAsset:localAsset];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    [self p_startObservers];
    [self.playerView addPlayer:self.player];
    self.playerView.videoGravity = self.videoGravity;
    if ([self.state isPlayable]) {
        [self p_play];
    }
    [self seekToTime:seekTime completion:completion];
}

- (void)p_play {
    if (![self isPlayable]) {
        return;
    }
    [self p_resumePlay];
    self.state.playState = DVECropVideoPlayStateNone;
}

- (void)p_pause {
    if (!_isPlaying) {
        return;
    }
    [self.player pause];
    _isPlaying = NO;
}

- (void)p_resumePlay {
    if (self.rate.playRateMode == DVECropVideoRatePlaySet) {
        if (@available(iOS 10.0, *)) {
            [self.player playImmediatelyAtRate:self.rate.value];
        } else {
            self.player.rate = self.rate.value;
        }
    } else {
        [self.player play];
    }
    _isPlaying = YES;
}

- (void)p_restartPlay {
    [self.playerItem seekToTime:kCMTimeZero completionHandler:nil];
    [self p_resumePlay];
}

- (void)p_reset {
    [self.player replaceCurrentItemWithPlayerItem:nil];
    [self p_pause];
    [self p_stopObservers];
    [self.playerView removePlayer];
    _asset = nil;
    [self.playerItem seekToTime:kCMTimeZero completionHandler:nil];
    _playerItem = nil;
    _isPlaying = _isUserPaused = _isAssetLoaded = NO;
}

- (BOOL)isPlayable {
    if (self.playerItem == nil || self.isPlaying ||
        [UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return false;
    }
    return _isAssetLoaded;
}


- (void)p_startObservers {
    
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    @weakify(self);
    _timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(16, 1000)
                                                              queue:dispatch_get_main_queue()
                                                         usingBlock:^(CMTime time) {
        @strongify(self);
        if (!self) {
            return;
        }
        [self.delegate videoPlayCurrentTime:[self currentTime]];
        NSTimeInterval curTime = CMTimeGetSeconds([self currentTime]);
        NSTimeInterval endTime = CMTimeGetSeconds([self playTimeEnd]);
        DVELogInfo(@"videoPlayer current:%.10f", curTime);
        DVELogInfo(@"videoPlayer endTime:%.10f", endTime);
        if (curTime >= endTime) {
            [self pause];
            [self.delegate videoPlayToEnd];
        }
    }];
    _isObserving = YES;
}

- (void)p_stopObservers {
    if (!_isObserving) {
        return;
    }
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    if (_timeObserver) {
        [self.player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
    _isObserving = NO;
}

- (void)p_addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnteredBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioInterrupted:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioRouteChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
}

@end
