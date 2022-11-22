//
//   DVEComponentAction+Animation.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/27.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEComponentAction+Animation.h"
#import "DVEComponentAction+Private.h"
#import "DVEAnimationBar.h"
#import "DVETransitionBar.h"
#import "DVEReportUtils.h"

@implementation DVEComponentAction (Animation)

-(void)openAnimationIn:(id<DVEBarComponentProtocol>)component
{
    [self openAnimation:DVEModuleCutSubTypeAnimationTypeAdmission];
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeAnimationIn];
}


-(void)openAnimationOut:(id<DVEBarComponentProtocol>)component
{
    [self openAnimation:DVEModuleCutSubTypeAnimationTypeDisappear];
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeAnimationOut];
}


-(void)openAnimationCombination:(id<DVEBarComponentProtocol>)component
{
    [self openAnimation:DVEModuleCutSubTypeAnimationTypeCombination];
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeAnimationCombine];
}

-(void)openAnimation:(DVEModuleCutSubTypeAnimationType)type
{
    CGFloat H = 200 + VEBottomMargn;
    CGFloat Y = VE_SCREEN_HEIGHT - H;
    
    DVEAnimationBar* barView = [[DVEAnimationBar alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
    barView.type = type;
    [self showActionView:barView];
}

-(void)openTransitionAnimation:(id<DVEBarComponentProtocol>)component slot:(NLETrackSlot_OC*)param
{
    CGFloat H = 200 + VEBottomMargn;
    CGFloat Y = VE_SCREEN_HEIGHT - H;
    
    DVETransitionBar* barView = [[DVETransitionBar alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
    
    barView.preSlot = param;
    [self showActionView:barView];
}

-(NSNumber*)showTransitionAnimation:(id<DVEBarComponentProtocol>)component
{
    return @(DVEBarComponentViewStatusHidden);
}


@end
