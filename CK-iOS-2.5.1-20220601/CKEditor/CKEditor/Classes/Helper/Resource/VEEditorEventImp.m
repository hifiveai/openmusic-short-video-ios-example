//
//   VEEditorEventImp.m
//   CKEditor
//
//   Created  by ByteDance on 2021/9/9.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "VEEditorEventImp.h"

@implementation VEEditorEventImp

///导出视频
- (void)editorDidExportedVideo:(UIViewController*)viewController
                        result:(BOOL)success
                      videoURL:(NSURL * _Nullable)url
                       draftID:(NSString *)draftID
{
    if (success && url) {
        UISaveVideoAtPathToSavedPhotosAlbum([url path], nil, nil, nil);
    }
    [viewController dismissViewControllerAnimated:YES completion:nil];
}


@end
