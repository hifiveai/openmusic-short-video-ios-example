//
//  DVETextFontCell.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVETextFontCell.h"
#import "DVEBundleLoader.h"
#import "DVETextCommonItem.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEMacros.h"
#import "DVETextFontItemCell.h"
#import "DVEPickerBaseCell.h"
#import <NLEPlatform/NLEStyleText+iOS.h>
#import "NSString+DVE.h"

@implementation DVETextFontCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collecView.height = 60;
        [self.collecView registerClass:[DVEPickerBaseCell class] forCellWithReuseIdentifier:@"2"];
        [self.collecView registerClass:[DVETextFontItemCell class] forCellWithReuseIdentifier:DVETextFontItemCell.description];
    }
    return self;
}

- (void)setVcContext:(DVEVCContext *)context {
    _vcContext = context;
    @weakify(self);
    [[DVEBundleLoader shareManager] textFont:self.vcContext handler:^(NSArray<DVEEffectValue *> * _Nullable datas, NSString * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            self.dataSourceArr = datas;
            [self p_defaultSelect];
        });
    }];
}
/// 按上次记录，默认选中
- (void)p_defaultSelect {
    NLEStyleText_OC *style = [DVEAutoInline(self.vcContext.serviceProvider, DVECoreStickerProtocol) currentStyle];
    // 可能经过url编码，所以使用stringByRemovingPercentEncoding去掉
    NSString *fontName = [style.font.resourceFile.dve_lowercasePathName stringByRemovingPercentEncoding];
    
    // 默认选中首个
    __block NSUInteger index = 0;
    if (style && fontName.length > 0) {
        // 找到上次记录的value
        [self.dataSourceArr enumerateObjectsUsingBlock:^(DVEEffectValue*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *n = obj.sourcePath.dve_lowercasePathName;
            if ([fontName isEqualToString:n]) {
                index = idx;
                *stop = YES;
            }
        }];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.collecView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(67, 30);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10,10);
   
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DVEEffectValue *model = self.dataSourceArr[indexPath.row];
    if(model.status == DVEResourceModelStatusDefault){
        if (self.fontBlock) {
            self.fontBlock(model);
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

#pragma mark -- UICollectionViewDataSource
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DVETextFontItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DVETextFontItemCell.description forIndexPath:indexPath];
    DVEEffectValue *value = self.dataSourceArr[indexPath.row];
    cell.model = value;
    
    return cell;
}

@end
