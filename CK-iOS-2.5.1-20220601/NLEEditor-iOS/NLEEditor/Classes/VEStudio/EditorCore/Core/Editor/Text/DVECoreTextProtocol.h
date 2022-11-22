//
//  DVECoreTextProtocol.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/28.
//

#import <Foundation/Foundation.h>
#import "DVETextReaderModelProtocol.h"
#import "DVECoreProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DVECoreTextProtocol <DVECoreProtocol>

- (void)showAlertForReplaceTextAudio:(id<DVETextReaderModelProtocol>)textReaderModel
                             forSlot:(NLETrackSlot_OC *)slot
                    inViewController:(UIViewController *)viewController;

/// 拆分文本
/// @param slot 被拆分Slot
// - (NSString*)splitTextForSlot:(NLETrackSlot_OC*)slot;

@end

NS_ASSUME_NONNULL_END
