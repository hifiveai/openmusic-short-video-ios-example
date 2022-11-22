//
//  DVEBDImageUploadService.m
//  CameraClient-Pods-Aweme
//
//  Created by bytedance on 2020/12/21.
//

#import "DVEBDImageUploadService.h"
#import "DVEFileUploadResponseInfoModel.h"

@interface DVEBDImageUploadService()<BDImageUploadClientDelegate>

@property (nonatomic, strong) BDImageUploaderClient *imageUploadClient;
@property (nonatomic, strong) id<BDImageUploadClientDelegate> imageUploadDelegate;

@end

@implementation DVEBDImageUploadService

@end

