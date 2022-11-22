//
//  DVERecognizer.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/18.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "DVEVCContext.h"
#import "DVECaptionModel.h"

typedef NS_ENUM(NSUInteger, DVETextRecognizerStatus) {
    DVETextRecognizerStatusAnalysing,
    DVETextRecognizerStatusFailed,
    DVETextRecognizerStatusSuccess
};

typedef void(^DVEExportCompletion)(NSURL * _Nonnull url, NSError * _Nonnull error, AVAssetExportSessionStatus status);

typedef void(^DVEAudioUploadCompletion)(NSArray *_Nullable captionsArray, NSError *_Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface DVERecognizer : NSObject

- (instancetype)initWithContext:(DVEVCContext *)context;

- (RACSignal<DVESubtitleQueryModel *> *)recognizeAudioText;

@end

NS_ASSUME_NONNULL_END
