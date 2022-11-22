//
//  VECapBaseCollectionViewCell.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VEVButton.h"
#import "VEBarValue.h"

NS_ASSUME_NONNULL_BEGIN

@interface VECapBaseCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) VEVButton *button;
@property (nonatomic, strong) VEBarValue *barValue;

@end

NS_ASSUME_NONNULL_END
