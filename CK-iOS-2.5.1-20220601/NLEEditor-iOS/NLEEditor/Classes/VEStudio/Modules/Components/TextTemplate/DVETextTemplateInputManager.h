//
//  DVETextTemplateInputManager.h
//  NLEEditor
//
//  Created by bytedance on 2021/7/9.
//
//  文字模板输入框会在多处被唤起，使用「通知」传参不方便，遂使用此类统一管理
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DVETextTemplateInputManagerSource) {
    DVETextTemplateInputManagerSourceNone,
    /// 模板cell
    DVETextTemplateInputManagerSourcePickerCell,
    /// 底部按钮
    DVETextTemplateInputManagerSourceBottomBtn,
    /// 预览区编辑框按钮
    DVETextTemplateInputManagerSourceEditBox,
};

@class DVEVCContext;
@class DVEViewController;
@interface DVETextTemplateInputManager : NSObject
@property (nonatomic, weak) DVEVCContext *vcContext;
@property (nonatomic, weak) DVEViewController *parentVC;
@property (nonatomic, readonly) DVETextTemplateInputManagerSource source;
+ (instancetype)sharedInstance;
/// 显示输入框
/// @param textIndex 文字模板多段文字列表的index
- (void)showWithTextIndex:(NSUInteger)textIndex source:(DVETextTemplateInputManagerSource)source;
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
