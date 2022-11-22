//
//  DVEAudioPlayer.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVEAudioPlayer : NSObject

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSURL *curURL;
@property (nonatomic, copy) void(^completBlock)(void);
@property (nonatomic, copy) void(^playingBlock)(NSTimeInterval curSec,NSTimeInterval total);

+ (instancetype)shareManager;

- (void)playWithURL:(NSURL *)URL;
- (void)pause;

+ (NSTimeInterval)durationWithPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
