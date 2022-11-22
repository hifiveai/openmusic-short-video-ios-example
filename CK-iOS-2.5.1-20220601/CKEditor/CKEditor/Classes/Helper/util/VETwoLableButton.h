//
//  VETwoLableButton.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VETwoLableButton : UIButton

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title des:(NSString *)des;

- (void)updateDes:(NSString *)des;

@end

NS_ASSUME_NONNULL_END
