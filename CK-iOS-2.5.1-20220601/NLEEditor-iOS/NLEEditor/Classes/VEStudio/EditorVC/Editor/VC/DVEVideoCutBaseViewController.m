//
//  DVEVideoCutBaseViewController.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEVideoCutBaseViewController.h"
#import "DVEVideoCutBaseViewController+Private.h"
#import "DVEVideoCutBaseViewController+layout.h"
#import "DVEDraftModel.h"
#import "NSString+DVEToPinYin.h"
#import "NSString+VEToImage.h"
#import "NSString+VEIEPath.h"
#import "DVEUIHelper.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEMacros.h"
#import "DVELoggerImpl.h"
#import <DVETrackKit/DVEUILayout.h>
#import "DVEReportUtils.h"
#import "DVENotification.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <DVETrackKit/DVEMediaTimelineView.h>
#import <MJExtension/MJExtension.h>

@interface DVEVideoCutBaseViewController ()

@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@end

@implementation DVEVideoCutBaseViewController

DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = false;
}

- (DVETopVideoView *)videoView
{
    if (!_videoView) {
        _videoView = [[DVETopVideoView alloc] initWithFrame:CGRectZero];
        _videoView.vcContext = self.vcContext;
    }
    return _videoView;
}

- (DVETopBar *)topBar
{
    if (!_topBar) {
        _topBar = [[DVETopBar alloc] initWithFrame:CGRectZero];
        _topBar.vcContext = self.vcContext;
        _topBar.parentVC = self;
    }
    return _topBar;
}

- (DVEMediaTimelineView *)timeLineView
{
    if (!_timeLineView) {
        _timeLineView = [[DVEMediaTimelineView alloc] initWithContext:self.vcContext.mediaContext];
    }
    return _timeLineView;
}

- (UIView *)playHead
{
    if (!_playHead) {
        _playHead = [[UIView alloc] init];
        _playHead.layer.cornerRadius = 1.0;
        _playHead.backgroundColor = [UIColor whiteColor];
        _playHead.layer.shadowRadius = 3;
        _playHead.layer.shadowOpacity = 0.5;
        _playHead.layer.shadowOffset = CGSizeZero;
        _playHead.layer.shadowColor = [UIColor blackColor].CGColor;
    }
    return _playHead;
}

- (UIButton *)addButton
{
    if (!_addButton) {
        CGSize size = [DVEUILayout dve_sizeWithName:DVEUILayoutVideoAddButtonSize];
        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        [_addButton setImage:@"icon_vevc_addresource".dve_toImage forState:UIControlStateNormal];
    }
    return _addButton;
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        CGSize size = [DVEUILayout dve_sizeWithName:DVEUILayoutTopBarCloseButtonSize];
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        _closeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_closeButton setImage:@"icon_close".dve_toImage forState:UIControlStateNormal];
        @weakify(self);
        [[_closeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self closeMethod];
        }];
    }
    return _closeButton;
}
- (void)saveDraft
{
    id<DVECoreDraftServiceProtocol> draftService = DVEAutoInline(self.vcContext.serviceProvider, DVECoreDraftServiceProtocol);
    DVEDraftModel *draftModel = draftService.draftModel;
    
    [draftService saveDraftModel:draftModel];
}

- (void)releaseResouce
{
    
}

@end
