//
//  VEMenuCollectionViewCell.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEMenuCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) NSString *iconName;
@property (nonatomic, strong) NSString *titleName;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end

NS_ASSUME_NONNULL_END
