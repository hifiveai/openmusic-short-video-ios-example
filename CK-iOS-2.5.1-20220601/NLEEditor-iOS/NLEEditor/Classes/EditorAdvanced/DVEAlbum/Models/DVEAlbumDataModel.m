//
//  DVEAlbumDataModel.m
//  CameraClient
//
//  Created by bytedance on 2020/6/22.
//

#import "DVEAlbumDataModel.h"
#import "DVEAlbumMacros.h"

@implementation DVEAlbumVCModel

@end

@interface DVEAlbumAssetModelManager()

@property (nonatomic, strong) NSMutableDictionary<NSString *, DVEAlbumAssetModel *> *sourceAssetDic;
@property (nonatomic, strong) PHFetchResult *fetchResult;

@end

@implementation DVEAlbumAssetModelManager

+ (instancetype)createWithPHFetchResult:(PHFetchResult *)result
{
    DVEAlbumAssetModelManager *manager = [DVEAlbumAssetModelManager new];
    manager.sourceAssetDic = [NSMutableDictionary new];
    manager.fetchResult = result;
    return manager;
}

- (DVEAlbumAssetModel *)objectIndex:(NSInteger)index
{
    DVEAlbumAssetModel *assetModel;
    if (index < [self.fetchResult count]) {
        PHAsset *asset = [self.fetchResult objectAtIndex:index];
        assetModel = [self assetModelForPhAsset:asset];
    }
    return assetModel;
}

- (DVEAlbumAssetModel *)assetModelForPhAsset:(PHAsset *)asset
{
    DVEAlbumAssetModel *assetModel = self.sourceAssetDic[asset.localIdentifier];;
    if (!assetModel && asset.localIdentifier) {
        assetModel = [self p_createAssetModel:asset];
    }
    return assetModel;
}

- (DVEAlbumAssetModel *)p_createAssetModel:(PHAsset *)asset
{
    DVEAlbumAssetModel *assetModel = [DVEAlbumAssetModel createWithPHAsset:asset];
    self.sourceAssetDic[asset.localIdentifier] = assetModel;
    return assetModel;
}

- (BOOL)containsObject:(DVEAlbumAssetModel *)anObject
{
    return [self.fetchResult containsObject:anObject.asset];
}

- (NSInteger)indexOfObject:(DVEAlbumAssetModel *)model
{
    NSInteger originIndex = [self.fetchResult indexOfObject:model.asset];
    return originIndex;
}

@end

@interface DVEAlbumAssetDataModel()

//transform the show index to origin fetchResult index
@property (nonatomic, strong) NSMutableArray<NSNumber*> *typeIndexArr;
//transform the preview index to origin fetchResult index
@property (nonatomic, strong) NSMutableArray<NSNumber*> *previewIndexArr;
@property (nonatomic, assign) NSInteger imageCount;
@property (nonatomic, assign) NSInteger videoCount;
@property (nonatomic, copy) BOOL (^filterBlock)(PHAsset *asset);
@property (nonatomic, copy) BOOL (^previewFilterBlock)(PHAsset *asset);

@end

@implementation DVEAlbumAssetDataModel

- (void)setAssetModelManager:(DVEAlbumAssetModelManager *)assetModelManager
{
    _assetModelManager = assetModelManager;
}

- (DVEAlbumAssetModel *)objectIndex:(NSInteger)index
{
    if (self.filterBlock) {
        NSNumber *indexValue = [self.typeIndexArr objectAtIndex:index];
        DVEAlbumAssetModel *assetModel = [self.assetModelManager objectIndex:indexValue.integerValue];
        return assetModel;
    } else {
        DVEAlbumAssetModel *assetModel = [self.assetModelManager objectIndex:index];
        return assetModel;
    }
}

- (NSInteger)numberOfObject
{
    if (self.filterBlock) {
        return self.typeIndexArr.count;
    } else {
        return self.assetModelManager.fetchResult.count;
    }
}

- (void)configShowIndexFilterBlock:(BOOL (^)(PHAsset *asset))filterBlock
{
    if (filterBlock) {
        self.filterBlock = filterBlock;
        self.typeIndexArr = [NSMutableArray array];
        [self.assetModelManager.fetchResult enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (self.filterBlock(obj)) {
                [self.typeIndexArr addObject:@(idx)];
            }
        }];
    };
}

- (NSInteger)indexOfObject:(DVEAlbumAssetModel *)model
{
    if (![self.assetModelManager.fetchResult containsObject:model.asset]) {
        return  0;
    }
    NSInteger originIndex = [self.assetModelManager.fetchResult indexOfObject:model.asset];
    if (self.filterBlock) {
        return [self.typeIndexArr indexOfObject:@(originIndex)];
    } else {
        return originIndex;
    }
}

- (BOOL)containsObject:(DVEAlbumAssetModel *)anObject
{
    if (![self.assetModelManager containsObject:anObject]) {
        return  NO;
    }
    if (self.filterBlock) {
        NSInteger originIndex = [self.assetModelManager indexOfObject:anObject];
        return [self.typeIndexArr containsObject:@(originIndex)];
    } else {
        return [self.assetModelManager containsObject:anObject];;
    }
}

#pragma mark - preview

- (void)configDataWithPreviewFilterBlock:(BOOL (^)(PHAsset *asset))filterBlock
{
    self.previewFilterBlock = filterBlock;
    self.previewIndexArr = [NSMutableArray array];
    NSInteger length = [self numberOfObject];
    for (NSUInteger i = 0; i < length; i++) {
        [self.previewIndexArr addObject:@(i)];
    }
}

