//
//  HFSearchBarView.h
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/21.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HFSearchBarView : UIView

@property (nonatomic ,copy) void(^cancelBtnBlock)(void);
@property (nonatomic ,copy) void(^searchActionBlock)(NSString *searchName);

@property (nonatomic ,strong) UITextField *searchTextFieldView;


+ (HFSearchBarView *)configWithFrame:(CGRect)frame searchImage:(NSString *)searchImageName placeHolder:(NSString *)placeHolder;

@end

NS_ASSUME_NONNULL_END
