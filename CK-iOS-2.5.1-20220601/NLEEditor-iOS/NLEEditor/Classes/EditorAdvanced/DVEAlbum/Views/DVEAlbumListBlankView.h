//
//  DVEAlbumListBlankView.h
//  AWEStudio
//
//  Created by bytedance on 2018/2/8.
//  Copyright © 2018年 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVEAlbumAnimatedButton.h"

typedef enum : NSUInteger {
    DVEAlbumListBlankViewTypeNoPermissions,
    DVEAlbumListBlankViewTypeNoVideo,
    DVEAlbumListBlankViewTypeNoPhoto,
    DVEAlbumListBlankViewTypeNoVideoAndPhoto,
} DVEAlbumListBlankViewType;

@interface DVEAlbumListBlankView : UIView

@property (nonatomic, assign) DVEAlbumListBlankViewType type;
@property (nonatomic, strong, readonly) DVEAlbumAnimatedButton *toSetupButton;
@property (nonatomic, strong) UIView *containerView;

@end
