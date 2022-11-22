//
//  DVETopVideoView.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEBaseView.h"
#import "DVEPreview.h"
#import "DVEVideoToolBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVETopVideoView : DVEBaseView<DVEFullScreenProtocol>

@property (nonatomic, strong) DVEPreview *preview;
@property (nonatomic, strong) DVEVideoToolBar *toolview;

- (void)updatePreviewSize;

@end

NS_ASSUME_NONNULL_END
