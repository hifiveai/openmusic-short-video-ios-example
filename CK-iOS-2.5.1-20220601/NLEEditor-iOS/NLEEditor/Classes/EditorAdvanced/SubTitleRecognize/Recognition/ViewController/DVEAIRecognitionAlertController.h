//
//  DVEAIRecognitionAlertController.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DVEVCContext;

@interface DVEAIRecognitionAlertController : UIViewController

@property (nonatomic, strong) DVEVCContext* vcContext;
@property (nonatomic, assign, readonly) BOOL clearExistSubtitleSelected;

@end

NS_ASSUME_NONNULL_END
