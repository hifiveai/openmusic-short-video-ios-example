//
//  VECapViewController.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECapBaseViewController.h"
#import "VECapBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface VECapViewController : VECapBaseViewController

+ (instancetype)VECapVCWithType:(VECPViewType)viewType;
@property (nonatomic, strong) NSURL *duetURL;

@end

NS_ASSUME_NONNULL_END
