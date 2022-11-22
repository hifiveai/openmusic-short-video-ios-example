//
//  VECollectionViewLayoutAttributes.h
//  VECollectionView
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2018年 VE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VECollectionViewLayoutAttributes : UICollectionViewLayoutAttributes

@property(nonatomic,copy)UIColor* color;
@property(nonatomic,copy)UIImage* image;

//此属性只是header会单独设置，其他均直接返回其frame属性
@property(nonatomic,assign,readonly)CGRect orginalFrame;



@end
