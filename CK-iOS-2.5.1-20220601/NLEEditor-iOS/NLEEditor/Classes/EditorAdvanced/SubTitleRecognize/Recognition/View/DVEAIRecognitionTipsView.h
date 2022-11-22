//
//  DVEAIRecognitionTipsView.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DVEAIRecognitionTipsView;
@class DVEVCContext;


typedef NS_ENUM(NSInteger, DVEAIRecognitionStatus) {
    DVEAIRecognitionStatusLoading,
    DVEAIRecognitionStatusSuccess,
    DVEAIRecognitionStatusFailed,
};

@interface DVEAIRecognitionTipsView : UIView

@property (nonatomic, assign) DVEAIRecognitionStatus status;

@property (nonatomic, strong) DVEVCContext* vcContext;

- (void)showAtView:(UIView *)view;

- (void)showAtView:(UIView *)view title:(NSString *)title autoDismiss:(BOOL)autoDismiss;

- (void)dismiss;

- (void)startAudioToSubtitleRecognizerWithCoverOldSubtitle:(BOOL)coverOldSubtitle;

@end

NS_ASSUME_NONNULL_END
