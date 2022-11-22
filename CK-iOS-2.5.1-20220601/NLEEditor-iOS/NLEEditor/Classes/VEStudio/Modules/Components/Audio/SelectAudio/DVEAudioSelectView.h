//
//  DVEAudioSelectView.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEBaseBar.h"

NS_ASSUME_NONNULL_BEGIN

@class DVEVCContext;

typedef void (^DVESelectAudioBlock)(id _Nullable audio,NSString *audioName) ;

@interface DVEAudioSelectView : DVEBaseBar

+ (DVEAudioSelectView*)showAudioSelectViewInView:(UIView *)view context:(DVEVCContext*)context withSelectAudioBlock:(DVESelectAudioBlock)selectAudioBlock;

@end

NS_ASSUME_NONNULL_END
