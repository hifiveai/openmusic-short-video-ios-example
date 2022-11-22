//
//  DVERecognizeSentence.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/18.
//

#import "DVERecognizeSentence.h"

@implementation DVERecognizeSentence

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"text": @"text",
             @"endTime": @"end_time",
             @"startTime": @"start_time",
             @"type": @"type",
    };
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"字幕句子:%@-%@:%@", @(self.startTime), @(self.endTime), self.text];
}

@end
