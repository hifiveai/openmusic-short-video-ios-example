//
//  HFRegistViewController.h
//  TTVideoEditorDemo
//
//  Created by ly on 2022/8/2.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HFRegistViewController : UIViewController

@property (nonatomic ,copy) void(^loginSuccessBlock)(void);

@end

NS_ASSUME_NONNULL_END
