//
//   DVEComponentAction+Filter.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/27.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEComponentAction+Filter.h"
#import "DVEComponentAction+Private.h"
#import "DVEFilterBar.h"
#import "DVEReportUtils.h"

@implementation DVEComponentAction (Filter)

- (void)filterComponentOpen:(id<DVEBarComponentProtocol>)component
{
    if (!self.vcContext.mediaContext.selectMainVideoSegment && !self.vcContext.mediaContext.selectBlendVideoSegment) {
        self.vcContext.mediaContext.multipleTrackType = DVEMultipleTrackTypeGlobalFilter;
        [self openSubComponent:component];
    } else {
        [self openFilter:component];
    }
}

- (void)filterComponentClose:(id<DVEBarComponentProtocol>)component
{
    if(component.currentSubGroup == DVEBarSubComponentGroupEdit){
        [[DVEComponentViewManager sharedManager] showComponentType:DVEBarComponentTypeFilterGobal groupTpye:DVEBarSubComponentGroupAdd];
    }else{
        [self openParentComponent:component];
    }
    self.vcContext.mediaContext.selectFilterSegment = nil;
    [self hideMultipleTrackIfNeed];
}

- (void)openFilter:(id<DVEBarComponentProtocol>)component
{
    [self showFilterBar];
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeFilterAdd];
}

- (void)changeFilter:(id<DVEBarComponentProtocol>)component
{
    if (!self.vcContext.mediaContext.selectFilterSegment) return;
    [self showFilterBar];
}

- (void)deleteFilter:(id<DVEBarComponentProtocol>)component
{
    if (!self.vcContext.mediaContext.selectFilterSegment) return;
    [self.filterEditor deleteCurrentFilterNeedCommit:YES];
    [self.vcContext.mediaContext seekToCurrentTime];
}

- (void)showFilterBar
{
    CGFloat H = 220 - VEBottomMargnValue + VEBottomMargn;
    CGFloat Y = VE_SCREEN_HEIGHT - H;
    DVEFilterBar* barView = [[DVEFilterBar alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
    [self showActionView:barView];
}

@end
