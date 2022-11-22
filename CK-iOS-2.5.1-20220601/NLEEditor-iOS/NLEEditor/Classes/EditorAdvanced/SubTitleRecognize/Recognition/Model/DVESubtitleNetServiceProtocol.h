//
//  DVESubtitleNetServiceProtocol.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/18.
//

#import <Foundation/Foundation.h>
#import "DVECaptionModel.h"

typedef void (^DVESubtitleNetCompletionBlock)(DVESubtitleQueryModel* _Nullable model, NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@protocol DVESubtitleNetServiceProtocol <NSObject>

/*
*  查询字幕
*/
- (void)queryCaptionWithTaskId:(NSString *)taskId
                    completion:(DVESubtitleNetCompletionBlock)completion;

/*
*  通过 TOS 的文件 ID 来提交字幕，需要先把文件上传TOS
*/
- (void)commitAudioWithMaterialId:(NSString *)materialId
                         maxLines:(NSNumber *)maxLine
                     wordsPerLine:(NSNumber *)wordsPerLine
                       completion:(DVESubtitleNetCompletionBlock)completion;

/*
*  直接上传文件，分析
*/
- (void)commitAudioWithUrl:(NSURL *)audioUrl
                  maxLines:(NSNumber *)maxLine
              wordsPerLine:(NSNumber *)wordsPerLine
                completion:(DVESubtitleNetCompletionBlock)completion;

/*
*  反馈字幕信息
*/
- (void)feedbackCaptionWithAwemeId:(nonnull NSString *)awemeId
                            taskID:(NSString *)taskId
                               vid:(NSString *)vid
                        utterances:(NSArray *)captionsArr;

@end

NS_ASSUME_NONNULL_END
