//
//  DVEDraftViewController.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/2/28.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVEVCContextExternalInjectProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEDraftViewController : UIViewController
///外部注入服务
@property (nonatomic, strong) id<DVEVCContextExternalInjectProtocol> serviceInjectContainer;

@end

NS_ASSUME_NONNULL_END
