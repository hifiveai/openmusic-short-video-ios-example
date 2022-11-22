//
//  DVECoreTextTemplateProtocol.h
//  NLEEditor
//
//  Created by bytedance on 2021/6/24.
//

#import <Foundation/Foundation.h>
#import "DVECoreProtocol.h"
#import "DVETextTemplateDepResourceModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DVECoreTextTemplateProtocol <DVECoreProtocol>

@property (nonatomic, strong) NLETrackSlot_OC *trackSlot;

- (NSString *)addTemplateWithPath:(NSString *)path
                     depResModels:(NSArray<DVETextTemplateDepResourceModelProtocol> *)depResModels
                       needCommit:(BOOL)commit
                       completion:(nullable void(^)(void))completion;

- (void)setSticker:(NSString *)segmentId startTime:(CGFloat)startTime duration:(CGFloat)duration;

- (void)updateText:(NSString *)text atIndex:(NSUInteger)index isCommit:(BOOL)commit;

- (void)removeSelectedTextTemplateWithIsCommit:(BOOL)commit;

- (void)removeTextTemplate:(NSString * )segmentId isCommit:(BOOL)commit;

- (NSString *)copyTextTemplateWithIsCommit:(BOOL)commit;

- (NLETrackSlot_OC * _Nullable)slotByeffectObjID:(NSString*)effectObjID;

-(NSArray<NLETrackSlot_OC *> *)textTemplatestickerSlots;

/// 选中的模板其中的文字
- (NSArray *)selectedTexts;

/// 更新所有文字模板slot的预览模式
/// @param previewMode 预览模式 0:取消预览模式 1:预览入场动画 2:出场动画 3:循环动画 4.整个贴纸
- (void)updateAllTextTemplateSlotPreviewMode:(int)previewMode;

/// （原位置）替换模板
/// @param slot 要替换的模板Slot
/// @param startTime 原模板开始时间
/// @param endTime 原模板结束时间
/// @param path 新模板资源路径
/// @param depResModels 新模板依赖资源
/// @param commit 提交done
/// @param completion 回调
- (NSString *)replaceTemplateAtSlot:(NLETrackSlot_OC *)slot
                          startTime:(Float64)startTime
                            endTime:(Float64)endTime
                               path:(NSString *)path
                       depResModels:(NSArray<DVETextTemplateDepResourceModelProtocol> *)depResModels
                             commit:(BOOL)commit
                         completion:(nullable void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END
