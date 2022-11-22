//
//  DVEBaseBar.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEBaseBar.h"
#import "DVEModuleItem.h"
#import "NSString+DVEToPinYin.h"
#import "NSString+VEToImage.h"
#import "DVEMacros.h"
#import <DVETrackKit/UIView+VEExt.h>



@implementation DVEBaseBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = HEXRGBCOLOR(0x181718);
        [self buildBaseLayout];
    }
    
    return self;
}

- (void)buildBaseLayout
{
    [self addSubview:self.slider];
}

- (DVEStepSlider *)slider
{
    if (!_slider) {
        _slider = [[DVEStepSlider alloc] initWithStep:1 defaultValue:0 frame:CGRectMake(34, 0, VE_SCREEN_WIDTH - 68, 50)];
        _slider.hidden = YES;
    }
    
    return _slider;
}

- (void)refreshBar
{
    
}

- (void)showInView:(UIView *)view animation:(BOOL)animation
{
    if (view) {
        [view addSubview:self];
        if(animation){
            UIView* bar = self;
            CGRect targetFrame = bar.frame;
            bar.frame = CGRectMake(bar.frame.origin.x, VE_SCREEN_HEIGHT, bar.frame.size.width, bar.frame.size.height);

            [UIView animateWithDuration:DVEBaseBarAnimationDuration
                             animations:^{
                bar.frame = targetFrame;
            }];
        }
    }
}

- (void)dismiss:(BOOL)animation
{
    UIView* bar = self;
    if(animation){
        CGRect org = bar.frame;
        [UIView animateWithDuration:DVEBaseBarAnimationDuration
                         animations:^{
            bar.frame = CGRectMake(bar.frame.origin.x, VE_SCREEN_HEIGHT, bar.frame.size.width, bar.frame.size.height);
        }                completion:^(BOOL finished) {
            if(finished){
                [bar removeFromSuperview];
                bar.frame = org;
            }
        }];
    }else{
        [bar removeFromSuperview];
    }
}


@end
