//
//   DVEComponentAction+TrackView.m
//   NLEEditor
//
//   Created  by ByteDance on 2021/6/7.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEComponentAction+Private.h"

@implementation DVEComponentAction (TrackView)


- (void)hideMultipleTrackIfNeed
{
    if ([DVEComponentViewManager sharedManager].currentBarType == DVEBarComponentTypeRoot) {
        // if has audio or pic in pic video, show all of them
        if ([self.nleEditor.nleModel nle_hasAudioOrPicInPicSegments]) {
            self.vcContext.mediaContext.multipleTrackType = DVEMultipleTrackTypeAudioAndBlend;
        } else {
            self.vcContext.mediaContext.multipleTrackType = DVEMultipleTrackTypeNone;
        }
    }
}

@end
