//
//  AWEPlaybackView.m
//  AWEStudio
//
//  Created by bytedance on 2018/6/5.
//  Copyright © 2018年 bytedance. All rights reserved.
//

#import "DVEAlbumPlaybackView.h"
#import <AVFoundation/AVFoundation.h>
#import "DVEAlbumResourceUnion.h"

@implementation DVEAlbumPlaybackView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = TOCResourceColor(TOCColorBGCreation);
        [(AVPlayerLayer *)self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    
    return self;
}

- (AVPlayer *)player
{
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player
{
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

@end
