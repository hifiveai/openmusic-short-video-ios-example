//
//   DVEComponentAction+PicInPic.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/27.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEComponentAction+PicInPic.h"
#import "DVEComponentAction+Private.h"
#import "DVEComponentViewManager.h"
#import "DVEMacros.h"
#import "DVEReportUtils.h"
#import "DVEComponentAction+MixedMode.h"

@implementation DVEComponentAction (PicInPic)

-(void)picInpicComponentOpen:(id<DVEBarComponentProtocol>)component
{
    self.vcContext.mediaContext.multipleTrackType = DVEMultipleTrackTypeBlend;
    [self openSubComponent:component];
}

-(void)picInpicComponentClose:(id<DVEBarComponentProtocol>)component
{
    ///防止外部监听mediaContext信号重复触发action，需要加标志
    [DVEComponentViewManager sharedManager].enable = NO;
    self.vcContext.mediaContext.selectBlendVideoSegment = nil;
    [DVEComponentViewManager sharedManager].enable = YES;
    [self openParentComponent:component];
    [self hideMultipleTrackIfNeed];
}

-(void)addPicInPic:(id<DVEBarComponentProtocol>)component
{
    @weakify(self);
    [self.resourcePicker pickSingleResourceWithCompletion:^(NSArray<id<DVEResourcePickerModel>> * _Nonnull resources, NSError * _Nullable error, BOOL cancel) {
        @strongify(self);
        if (resources.count <= 0) {
            return;
        }
        [self.importService addSubTrackResource:[resources firstObject]
                                     completion:^(NLETrackSlot_OC *slot) {
            @strongify(self);
            if (slot) {
                self.vcContext.mediaContext.selectBlendVideoSegment = slot;
            }
        }];
        if (resources.count > 0) {
            NSDictionary *dic = @{@"type": @"pip"};
            [DVEReportUtils logEvent:@"video_edit_import_complete_click" params:dic];
        }
    }];
    [DVEReportUtils logComponentClickAction:self.vcContext event:DVEVideoEditToolsCutClick actionType:DVEBarActionTypePicInPicAdd];
}

@end
