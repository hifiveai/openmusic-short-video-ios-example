//
//   DVEComponentAction+Cut.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/27.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEComponentAction+Cut.h"
#import "DVEComponentAction+Private.h"
#import "DVECropBar.h"
#import "DVESpeedBar.h"
#import "DVECurveSpeedBar.h"
#import "DVECustomerHUD.h"
#import "DVEReportUtils.h"
#import "DVEComponentAction+TrackView.h"
#import "DVEComponentAction+MixedMode.h"
#import <NLEPlatform/NLETrackSlot+iOS.h>

@implementation DVEComponentAction (Cut)

- (void)cutComponentOpen:(id<DVEBarComponentProtocol>)component
{
    if (!self.vcContext.mediaContext.selectMainVideoSegment) {
        [DVEComponentViewManager sharedManager].enable = NO;
        self.vcContext.mediaContext.selectMainVideoSegment = self.vcContext.mediaContext.mappingTimelineVideoSegment.slot;
        [DVEComponentViewManager sharedManager].enable = YES;
    }
    
    [self openSubComponent:component];
}

- (void)blendCutComponentOpen:(id<DVEBarComponentProtocol>)component
{
    self.vcContext.mediaContext.multipleTrackType = DVEMultipleTrackTypeBlend;
    id<DVEBarComponentProtocol> target;
    for(id<DVEBarComponentProtocol> c in component.parent.subComponents){
        if(c.componentType == DVEBarComponentTypeCut){
            target = c;
            break;
        }
    }
    [self openSubComponent:target];
}

- (NSNumber*)showBlendCutComponent:(id<DVEBarComponentProtocol>)component
{
    return @(DVEBarComponentViewStatusHidden);
}

- (void)cutComponentClose:(id<DVEBarComponentProtocol>)component
{
    ///防止外部监听mediaContext信号重复触发action，需要加标志
    [DVEComponentViewManager sharedManager].enable = NO;
    self.vcContext.mediaContext.selectBlendVideoSegment = nil;
    self.vcContext.mediaContext.selectAudioSegment = nil;
    self.vcContext.mediaContext.selectMainVideoSegment = nil;
    [DVEComponentViewManager sharedManager].enable = YES;
    [self openParentComponent:component];
    [self hideMultipleTrackIfNeed];
}

- (void)openSplit:(id<DVEBarComponentProtocol>)component
{
    NLETrackSlot_OC* slot = [self.vcContext.mediaContext currentMainVideoSlotWithAudio];
    [self.videoEditor videoSplitForSlot:slot isMain:[self.vcContext.mediaContext isMainTrack:slot]];
}

- (void)cut_openFreeze:(id<DVEBarComponentProtocol>)component
{
    NLETrackSlot_OC* slot = [self.vcContext.mediaContext currentMainVideoSlotWithAudio];
    [self.videoEditor videoFreezeForSlot:slot isMain:[self.vcContext.mediaContext isMainTrack:slot]];
}

- (NSNumber *)cut_freezeStatus:(id<DVEBarComponentProtocol>)component
{
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentMainVideoSlotWithAudio];
    // 仅视频资源支持定格
    if ([slot.segment getType] == NLEResourceTypeVideo) {
        return @(DVEBarComponentViewStatusNormal);
    }

    return @(DVEBarComponentViewStatusDisable);
}

- (void)cut_replaceVideoOrImage:(id<DVEBarComponentProtocol>)component
{
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentMainVideoSlotWithAudio];

    @weakify(self);
    [self.resourcePicker pickSingleResourceWithLimitDuration:CMTimeGetSeconds(slot.duration) * 1000 completion:^(NSArray<id<DVEResourcePickerModel>> * _Nonnull resources, NSError * _Nullable error, BOOL cancel) {
        @strongify(self);
        id<DVEResourcePickerModel> model = [resources firstObject];

        DVEResourcePickerModelType type = model.type;
        if (type != DVEResourceModelPickerTypeVideo && type != DVEResourceModelPickerTypeImage) {
            [DVECustomerHUD showMessage:NLELocalizedString(@"ck_material_type_error", @"素材类型错误")];
            return;
        }

        if (error) {
            return;
        }

        [self.importService replaceResourceForSlot:slot albumResource:model];
    }];
}

- (void)cut_copyVideoOrImageSlot:(id<DVEBarComponentProtocol>)component
{
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentMainVideoSlotWithAudio];
    [self.videoEditor copyVideoOrImageSlot:slot];
}

- (void)openNormalSpeed:(id<DVEBarComponentProtocol>)component
{
    NLETrackSlot_OC* slot = [self.vcContext.mediaContext currentMainVideoSlotWithAudio];
    if(slot){
        CGFloat H = 200 - VEBottomMargnValue + VEBottomMargn;
        CGFloat Y = VE_SCREEN_HEIGHT - H;
        DVESpeedBar* barView = [[DVESpeedBar alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
        barView.editingSlot = slot;
        barView.isMainTrack = [self.vcContext.mediaContext isMainTrack:slot];
        [self showActionView:barView];
    }
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeNormalSpeed];
    
}

- (void)openCurveSpeed:(id<DVEBarComponentProtocol>)component
{
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentMainVideoSlotWithAudio];
    if (!slot)
        return;
    CGFloat H = 200 - VEBottomMargnValue + VEBottomMargn;
    CGFloat Y = VE_SCREEN_HEIGHT - H;
    DVECurveSpeedBar* barView = [[DVECurveSpeedBar alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
    barView.editingSlot = slot;
    barView.isMainTrack = [self.vcContext.mediaContext isMainTrack:slot];
    [self showActionView:barView];
}

- (void)openRotate:(id<DVEBarComponentProtocol>)component
{
    NLETrackSlot_OC* slot = [self.vcContext.mediaContext currentMainVideoSlotWithAudio];
    if(slot){
        [self.videoEditor changeVideoRotate:slot];
        [self.parentVC showCanvasBorderIfNeededEnableGesture:YES];
    }
}

- (void)openFlip:(id<DVEBarComponentProtocol>)component
{
    NLETrackSlot_OC* slot = [self.vcContext.mediaContext currentMainVideoSlotWithAudio];
    if(slot){
        [self.videoEditor changeVideoFlip:slot];
    }
}

- (void)openCrop:(id<DVEBarComponentProtocol>)component
{
    DVECropBar* barView = [[DVECropBar alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, VE_SCREEN_HEIGHT)];
    [self showActionView:barView];
}

- (void)openReverse:(id<DVEBarComponentProtocol>)component
{
    NLETrackSlot_OC* slot = [self.vcContext.mediaContext currentMainVideoSlotWithAudio];
    if(slot){
        if ([slot.segment getType] == NLEResourceTypeVideo) {
            [self.videoEditor handleVideoReverse:slot isMain:[self.vcContext.mediaContext isMainTrack:slot]];
        } else {
            [DVECustomerHUD showMessage:NLELocalizedString(@"ck_tips_only_support_video", @"只支持视频") afterDele:3];
        }
    }

}

- (void)deleteMedia:(id<DVEBarComponentProtocol>)component
{
    NLETrackSlot_OC* slot = [self.vcContext.mediaContext currentMainVideoSlotWithAudio];
    if(slot){
        [self.videoEditor deleteVideoClip:slot isMain:[self.vcContext.mediaContext isMainTrack:slot]];
    }
}

@end
