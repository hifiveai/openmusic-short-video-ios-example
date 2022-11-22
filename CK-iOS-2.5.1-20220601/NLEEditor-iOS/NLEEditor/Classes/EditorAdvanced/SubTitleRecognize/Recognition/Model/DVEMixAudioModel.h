//
//  DVEMixAudioModel.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/18.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DVETextRecognizeAudioSourceType) {
    DVETextRecognizeAudioSourceTypeMusic,
    DVETextRecognizeAudioSourceTypeLocalMusic,
    DVETextRecognizeAudioSourceTypeVideo,
};

NS_ASSUME_NONNULL_BEGIN


@interface DVERecognizeAudioInfo : NSObject

@property (nonatomic, assign) DVETextRecognizeAudioSourceType source;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval endTime;

@end

@interface DVEMixAudioModel : NSObject

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSArray<DVERecognizeAudioInfo *> *fragments;

@end

NS_ASSUME_NONNULL_END
