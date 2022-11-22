//
//  DVEAudioPlayer.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "DVEAudioPlayer.h"
#import "NSString+VEIEPath.h"
#import "DVEMacros.h"
#import <AVFoundation/AVFoundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface DVEAudioPlayer ()

@end

@implementation DVEAudioPlayer

+ (instancetype)shareManager {
    static DVEAudioPlayer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:nil] init];
    });
    return instance;
}

+(id)allocWithZone:(NSZone *)zone{
    return [self shareManager];
}
-(id)copyWithZone:(NSZone *)zone{
    return [[self class] shareManager];
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return [[self class] shareManager];
}


- (instancetype)init {
    if (self = [super init]) {
        [self baseInit];
    }
    return self;
}

- (void)baseInit

{
    
}

- (void)playWithURL:(NSURL *)URL
{
    self.curURL = URL;
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:URL];
    [self.player replaceCurrentItemWithPlayerItem:item];
    [self.player play];
    [self updateTime];
}

- (void)updateTime
{
    if (self.playingBlock) {
        if (self.player.status == AVPlayerStatusReadyToPlay) {
            self.playingBlock(CMTimeGetSeconds(self.player.currentTime), CMTimeGetSeconds(self.player.currentItem.duration));
        }
        
    }
    if (CMTimeGetSeconds(self.player.currentItem.duration) - CMTimeGetSeconds(self.player.currentTime) < 0.01) {
        if (self.completBlock) {
            self.completBlock();
        }
    } else {
        [self performSelector:@selector(updateTime) withObject:nil afterDelay:0.02];
    }
    
}

- (void)pause
{
    self.curURL = nil;
    [self.player pause];
}

- (AVPlayer *)player

{
    if (!_player) {
        _player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:@""]]];
    }
    
    return _player;
}

+ (NSTimeInterval)durationWithPath:(NSString *)url
{
    AVURLAsset *audioAsset = nil;
    NSDictionary *dic = @{AVURLAssetPreferPreciseDurationAndTimingKey:@(YES)};
    if ([url hasPrefix:@"http://"]) {
        audioAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:url] options:dic];
    }else {
        audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:url] options:dic];
    }
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    return audioDurationSeconds;
}

@end
