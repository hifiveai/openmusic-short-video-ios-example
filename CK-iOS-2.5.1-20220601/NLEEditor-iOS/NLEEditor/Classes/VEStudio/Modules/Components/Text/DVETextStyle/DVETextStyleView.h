//
//  DVETextStyleView.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVETextParm.h"
#import "DVEVCContext.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^selectBaseStyleBlock)(DVEEffectValue *value);
typedef void (^selectAlignmentBlock)(DVEEffectValue *alignment);
typedef void (^selectFontBlock)(DVEEffectValue *font);
typedef void (^selectColorBlock)(DVEEffectValue *color, NSInteger colorType, NSDictionary *extraDict);

@interface DVETextStyleView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) DVEVCContext *vcContext;
@property (nonatomic, copy) selectBaseStyleBlock selectStyleBlock;
@property (nonatomic, copy) selectAlignmentBlock alignMentBlock;
@property (nonatomic, copy) selectFontBlock fontBlock;
@property (nonatomic, copy) selectColorBlock colorBlock;

@end

NS_ASSUME_NONNULL_END
