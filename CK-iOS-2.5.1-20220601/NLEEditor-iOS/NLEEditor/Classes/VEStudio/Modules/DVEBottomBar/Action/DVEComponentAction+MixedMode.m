//
//   DVEComponentAction+MixedMode.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/27.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEComponentAction+MixedMode.h"
#import "DVEComponentAction+Private.h"
#import "DVEMixedEffectBar.h"
#import "DVEComponentViewManager.h"

@implementation DVEComponentAction (MixedMode)

-(void)openMixedMode:(id<DVEBarComponentProtocol>)component
{
    DVEMixedEffectBar* barView = [[DVEMixedEffectBar alloc] initWithFrame:CGRectMake(0, VE_SCREEN_HEIGHT - 280, VE_SCREEN_WIDTH, 280)];
    [self showActionView:barView];
}

-(NSNumber*)showMixedModeCompoment:(id<DVEBarComponentProtocol>)component
{
    NLEModel_OC* model = self.nleEditor.nleModel;
    for (NLETrack_OC *track in [model getTracks]) {
        if (track.extraTrackType == NLETrackVIDEO && !track.isMainTrack) {//存在画中画才展示“混合模式”
            NLETrackSlot_OC* slot = [self.vcContext.mediaContext currentMainVideoSlotWithAudio];
            NLETrack_OC* currentTrack = [model trackContainSlotId:slot.nle_nodeId];
            return currentTrack.isMainTrack ? @(DVEBarComponentViewStatusDisable) : @(DVEBarComponentViewStatusNormal);//如果当前选择主轨则置灰按钮
        }
    }
    return @(DVEBarComponentViewStatusHidden);
}

@end
