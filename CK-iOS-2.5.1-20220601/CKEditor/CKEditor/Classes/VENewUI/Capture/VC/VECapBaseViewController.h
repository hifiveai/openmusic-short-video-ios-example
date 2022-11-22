//
//  VECapBaseViewController.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VECapProtocol.h"
#import "VESourceValue.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^capsourceResultBlock)(VESourceValue *oneSource);
typedef void (^recordAction)(UIButton *button);

@interface VECapBaseViewController : UIViewController

@property (nonatomic, strong) id<VECapProtocol> capManager;

@property (nonatomic, copy) capsourceResultBlock cpResultBlock;

@property (nonatomic, copy) recordAction recordAction;

@end

NS_ASSUME_NONNULL_END
