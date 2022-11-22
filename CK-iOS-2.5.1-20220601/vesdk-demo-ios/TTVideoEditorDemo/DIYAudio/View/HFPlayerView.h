//
//  HFPlayerView.h
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/18.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class HFMusicListCellModel;
@interface HFPlayerView : UIView

@property (nonatomic ,strong) NSMutableArray *collectedArray;
@property (nonatomic ,strong) UIButton *playButton;

- (void)play;
- (void)pause;

- (void)configWithModel:(HFMusicListCellModel *)model;

@end

NS_ASSUME_NONNULL_END
