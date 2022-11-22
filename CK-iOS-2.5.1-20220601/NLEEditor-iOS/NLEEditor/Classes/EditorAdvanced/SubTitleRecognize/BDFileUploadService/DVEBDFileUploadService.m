//
//  DVEBDFileUploadService.m
//  CameraClient-Pods-Aweme
//
//  Created by bytedance on 2020/12/21.
//

#import "DVEBDFileUploadService.h"

@interface DVEBDFileUploadService()

@property (nonatomic, strong) DVEUploadParametersResponseModel *uploadParams;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSArray<NSString *> *filePaths;
@property (nonatomic, assign) DVEBDUploadFileType uploadFileType;
@property (nonatomic, copy, readwrite) DVEFileUploadCompletion completion;

@property (nonatomic, assign) BOOL activityFlag;

@end

@implementation DVEBDFileUploadService

@synthesize isUploading = _isUploading;
@synthesize progressCallback = _progressCallback;
@synthesize context = _context;

- (instancetype)initWithUploadParams:(DVEUploadParametersResponseModel *)uploadParams filePath:(NSString * _Nonnull )filePath fileType:(DVEBDUploadFileType)fileType
{
    self = [super init];
    if (self) {
        _uploadParams = uploadParams;
        _filePath = filePath;
        _uploadFileType = fileType;
        _activityFlag = NO;
    }
    return self;
}

- (instancetype)initImagesUploadWithParams:(DVEUploadParametersResponseModel *)uploadParams filePaths:(NSArray<NSString *> *)filePaths
{
    if ([filePaths count] == 0) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _uploadParams = uploadParams;
        _filePaths = filePaths;
        _uploadFileType = DVEBDUploadFileTypeImage;
        _activityFlag = NO;
    }
    return self;
}

#pragma mark - DVEFileUploadServiceProtocol

- (void)uploadFileWithProgress:(NSProgress *__autoreleasing *)progress
                     completion:(DVEFileUploadCompletion)completion
{
    self.completion = completion;
    [self resetProgress:progress];
    [self startUploading];
}

- (void)stopUploading
{
    
}

- (void)configActivityFlag
{
    self.activityFlag = YES;
}

#pragma mark - For Subclassing
- (void)startUploading
{
    
}

#pragma mark - Private Helpers
- (void)resetProgress:(NSProgress * __autoreleasing *)progress
{
    if (progress) {
        *progress = [NSProgress progressWithTotalUnitCount:100];
        self.progress = *progress;
    }
}

@end
