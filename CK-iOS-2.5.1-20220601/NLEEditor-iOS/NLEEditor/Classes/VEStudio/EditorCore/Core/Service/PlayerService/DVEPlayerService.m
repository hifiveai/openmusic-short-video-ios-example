//
//  DVEPlayerService.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEPlayerService.h"
#import "DVEMacros.h"
#import "NSString+VEIEPath.h"
#import "DVECustomerHUD.h"
#import "DVELoggerImpl.h"
#import <NLEPlatform/NLECaptureOutput.h>
#import <NLEPlatform/NLEInterface.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <TTVideoEditor/VEEditorSession+CaptureFrame.h>

@interface DVEPlayerService ()

@property (nonatomic, weak) NLEInterface_OC *nle;

@property (nonatomic, strong) NSMutableArray<dispatch_block_t> *updateVideoDataBlocks;
@property (nonatomic, strong) NSMutableArray<dispatch_block_t> *playerTimeChangeBlocks;
@property (nonatomic, strong) NSMutableArray<dispatch_block_t> *statuseChangeBlocks;

@end

@implementation DVEPlayerService

@synthesize playerAutoRepeatBlock = _playerAutoRepeatBlock;
@synthesize playerTimerBlock = _playerTimerBlock;
@synthesize playerCompleteBlock = _playerCompleteBlock;
@synthesize currentPlayerTime = _currentPlayerTime;
@synthesize status = _status;
@synthesize isPlayComplete = _isPlayComplete;
@synthesize needPausePlayerTime = _needPausePlayerTime;

#pragma mark - LifeCycle

- (void)dealloc
{
    DVELogInfo(@"DVEPlayerService dealloc");
}

- (instancetype)initWithNLEInterface:(NLEInterface_OC *)nle
{
    if (self = [super init]) {
        _nle = nle;
        _updateVideoDataBlocks = [NSMutableArray new];
        _playerTimeChangeBlocks = [NSMutableArray new];
        _statuseChangeBlocks = [NSMutableArray new];

        [self initRACObserve];
    }
    return self;
}

- (void)initRACObserve
{
    @weakify(self);
    [RACObserve(self.nle, currentPlayerTime) subscribeNext:^(NSNumber *x) {
        @strongify(self);
        self.isPlayComplete = NO;
        self.currentPlayerTime = x.doubleValue;
        [self notifyTimeChangeEvent];
        if (self.needPausePlayerTime > 0 && (self.needPausePlayerTime - x.doubleValue < 0.01)) {
            [self pause];
        }
    }];
    
    [RACObserve(self.nle, status) subscribeNext:^(NSNumber *x) {
        @strongify(self);
        self.status = x.integerValue;
        [self notifyStatuesEvent];
    }];
}

#pragma mark - DVEPlayerServiceProtocol

- (void)getProcessedPreviewImageAtTime:(NSTimeInterval)atTime
                         preferredSize:(CGSize)size
                           compeletion:(void (^)(UIImage *image, NSTimeInterval atTime))completion
{
    [self.nle.captureOutput getProcessedPreviewImageAtTime:atTime preferredSize:size isLastImage:YES compeletion:completion];
}

- (void)updateVideoData:(HTSVideoData *)data
          completeBlock:(void(^)(NSError * _Nullable error))complete
{
    @weakify(self);
    [self.nle updateVideoData:data completeBlock:^(NSError * _Nullable error) {
        @strongify(self);
        [self notifyUpdateVideoDataEvent];
        if (complete) {
            complete(error);
        }        
    }];
}

- (BOOL)isPlaying
{
    return self.nle.status == HTSPlayerStatusPlaying;
}

- (void)play
{
    if (self.isPlayComplete || fabs(self.currentPlayerTime - self.veVideoData.maxTrackDuration) < 0.016 ) {
        [self.nle seekToTime:CMTimeMake(0, 1)];
        self.isPlayComplete = NO;
    }
    [self.nle start];
}

- (void)pause
{
    self.needPausePlayerTime = -1;
    [self.nle pause];
}

