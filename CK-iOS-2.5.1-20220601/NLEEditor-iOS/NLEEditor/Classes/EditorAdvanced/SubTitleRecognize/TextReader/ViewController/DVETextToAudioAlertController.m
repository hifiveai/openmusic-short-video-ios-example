//
//  DVETextToAudioAlertController.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/27.
//

#import "DVETextToAudioAlertController.h"
#import "DVESubtitleAlertView.h"
#import "DVEMacros.h"
#import "DVEVCContext.h"
#import "DVECustomerHUD.h"
#import "DVETextReaderServiceImpl.h"
#import <DVETrackKit/UIView+VEExt.h>
#import <Masonry/Masonry.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface DVETextToAudioAlertController ()<DVETextReaderServiceDelegate>

@property (nonatomic, strong) DVESubtitleAlertView *alertView;
@property (nonatomic, strong) id<DVETextReaderServiceProtocol> textReaderService;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@end

@implementation DVETextToAudioAlertController

DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

@synthesize alertView = _alertView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (BOOL)clearExistSubtitleSelected
{
    return self.alertView.clearSubtitleButton.selected;
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

#pragma mark - Private

- (void)setupUI
{
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    self.alertView = [[DVESubtitleAlertView alloc] init];
    self.alertView.titleLabel.text = @"文本朗读";
    self.alertView.clearSubtitleButton.titleLabel.text = @"同时替换原朗读音频";
    [self.alertView.confirmButton setTitle:@"开始朗读" forState:UIControlStateNormal];
    [self.view addSubview:self.alertView];
    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.alertView.superview);
        make.left.right.equalTo(self.view).inset(47);
    }];
    
    [self.alertView.cancelButton addTarget:self action:@selector(handleCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.alertView.confirmButton addTarget:self action:@selector(handleConfirm) forControlEvents:UIControlEventTouchUpInside];
    [self.alertView.clearSubtitleButton addTarget:self action:@selector(handleClearSubtitle) forControlEvents:UIControlEventTouchUpInside];
}

- (DVESubtitleAlertView *)alertView
{
    if(!_alertView) {
        _alertView = [[DVESubtitleAlertView alloc] init];
        _alertView.titleLabel.text = @"文本朗读";
        _alertView.clearSubtitleButton.titleLabel.text = @"同时替换原朗读音频";
        [_alertView.confirmButton setTitle:@"开始朗读" forState:UIControlStateNormal];
        [self.view addSubview:_alertView];
        [_alertView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.left.right.equalTo(self.view).inset(47);
        }];
        
        [_alertView.cancelButton addTarget:self action:@selector(handleCancel) forControlEvents:UIControlEventTouchUpInside];
        [_alertView.confirmButton addTarget:self action:@selector(handleConfirm) forControlEvents:UIControlEventTouchUpInside];
        [_alertView.clearSubtitleButton addTarget:self action:@selector(handleClearSubtitle) forControlEvents:UIControlEventTouchUpInside];
    }
    return _alertView;
}

- (void)setAlertView:(DVESubtitleAlertView *)alertView
{
    if(alertView == _alertView) return;
    
    [_alertView removeFromSuperview];
    _alertView = alertView;
    if(_alertView != nil){
        [self.view addSubview:_alertView];
        [_alertView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.left.right.equalTo(self.view).inset(47);
        }];
    }
}

#pragma mark - Action

- (void)handleCancel
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)handleConfirm
{
    if (!self.textReaderModel) {
        return;
    }
    [self showLoading];
    NLESegmentTextSticker_OC *textSegment = nil;
    NLETrackSlot_OC *textSlot = self.vcContext.mediaContext.selectTextSlot;
    if ([textSlot.segment isKindOfClass:NLESegmentTextSticker_OC.class]) {
        textSegment = (NLESegmentTextSticker_OC *)textSlot.segment;
    }
    
    if (textSegment.content.length > 0) {
        if (!self.textReaderService) {
            self.textReaderService = DVEAutoInline(self.vcContext.serviceProvider, DVETextReaderServiceProtocol);
            if(self.textReaderService == nil){
                self.textReaderService = [DVETextReaderServiceImpl new];
            }
            self.textReaderService.delegate = self;
        }
        [self.textReaderService beginDownloadVoice:@[textSegment.content] voiceInfo:self.textReaderModel];
        self.alertView = nil;
        self.view.backgroundColor = [UIColor clearColor];
    }
}

- (MBProgressHUD *)hud
{
    if(!_hud) {
        UIView *view = [UIView currentWindow];
        _hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        _hud.mode = MBProgressHUDModeText;
    }
    return _hud;
}


- (void)handleClearSubtitle
{
    self.alertView.clearSubtitleButton.selected = !self.alertView.clearSubtitleButton.isSelected;
}

- (void)showLoading
{
    self.hud.label.text = @"音频下载中...";
}

- (void)showMessage:(NSString*)mesage
{
    self.hud.label.text = mesage;
    [self.hud hideAnimated:YES afterDelay:1.5f];
}

#pragma mark - DVETextReaderServiceDelegate

- (void)textReaderDidDownload:(NSArray<NSString *> *)audioFiles
{
    NLESegmentTextSticker_OC *textSegment = nil;
    NLETrackSlot_OC *textSlot = self.vcContext.mediaContext.selectTextSlot;
    if ([textSlot.segment isKindOfClass:NLESegmentTextSticker_OC.class]) {
        textSegment = (NLESegmentTextSticker_OC *)textSlot.segment;
    }
    
    NSURL *audioUrl = [NSURL fileURLWithPath:audioFiles.firstObject];
    [DVEAutoInline(self.vcContext.serviceProvider, DVECoreAudioProtocol) addText2AudioResource:audioUrl audioName:textSegment.content startTime:textSlot.startTime replaceOld:self.replaceOldText2Audio];
    
    @weakify(self);
    [self.vcContext.playerService updateVideoData:self.nle.videoData completeBlock:^(NSError * _Nullable error) {
        @strongify(self);
        [self.vcContext.mediaContext seekToCurrentTime];
        [self showMessage:@"音频已生成，请到音频模块查看"];
        [self handleCancel];

    }];
}

- (void)textReaderFailAnalysis:(NSError *)error
{
    [self showMessage:@"音频下载失败！"];
}


@end
