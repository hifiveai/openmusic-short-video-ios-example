//
//  DVEImportSelectCollectionViewCell.h
//  CutSameIF
//
//  Created by bytedance on 2020/3/5.
//

#import <UIKit/UIKit.h>
#import "DVEAlbumAssetModel.h"
#import "DVEAlbumViewModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface DVEImportSelectCollectionViewCell : UICollectionViewCell

@property (nonatomic, copy) void (^deleteAction)(DVEImportSelectCollectionViewCell *cell);

@property (nonatomic, copy) NSIndexPath *currentIndexPath;

@property (nonatomic, strong) DVEImportMaterialSelectCollectionViewCellModel *cellModel;

- (void)bindModel:(DVEImportMaterialSelectCollectionViewCellModel *)cellModel;

@end

NS_ASSUME_NONNULL_END
