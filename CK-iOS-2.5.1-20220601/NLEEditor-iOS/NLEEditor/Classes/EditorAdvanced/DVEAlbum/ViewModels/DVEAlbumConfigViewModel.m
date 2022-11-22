//
//  DVEAlbumConfigViewModel.m
//  CameraClient
//
//  Created by bytedance on 2020/6/22.
//

#import "DVEAlbumViewControllerProtocol.h"

@interface DVEAlbumConfigViewModel()

@end

@implementation DVEAlbumConfigViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (YES) {
#ifdef __IPHONE_14_0 //xcode12
            if (@available(iOS 14.0, *)) {
                PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
                if (status == PHAuthorizationStatusLimited) {
                    _shouldShowGoSettingStrip = YES;
                }
            }
#endif
        }
    }
    return self;
}

#pragma mark - Getter

- (BOOL)enableMixedUploadAB
{
    return [self enableAIVideoClipMode] && YES;
}

- (BOOL)enableAIVideoClipMode
{
    return YES;
}

- (BOOL)enableAllTab
{
    return YES;
}

- (BOOL)enableMutilPhotosToAIVideo
{
    return NO;
}

- (BOOL)enableNewMVPage
{
    return NO;
}

//- (BOOL)enableVELVAudioFrame
//{
//    return YES;
//}

//- (BOOL)enableMoments
//{
//    return [DVEAlbumExteranl() supportMoments];
//}

- (BOOL)showVerticalView
{
    return self.newStyle == DVEAlbumNewStyleTime || self.newStyle == DVEAlbumNewStyleTimeAndInteraction;
}

- (DVEAlbumNewStyle)newStyle
{
    return 1 % 4;
}

- (CGFloat)videoMinSeconds
{
//    id<DVEVideoConfigProtocol> config = TOCVideoConfig();
    return 0.1;
}

- (CGFloat)videoSelectableMaxSeconds
{
    
    return 60 * 60 * 2;
}

@end
