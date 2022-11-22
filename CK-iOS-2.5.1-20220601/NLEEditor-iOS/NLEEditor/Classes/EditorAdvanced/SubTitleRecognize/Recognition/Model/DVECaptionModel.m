//
//  DVECaptionModel.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/18.
//

#import "DVECaptionModel.h"

@implementation DVESubtitleCommitModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
              @"videoCaption" : @"video_caption",
            };
}

+ (NSValueTransformer *)captionsJSONTransformer
{
    return [MTLJSONAdapter arrayTransformerWithModelClass:[DVESubtitleSentenceModel class]];
}

@end

@implementation DVESubtitleQueryModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
              @"captionId" : @"id",
              @"code" : @"code",
              @"message" : @"message",
              @"captions" : @"utterances",
              };
}

+ (NSValueTransformer *)captionsJSONTransformer
{
    return [MTLJSONAdapter arrayTransformerWithModelClass:[DVESubtitleSentenceModel class]];
}

@end


@implementation DVESubtitleSentenceModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
              @"text"       : @"text",
              @"startTime"  : @"start_time",
              @"endTime"    : @"end_time",
              @"words"      : @"words",
              };
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    DVESubtitleSentenceModel *model = [super copyWithZone:zone];

    model.text = [self.text copy];
    model.startTime = self.startTime;
    model.endTime = self.endTime;
    model.words = [self.words copy];

    return model;
}

- (NSString *)text
{
    if (!_text) {
        _text = @"";
    }
    return _text;
}

@end
