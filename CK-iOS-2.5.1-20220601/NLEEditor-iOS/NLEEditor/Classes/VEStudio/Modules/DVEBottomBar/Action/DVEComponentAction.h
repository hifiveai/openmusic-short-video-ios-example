//
//   DVEComponentAction.h
//   NLEEditor
//
//   Created  by bytedance on 2021/5/26.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    
 
#import <Foundation/Foundation.h>
#import "DVEBarComponentModel.h"
#import "DVEVCContext.h"
#import "DVEViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEComponentAction : NSObject

+ (instancetype)shareManager;

/// 设置依附VC和上下文
/// @param parentVC 依附VC
/// @param context 上下文
- (void)setupParentVC:(DVEViewController *)parentVC context:(DVEVCContext *)context;


/// DVEComponentAction找不到方法处理函数
/// @param obj 参数列表
- (void)actionNotFound:(NSObject*)obj;


/// 通过方法名尝试调用DVEComponentAction的方法
/// @param method 方法名
/// @param arguments 参数列表
- (id)callMethod:(NSString*)method withArgument:(NSArray* __nullable)arguments;


/// 打开子节点
/// @param component 子节点的父节点
- (void)openSubComponent:(id<DVEBarComponentProtocol>)component;


/// 打开父节点
/// @param component 被打开父节点的节点
- (void)openParentComponent:(id<DVEBarComponentProtocol>)component;

#pragma mark - Editor

@property (nonatomic, weak, readonly) id<DVECoreVideoProtocol> videoEditor;
@property (nonatomic, weak, readonly) id<DVECoreAudioProtocol> audioEditor;
@property (nonatomic, weak, readonly) id<DVECoreTextProtocol> textEditor;
@property (nonatomic, weak, readonly) id<DVECoreTextTemplateProtocol> textTemplateEditor;
@property (nonatomic, weak, readonly) id<DVECoreEffectProtocol> effectEditor;
@property (nonatomic, weak, readonly) id<DVECoreFilterProtocol> filterEditor;
@property (nonatomic, weak, readonly) id<DVECoreStickerProtocol> stickerEditor;
@property (nonatomic, weak, readonly) id<DVECoreRegulateProtocol> regulateEditor;
@property (nonatomic, weak, readonly) id<DVECoreImportServiceProtocol> importService;
@property (nonatomic, weak, readonly) id<DVEResourcePickerProtocol> resourcePicker;
@property (nonatomic, weak, readonly) id<DVECoreSlotProtocol> slotEditor;
@property (nonatomic, weak, readonly) id<DVENLEEditorProtocol> nleEditor;

@end

NS_ASSUME_NONNULL_END
