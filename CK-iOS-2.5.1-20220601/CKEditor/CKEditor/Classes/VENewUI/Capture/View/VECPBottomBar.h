//
//  VECPBottomBar.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECPBaseBar.h"
#import "VECapBaseViewController.h"

#define VECPBottomBarH 228

NS_ASSUME_NONNULL_BEGIN
typedef void (^recordAction)(UIButton *button);
typedef void (^deletActionBlockType)(NSIndexPath *indexPath);
@interface VECPBottomBar : VECPBaseBar

@property (nonatomic, copy) recordAction recordAction;

@property (nonatomic, assign) NSTimeInterval duration;

@property (nonatomic, copy) capsourceResultBlock cpResultBlock;
@property (nonatomic, copy) deletActionBlockType deletActionBlock;

@property (nonatomic, assign) BOOL disableTimer;



@end

NS_ASSUME_NONNULL_END
