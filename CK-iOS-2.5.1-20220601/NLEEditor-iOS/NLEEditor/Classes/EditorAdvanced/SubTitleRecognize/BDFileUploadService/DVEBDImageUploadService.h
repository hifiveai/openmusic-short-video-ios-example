//
//  DVEBDImageUploadService.h
//  CameraClient-Pods-Aweme
//
//  Created by bytedance on 2020/12/21.
//

#import "DVEBDFileUploadService.h"

@interface DVEBDImageUploadService : DVEBDFileUploadService

- (void)configImageUploadDelegateWithDelegate:(id<BDImageUploadClientDelegate>)delegate;

@end
