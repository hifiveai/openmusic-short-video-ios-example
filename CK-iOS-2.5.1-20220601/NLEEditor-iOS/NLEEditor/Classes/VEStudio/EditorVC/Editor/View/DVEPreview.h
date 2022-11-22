//
//  DVEPreview.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVEVCContext.h"
NS_ASSUME_NONNULL_BEGIN

@class DVECanvasVideoBorderView;
@interface DVEPreview : UIView<DVECoreActionNotifyProtocol>
@property (nonatomic, weak) DVEVCContext *vcContext;
@property (nonatomic, strong) DVECanvasVideoBorderView *canvasBorderView;


/// 画布框显示是否支持手势
/// @param enableGesture 是否支持手势
- (void)showCanvasBorderEnableGesture:(BOOL)enableGesture;

/// 是否禁用手势
/// @param disable 是否禁用手势
- (void)disableGesture:(BOOL)disable;

/// 隐藏画布框
- (void)hideCanvasBorder;

- (void)isShow;

/// 刷新preview中画布框的大小、位置、旋转角度、剪裁
- (void)refresh;


@end

NS_ASSUME_NONNULL_END
