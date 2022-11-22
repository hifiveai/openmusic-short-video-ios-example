//
//  DVETextFontCell.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVETextBaseCell.h"
#import "DVEVCContext.h"
NS_ASSUME_NONNULL_BEGIN

@interface DVETextFontCell : DVETextBaseCell

@property (nonatomic, copy) selectFontBlock fontBlock;
@property (nonatomic, weak) DVEVCContext *vcContext;

@end

NS_ASSUME_NONNULL_END
