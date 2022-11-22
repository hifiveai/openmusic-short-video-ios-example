//
//  DVEFileUploadServiceProtocol.h
//  CameraClient-Pods-Aweme
//
//  Created by bytedance on 2020/12/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DVEFileUploadResponseInfoModel;

typedef void(^DVEFileUploadCompletion)(DVEFileUploadResponseInfoModel * _Nullable uploadInfoModel, NSError * _Nullable error);
typedef void(^DVEFileUploadProgressCallback)(CGFloat progress);

@protocol DVEFileUploadServiceProtocol <NSObject>

@property(nonatomic, assign) BOOL isUploading;
@property(nonatomic,   copy) DVEFileUploadProgressCallback progressCallback;
@property(nonatomic, strong) id context;

- (void)stopUploading;
- (void)uploadFileWithProgress:(NSProgress * __autoreleasing *)progress
                    completion:(DVEFileUploadCompletion)completion;
- (void)configActivityFlag;

@end

NS_ASSUME_NONNULL_END
