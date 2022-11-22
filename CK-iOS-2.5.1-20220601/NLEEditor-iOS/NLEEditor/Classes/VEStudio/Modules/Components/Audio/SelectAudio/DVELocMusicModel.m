//
//  DVELocMusicModel.m
//  NLEEditor
//
//  Created by bytedance on 2021/7/5.
//

#import "DVELocMusicModel.h"


@implementation DVELocMusicModel
@synthesize identifier;
@synthesize imageURL;
@synthesize name;
@synthesize sourcePath;
@synthesize assetImage;
@synthesize singer;
@synthesize stickerType;
@synthesize alignType;
@synthesize color;
@synthesize overlap;
@synthesize resourceTag;
@synthesize style;
@synthesize textTemplateDeps;
@synthesize typeSettingKind;



- (nonnull UIView *)actionView:(nonnull UIView *)currentView {
    return nil;
}

- (BOOL)loadWithUserInfo:(nonnull id)userInfo Handler:(nonnull void (^)(id _Nonnull))handler {
    return NO;
}

- (void)downloadModel:(nonnull void (^)(id<DVEResourceModelProtocol> _Nonnull))handler {
    
}

- (DVEResourceModelStatus)status {
    return DVEResourceModelStatusDefault;
}

@end
