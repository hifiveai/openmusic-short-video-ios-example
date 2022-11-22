//
//  VEEBeautyViewController.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN
typedef void (^VEEBeautyCallBackBlock)(DVEEffectValue *evalue,NSUInteger index);
typedef void (^VEEBeautyCloseBlock)(NSUInteger index,UIButton *btn);


@interface VEEBeautyViewController : UIViewController

@property (nonatomic, weak) UIView *parentView;
@property (nonatomic, assign) NSUInteger index;

@property (nonatomic, copy) VEEBeautyCallBackBlock didSelectedBlock;
@property (nonatomic, copy) VEEBeautyCloseBlock closeBlock;
@property (nonatomic, strong) NSMutableArray *dataSourceArr;
@property (nonatomic, strong) UIButton *eyeButton;

- (void)reset;

- (void)reLoad;

@end

NS_ASSUME_NONNULL_END
