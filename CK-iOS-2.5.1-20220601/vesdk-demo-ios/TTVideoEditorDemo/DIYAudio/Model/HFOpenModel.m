//
//  HFOpenModel.m
//  HFOpenMusic
//
//  Created by 郭亮 on 2021/3/23.
//

#import "HFOpenModel.h"

@implementation HFOpenModel

@end



@implementation HFOpenChannelModel

@end


@implementation HFOpenChannelSheetModel

+ (NSDictionary *)mj_objectClassInArray{
    return @{
        @"tag" : @"HFOpenChannelSheetTagModel",
        @"music" : @"HFOpenMusicModel",
        @"cover" : @"HFOpenMusicCoverModel"
    };
}

@end


@implementation HFOpenMetaModel

@end



@implementation HFOpenChannelSheetTagModel

@end



@implementation HFOpenMusicModel

+ (NSDictionary *)mj_objectClassInArray{
    return @{
        
        @"author" : @"HFOpenMusicAuthorModel",
        @"composer": @"HFOpenMusicComposerModel",
        @"arranger": @"HFOpenMusicArrangerModel",
        @"cover": @"HFOpenMusicCoverModel",
        @"tag": @"HFOpenChannelSheetTagModel",
        @"version": @"HFOpenMusicVersionModel",
        @"artist" : @"HFOpenMusicArtistModel",
    };
}

@end


@implementation HFOpenMusicArtistModel

@end


@implementation HFOpenMusicAuthorModel

@end


@implementation HFOpenMusicComposerModel

@end


@implementation HFOpenMusicArrangerModel

@end


@implementation HFOpenMusicCoverModel

@end


@implementation HFOpenMusicVersionModel

@end

@implementation HFOpenMusicDetailInfoModel

@end
