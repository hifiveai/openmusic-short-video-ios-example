//
//   DVEComponentAction+Mask.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/27.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEComponentAction+Mask.h"
#import "DVEComponentAction+Private.h"
#import "DVEMaskBar.h"

@implementation DVEComponentAction (Mask)

-(void)openMask:(id<DVEBarComponentProtocol>)component
{
    CGFloat H = 270 - VEBottomMargnValue + VEBottomMargn;
    CGFloat Y = VE_SCREEN_HEIGHT - H;
    DVEMaskBar* barView = [[DVEMaskBar alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
    [self showActionView:barView];
}

@end
