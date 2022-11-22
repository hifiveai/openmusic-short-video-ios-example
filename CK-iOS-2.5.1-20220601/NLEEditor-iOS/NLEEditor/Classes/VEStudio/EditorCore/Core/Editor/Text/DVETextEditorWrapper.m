//
//  DVETextEditorWrapper.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/23.
//

#import "DVETextEditorWrapper.h"
#import "DVETextEditor.h"
#import "DVELoggerImpl.h"

@interface DVETextEditorWrapper ()

@property (nonatomic, strong) id<DVECoreTextProtocol> textEditor;

@end

@implementation DVETextEditorWrapper

@synthesize vcContext = _vcContext;

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if (self = [super init]) {
        _vcContext = context;
        _textEditor = [[DVETextEditor alloc] initWithContext:context];
    }
    return self;
}

#pragma mark - DVECoreTextProtocol

- (void)showAlertForReplaceTextAudio:(id<DVETextReaderModelProtocol>)textReaderModel
                             forSlot:(NLETrackSlot_OC *)slot
                    inViewController:(UIViewController *)viewController
{
    DVELogReport(@"EditorCoreFunctionCalled");
    [self.textEditor showAlertForReplaceTextAudio:textReaderModel forSlot:slot inViewController:viewController];
}

@end
