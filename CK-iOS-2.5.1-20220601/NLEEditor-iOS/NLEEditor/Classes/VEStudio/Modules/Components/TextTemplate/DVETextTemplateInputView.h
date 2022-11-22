//
//  DVETextTemplateInputView.h
//  NLEEditor
//
//  Created by bytedance on 2021/7/2.
//
//  文字模板输入文字
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVETextTemplateInputView : UIView
@property (nonatomic, readonly) UITextField *textView;
@property (nonatomic, readonly) UIButton *btn;
- (void)showWithText:(NSString *)text;
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
