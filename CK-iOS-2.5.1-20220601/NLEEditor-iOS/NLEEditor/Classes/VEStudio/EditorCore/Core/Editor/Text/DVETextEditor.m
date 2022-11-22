//
//  DVETextEditor.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/28.
//

#import "DVETextEditor.h"
#if ENABLE_SUBTITLERECOGNIZE
#import "DVETextToAudioAlertController.h"
#endif
#import "DVEVCContext.h"
#import "DVEMacros.h"
#import <DVETrackKit/NLETrack_OC+NLE.h>
#import <NLEPlatform/NLETrackSlot+iOS.h>

@interface DVETextEditor()

@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;

@end

@implementation DVETextEditor

@synthesize vcContext = _vcContext;

DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if(self = [super init]) {
        self.vcContext = context;
    }
    return self;
}

- (void)showAlertForReplaceTextAudio:(id<DVETextReaderModelProtocol>)textReaderModel
                             forSlot:(NLETrackSlot_OC *)slot
                    inViewController:(UIViewController *)viewController
{
#if ENABLE_SUBTITLERECOGNIZE
    DVETextToAudioAlertController *alertVC = [[DVETextToAudioAlertController alloc] init];
    alertVC.textReaderModel = textReaderModel;
    alertVC.vcContext = self.vcContext;
    [viewController presentViewController:alertVC animated:NO completion:nil];
#endif
}

@end
