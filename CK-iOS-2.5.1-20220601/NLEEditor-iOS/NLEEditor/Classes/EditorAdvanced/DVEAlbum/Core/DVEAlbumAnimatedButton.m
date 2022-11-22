//
//  DVEAlbumAnimatedButton.m
//  Aweme
//
//  Created by bytedance on 2017/6/8.
//  Copyright © 2017年 Bytedance. All rights reserved.
//

#import "DVEAlbumAnimatedButton.h"
#import <AVFoundation/AVFoundation.h>

@interface DVEAlbumAnimatedButton ()

@property (nonatomic, assign) DVEAlbumAnimatedButtonType type;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong, nullable) NSValue *transformBeforeAnimation;

@end

@implementation DVEAlbumAnimatedButton

- (instancetype)initWithType:(DVEAlbumAnimatedButtonType)type {
    
    return [self initWithFrame:CGRectZero type:type];
}

- (instancetype)initWithFrame:(CGRect)frame type:(DVEAlbumAnimatedButtonType)btnType {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.adjustsImageWhenHighlighted = NO;
        _type = btnType;
        _animationDuration = 0.1;
        _highlightedScale = 1.2;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    return [self initWithFrame:frame type:SCIFAnimatedButtonTypeScale];
}

- (void)setAudioURL:(NSURL *)audioURL
{
    if (_audioURL != audioURL) {
        _audioURL = audioURL;
        _player = nil;
        if (audioURL) {
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:NULL];
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    BOOL currentState = self.highlighted;
    [super setHighlighted:highlighted];
    if (highlighted) {
        if (currentState != highlighted) {
            [self.player play];
        }
        [UIView animateWithDuration:self.animationDuration animations:^{
            switch (self.type) {
                case SCIFAnimatedButtonTypeScale: {
                    CGAffineTransform initialTransform = self.transform;
                    if (self.transformBeforeAnimation == nil) {
                        self.transformBeforeAnimation = [NSValue valueWithCGAffineTransform:self.transform];
                    } else {
                        initialTransform = [self.transformBeforeAnimation CGAffineTransformValue];
                    }
                    
                    self.transform = CGAffineTransformConcat(initialTransform, CGAffineTransformMakeScale(self.highlightedScale, self.highlightedScale));
                }
                    break;
                case SCIFAnimatedButtonTypeAlpha:
                    self.alpha = 0.75;
                    break;
            }
        } completion:^(BOOL finished) {
        }];
    } else {
        [UIView animateWithDuration:self.animationDuration animations:^{
            switch (self.type) {
                case SCIFAnimatedButtonTypeScale: {
                    CGAffineTransform transform = CGAffineTransformIdentity;
                    if (self.transformBeforeAnimation != nil) {
                        transform = [self.transformBeforeAnimation CGAffineTransformValue];
                    }
                    self.transform = transform;
                }
                    break;
                case SCIFAnimatedButtonTypeAlpha:
                    self.alpha = 1.0;
                    break;
            }
        } completion:^(BOOL finished) {
            self.transformBeforeAnimation = nil;
        }];
    }
}

@end
