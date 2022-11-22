//
//  DVEAudioFadeInOutBar.h
//  NLEEditor
//
//  Created by bytedance on 2021/6/28.
//

#import "DVEBaseBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEAudioFadeInOutBar : DVEBaseBar

@property(nonatomic,strong) NLETrackSlot_OC* editingSlot;
@property(nonatomic,assign) BOOL isMainTrack;

@end

NS_ASSUME_NONNULL_END
