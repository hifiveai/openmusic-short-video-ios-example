//
//  DVEAlbumConfigViewModel.h
//  CameraClient
//
//  Created by bytedance on 2020/6/22.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DVEAlbumNewStyle) {
    DVEAlbumNewStyleDefault = 0,
    DVEAlbumNewStyleInteraction = 1,
    DVEAlbumNewStyleTime = 2,
    DVEAlbumNewStyleTimeAndInteraction = 3,
};

NS_ASSUME_NONNULL_BEGIN

@interface DVEAlbumConfigViewModel : NSObject

@property (nonatomic, assign, readonly) BOOL enableMixedUploadAB;   // enable photos and videos mixed upload
@property (nonatomic, assign, readonly) BOOL enableAIVideoClipMode; // enable music card point mode
@property (nonatomic, assign, readonly) BOOL enableAllTab;          // enable upload page add all tab
@property (nonatomic, assign, readonly) BOOL enableMutilPhotosToAIVideo;    // enable upload page add all tab
@property (nonatomic, assign, readonly) BOOL enableNewMVPage;       // enable new mv page
//@property (nonatomic, assign, readonly) BOOL enableVELVAudioFrame;  // enable VE LVAudioFrame
//@property (nonatomic, assign, readonly) BOOL enableMoments;         // enable moments
@property (nonatomic, assign, readonly) BOOL showVerticalView;      // show album vertical view
@property (nonatomic, assign, readonly) DVEAlbumNewStyle newStyle;  // [Douyou] album New style preview page

@property (nonatomic, assign, readonly) CGFloat videoMinSeconds;
@property (nonatomic, assign, readonly) CGFloat videoSelectableMaxSeconds;
@property (nonatomic, assign) BOOL shouldShowGoSettingStrip;

@end

NS_ASSUME_NONNULL_END
