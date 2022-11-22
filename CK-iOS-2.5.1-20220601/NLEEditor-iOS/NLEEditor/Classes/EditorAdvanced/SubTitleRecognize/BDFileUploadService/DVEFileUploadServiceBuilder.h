//
//  DVEFileUploadServiceBuilder.h
//  CameraClient-Pods-Aweme
//
//  Created by bytedance on 2021/1/5.
//

#import <Foundation/Foundation.h>
#import "DVEFileUploadServiceProtocol.h"
#import "DVEUploadParametersResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

// upload type
typedef NS_ENUM(NSUInteger, DVEUploadFileType){
    DVEUploadFileTypeVideo,//视频
    DVEUploadFileTypeAudio, //音频
    DVEUploadFileTypeImage,//图片
    DVEUploadFileTypeObject,//文件
};

@interface DVEFileUploadServiceBuilder : NSObject

- (id<DVEFileUploadServiceProtocol>)createUploadServiceWithParams:(DVEUploadParametersResponseModel *)uploadParams filePaths:(NSArray<NSString *> *)fileURLs;
- (id<DVEFileUploadServiceProtocol>)createUploadServiceWithParams:(DVEUploadParametersResponseModel *)uploadParams filePath:(NSString * _Nonnull)filePath fileType:(DVEUploadFileType)fileType;

@end

NS_ASSUME_NONNULL_END
