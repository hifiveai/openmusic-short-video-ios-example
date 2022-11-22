//
//   DVEComponentAction+Audio.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/27.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEComponentAction+Audio.h"
#import "DVEComponentAction+Private.h"
#import "DVEAudioBar.h"
#import "DVEAudioSelectView.h"
#import "DVEComponentViewManager.h"
#import "DVECustomerHUD.h"
#import "DVEComponentAction+TrackView.h"
#import "DVESoundRecord.h"
#import "DVEAudioFadeInOutBar.h"
#import "DVESoundEffectSelectView.h"
#import "DVESpeedBar.h"
#import "DVEChangAudioBar.h"
#import "DVEReportUtils.h"
#import "../../../../../../../vesdk-demo-ios/TTVideoEditorDemo/DIYAudio/AddAudioViewController.h"

@implementation DVEComponentAction (Audio)

-(void)audioComponentOpen:(id<DVEBarComponentProtocol>)component
{
    self.vcContext.mediaContext.multipleTrackType = DVEMultipleTrackTypeAudio;
    [self openSubComponent:component];
}

-(void)audioComponentClose:(id<DVEBarComponentProtocol>)component
{
    ///防止外部监听mediaContext信号重复触发action，需要加标志
    [DVEComponentViewManager sharedManager].enable = NO;
    self.vcContext.mediaContext.selectAudioSegment = nil;
    [DVEComponentViewManager sharedManager].enable = YES;
    if(component.currentSubGroup == DVEBarSubComponentGroupEdit){
        [[DVEComponentViewManager sharedManager] showComponentType:DVEBarComponentTypeAudio groupTpye:DVEBarSubComponentGroupAdd];
    } else{
        [self openParentComponent:component];
    }
    [self hideMultipleTrackIfNeed];
}

-(void)addAudio:(id<DVEBarComponentProtocol>)component
{
    @weakify(self);
    UIViewController* vc = nil;
    ///如果外部有注入VC则优先展示
    if([self.resourcePicker respondsToSelector:@selector(pickAudioResourceWithCompletion:)]){
        vc = [self.resourcePicker pickAudioResourceWithCompletion:^(NSArray<id<DVEResourcePickerModel>> * _Nonnull resources, NSError * _Nullable error, BOOL cancel) {
            if(!error && resources.count > 0){
                id<DVEResourcePickerModel> model = resources.firstObject;
                @strongify(self);
                DVELogInfo(@"--------%@--in class:%@",model,self.description);
                NSString* name = nil;
                if([model respondsToSelector:@selector(resourceName)]){
                    name = [model resourceName];
                }
                NLETrackSlot_OC* slot = [self.audioEditor addAudioResource:model.URL audioName:name];
                if(slot){
                    self.vcContext.mediaContext.selectAudioSegment = slot;
                }
            }
        }];
    }
    
    if(vc != nil){
        [self.parentVC presentViewController:vc animated:YES completion:nil];
    }
    else{
        @weakify(self);
        AddAudioViewController *audioVC = [[AddAudioViewController alloc] init];
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:audioVC];
        navigation.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.parentVC presentViewController:navigation animated:YES completion:nil];
        audioVC.chooseBlock = ^(NSURL * _Nonnull filePath, NSString * _Nonnull name) {
            @strongify(self);
            NLETrackSlot_OC* slot = [self.audioEditor addAudioResource:filePath audioName:name];
            if(slot){
                self.vcContext.mediaContext.selectAudioSegment = slot;
            }
        };
        
//        [DVEAudioSelectView showAudioSelectViewInView:self.parentVC.view context:self.vcContext withSelectAudioBlock:^(id  _Nullable audio, NSString * _Nonnull audioName) {
//            @strongify(self);
//            DVELogInfo(@"--------%@--in class:%@",audio,self.description);
//            NLETrackSlot_OC* slot = [self.audioEditor addAudioResource:audio audioName:audioName];
//            if(slot){
//                self.vcContext.mediaContext.selectAudioSegment = slot;
//            }
//        }];
    }
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeAudioAdd];
}

