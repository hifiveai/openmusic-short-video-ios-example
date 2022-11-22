//
//   DVEComponentAction+Text.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/27.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEComponentAction+Text.h"
#import "DVEComponentAction+Private.h"
#import "DVETextBar.h"
#import "DVEReportUtils.h"
#import "DVECustomerHUD.h"
#import "DVETextTemplateBar.h"
#import "DVETextTemplateInputManager.h"
#if ENABLE_SUBTITLERECOGNIZE
#import "DVETextReaderSoundEffectsSelectionBar.h"
#import "DVEAIRecognitionAlertController.h"
#endif

@implementation DVEComponentAction (Text)

-(void)textComponentOpen:(id<DVEBarComponentProtocol>)component
{
    self.vcContext.mediaContext.multipleTrackType = DVEMultipleTrackTypeTextSticker;
    [self.parentVC showEditStickerViewWithType:VEVCStickerEditTypeText];
    [self openSubComponent:component];
}

-(void)textComponentClose:(id<DVEBarComponentProtocol>)component
{
    ///防止外部监听mediaContext信号重复触发action，需要加标志
    self.vcContext.mediaContext.selectTextSlot = nil;
    ///如果是文本编辑态，则先切回回添加态面板
    if(component.currentSubGroup == DVEBarSubComponentGroupEdit){
        [[DVEComponentViewManager sharedManager] showComponentType:DVEBarComponentTypeText groupTpye:DVEBarSubComponentGroupAdd];
    }else{
        [self.parentVC.stickerEditAdatper hideFromPreview];
        [self openParentComponent:component];
    }
    [self hideMultipleTrackIfNeed];
}


-(void)openText:(id<DVEBarComponentProtocol>)component
{
    [self showText:nil];
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeTextAdd];
}

#if ENABLE_SUBTITLERECOGNIZE
-(void)openRecognition:(id<DVEBarComponentProtocol>)component
{
    DVEAIRecognitionAlertController *alert = [[DVEAIRecognitionAlertController alloc] init];
    alert.modalPresentationStyle = UIModalPresentationCustom;
    alert.vcContext = self.vcContext;
    [self.parentVC presentViewController:alert animated:NO completion:nil];
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeTextRecognize];
}


-(void)openTextReader:(id<DVEBarComponentProtocol>)component
{
    CGFloat H = 80 + 40 + VEBottomMargn;
    CGFloat Y = VE_SCREEN_HEIGHT - H;
    DVETextReaderSoundEffectsSelectionBar* barView = [[DVETextReaderSoundEffectsSelectionBar alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
    [self showActionView:barView];
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeTextReader];
}

#endif

-(void)editText:(id<DVEBarComponentProtocol>)component
{
    DVELogInfo(@"edit one text track ");
    
    NSString *segmentId = [self textTemplateSegmentId];
    if(segmentId){
        [self editTextTemplate];
        return;
    }
    
    segmentId = [self textSegmentId];
    if(!segmentId){
        return;
    }
    
    [self.parentVC.stickerEditAdatper activeEditBox:segmentId];
    [self showText:segmentId];
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeTextEdit];
}

-(void)splitText:(id<DVEBarComponentProtocol>)component
{
    NSString *newSegId = [self splitSlot];
    if (!newSegId) {
        return;
    }
    
    [self.parentVC.stickerEditAdatper addEditBoxForSticker:newSegId];
}

-(void)copyText:(id<DVEBarComponentProtocol>)component
{
    
    NSString *newSegId = [self textTemplateSegmentId];
    if(newSegId){
        [self copyTextTemplate];
        return;
    }
    
    newSegId = [self copyTextSlot];
    
    [self.parentVC.stickerEditAdatper addEditBoxForSticker:newSegId];
}

-(void)deleteText:(id<DVEBarComponentProtocol>)component
{
    DVELogInfo(@"delet one text track ");
    
    NSString *segmentId = [self textTemplateSegmentId];
    if(segmentId){
        [self deleteTextTemplate];
        return;
    }
    
    segmentId = [self textSegmentId];
    if(!segmentId)return;

    [self.parentVC.stickerEditAdatper removeStickerBox:[self textSegmentId]];
    
    [self deleteSlot];
 
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeTextDelete];
}

