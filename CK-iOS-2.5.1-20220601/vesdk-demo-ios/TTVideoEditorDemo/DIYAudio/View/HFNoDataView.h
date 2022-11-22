//
//  HFNoDataView.h
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/27.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HFNoDataView : UIView

- (void)updateTitle:(NSString *)title;
- (void)updateImage:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
