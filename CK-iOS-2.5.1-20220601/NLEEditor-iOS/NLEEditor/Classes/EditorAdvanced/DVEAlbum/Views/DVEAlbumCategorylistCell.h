//
//  DVEAlbumCategorylistCell.h
//  CutSameIF
//
//  Created by bytedance on 2020/7/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DVEAlbumModel;

@interface DVEAlbumCategorylistCell : UITableViewCell

- (void)configCellWithAlbumModel:(DVEAlbumModel *)albumModel;

@end

NS_ASSUME_NONNULL_END
