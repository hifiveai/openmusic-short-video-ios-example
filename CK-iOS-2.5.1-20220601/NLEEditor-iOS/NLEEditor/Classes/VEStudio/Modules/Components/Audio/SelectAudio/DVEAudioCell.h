//
//  DVEAudioCell.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVEStepSlider.h"
#import "DVEResourceMusicModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class LOTAnimationView;
@interface DVEAudioCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) LOTAnimationView *waveImage;
@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UILabel *desLable;
@property (nonatomic, strong) UILabel *timeLable;
@property (nonatomic, strong) UIButton *useButton;
@property (nonatomic, strong) DVEStepSlider *slider;

@property (nonatomic, strong) id<DVEResourceMusicModelProtocol> audioSource;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, assign) BOOL isSound;

@property (nonatomic, copy) void(^addBlock)(NSIndexPath *);

@end

NS_ASSUME_NONNULL_END
