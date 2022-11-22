//
//  DVETextReaderTask.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/27.
//

#import <Foundation/Foundation.h>
#import "DVETextReaderModelProtocol.h"

typedef NS_ENUM(NSUInteger, DVETextReaderTaskType) {
    DVETextReaderTaskTypePlayDemo,
    DVETextReaderTaskTypeDownload,
};

NS_ASSUME_NONNULL_BEGIN

@interface DVETextReaderTask : NSObject


@property (nonatomic, strong) id<DVETextReaderModelProtocol> voiceInfo;
@property (nonatomic, copy) NSArray<NSString *> *texts;
@property (nonatomic, assign) DVETextReaderTaskType type;

- (instancetype)initWithVoiceInfo:(id<DVETextReaderModelProtocol>)voiceInfo
                            texts:(NSArray<NSString *> *)texts
                             type:(DVETextReaderTaskType)type;

@end

NS_ASSUME_NONNULL_END
