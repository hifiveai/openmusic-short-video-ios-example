//
//  DVETextReaderTask.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/27.
//

#import "DVETextReaderTask.h"

@implementation DVETextReaderTask

- (instancetype)initWithVoiceInfo:(id<DVETextReaderModelProtocol>)voiceInfo
                            texts:(NSArray<NSString *> *)texts
                             type:(DVETextReaderTaskType)type
{
    self = [super init];
    if (self) {
        _voiceInfo = voiceInfo;
        _texts = texts;
        _type = type;
    }
    return self;
}

@end
