//
//  VECPBottomBox.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECPBaseBar.h"
#import "VESourceValue.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^nextActionBlockType)(UIButton *);
typedef void (^deletActionBlockType)(NSIndexPath *indexPath);

@interface VECPBottomBox : VECPBaseBar

@property (nonatomic, copy) nextActionBlockType nextActionBlock;
@property (nonatomic, copy) deletActionBlockType deletActionBlock;


@property (nonatomic, strong) NSMutableArray <VESourceValue *>*dataSource;

- (void)addOneSource:(VESourceValue *)value;

- (void)clean;

@end

NS_ASSUME_NONNULL_END
