//
//  DVEBaseBar.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEBaseView.h"
#import "DVEStepSlider.h"
#import "DVECommonDefine.h"
#import "NSString+DVEToPinYin.h"
#import "DVEMacros.h"

NS_ASSUME_NONNULL_BEGIN

#define DVEBaseBarAnimationDuration (0.2f)


@interface DVEBaseBar : DVEBaseView

@property (nonatomic, strong) DVEStepSlider *slider;

- (void)refreshBar;

- (void)showInView:(UIView *)view animation:(BOOL)animation;

- (void)dismiss:(BOOL)animation;

@end


NS_ASSUME_NONNULL_END