- (DVEAlbumAssetModel *)previewObjectIndex:(NSInteger)index
{
    if (self.previewFilterBlock) {
        NSNumber *indexValue = [self.previewIndexArr objectAtIndex:index];
        DVEAlbumAssetModel *assetModel = [self.assetModelManager objectIndex:indexValue.integerValue];
        return assetModel;
    } else {
        DVEAlbumAssetModel *assetModel = [self.assetModelManager objectIndex:index];
        return assetModel;
    }
}

- (NSInteger)previewNumberOfObject
{
    return self.previewIndexArr.count;
}

- (NSInteger)previewIndexOfObject:(DVEAlbumAssetModel *)model
{
    NSInteger index = [self.assetModelManager indexOfObject:model];
    index = [self.previewIndexArr indexOfObject:@(index)];
    return index;
}

- (BOOL)previewContainsObject:(DVEAlbumAssetModel *)anObject
{
    return NSNotFound != [self previewIndexOfObject:anObject];
}

- (BOOL)removePreviewInvalidAssetForPostion:(NSInteger)position
{
    if (!self.previewFilterBlock) {
        return NO;
    }
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSInteger index = position + 1; index < [self previewNumberOfObject]; index += 1) {
        DVEAlbumAssetModel *assetModel = [self previewObjectIndex:index];
        if (![self isValidAspectRatioAssetModel:assetModel]) {
            [indexSet addIndex:index];
        } else {
            break;
        }
    }
    for (NSInteger index = position - 1; index >= 0; index -= 1) {
        DVEAlbumAssetModel *assetModel = [self previewObjectIndex:index];
        if (![self isValidAspectRatioAssetModel:assetModel]) {
            [indexSet addIndex:index];
        } else {
            break;
        }
    }
    if (indexSet.count > 0) {
        NSMutableIndexSet *removeIndexSet = [NSMutableIndexSet indexSet];
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self.previewIndexArr containsObject:@(idx)]) {
                [removeIndexSet addIndex:[self.previewIndexArr indexOfObject:@(idx)]];
            }
        }];
        [self.previewIndexArr removeObjectsAtIndexes:removeIndexSet];
        return YES;
    }
    return  NO;
}

- (BOOL)isValidAspectRatioAssetModel:(DVEAlbumAssetModel *)assetModel
{
    if (self.previewFilterBlock) {
        return self.previewFilterBlock(assetModel.asset);
    }
    return YES;
}

@end

@implementation DVEAlbumDataModel

#pragma mark - update assets

- (void)addAsset:(DVEAlbumAssetModel *)model forResourceType:(DVEAlbumGetResourceType)resourceType
{
    NSString *keyPath = [self selectedAssetModelsKeyWithResourceType:resourceType];
    if (!model || TOC_isEmptyString(keyPath)) {
        return;
    }
    
    self.beforeSelectedPhotoCount = self.mixedSelectAssetsModels.count;
    [[self mutableArrayValueForKeyPath:keyPath] addObject:model];
}

- (void)removeAsset:(DVEAlbumAssetModel *)model forResourceType:(DVEAlbumGetResourceType)resourceType
{
    NSString *keyPath = [self selectedAssetModelsKeyWithResourceType:resourceType];
    if (!model || TOC_isEmptyString(keyPath)) {
        return;
    }
    
    self.beforeSelectedPhotoCount = self.mixedSelectAssetsModels.count;
    [[self mutableArrayValueForKeyPath:keyPath] removeObject:model];
}

- (void)removeAllAssetsForResourceType:(DVEAlbumGetResourceType)resourceType
{
    NSString *keyPath = [self selectedAssetModelsKeyWithResourceType:resourceType];
    if (TOC_isEmptyString(keyPath)) {
        return;
    }
    
    self.beforeSelectedPhotoCount = self.mixedSelectAssetsModels.count;
    [[self mutableArrayValueForKeyPath:keyPath] removeAllObjects];
}

#pragma mark - Getter

- (NSMutableArray<DVEAlbumAssetModel *> *)videoSelectAssetsModels
{
    if (!_videoSelectAssetsModels) {
        _videoSelectAssetsModels = [NSMutableArray array];
    }

    return _videoSelectAssetsModels;
}

- (NSMutableArray<DVEAlbumAssetModel *> *)photoSelectAssetsModels
{
    if (!_photoSelectAssetsModels) {
        _photoSelectAssetsModels = [NSMutableArray array];
    }
    return _photoSelectAssetsModels;
}

- (NSMutableArray<DVEAlbumAssetModel *> *)mixedSelectAssetsModels
{
    if (!_mixedSelectAssetsModels) {
        _mixedSelectAssetsModels = [NSMutableArray array];
    }
    return _mixedSelectAssetsModels;
}


- (RACSubject *)resultSourceAssetsSubject
{
    if (!_resultSourceAssetsSubject) {
        _resultSourceAssetsSubject = [RACSubject subject];
    }
    return _resultSourceAssetsSubject;
}

#pragma mark - Utils

- (NSString *)selectedAssetModelsKeyWithResourceType:(DVEAlbumGetResourceType)type
{
    if (type == DVEAlbumGetResourceTypeImage) {
        return @keypath(self, photoSelectAssetsModels);
    }
    
    if (type == DVEAlbumGetResourceTypeVideo) {
        return @keypath(self, videoSelectAssetsModels);
    }
    
    if (type == DVEAlbumGetResourceTypeImageAndVideo) {
        return @keypath(self, mixedSelectAssetsModels);
    }
    
    return @"";
}

@end
