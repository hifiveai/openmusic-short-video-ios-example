//
//   DVEComponentAction+Sticker.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/27.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEComponentAction+Sticker.h"
#import "DVEComponentAction+Private.h"
#import "DVEStickerBar.h"
#import "DVEReportUtils.h"
#import "DVEStickerActionObjectBar.h"
#import "DVEComponentAction+Text.h"
#import <NLEPlatform/NLESegmentInfoSticker+iOS.h>
#import <DVETrackKit/NLEVideoFrameModel_OC+NLE.h>

@interface DVEComponentAction(Sticker) <DVEStickerActionObjectBarDelegate>



@end

@implementation DVEComponentAction (Sticker)

-(void)stickerComponentOpen:(id<DVEBarComponentProtocol>)component
{
    self.vcContext.mediaContext.multipleTrackType = DVEMultipleTrackTypeSticker;
    [self.parentVC showEditStickerViewWithType:VEVCStickerEditTypeSticker];
    [self openSubComponent:component];
}

-(void)stickerComponentClose:(id<DVEBarComponentProtocol>)component
{
    ///防止外部监听mediaContext信号重复触发action，需要加标志
    [DVEComponentViewManager sharedManager].enable = NO;
    
    self.vcContext.mediaContext.selectTextSlot = nil;
    [DVEComponentViewManager sharedManager].enable = YES;
    if(component.currentSubGroup == DVEBarSubComponentGroupEdit){
        [[DVEComponentViewManager sharedManager] showComponentType:DVEBarComponentTypeSticker groupTpye:DVEBarSubComponentGroupAdd];
    }else{
        [self.parentVC.stickerEditAdatper hideFromPreview];
        [self openParentComponent:component];
    }
    [self hideMultipleTrackIfNeed];
}


-(void)openSticker:(id<DVEBarComponentProtocol>)component
{
    CGFloat H =  253 + 50 + VEBottomMargn;
    CGFloat Y = VE_SCREEN_HEIGHT - H;
    DVEStickerBar* barView = [[DVEStickerBar alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
    [self showActionView:barView];
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeStickerAdd];
}

- (void)splitSticker:(id<DVEBarComponentProtocol>)component
{    
    NSString *newSegId = [self splitSlot];
    if (!newSegId) {
        return;
    }
        
    [self.parentVC.stickerEditAdatper addEditBoxForSticker:newSegId];
}

- (void)copySticker:(id<DVEBarComponentProtocol>)component
{
    NSString *newSegId = [self copyStickerSlot];
    if (!newSegId) {
        return;
    }
    
    [self.parentVC.stickerEditAdatper addEditBoxForSticker:newSegId];
}

- (NSString *)copyStickerSlot
{
    DVELogInfo(@"copy slot ");
    
    NSString *segmentId = [self stickerSegmentId];
    if(!segmentId){
        return nil;
    }

    NLETrackSlot_OC *newSlot = [self.slotEditor copyForSlot:segmentId needCommit:YES];

    return newSlot.nle_nodeId;
}

- (NSString *)stickerSegmentId
{
    NLETrackSlot_OC* slot = self.vcContext.mediaContext.selectTextSlot;
    if (slot && ([slot.segment isKindOfClass:NLESegmentInfoSticker_OC.class] || [slot.segment isKindOfClass:[NLESegmentImageSticker_OC class]])) {
        return slot.nle_nodeId;
    }
    return nil;
}

- (void)showAnimation
{
    CGFloat H = 204 + 50;
    CGFloat Y = VE_SCREEN_HEIGHT - H - VEBottomMargn;
    
    DVEStickerActionObjectBar *barView = [[DVEStickerActionObjectBar alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
    barView.vcContext = self.vcContext;
    barView.delegate = self;
    [self showActionView:barView];
}

- (void)deleteSticker
{
    // Need removeStickerBox before「commit」，editView will set to nil when「commit」.
    [self.parentVC.stickerEditAdatper removeStickerBox:[self stickerSegmentId]];
    
    [self deleteStickerSlot];
    [self.vcContext.mediaContext seekToCurrentTime];
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeTextDelete];
}

- (BOOL)deleteStickerSlot
{
    DVELogInfo(@"delet slot ");
    NSString *segmentId = [self stickerSegmentId];
    if(!segmentId) return NO;

    [self.slotEditor removeSlot:segmentId needCommit:YES isMainEdit:YES];
    [self.vcContext.mediaContext seekToCurrentTime];
    return YES;
}

#pragma mark DVEStickerActionObjectBarDelegate
- (void)animationDidUpdate
{
    DVEViewController *vc = (DVEViewController *) self.parentVC;

    [vc.stickerEditAdatper refreshEditBox:self.stickerSegmentId];
}

@end
