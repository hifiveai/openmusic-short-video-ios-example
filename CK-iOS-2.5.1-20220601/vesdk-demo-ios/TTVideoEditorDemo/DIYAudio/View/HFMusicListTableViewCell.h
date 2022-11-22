//
//  HFMusicListTableViewCell.h
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/14.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HFMusicListCellModel;
NS_ASSUME_NONNULL_BEGIN

@interface HFMusicListTableViewCell : UITableViewCell

@property (nonatomic ,copy) void(^useActionBlock)(HFMusicListCellModel *model);

- (void)configWith:(HFMusicListCellModel *)model;
- (void)beginLoading;
@end

NS_ASSUME_NONNULL_END
