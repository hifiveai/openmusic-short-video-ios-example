//
//  DVEVideoCutBaseViewController+Private.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEVideoCutBaseViewController.h"
#import <NLEPlatform/NLEEditor+iOS.h>
#import <NLEPlatform/NLEModel+iOS.h>
#import <NLEPlatform/NLESegmentVideo+iOS.h>
#import <NLEPlatform/NLETrack+iOS.h>
#import <NLEPlatform/NLEResourceNode+iOS.h>
#import <NLEPlatform/NLETrackSlot+iOS.h>
#import <NLEPlatform/NLEResourceAV+iOS.h>
#import <DVETrackKit/DVEMediaTimelineView.h>
#import "DVETopVideoView.h"
#import "DVETopBar.h"

@class DVEDraftModel;

NS_ASSUME_NONNULL_BEGIN

@interface DVEVideoCutBaseViewController ()

@property (nonatomic, strong) DVETopVideoView *videoView;
@property (nonatomic, strong) DVETopBar *topBar;
@property (nonatomic, strong) DVEMediaTimelineView *timeLineView;
@property (nonatomic, strong) UIView *playHead;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *closeButton;

@end

NS_ASSUME_NONNULL_END
