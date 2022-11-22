//
//  DVETextToAudioAlertController.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/27.
//

#import <Foundation/Foundation.h>
#import "DVETextReaderModelProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@class DVEVCContext;

@interface DVETextToAudioAlertController : UIViewController

@property (nonatomic, strong) id<DVETextReaderModelProtocol> textReaderModel;
@property (nonatomic, assign) BOOL replaceOldText2Audio;
@property (nonatomic, assign, readonly) BOOL clearExistSubtitleSelected;
@property (nonatomic, strong) DVEVCContext* vcContext;
@end

NS_ASSUME_NONNULL_END