- (void)seekToTime:(CMTime)time
          isSmooth:(BOOL)isSmooth
{
    [self.nle seekToTime:time seekMode:isSmooth ? VESmoothSeek: VEAccurateSeek];
}

- (void)seekToTime:(CMTime)time
          isSmooth:(BOOL)isSmooth
 completionHandler:(void (^_Nullable)(BOOL finished))completionHandler
{
    [self.nle seekToTime:time seekMode:isSmooth ? VESmoothSeek: VEAccurateSeek  completionHandler:completionHandler];
}

- (NSTimeInterval)updateVideoDuration
{
    NSTimeInterval duration = 0;
    duration = [self.veVideoData maxTrackDuration];
    return duration;
}

- (void)updateCurVideoDataWithCompleteBlock:(void (^)(NSError *_Nullable error))completeBlock
{
    @weakify(self);
    [self.nle updateVideoData:self.veVideoData completeBlock:^(NSError * _Nullable error) {
        @strongify(self);
        [self notifyUpdateVideoDataEvent];
        if (completeBlock) {
            completeBlock(error);
        }
    }];
}

- (void)updateSpeedWithAsset:(AVAsset *)asset
                     ToScale:(CGFloat)speed
{
    self.veVideoData.videoTimeScaleInfo[asset] = @(2.0); // 2倍速率播放
    self.veVideoData.videoCurves[asset] = nil; // 关闭曲线变速
    self.veVideoData.maxTrackDuration = [self.veVideoData totalVideoDuration]; // 更新maxtack
    [self updateCurVideoDataWithCompleteBlock:nil];
}

- (void)playFrom:(CMTime)start
        duration:(NSTimeInterval)lenth
   completeBlock:(dispatch_block_t)completeBlock
{
    @weakify(self);
    [self.nle seekToTime:start completionHandler:^(BOOL finished) {
        if (finished) {
            @strongify(self);
            [self.nle start];
            self.needPausePlayerTime = CMTimeGetSeconds(start) + lenth;
        } else {
            [DVECustomerHUD showMessage:@"seek失败"];
        }
    }];
}

- (void)notifyUpdateVideoDataEvent
{
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        [self.updateVideoDataBlocks enumerateObjectsUsingBlock:^(void (^ _Nonnull obj)(void), NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj) {
                obj();
            }
        }];
    });
}

- (void)notifyTimeChangeEvent
{
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        [self.playerTimeChangeBlocks enumerateObjectsUsingBlock:^(void (^ _Nonnull obj)(void), NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj) {
                obj();
            }
        }];
    });
}

- (void)notifyStatuesEvent
{
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        [self.statuseChangeBlocks enumerateObjectsUsingBlock:^(void (^ _Nonnull obj)(void), NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj) {
                obj();
            }
        }];
    });
}

#pragma mark - Setter

- (void)setPlayerTimerBlock:(void (^)(CGFloat))playerTimerBlock
{
    _playerTimerBlock = playerTimerBlock;
}

- (void)setPlayerCompleteBlock:(dispatch_block_t)playerCompleteBlock
{
    _playerCompleteBlock = playerCompleteBlock;
    [self.nle setMixPlayerCompleteBlock:self.playerCompleteBlock];
}

- (void)setVideoDataChangBlock:(nonnull dispatch_block_t)videoDataChangBlock
{
    if (![self.updateVideoDataBlocks containsObject:videoDataChangBlock]) {
        [self.updateVideoDataBlocks addObject:videoDataChangBlock];
    }
}

- (void)setPlayerTimeChangBlock:(dispatch_block_t)block
{
    if (![self.playerTimeChangeBlocks containsObject:block]) {
        [self.playerTimeChangeBlocks addObject:block];
    }
}

- (void)setPlayerStatuseChangBlock:(dispatch_block_t)block
{
    if (![self.statuseChangeBlocks containsObject:block]) {
        [self.statuseChangeBlocks addObject:block];
    }
}

#pragma mark - Getter

- (HTSVideoData *)veVideoData
{
    return self.nle.veVideoData;
}

@end
