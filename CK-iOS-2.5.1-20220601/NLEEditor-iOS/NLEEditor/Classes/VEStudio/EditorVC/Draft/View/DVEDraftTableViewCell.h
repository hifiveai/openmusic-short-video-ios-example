//
//  DVEDraftTableViewCell.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/2/28.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class DVEDraftModel;
@interface DVEDraftTableViewCell : UITableViewCell

@property (nonatomic, strong) DVEDraftModel *model;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, copy) void (^deletDraftBlock)(void);

@end

NS_ASSUME_NONNULL_END
