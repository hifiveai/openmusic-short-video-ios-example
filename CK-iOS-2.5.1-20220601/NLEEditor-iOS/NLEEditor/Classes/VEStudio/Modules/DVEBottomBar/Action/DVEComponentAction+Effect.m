//
//   DVEComponentAction+Effect.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/27.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEComponentAction+Effect.h"
#import "DVEComponentAction+Private.h"
#import "DVEEffectsBar.h"
#import "DVECustomerHUD.h"
#import "DVEReportUtils.h"
#import "DVEEditorEventProtocol.h"
#import "DVEEffectsActionObjectBar.h"
#import "DVEServiceLocator.h"

@implementation DVEComponentAction (Effect)

-(void)effectComponentOpen:(id<DVEBarComponentProtocol>)component
{
    self.vcContext.mediaContext.multipleTrackType = DVEMultipleTrackTypeEffect;
    [self openSubComponent:component];
}

-(void)effectComponentClose:(id<DVEBarComponentProtocol>)component
{
    ///防止外部监听mediaContext信号重复触发action，需要加标志
    [DVEComponentViewManager sharedManager].enable = NO;
    self.vcContext.mediaContext.selectEffectSegment = nil;
    [DVEComponentViewManager sharedManager].enable = YES;
    if(component.currentSubGroup == DVEBarSubComponentGroupEdit){
        [[DVEComponentViewManager sharedManager] updateCurrentBarGroupTpye:DVEBarSubComponentGroupAdd];
    }else{
        [self openParentComponent:component];
        [self hideMultipleTrackIfNeed];
    }
}


-(void)openEffect:(id<DVEBarComponentProtocol>)component
{
    CMTime exist = CMTimeSubtract(self.vcContext.mediaContext.duration,self.vcContext.mediaContext.currentTime);
    //如果最后剩下时间不足1s时长，则不允许添加特效
    if(exist.value < USEC_PER_SEC){
        [DVECustomerHUD showMessage:NLELocalizedString(@"ck_notice_cannotaddeffect", @"当前位置不可添加特效")];
    }else{
        [self showEffect];
    }
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeEffectAdd];
}

-(void)objectEffect:(id<DVEBarComponentProtocol>)component
{
    CGFloat H =  138 + 50 + VEBottomMargn;
    CGFloat Y = VE_SCREEN_HEIGHT - H;

    DVEEffectsActionObjectBar* barView = [[DVEEffectsActionObjectBar alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
    
    [self showActionView:barView];
}

-(void)replaceEffect:(id<DVEBarComponentProtocol>)component
{
    [self showEffect];
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeEffectReplace];
}

-(void)copyEffect:(id<DVEBarComponentProtocol>)component
{
    NLETimeSpaceNode_OC *timespaceNode = self.vcContext.mediaContext.selectEffectSegment;
    NLETrackSlot_OC* slot = (NLETrackSlot_OC *)timespaceNode;
    //被复制特效默认追加在当前特效后面，如果时长超出视频总时长则不允许复制
    if(CMTimeGetSeconds(self.vcContext.mediaContext.duration) < (CMTimeGetSeconds(slot.endTime) + CMTimeGetSeconds(slot.duration))){
        [DVECustomerHUD showMessage:NLELocalizedString(@"ck_tips_not_enough_spacing",@"特效与结尾间距不足，无法复制")
];
    }else{
        NSString* identifier = [self.effectEditor copySelectedEffects];
        slot = [self.effectEditor slotByeffectObjID:identifier];
        self.vcContext.mediaContext.selectEffectSegment = slot;
        [self.vcContext.mediaContext updateTargetOffsetWithTime:slot.startTime];
//        [DVECustomerHUD showMessage:@"特效复制成功" afterDele:1.0];
    }
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeEffectCopy];
}

-(void)deleteEffect:(id<DVEBarComponentProtocol>)component
{
    NLETimeSpaceNode_OC *timespaceNode = self.vcContext.mediaContext.selectEffectSegment;
    NLETrackSlot_OC* slot = (NLETrackSlot_OC *)timespaceNode;
    NLESegmentEffect_OC *seg =  (NLESegmentEffect_OC*)slot.segment;
    [self.effectEditor deleteNLEEffect:seg.effectSDKEffect.nle_nodeId needCommit:YES];
    [self.vcContext.mediaContext seekToCurrentTime];
    [[DVEComponentViewManager sharedManager] updateCurrentBarGroupTpye:DVEBarSubComponentGroupAdd];
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeEffectDelete];
}

-(void)showEffect
{
    CGFloat H =  214 + 50 + 40 + VEBottomMargn;
    CGFloat Y = VE_SCREEN_HEIGHT - H;

    DVEEffectsBar* barView = [[DVEEffectsBar alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
    [self showActionView:barView];
}


-(NSNumber*)showParentEffectComponent:(id<DVEBarComponentProtocol>)component
{
    id<DVEEditorEventProtocol> config = DVEOptionalInline(self.vcContext.serviceProvider, DVEEditorEventProtocol);
    if([config respondsToSelector:@selector(onlyUseGlobalEffect)] && [config onlyUseGlobalEffect])
    {
        return @(DVEBarComponentViewStatusHidden);
    }
    
    return @(DVEBarComponentViewStatusNormal);
}

@end
