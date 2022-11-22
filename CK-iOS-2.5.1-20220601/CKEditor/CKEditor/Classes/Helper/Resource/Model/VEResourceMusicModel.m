//
//   VEResourceMusicModel.m
//   TTVideoEditorDemo
//
//   Created  by bytedance on 2021/5/19.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "VEResourceMusicModel.h"


@implementation VEResourceMusicModel
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
@synthesize style;
@synthesize textTemplateDeps;
@synthesize typeSettingKind;
@synthesize resourceTag;

- (instancetype)init {
    
    if(self = [super init]){
        self.modelState = DVEResourceModelStatusDefault;
    }
    
    return self;
}

- (nonnull UIView *)actionView:(nonnull UIView *)currentView {
    UIView* view = nil;
    if(currentView == nil || currentView.tag != [self status]){
        if([self status] == DVEResourceModelStatusDefault){
            UIButton* useButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 27)];
            useButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [useButton setBackgroundImage:@"icon_music_done".UI_VEToImage forState:UIControlStateNormal];
            [useButton setTitle:CKEditorLocStringWithKey(@"ck_use", @"使用") forState:UIControlStateNormal];
            useButton.titleLabel.textColor = [UIColor whiteColor];
            useButton.titleLabel.font = SCRegularFont(12);
            view = useButton;
        }else if([self status] == DVEResourceModelStatusDownloding){
            UIActivityIndicatorView* act = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhite)];
            act.frame= CGRectMake(0, 0, 50, 50);
            [act startAnimating];
            view = act;
        }else{
            UIImageView* imageView = [[UIImageView alloc] initWithImage:@"icon_music_download".UI_VEToImage];
            view = imageView;
        }
        view.tag = [self status];
    }else{
        view = currentView;
    }
    return view;
}

-(BOOL)loadWithUserInfo:(id)userInfo Handler:(void(^)(id userInfo))handler{
    if([self status] == DVEResourceModelStatusNeedDownlod){
        @weakify(self);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @strongify(self);
            self.modelState = DVEResourceModelStatusDefault;
            if(handler){
                handler(userInfo);
            }
        });
        self.modelState = DVEResourceModelStatusDownloding;
        return YES;
    }
    return NO;
}

- (DVEResourceModelStatus)status {
    return self.modelState;
}

@end
