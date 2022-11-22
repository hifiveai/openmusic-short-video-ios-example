//
//  DVEVideoCutBaseViewController.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DVEVCContext;

NS_ASSUME_NONNULL_BEGIN

@interface DVEVideoCutBaseViewController : UIViewController

@property (nonatomic, strong) DVEVCContext *vcContext;

- (void)releaseResouce;
- (void)saveDraft;
- (void)closeMethod;

@end

NS_ASSUME_NONNULL_END
