//
//   DVEComponentAction+Regulate.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/27.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEComponentAction+Regulate.h"
#import "DVEComponentAction+Private.h"
#import "DVERegulateBar.h"

@implementation DVEComponentAction (Regulate)

-(void)regulateComponentOpen:(id<DVEBarComponentProtocol>)component
{
    if (!self.vcContext.mediaContext.selectMainVideoSegment && !self.vcContext.mediaContext.selectBlendVideoSegment) {
        self.vcContext.mediaContext.multipleTrackType = DVEMultipleTrackTypeGlobalAdjust;
        [self openSubComponent:component];
    } else {
        [self openRegulate:component];
    }
}

-(void)regulateComponentClose:(id<DVEBarComponentProtocol>)component
{
    if(component.currentSubGroup == DVEBarSubComponentGroupEdit){
        [[DVEComponentViewManager sharedManager] showComponentType:DVEBarComponentTypeRegulate groupTpye:DVEBarSubComponentGroupAdd];
    }else{
        [self openParentComponent:component];
    }
    self.vcContext.mediaContext.selectFilterSegment = nil;
    [self hideMultipleTrackIfNeed];
}

-(void)openRegulate:(id<DVEBarComponentProtocol>)component
{
    [self showRegulateBar];
}

- (void)editRegulate:(id<DVEBarComponentProtocol>)component
{
    if (!self.vcContext.mediaContext.selectFilterSegment) {
        return;
    }
    [self showRegulateBar];
}

- (void)deleteRegulate:(id<DVEBarComponentProtocol>)component
{
    if (!self.vcContext.mediaContext.selectFilterSegment) {
        return;
    }
    [self.regulateEditor deleteSelectRegulateSegment];
    self.vcContext.mediaContext.selectFilterSegment = nil;
}

- (void)showRegulateBar
{
    CGFloat H = 200 - VEBottomMargnValue + VEBottomMargn;
    CGFloat Y = VE_SCREEN_HEIGHT - H;
    DVERegulateBar* barView = [[DVERegulateBar alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
    [self showActionView:barView];
}


@end
