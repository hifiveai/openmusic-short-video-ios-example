//
//  VECapProtocol.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "VEBarValue.h"
#import <NLEEditor/DVEEffectValue.h>

#define kUserParmForCamare  @"kUserParmForCamare"
#define kUserParmForRatio  @"kUserParmForRatio"
#define kUserParmForReslution @"kUserParmForReslution"
#define kUserParmForTime @"kUserParmForTime"
#define kStopRecordDeviation 0.065

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VECPRecordDurationType) {
    VECPRecordDurationTypeFree = 0,
    VECPRecordDurationType15s,
    VECPRecordDurationType60s,
    VECPRecordDurationTypeDuet
    
};

typedef NS_ENUM(NSInteger, VECPBoxState) {
    VECPBoxStateIdle = 0,
    VECPBoxStateInprocess,
    
};

typedef NS_ENUM(NSInteger, VECPCameraPosion) {
    VECPCameraPosionUnknow = 0,
    VECPCameraPosionFront,
    VECPCameraPosionBack,
    
};

typedef NS_ENUM(NSInteger, VECPCurrentPreViewType) {
    VECPCurrentPreViewTypePicture = 0,
    VECPCurrentPreViewTypeRecord,
    VECPCurrentPreViewTypeDuet,
    
};

typedef NS_ENUM(NSInteger, VECPPictureStatues) {
    VECPPictureStatuesIdle = 0,
   
    
};

typedef NS_ENUM(NSInteger, VECPCaptureStatues) {
    VECPCaptureStatuesIdle = 0,
    VECPCaptureStatuesStart,
    VECPCaptureStatuesRecording,
    VECPCaptureStatuesPause,
    VECPCaptureStatuesMaxTime,
    
};

typedef NS_ENUM(NSInteger, VECPDuetStatues) {
    VECPDuetStatuesIdle = 0,
    VECPDuetStatuesStart,
    VECPDuetStatuesRecording,
    VECPDuetStatuesPause,
    VECPDuetStatuesMaxTime,
    
};

typedef NS_ENUM(NSInteger, VECPDuetLayoutType) {
    VECPDuetLayoutTypeHorizontal = 0,
    VECPDuetLayoutTypeVertical,
    VECPDuetLayoutTypeThree,
    
};

typedef void (^VECapFragmentBlock)(NSArray <AVURLAsset *>* assets);

@protocol VECapProtocol <NSObject>

@property (nonatomic, assign) BOOL disableLandscap;
@property (nonatomic, assign) UIDeviceOrientation preDeviceOrientation;

@property (nonatomic, strong) NSNumber *isVideoPreviewing;
@property (nonatomic, strong) NSNumber *isAudioPreviewing;

@property (nonatomic, copy) void (^_Nullable VECameraDurationBlock)(CGFloat duration, CGFloat totalDuration);

@property (nonatomic, assign) CGFloat recordRate;
@property (nonatomic, assign) VECPRecordDurationType durationType;
@property (nonatomic, assign) VECPBoxState boxState;

@property (nonatomic, strong) VEBarValue *capWaitTime;
@property (nonatomic, strong) VEBarValue *lightValue;

@property (nonatomic, assign) CGFloat curZoomScal;

@property (nonatomic, assign) BOOL isShowEffectBox;

@property (nonatomic, assign) VECPCurrentPreViewType currentPreviewType;
@property (nonatomic, assign) VECPDuetLayoutType currentDuetLayoutType;
@property (nonatomic, strong) NSURL *duetURL;
@property (nonatomic, assign) CGFloat duetPresent;
@property (nonatomic, assign) BOOL isDuetComplet;

@property (nonatomic, assign) BOOL isRecordComplet;

@property (nonatomic, assign) BOOL isDeviceChang;

- (AVCaptureDevicePosition)GetCurrentCameraPosition;

- (CGFloat)maxExposureBias;

- (CGFloat)minExposureBias;

- (CGFloat)exposureBias;

- (void)startPreviewWithView:(UIView *)preview;
/**
 *  @brief 切换前后摄像头
 */
- (void)switchCameraSource;

- (void)pausePreview;
- (void)resumPreview;
- (void)endPreview;



- (void)captureStillImageByUser:(BOOL)byUser
                     completion:(void (^_Nullable)(UIImage *_Nullable processedImage, NSError *_Nullable error))block;




- (void)startVideoRecordWithRate:(CGFloat)rate WithResult:(VECapFragmentBlock)block;

- (void)pauseVideoRecord;

- (void)stopVideoRecordWithVideoData:(void (^_Nullable)(id videoData, NSError *_Nullable error))completeBlock;

- (void)stopVideoRecordWithVideoFragments:(void (^_Nullable)(NSArray *videoFragments, NSError *_Nullable error))completeBlock;

/**
 *  @brief 放弃录制视频，删除所有片段
 */
- (void)cancelVideoRecord;

/**
 *  @brief 重置录制预启动
 */
- (void)resetVideoRecordReady;

- (void)removeAllVideoFragments:(dispatch_block_t _Nullable)completion;

- (void)tapAtPoint:(CGPoint)point;

- (BOOL)cameraSetZoomFactor:(CGFloat)zoomFactor;

- (BOOL)cameraRampToZoomFactor:(CGFloat)zoomFactor withRate:(CGFloat)rate;

- (CGFloat)currentCameraZoomFactor;

/**
 * @brief 滑动切换滤镜
 * @param left left-filter's resource path
 * @param right right-filter's resoruce path
 * @param progress 滑动的进度
 */
- (void)switchFilterWithLeftPath:(NSString *_Nullable)left
                       rightPath:(NSString *_Nullable)right
                        progress:(CGFloat)progress;


- (void)dealWithValue:(VEBarValue *)barValue;

- (void)setFliter:(DVEEffectValue *)evalue;

- (void)setSticker:(DVEEffectValue *)evalue;
- (void)removeSticker;

- (void)setMakeup:(DVEEffectValue *)evalue;
- (void)removeMakeup:(DVEEffectValue *)evalue;
- (void)updateMakeup:(DVEEffectValue *)evalue;

- (void)changeExposureBias:(CGFloat)bias;

- (void)addOneImageVideo:(UIImage *)image;

- (void)removeLastVideoAsset;

- (void)dismissMakeUp;

- (void)showMakeUp;

- (void)resetMakeUp;

- (void)setBeautyFaceWithArr:(NSArray <DVEEffectValue *>*)values;
- (void)setBeautyVFaceWithArr:(NSArray <DVEEffectValue *>*)values;
- (void)setBeautyBodyWithArr:(NSArray <DVEEffectValue *>*)values;
- (void)setBeautyMakeupWithArr:(NSArray <DVEEffectValue *>*)values;

- (void)resetBeautyFace;
- (void)resetBeautyVFace;
- (void)resetBeautyBody;
- (void)resetBeautyMakeUp;

- (void)closeBeautyFace;
- (void)closeBeautyVFace;
- (void)closeBeautyBody;
- (void)closeBeautyMakeUp;

- (void)exportVideoWithProgress:(void (^_Nullable )(CGFloat progress))progressBlock resultBlock:(void (^)(NSError *error,id result))exportBlock;

- (void)setDuetValue:(id<DVEResourceModelProtocol>)evalue;
- (void)setDuetURL:(NSURL *)URL;
- (void)updateDuetValue:(id<DVEResourceModelProtocol>)evalue;


@end

NS_ASSUME_NONNULL_END
