//
//  DVETextTemplateInputManager.m
//  NLEEditor
//
//  Created by bytedance on 2021/7/9.
//

#import "DVETextTemplateInputManager.h"
// model

// mgr

// view
#import "DVETextTemplateInputView.h"
// support
#import <DVETrackKit/UIView+VEExt.h>
#import "DVELoggerImpl.h"
#import "DVEViewController.h"
#import "DVEVCContext.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface DVETextTemplateInputManager ()

@property (nonatomic, strong) DVETextTemplateInputView *textTemplateInputView;
/// 模板里文字列表的index
@property (nonatomic, assign) NSUInteger textIndex;
@property (nonatomic, assign) DVETextTemplateInputManagerSource source;

@property (nonatomic, weak) id<DVECoreTextTemplateProtocol> textTemplateEditor;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@end

@implementation DVETextTemplateInputManager

DVEAutoInject(self.vcContext.serviceProvider, textTemplateEditor, DVECoreTextTemplateProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

// MARK: - Initialization

// MARK: - Override

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

// MARK: - Public
- (void)showWithTextIndex:(NSUInteger)textIndex source:(DVETextTemplateInputManagerSource)source {
    _textIndex= textIndex;
    _source = source;
    
    NSArray *texts = [self.textTemplateEditor selectedTexts];
    if (textIndex >= texts.count) {
        return;
    }
    
    [self.parentVC.view addSubview:self.textTemplateInputView];
    [self.textTemplateInputView showWithText:texts[textIndex]];
    // 预览模板
    [self.textTemplateEditor updateAllTextTemplateSlotPreviewMode:4];
//    [self.nle setStickerPreviewMode:self.vcContext.mediaContext.selectTextSlot previewMode:4];
}

- (void)dismiss {
    if (!_textTemplateInputView) {
        return;
    }
    [self p_dismiss];
}

// MARK: - Event
- (void)textFieldDidChanged:(UITextField *)textField {
    [self p_textParmDidChange];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if (!_textTemplateInputView) {
        return;
    }
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];

    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];

    CGRect keyboardRect = [value CGRectValue];
    NSInteger height = keyboardRect.size.height + 54;
    
    _textTemplateInputView.height = height;
    _textTemplateInputView.top = self.parentVC.view.height - height;
}
// MARK: - Private

- (void)p_textParmDidChange
{
    [self.textTemplateEditor updateText:_textTemplateInputView.textView.text atIndex:_textIndex isCommit:YES];
    
    DVEViewController *vc = (DVEViewController *)self.parentVC;
    NSString *segmentId = self.vcContext.mediaContext.selectTextSlot.nle_nodeId;
    [vc.stickerEditAdatper refreshEditBox:segmentId];
}

- (void)p_dismiss {
    // 取消预览
    if (_source == DVETextTemplateInputManagerSourceBottomBtn || _source == DVETextTemplateInputManagerSourceEditBox) {
        [self.textTemplateEditor updateAllTextTemplateSlotPreviewMode:0];
//        NLETrackSlot_OC *slot = self.vcContext.mediaContext.selectTextSlot;
//        if (slot) {
//            [self.nle setStickerPreviewMode:slot previewMode:0];
//        }
    }
    [self.textTemplateInputView dismiss];
}

// MARK: - Getters and setters
- (DVETextTemplateInputView *)textTemplateInputView {
    if (!_textTemplateInputView) {
        CGFloat keybardHeight = 291;
        CGFloat h = keybardHeight + 54;
        _textTemplateInputView = [[DVETextTemplateInputView alloc] initWithFrame:CGRectMake(0, VE_SCREEN_HEIGHT-h, VE_SCREEN_WIDTH, h)];
        
        [_textTemplateInputView.textView addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
        
        @weakify(self);
        [[_textTemplateInputView.btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self p_dismiss];
        }];
    }
    return _textTemplateInputView;
}
@end

