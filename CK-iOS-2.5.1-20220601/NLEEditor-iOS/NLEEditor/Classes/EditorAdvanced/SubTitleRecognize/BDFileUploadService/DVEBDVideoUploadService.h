//
//  DVEBDVideoUploadService.h
//  CameraClient-Pods-Aweme
//
//  Created by bytedance on 2020/12/21.
//

#import "DVEBDFileUploadService.h"

@interface DVEBDVideoUploadService : DVEBDFileUploadService

- (void)configVideoUploadDelegateWithDelegate:(id<BDVideoUploadClientDelegate>)delegate;

- (void)configActivityFlag;

@end
