//
//  DVEAlbumVideoPreviewController.m
//  CutSameIF
//
//  Created by bytedance on 2020/7/21.
//

#import "DVEAlbumVideoPreviewController.h"
#import "DVEAlbumAssetModel.h"
#import "DVEAlbumDefinition.h"
#import <KVOController/KVOController.h>
#import "DVEAlbumMacros.h"
#import "UIDevice+DVEAlbumHardware.h"
#import "DVEAlbumLanguageProtocol.h"
#import "DVEAlbumZoomTransition.h"

@interface DVEAlbumVideoPreviewController () <DVEAlbumZoomTransitionInnerContextProvider, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImage *coverImage;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) DVEAlbumAssetModel *assetModel;
@property (nonatomic, strong) NSValue *videoSize;

@end

@implementation DVEAlbumVideoPreviewController

- (instancetype)initWithAssetModel:(DVEAlbumAssetModel *)assetModel coverImage:(UIImage *)image
{
    if (self = [super init]) {
        self.assetModel = assetModel;
        self.coverImage = image;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];

    self.videoSize = @(CGSizeMake(self.assetModel.asset.pixelWidth, self.assetModel.asset.pixelHeight));
    
    if (self.coverImage) {
        self.coverImageView = [[UIImageView alloc] initWithImage:self.coverImage];
        self.coverImageView.frame = [self playerFrame];
        [self.view addSubview:self.coverImageView];
    }
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSelf)];
    tapGes.delegate = self;
    [self.view addGestureRecognizer:tapGes];
    
    [self selectAsset:self.assetModel progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        
    } completion:^(AVAsset *videoAsset, NSError *error) {
        if (error){
            return;
        }
            
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[videoAsset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
                AVAssetTrack *firstTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo][0];
                CGSize dimensions = CGSizeApplyAffineTransform(firstTrack.naturalSize, firstTrack.preferredTransform);
                self.videoSize = @(CGSizeMake(fabs(dimensions.width), fabs(dimensions.height)));
            }
            
            self.avPlayer = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:videoAsset]];
            self.avPlayer.currentItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmSpectral;
            
            AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
            self.playerLayer = layer;
            
            layer.frame =  [self playerFrame];
            [self.view.layer addSublayer:layer];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runLoopTheMovie:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.avPlayer.currentItem];
            
            @weakify(self);
            [self.KVOController observe:self.avPlayer
                                keyPath:NSStringFromSelector(@selector(status))
                                options:NSKeyValueObservingOptionNew
                                  block:^(typeof(self) _Nullable observer, id object, NSDictionary *change) {
                                      @strongify(self);
                                      AVPlayerStatus newStatus = [change[NSKeyValueChangeNewKey] integerValue];
                                      if (newStatus == AVPlayerStatusReadyToPlay) {
                                          if (self.coverImageView) {
                                              [self.coverImageView removeFromSuperview];
                                              self.coverImageView = nil;
                                          }

                                          [self.avPlayer seekToTime:kCMTimeZero];
                                          [self.avPlayer play];
                                      }
                                  }];
            [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                              object:nil
                                                               queue:[NSOperationQueue mainQueue]
                                                          usingBlock:^(NSNotification * _Nonnull note) {
                                                              @strongify(self);
                                                              [self.avPlayer play];
                                                          }];
            [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
                                                              object:nil
                                                               queue:[NSOperationQueue mainQueue]
                                                          usingBlock:^(NSNotification * _Nonnull note) {
                                                              @strongify(self);
                                                              [self.avPlayer pause];
                                                          }];
        });
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.avPlayer pause];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.avPlayer play];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.avPlayer = nil;
}

- (void)runLoopTheMovie:(NSNotification *)notification
{
    [self.avPlayer seekToTime:kCMTimeZero];
    [self.avPlayer play];
}

