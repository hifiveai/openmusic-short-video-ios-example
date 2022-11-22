//
//  VECapManager+Private.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//


#import <TTVideoEditor/IESMMRecoder.h>
#import <TTVideoEditor/IESMMCameraConfig.h>
#import <TTVideoEditor/HTSVideoData.h>
#import <TTVideoEditor/IESMMBaseDefine.h>

NS_ASSUME_NONNULL_BEGIN

@interface VECapManager ()

@property (nonatomic, strong) IESMMRecoder<IESMMRecoderProtocol>  *recorder;
@property (nonatomic, strong) IESMMCameraConfig *config;
@property (nonatomic, strong) HTSVideoData *boxVideoData;



@property (nonatomic, assign) CGSize pSize;
@property (nonatomic, assign) CGSize lSize;
@property (nonatomic, assign) AVCaptureSessionPreset curPreset;
@property (nonatomic, assign) IESMMCaptureRatio curRatio;



@end

NS_ASSUME_NONNULL_END
