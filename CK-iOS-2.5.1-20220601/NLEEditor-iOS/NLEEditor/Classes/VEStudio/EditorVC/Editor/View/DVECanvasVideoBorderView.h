//
//  DVECanvasVideoBorderView.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVEVCContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVECanvasVideoBorderView : UIView

@property (nonatomic,weak) DVEVCContext *vcContext;

- (void)updateTranslation:(CGPoint)trans;

- (void)updateScale:(CGFloat )scale forSize:(CGSize)size;

- (void)updateRoation:(CGFloat)rotate;

- (void)updateCrop:(NLEStyCrop_OC *)crop scale:(CGFloat)scale maxBounds:(CGRect)bounds;

@end

NS_ASSUME_NONNULL_END