-(void)showText:(NSString*)segmentId
{
    CGFloat H = 291 + 153 - VEBottomMargnValue + VEBottomMargn;
    CGFloat Y = VE_SCREEN_HEIGHT - H;
    DVETextBar* barView = [[DVETextBar alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
    barView.vcContext = self.vcContext;
    barView.segmentId = segmentId;
    [self showActionView:barView];
}

- (NSString *)splitSlot
{
    DVELogInfo(@"split slot");
    NLETrackSlot_OC *slot = self.vcContext.mediaContext.selectTextSlot;
    
    BOOL res = [self canSplitWithSlot:slot];
    if (!res) {
        [DVECustomerHUD showMessage:NLELocalizedString(@"ck_tips_current_position_split_fail", @"当前位置不可拆分") afterDele:1];
        return nil;
    }
    
    NLETrackSlot_OC *newSlot = [self.slotEditor splitForSlot:slot];

    return newSlot.nle_nodeId;
}

- (NSString *)copyTextSlot
{
    DVELogInfo(@"copy slot ");
    
    NSString *segmentId = [self textSegmentId];
    if(!segmentId){
        return nil;
    }

    NLETrackSlot_OC *newSlot = [self.slotEditor copyForSlot:segmentId needCommit:YES];

    return newSlot.nle_nodeId;
}

- (BOOL)deleteSlot
{
    DVELogInfo(@"delet slot ");
    NSString *segmentId = [self textSegmentId];
    if(!segmentId) return NO;

    [self.slotEditor removeSlot:segmentId needCommit:YES isMainEdit:YES];
    [self.vcContext.mediaContext seekToCurrentTime];
    return YES;
}

- (NSString *)textSegmentId
{
    NLETrackSlot_OC* slot = self.vcContext.mediaContext.selectTextSlot;
    if (slot && [slot.segment isKindOfClass:NLESegmentTextSticker_OC.class]) {
        return slot.nle_nodeId;
    }
    return nil;
}

- (BOOL)canSplitWithSlot:(NLETrackSlot_OC *)slot
{
    if (!slot) {
        return NO;
    }
    
    CGFloat start = CMTimeGetSeconds(slot.startTime);
    CGFloat end = CMTimeGetSeconds(slot.endTime);
    CGFloat current = CMTimeGetSeconds(self.vcContext.mediaContext.currentTime);
    // 是否在边界上
    BOOL onBorder = fabs(start- current) < 0.1 || fabs(current - end) < 0.1;
    
    // 是否超过范围
    BOOL outline = current < start || current > end;
    if (!onBorder && !outline) {
        return YES;
    }
    return NO;
}

#pragma mark -- TextTemplate ---

/// 一级菜单入口展示控制
-(NSNumber*)showTextTemplateStatus:(id<DVEBarComponentProtocol>)component
{
    return [self textTemplateSegmentId] == nil ?@(DVEBarComponentViewStatusHidden):@(DVEBarComponentViewStatusNormal);
}

/// 显示模板面板
-(void)openTextTemplate:(id<DVEBarComponentProtocol>)component
{
    NSString *segmentId = @"";
    [self showTextTemplate:segmentId];
}

- (void)showTextTemplate:(NSString*)segmentId
{
    CGFloat H =  214 + 50 + 40 + VEBottomMargn;
    CGFloat Y = VE_SCREEN_HEIGHT - H;

    DVETextTemplateBar* barView = [[DVETextTemplateBar alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
    [self showActionView:barView];
}

- (void)replaceTextTemplate:(id<DVEBarComponentProtocol>)component {
    [self openTextTemplate:nil];
}

- (void)copyTextTemplate {
    DVELogInfo(@"copy one text template track");
    //默认追加到在当前模板下面
    id<DVECoreTextTemplateProtocol> editor = self.textTemplateEditor;
    [editor copyTextTemplateWithIsCommit:YES];
}

- (void)editTextTemplate {
    DVELogInfo(@"edit one text template track");
    [[DVETextTemplateInputManager sharedInstance] showWithTextIndex:0
                                                             source:DVETextTemplateInputManagerSourceBottomBtn];
}

- (void)deleteTextTemplate {
    DVELogInfo(@"delete one text template track");
    NSString *segmentId = [self textTemplateSegmentId];
    if(!segmentId)return;
    [self.textTemplateEditor removeTextTemplate:segmentId isCommit:YES];
    [self.parentVC.stickerEditAdatper removeStickerBox:segmentId];
    [self.vcContext.mediaContext seekToCurrentTime];
}

-(NSString*)textTemplateSegmentId
{
    NLETrackSlot_OC* slot = self.vcContext.mediaContext.selectTextSlot;
    if (slot && [slot.segment isKindOfClass:NLESegmentTextTemplate_OC.class]) {
        return slot.nle_nodeId;
    }
    return nil;
}

@end
