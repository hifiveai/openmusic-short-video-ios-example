//
//  DVEAlbumVideoListCell.h
//  AWEStudio
//
//  Created by bytedance on 2018/5/22.
//  Copyright © 2018年 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DVEAlbumVideoListCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *coverImage;
@property (nonatomic, strong) UILabel *timeLabel;

- (void)setCoverImage:(UIImage *)coverImage animated:(BOOL)animated;

@end