- (CGRect)playerFrame
{
    CGRect playerFrame = self.view.bounds;
    NSValue * sizeOfVideoValue = self.videoSize;
    if (sizeOfVideoValue) {
        CGSize sizeOfVideo = [sizeOfVideoValue CGSizeValue];
        CGSize sizeOfScreen = [UIScreen mainScreen].bounds.size;
        
        CGFloat videoScale = sizeOfVideo.width / sizeOfVideo.height;
        CGFloat screenScale = sizeOfScreen.width / sizeOfScreen.height;
        
        CGFloat playerWidth = 0;
        CGFloat playerHeight = 0;
        CGFloat playerX = 0;
        CGFloat playerY = 0;
        
        if ([UIDevice acc_isIPhoneX]) {
            if (videoScale > 9.0 / 16.0) {//两边不裁剪
                playerFrame = AVMakeRectWithAspectRatioInsideRect(sizeOfVideo, self.view.bounds);
            } else if (videoScale > screenScale) {//按高度
                playerHeight = self.view.frame.size.height;
                playerWidth = playerHeight * videoScale;
                playerY = 0;
                playerX = - (playerWidth - self.view.frame.size.width) * 0.5;
                playerFrame = CGRectMake(playerX, playerY, playerWidth, playerHeight);
            } else {//按宽度
                playerWidth = self.view.frame.size.width;
                playerHeight = playerWidth / videoScale;
                playerX = 0;
                playerY = - (playerHeight - self.view.frame.size.height) * 0.5;
                playerFrame = CGRectMake(playerX, playerY, playerWidth, playerHeight);
            }
        } else {
            //不是iphoneX全使用fit方式
            playerFrame = AVMakeRectWithAspectRatioInsideRect(sizeOfVideo, self.view.bounds);
        }
    }
    
    return playerFrame;
}

- (void)selectAsset:(DVEAlbumAssetModel *)assetModel progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^) (AVAsset *, NSError *))completion
{
    NSParameterAssert(completion);
    PHVideoRequestOptions *options = nil;
    if (@available(iOS 14.0, *)) {
        options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    }
    
    PHAsset *sourceAsset = assetModel.asset;
    [[PHImageManager defaultManager] requestAVAssetForVideo:sourceAsset
                                                    options:options
                                              resultHandler:^(AVAsset *_Nullable asset, AVAudioMix *_Nullable audioMix, NSDictionary *_Nullable info) {
                                                  
                                                  BOOL isICloud = [info[PHImageResultIsInCloudKey] boolValue];
                                                  if (isICloud && !asset) {
                                                      PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                                                      options.networkAccessAllowed = YES;
                                                      //progress
                                                      options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              if (progressHandler) {
                                                                  progressHandler(progress, error, stop, info);
                                                              }
                                                          });
                                                      };
                                                      if (@available(iOS 14.0, *)) {
                                                          options.version = PHVideoRequestOptionsVersionCurrent;
                                                          options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
                                                      }
                                                      
                                                      [[PHImageManager defaultManager] requestAVAssetForVideo:sourceAsset
                                                                                                      options:options
                                                                                                resultHandler:^(AVAsset *_Nullable asset, AVAudioMix *_Nullable audioMix,
                                                                                                                NSDictionary *_Nullable info) {
                                                                                                }];
                                                      
                                                      NSError *error = [NSError errorWithDomain:kDVEAlbumErrorDomain
                                                                                           code:SCIFAlbumErrorCodeRemoteResource
                                                                                       userInfo:@{NSLocalizedDescriptionKey:TOCLocalizedString(@"com_mig_the_video_is_being_synced_to_icloud_try_again_later", @"该视频正在从iCloud同步，请稍后再试")}];
                                                      completion(nil, error);
                                                  } else {
                                                      if (asset) {
                                                          completion(asset, nil);
                                                      } else {
                                                          NSError *error = [NSError errorWithDomain:kDVEAlbumErrorDomain
                                                                                               code:SCIFAlbumErrorCodeNullResource
                                                                                           userInfo:@{NSLocalizedDescriptionKey:TOCLocalizedString(@"com_mig_resource_error", @"资源错误")}];
                                                          completion(nil, error);
                                                      }
                                                  }
                                              }];
}

- (void)closeSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - DVEAlbumZoomTransitionInnerContextProvider

- (DVEAlbumTransitionTriggerDirection)zoomTransitionAllowedTriggerDirection
{
    return DVEAlbumTransitionTriggerDirectionAny;
}

- (NSInteger)zoomTransitionItemOffset
{
    return self.assetModel.cellIndex;
}


@end
