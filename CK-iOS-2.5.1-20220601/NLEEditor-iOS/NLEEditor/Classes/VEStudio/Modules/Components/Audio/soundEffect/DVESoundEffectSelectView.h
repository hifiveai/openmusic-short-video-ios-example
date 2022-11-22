//
//  DVESoundEffectSelectView.h
//  NLEEditor
//
//  Created by bytedance on 2021/7/4.
//

#import "DVEBaseBar.h"

NS_ASSUME_NONNULL_BEGIN

@class DVEVCContext;

typedef void (^DVESelectSoundEffectBlock)(id _Nullable audio,NSString *audioName) ;

@interface DVESoundEffectSelectView : DVEBaseBar

+ (DVESoundEffectSelectView*)showSoundEffectSelectViewInView:(UIView *)view context:(DVEVCContext*)context withSelectAudioBlock:(DVESelectSoundEffectBlock)selectAudioBlock;


@end

NS_ASSUME_NONNULL_END
