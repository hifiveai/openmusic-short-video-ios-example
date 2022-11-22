//
//  DVETextBaseStyleCell.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVETextBaseStyleCell.h"
#import "DVEBundleLoader.h"
#import "DVETextCommonItem.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEMacros.h"

@implementation DVETextBaseStyleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collecView.height = 60;
        self.collecView.scrollEnabled = YES;
        [self.collecView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"1"];
    }
    return self;
}

- (void)setVcContext:(DVEVCContext *)context {
    _vcContext = context;
    @weakify(self);
    [[DVEBundleLoader shareManager] textStyle:self.vcContext handler:^(NSArray<DVEEffectValue *> * _Nullable textStlyeArr, NSString * _Nullable error) {
        if(!error){
            @strongify(self);
            @weakify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                self.dataSourceArr = @[textStlyeArr];
            });
        }
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [(NSArray *)self.dataSourceArr[section] count];
    
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DVETextCommonItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DVETextCommonItem.description forIndexPath:indexPath];
    DVEEffectValue *value = self.dataSourceArr[indexPath.section][indexPath.row];
    cell.model = value;
    cell.imageView.frame = CGRectMake(0, 0, 50, 50);
    [cell updateShowStatus];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSourceArr.count > 0 ? self.dataSourceArr.count : 0;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50, 50);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 0, 10,0);
   
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DVEEffectValue *model = self.dataSourceArr[indexPath.section][indexPath.row];
    if(model.status == DVEResourceModelStatusDefault){
        if (indexPath.section == 0) {
            if (self.selectStyleBlock) {
                self.selectStyleBlock(model);
            }
        } else {
            if (self.alignMentBlock) {
                self.alignMentBlock(model);
            }
        }
        return;
    }else if(model.status == DVEResourceModelStatusNeedDownlod || model.status == DVEResourceModelStatusDownlodFailed){
        @weakify(self);
        [model downloadModel:^(id<DVEResourceModelProtocol>  _Nonnull model) {
            [collectionView reloadData];
            if(model.status != DVEResourceModelStatusDefault) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self collectionView:collectionView didSelectItemAtIndexPath:indexPath];
            });
        }];
    }
    [collectionView reloadData];
}

@end
