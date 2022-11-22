//
//  DVESpeedBar.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEBaseBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVESpeedBar : DVEBaseBar

@property(nonatomic,strong)NLETrackSlot_OC* editingSlot;
@property(nonatomic,assign)BOOL isMainTrack;

@end

NS_ASSUME_NONNULL_END
