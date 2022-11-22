//
//  DVETextColorCell.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVETextBaseCell.h"
#import <SGPagingView/SGPagingView.h>
#import "DVEVCContext.h"
#import "DVECommonDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVETextColorCell : DVETextBaseCell<SGPageTitleViewDelegate>

@property (nonatomic, copy) selectColorBlock colorBlock;
@property (nonatomic, strong) SGPageTitleView *functionView;

@property (nonatomic, assign) DVETextColorConfigType colorType;
@property (nonatomic, strong) UIColor *curColor;
@property (nonatomic, weak) DVEVCContext *vcContext;

@end

NS_ASSUME_NONNULL_END
