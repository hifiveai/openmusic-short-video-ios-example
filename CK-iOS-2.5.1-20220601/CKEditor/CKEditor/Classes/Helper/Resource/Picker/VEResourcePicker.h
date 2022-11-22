//
//  VEResourcePicker.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <NLEEditor/DVEResourcePickerProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEResourcePickerModel :NSObject<DVEResourcePickerModel>

@property (nonatomic, assign) DVEResourcePickerModelType type;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) AVURLAsset *videoAsset;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, strong) AVAsset *imageAsset;
@property (nonatomic, assign) CMTime imageDuration;
@property (nonatomic, assign) float videoSpeed;
@property (nonatomic, assign) BOOL isGIFImage;

- (instancetype)initWithURL:(NSURL *)videoUrl;

@end

@interface VEResourcePicker : NSObject<DVEResourcePickerProtocol>


@end

NS_ASSUME_NONNULL_END
