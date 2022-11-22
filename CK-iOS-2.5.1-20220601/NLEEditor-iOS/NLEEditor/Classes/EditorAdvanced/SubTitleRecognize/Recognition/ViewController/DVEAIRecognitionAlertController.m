//
//  DVEAIRecognitionAlertController.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/18.
//

#import "DVEAIRecognitionAlertController.h"
#import "DVESubtitleAlertView.h"
#import "DVEMacros.h"
#import "DVEReportUtils.h"
#import "DVEVCContext.h"
#import "DVEAIRecognitionTipsView.h"
#import <Masonry/Masonry.h>

@interface DVEAIRecognitionAlertController ()

@property (nonatomic, strong) DVESubtitleAlertView *alertView;

@end

@implementation DVEAIRecognitionAlertController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (BOOL)clearExistSubtitleSelected
{
    return self.alertView.clearSubtitleButton.selected;
}

#pragma mark - Private

- (void)setupUI
{
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    self.alertView = [[DVESubtitleAlertView alloc] init];
    [self.view addSubview:self.alertView];
    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.alertView.superview);
        make.left.right.equalTo(self.view).inset(47);
    }];
    
    [self.alertView.cancelButton addTarget:self action:@selector(handleCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.alertView.confirmButton addTarget:self action:@selector(handleConfirm) forControlEvents:UIControlEventTouchUpInside];
    [self.alertView.clearSubtitleButton addTarget:self action:@selector(handleClearSubtitle) forControlEvents:UIControlEventTouchUpInside];
}

- (void)startAudioToSubtitleRecognizerWithCoverOldSubtitle:(BOOL)coverOldSubtitle
{
    DVEAIRecognitionTipsView* tipsView = [DVEAIRecognitionTipsView new];
    tipsView.vcContext = self.vcContext;
    [tipsView startAudioToSubtitleRecognizerWithCoverOldSubtitle:coverOldSubtitle];
}

#pragma mark - Action

- (void)handleCancel
{
    NSDictionary *dic = @{
        @"action":@"cancel",
        @"clear_pre_text":self.alertView.clearSubtitleButton.isSelected?@"1":@"0",
    };
    [DVEReportUtils logEvent:@"video_edit_ai_caption_click" params:dic];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)handleConfirm
{
    [self startAudioToSubtitleRecognizerWithCoverOldSubtitle:self.clearExistSubtitleSelected];
    NSDictionary *dic = @{
        @"action":@"recognize",
        @"clear_pre_text":self.alertView.clearSubtitleButton.isSelected?@"1":@"0",
    };
    [DVEReportUtils logEvent:@"video_edit_ai_caption_click" params:dic];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)handleClearSubtitle
{
    self.alertView.clearSubtitleButton.selected = !self.alertView.clearSubtitleButton.isSelected;
}


@end
