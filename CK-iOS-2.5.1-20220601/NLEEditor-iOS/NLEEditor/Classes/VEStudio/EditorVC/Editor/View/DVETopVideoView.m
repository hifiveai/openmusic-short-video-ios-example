//
//  DVETopVideoView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVETopVideoView.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVELoggerImpl.h"
#import <Masonry/Masonry.h>
#import "DVEPreviewViewController.h"

#define DVEPreviewToolViewHeight (46)

@interface DVETopVideoView ()

@property (nonatomic, weak) id<DVECoreCanvasProtocol> canvasEditor;

@end

@implementation DVETopVideoView

@synthesize vcContext = _vcContext;

DVEAutoInject(self.vcContext.serviceProvider, canvasEditor, DVECoreCanvasProtocol)

- (void)dealloc
{
    DVELogInfo(@"DVETopVideoView dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildLayout];
        self.backgroundColor = HEXRGBCOLOR(0x181718);
        self.toolview.delegate = self;
    }
    
    return self;
}

- (void)setVcContext:(DVEVCContext *)vcContext
{
    _vcContext = vcContext;
    self.toolview.vcContext = vcContext;
    self.preview.vcContext = vcContext;
    [DVEAutoInline(_vcContext.serviceProvider, DVECoreActionServiceProtocol) addUndoRedoListener:self];
    
    [self updatePreviewSize];

}

- (void)undoRedoClikedByUser
{
    [self updatePreviewSize];
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self updatePreviewSize];
}


- (void)updatePreviewSize
{
    if(self.height <= DVEPreviewToolViewHeight){
        self.preview.frame = CGRectZero;
    }else{
        self.preview.frame = [self.canvasEditor subViewScaleAspectFit:CGRectMake(0, 0, VE_SCREEN_WIDTH, self.height - DVEPreviewToolViewHeight)];
        [self.canvasEditor setCanvasRatio:self.canvasEditor.ratio inPreviewView:self.preview needCommit:NO];
        [self.preview refresh];
    }
}

- (void)buildLayout
{
    [self addSubview:self.preview];
    [self addSubview:self.toolview];
    [self.toolview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(DVEPreviewToolViewHeight);
    }];
}

- (DVEPreview *)preview
{
    if (!_preview) {
        _preview = [[DVEPreview alloc] initWithFrame:CGRectZero];
    }
    
    return _preview;
}

- (DVEVideoToolBar *)toolview
{
    if (!_toolview) {
        _toolview = [[DVEVideoToolBar alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, DVEPreviewToolViewHeight)];
        _toolview.parentVC = self.parentVC;
    }
    
    return _toolview;
}

#pragma mark - DVEFullScreenProtocol实现

- (void)showInFullScreen
{
    //进入全屏预览前，先将selectMainVideoSegment设置为nil
    self.vcContext.mediaContext.selectMainVideoSegment = nil;
    DVEPreviewViewController *vc = [[DVEPreviewViewController alloc] initWithContext:self.vcContext preview:self.preview isPLayed:YES parentVC:self.parentVC closeBlock:^{
        [self addSubview:self.preview];
        [self updatePreviewSize];
    }];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.parentVC presentViewController:vc animated:NO completion:^{
        
    }];
}

@end
