//
//  VEEMakeUpSelectBar.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VEEBeautyViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEEMakeUpSelectBar : UIView

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) NSInteger subSelectIndex;

@property (nonatomic, copy) VEEBeautyCallBackBlock didSelectedBlock;
@property (nonatomic, copy) VEEBeautyCloseBlock closeBlock;
@property (nonatomic, strong) NSArray *dataSourceArr;
@property (nonatomic, strong) UIButton *eyeButton;

@end

NS_ASSUME_NONNULL_END
