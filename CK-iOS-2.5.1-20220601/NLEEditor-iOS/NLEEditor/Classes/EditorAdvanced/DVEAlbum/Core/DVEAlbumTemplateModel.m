//
//  DVEAlbumTemplateModel.m
//  VideoTemplate
//
//  Created by bytedance on 2021/4/20.
//

#import "DVEAlbumTemplateModel.h"
@implementation DVEAlbumTemplateAuthor

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"uid" : @"uid",
            @"name" : @"name",
            @"avatarUrl" : @"avatar_url",
    };
}

@end
// -
@implementation DVEAlbumTemplateVideoInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"url" : @"url",
    };
}

@end
// -
@implementation DVEAlbumTemplateCoverModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"url" : @"url",
            @"width" : @"width",
            @"height" : @"height",
    };
}

@end
// -
@implementation DVEAlbumTemplateLimit


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"sdkVersionMin" : @"sdk_version_min",
            @"platform" : @"platform",
    };
}

@end

@implementation DVEAlbumCutSameTemplateModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"fragments" : @"fragments",
            @"alignMode" : @"align_mode",
    };
}

@end
// -
@implementation DVEAlbumTemplateModel


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"templateID" : @"id",
            @"shortTitle" : @"short_title",
            @"title" : @"title",
            @"author" : @"author",
            @"cover" : @"cover",
            @"limit" : @"limit",
            @"duration" : @"duration",
            @"extra" : @"extra",
            @"extraModel" : @"extra",
            @"status" : @"status",
            @"md5" : @"md5",
            @"counterData" : @"counter_data",
            @"originVideoInfo" : @"origin_video_info",
            @"videoInfo" : @"video_info",
            @"createTime" : @"create_time",
            @"fragmentCount" : @"fragment_count",
            @"templateTags" : @"template_tags",
            @"templateUrl" : @"template_url",
    };
}



#if CUTSAMEIF
+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"templateID"]) {
        return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            *success = YES;
            if ([value isKindOfClass:[NSString class]]) {
                NSInteger intVal = [value intValue];
                return [NSNumber numberWithInteger:intVal];
            } else {
                return nil;
            }
        }];
    }

    return nil;
}

#endif


- (NSString *)hintLabel {
    return [NSString stringWithFormat:@"%ld个素材", (long)self.fragmentCount];
}

- (NSUInteger)likeAmount {
    return ((NSNumber *)[self.counterData valueForKey:@"like"]).integerValue;
}

@end