-(void)openSound:(id<DVEBarComponentProtocol>)component
{
    NLETrackSlot_OC* slot = [self.vcContext.mediaContext currentMainVideoSlotWithAudio];
    CGFloat H = 160 - VEBottomMargnValue + VEBottomMargn;
    CGFloat Y = VE_SCREEN_HEIGHT - H;
    DVEAudioBar* barView = [[DVEAudioBar alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
    barView.editingSlot = slot;
    barView.isMainTrack = [self.vcContext.mediaContext isMainTrack:slot];
    [self showActionView:barView];
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeAudioSound];
}

-(NSNumber*)openSoundStatus:(id<DVEBarComponentProtocol>)component
{
    
    DVELogInfo(@"-----%@",[self class]);
    NLETrackSlot_OC* slot = [self.vcContext.mediaContext currentMainVideoSlotWithAudio];
    if ([slot.segment getType] == NLEResourceTypeImage) {
        return @(DVEBarComponentViewStatusDisable);
    }
    
    if ([slot.segment isKindOfClass:[NLESegmentVideo_OC class]]) {
        NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)slot.segment;
        if (segment.rewind) {
            return @(DVEBarComponentViewStatusDisable);
        }
    }
    
    return @(DVEBarComponentViewStatusNormal);
}

-(void)deleteAudio:(id<DVEBarComponentProtocol>)component
{
    DVELogInfo(@"delet one audio ");
    NSString *slotId = self.vcContext.mediaContext.selectAudioSegment.nle_nodeId;
    [self.audioEditor removeAudioSegment:slotId];
    self.vcContext.mediaContext.selectAudioSegment = nil;
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeAudioDelete];
}

-(void)addSound:(id<DVEBarComponentProtocol>)component
{
    @weakify(self);
    [DVESoundEffectSelectView showSoundEffectSelectViewInView:self.parentVC.view context:self.vcContext withSelectAudioBlock:^(id  _Nullable audio, NSString * _Nonnull audioName) {
        @strongify(self);
        DVELogInfo(@"--------%@--in class:%@",audio,self.description);
        NLETrackSlot_OC* slot = [self.audioEditor addAudioEffectResource:audio audioName:audioName];
        if(slot){
            self.vcContext.mediaContext.selectAudioSegment = slot;
        }
    }];
}

-(void)addSoundRecording:(id<DVEBarComponentProtocol>)component
{
    CGFloat H =  115 + 50 + VEBottomMargn;
    CGFloat Y = VE_SCREEN_HEIGHT - H;

    DVESoundRecord* barView = [[DVESoundRecord alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
    [self showActionView:barView];
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypeAudioRecord];
}

-(void)audioCopy:(id<DVEBarComponentProtocol>)component
{
    NLETrackSlot_OC* slot = [self.vcContext.mediaContext currentMainVideoSlotWithAudio];
    if(slot){
        NLETrackSlot_OC* newSlot = [self.audioEditor copyAudioSlot:slot];
        if(newSlot){
            self.vcContext.mediaContext.selectAudioSegment = newSlot;
            [self.vcContext.mediaContext updateTargetOffsetWithTime:newSlot.startTime];
        }
    }
}

-(void)audioSplit:(id<DVEBarComponentProtocol>)component
{
    NLETrackSlot_OC* slot = self.vcContext.mediaContext.selectAudioSegment;
    if(slot){
        if(slot.segment.getResNode.resourceType == NLEResourceTypeRecord){
            [self.audioEditor audioSplitForSlot:slot newSlotName:slot.segment.getResNode.resourceName];
        }else{
            [self.audioEditor audioSplitForSlot:slot];
        }
    }
}

-(void)audioFade:(id<DVEBarComponentProtocol>)component
{
    CGFloat H =  100 + 50 + VEBottomMargn;
    CGFloat Y = VE_SCREEN_HEIGHT - H;
    
    DVEAudioFadeInOutBar *fadeBar = [[DVEAudioFadeInOutBar alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
    
    [self showActionView:fadeBar];
}

-(void)audioEffect:(id<DVEBarComponentProtocol>)component
{
    NLETrackSlot_OC* slot = [self.vcContext.mediaContext currentMainVideoSlotWithAudio];

    NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)slot.segment;
    if (segment.rewind) {
        [DVECustomerHUD showMessage:@"倒放片段无需变声" afterDele:3];
        return;
    }
    
    CGFloat H =  100 + 50 + VEBottomMargn;
    CGFloat Y = VE_SCREEN_HEIGHT - H;
    DVEChangAudioBar *changBar = [[DVEChangAudioBar alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
    [self showActionView:changBar];
}

-(NSNumber*)audioEffectStatus:(id<DVEBarComponentProtocol>)component
{
    NLETrackSlot_OC* slot = [self.vcContext.mediaContext currentMainVideoSlotWithAudio];
    if(slot.segment.getResNode.resourceType == NLEResourceTypeRecord || ([slot.segment getType] == NLEResourceTypeVideo)) {
        return @(DVEBarComponentViewStatusNormal);
    }else{
        return @(DVEBarComponentViewStatusDisable);
    }
}

-(void)audioSpeed:(id<DVEBarComponentProtocol>)component
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

@end
