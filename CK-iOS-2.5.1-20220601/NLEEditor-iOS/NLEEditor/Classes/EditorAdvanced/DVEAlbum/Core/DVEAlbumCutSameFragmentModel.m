//
//  DVEAlbumCutSameFragmentModel.m
//  VideoTemplate
//
//  Created by bytedance on 2021/4/20.
//

#import "DVEAlbumCutSameFragmentModel.h"

@implementation DVEAlbumCutSameFragmentModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"videoWidth" : @"video_width",
            @"videoHeight" : @"video_height",
            @"duration" : @"duration",
            @"materialId" : @"material_id",
    };
}


@end
