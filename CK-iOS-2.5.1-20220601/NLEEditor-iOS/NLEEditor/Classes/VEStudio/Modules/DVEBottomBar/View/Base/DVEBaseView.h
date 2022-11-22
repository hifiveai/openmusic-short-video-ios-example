//
//  DVEBaseView.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVEVCContext.h"

NS_ASSUME_NONNULL_BEGIN

@class NLEEditor_OC;
@interface DVEBaseView : UIView <DVECoreActionNotifyProtocol>

@property (nonatomic, weak) DVEVCContext *vcContext;

@property (nonatomic, weak) UIViewController *parentVC;

- (void)touchOutSide;

- (void)undoRedoClikedByUser;

- (void)undoRedoWillClikeByUser;

@end

NS_ASSUME_NONNULL_END
