//
//   DVEComponentAction+Canvas.m
//   NLEEditor
//
//   Created  by ByteDance on 2021/6/4.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEComponentAction+Canvas.h"
#import "DVEComponentAction+Private.h"
#import "DVECanvasBar.h"
#import "DVECanvasBackgroundBar.h"
#import "DVEComponentViewManager.h"

@implementation DVEComponentAction (Canvas)

-(void)openCanvas:(id<DVEBarComponentProtocol>)component
{
    CGFloat H = [DVEComponentViewManager sharedManager].componentViewBarHeight;
    DVECanvasBar* barView = [[DVECanvasBar alloc] initWithFrame:CGRectMake(0,VE_SCREEN_HEIGHT - H, VE_SCREEN_WIDTH, H)];
    [self showActionView:barView];
}

- (void)canvasBackgroundComponentOpen:(id<DVEBarComponentProtocol>)component {
    self.vcContext.mediaContext.enableCanvasBackgroundEdit = YES;
    [self openSubComponent:component];
}

- (void)canvasBackgroundComponentClose:(id<DVEBarComponentProtocol>)component {
    self.vcContext.mediaContext.enableCanvasBackgroundEdit = NO;
    [self openParentComponent:component];
    [self hideMultipleTrackIfNeed];
}

-(void)openCanvasBackgroundColor:(id<DVEBarComponentProtocol>)component
{
    [self openCanvasBackground:DVEModuleTypeBackgroundSubTypeCanvasColor];
}

-(void)openCanvasBackgroundStyle:(id<DVEBarComponentProtocol>)component
{
    [self openCanvasBackground:DVEModuleTypeBackgroundSubTypeCanvasStyle];
}

-(void)openCanvasBackgroundBlur:(id<DVEBarComponentProtocol>)component
{
    [self openCanvasBackground:DVEModuleTypeBackgroundSubTypeCanvasBlur];
}

-(void)openCanvasBackground:(DVEModuleTypeBackgroundSubType)type
{
    CGFloat H = 194;
    CGFloat Y = VE_SCREEN_HEIGHT - H;
    DVECanvasBackgroundBar* barView = [[DVECanvasBackgroundBar alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
    barView.canvasSubType = type;
    [self showActionView:barView];
}

@end
