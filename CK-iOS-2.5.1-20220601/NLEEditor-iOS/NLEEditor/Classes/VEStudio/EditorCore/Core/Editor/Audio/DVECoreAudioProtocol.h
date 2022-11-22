//
//   DVECoreAudioProtocol.h
//   NLEEditor
//
//   Created  by bytedance on 2021/4/26.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVECoreProtocol.h"
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DVECoreAudioProtocol <DVECoreProtocol>

// 添加音频
- (NLETrackSlot_OC*)addAudioResource:(NSURL *)audioUrl audioName:(NSString *)audioName;

// 添加音效
- (NLETrackSlot_OC*)addAudioEffectResource:(NSURL *)audioUrl audioName:(NSString *)audioName;

/// 复制音效并添加到Track中
/// @param audioSlot 被复制音效Slot
- (NLETrackSlot_OC *)copyAudioSlot:(NLETrackSlot_OC*)audioSlot;

/// 录音片段名称
- (NSString*)recordDefaultName;

/// 已有录音数量
-(NSInteger)numberOfRecoderSlot;

/// 已录音最大数量（包括已删除）
-(NSInteger)maxRecoderNumberSlot;

// 删除一个音频
- (void)removeAudioSegment:(NSString * )segmentId;

// 拆分
/// @param slot 被拆分Slot
- (void)audioSplitForSlot:(NLETrackSlot_OC *)slot;

// 拆分
/// @param slot 被拆分Slot
/// @param newSlotName 新拆分Slot展示名称
- (void)audioSplitForSlot:(NLETrackSlot_OC *)slot newSlotName:(NSString*)newSlotName;

/// 添加文本转语音
/// @param audioUrl NSURL * 音频资源
/// @param audioName NSString * 文本名称
/// @param startTime CMTime 相对轨道开始时间
/// @param repalceOld BOOL 是否替换掉同名的文本转语音音频
- (void)addText2AudioResource:(NSURL *)audioUrl
                    audioName:(NSString *)audioName
                    startTime:(CMTime)startTime
                   replaceOld:(BOOL)repalceOld;

/// 改变音频速度
/// @param speed 音频速度
/// @param slot 音频slot
/// @param shouldKeepTone 是否保持原调
- (void)changeAudioSpeed:(CGFloat)speed slot:(NLETrackSlot_OC *)slot shouldKeepTone:(BOOL)shouldKeepTone;

/// 应用变声
/// @param slot 音频/视频Slot
/// @param sourcePath 资源路径
/// @param sourceName 资源名称
- (NSString*)audioChangeForSlot:(NLETrackSlot_OC *)slot sourcePath:(NSString*)sourcePath sourceName:(NSString*)sourceName;

/// 移除变声
/// @param slot 音频/视频Slot
- (void)removeAudioChangeForSlot:(NLETrackSlot_OC *)slot;

@end

NS_ASSUME_NONNULL_END
