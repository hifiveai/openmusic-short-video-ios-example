//
//  DVEFileUploadServiceBuilder.m
//  CameraClient-Pods-Aweme
//
//  Created by bytedance on 2021/1/5.
//

#import "DVEFileUploadServiceBuilder.h"
#import "DVEBDImageUploadService.h"
#import "DVEBDVideoUploadService.h"

@interface DVEFileUploadServiceBuilder()

@property(nonatomic, strong) id<DVEFileUploadServiceProtocol> uploadService;

@end

@implementation DVEFileUploadServiceBuilder

- (id<DVEFileUploadServiceProtocol>)createUploadServiceWithParams:(DVEUploadParametersResponseModel *)uploadParams filePaths:(NSArray<NSString *> *)filePaths
{
    self.uploadService = [[DVEBDImageUploadService alloc] initImagesUploadWithParams:uploadParams filePaths:filePaths];
    return self.uploadService;
}

- (id<DVEFileUploadServiceProtocol>)createUploadServiceWithParams:(DVEUploadParametersResponseModel *)uploadParams filePath:(NSString * _Nonnull)filePath fileType:(DVEUploadFileType)fileType
{
    self.uploadService = [[DVEBDVideoUploadService alloc] initWithUploadParams:uploadParams filePath:filePath fileType:[self p_transBDUploadFileType:fileType]];
    return self.uploadService;
}

#pragma mark - Utils

- (DVEBDUploadFileType)p_transBDUploadFileType:(DVEUploadFileType)fileType
{
    switch (fileType) {
        case DVEUploadFileTypeAudio:
            return DVEBDUploadFileTypeAudio;
            break;
        case DVEUploadFileTypeImage:
            return DVEBDUploadFileTypeImage;
            break;
        case DVEUploadFileTypeVideo:
            return DVEBDUploadFileTypeVideo;
            break;
        case DVEUploadFileTypeObject:
            return DVEBDUploadFileTypeObject;
            break;
    }
}

@end
