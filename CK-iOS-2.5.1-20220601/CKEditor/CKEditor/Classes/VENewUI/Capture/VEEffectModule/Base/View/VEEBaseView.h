//
//  VEEBaseView.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VECapProtocol.h"


NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, VEEffectToolViewType) {
    VEEffectToolViewTypeNone = 0,
    VEEffectToolViewTypeFilter,
    VEEffectToolViewTypeSticker,
    VEEffectToolViewTypeBeauty,
};

typedef NS_ENUM(NSInteger, VEEBottomBarType) {
    VEEBottomBarTypeNone = 0,
    VEEBottomBarTypeVideo,
    VEEBottomBarTypePicture,
};

typedef void (^VEEVoidBlock)(void);

typedef void (^VEEBaseViewActionBlock)(VEEffectToolViewType toolType,VEEBottomBarType barType,UIButton *btn);





@interface VEEBaseView : UIView

@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, weak) id<VECapProtocol> capManager;

@property (nonatomic, copy) VEEVoidBlock dismissBlock;
@property (nonatomic, assign) VEEBottomBarType type;
@property (nonatomic, assign) VEEffectToolViewType effectType;

@property (nonatomic, strong) UIButton *capButton;
@property (nonatomic, copy) VEEBaseViewActionBlock capButtonBlock;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, copy) VEEBaseViewActionBlock actionButtonBlock;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, copy) VEEBaseViewActionBlock resetButtonBlock;
@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) UIView *bottomBar;

- (instancetype)initWithFrame:(CGRect)frame Type:(VEEffectToolViewType)type DismisBlock:(VEEVoidBlock)dismissBlock;

- (void)showInView:(UIView *)view;
- (void)dismiss;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
