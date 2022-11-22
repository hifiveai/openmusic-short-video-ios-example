//
//  DVEBDFileUploadService.h
//  CameraClient-Pods-Aweme
//
//  Created by bytedance on 2020/12/21.
//

#import <Foundation/Foundation.h>
#import "DVEFileUploadServiceProtocol.h"
#import "DVEUploadParametersResponseModel.h"
// BDUpload
#import <BDVCFileUploadClient/BDVideoUploaderClient.h>
#import <BDVCFileUploadClient/BDImageUploaderClient.h>
#import <BDVCFileUploadClient/BDFileSpeedTestClient.h>
#import <BDVCFileUploadClient/BDFileNetworkRoutClient.h>

// upload type
typedef NS_ENUM(NSUInteger, DVEBDUploadFileType){
    DVEBDUploadFileTypeVideo,//视频
    DVEBDUploadFileTypeAudio, //音频
    DVEBDUploadFileTypeImage,//图片
    DVEBDUploadFileTypeObject,//文件
};

@interface DVEBDFileUploadService : NSObject<DVEFileUploadServiceProtocol>

@property (nonatomic, strong, readonly) DVEUploadParametersResponseModel *uploadParams;
@property (nonatomic, strong, readonly) NSString *filePath;
@property (nonatomic, strong, readonly) NSArray<NSString *> *filePaths;
@property (nonatomic, assign, readonly) DVEBDUploadFileType uploadFileType;
@property (nonatomic, assign, readonly) BOOL activityFlag;

@property (nonatomic, strong) NSProgress *progress;
@property (nonatomic,   copy) DVEFileUploadProgressCallback progressCallback;
@property (nonatomic,   copy, readonly) DVEFileUploadCompletion completion;

- (instancetype)initWithUploadParams:(DVEUploadParametersResponseModel *)uploadParams filePath:(NSString * _Nonnull)filePath fileType:(DVEBDUploadFileType)fileType;
- (instancetype)initImagesUploadWithParams:(DVEUploadParametersResponseModel *)uploadParams filePaths:(NSArray<NSString *> *)filePaths;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)resetProgress:(NSProgress * __autoreleasing *)progress;
- (void)startUploading;


// DVEFileUploadServiceProtocol
@property (nonatomic, assign) BOOL isUploading;

- (void)uploadFileWithProgress:(NSProgress * __autoreleasing *)progress
                    completion:(DVEFileUploadCompletion)completion;
- (void)stopUploading;

@end
