//
//  DVEAlbumViewModel.m
//  CameraClient
//
//  Created by bytedance on 2020/6/17.
//

#import "DVEAlbumDeviceAuth.h"
#import "DVEAlbumMacros.h"
#import "DVEAlbumLanguageProtocol.h"
#import "NSArray+DVEAlbumAdditions.h"
#import "DVEAlbumVideoConfigProtocol.h"
#import "DVEAlbumToastImpl.h"
#import "DVEAlbumResponder.h"
#import "DVEAlbumListViewController.h"

@implementation DVEImportMaterialSelectCollectionViewCellModel
@end


NSInteger kDVEMaxAssetCountForAIClipMode = 35;
static const NSInteger kICloudDiskSpaceLowErrorCode = 256;

NSString *DVETemporaryDirectory(void)
{
    NSString *accTmp =[NSTemporaryDirectory() stringByAppendingPathComponent:@"toc/"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:accTmp]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:accTmp withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return accTmp;
}

static NSURL *p_outputURLForPHAsset(PHAsset *asset) {
    NSString *tempDir = DVETemporaryDirectory();
    tempDir = [tempDir stringByAppendingPathComponent:@"PHAssetImage"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:tempDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileName = [NSString stringWithFormat:@"tmpImage_%@.jpg", @([asset hash])];
    tempDir = [tempDir stringByAppendingPathComponent:fileName];
    return [NSURL fileURLWithPath:tempDir];
}

@interface DVEAlbumViewModel() <PHPhotoLibraryChangeObserver>

@property (nonatomic, assign, readwrite) NSInteger currentSelectedIndex;
@property (nonatomic, strong, readwrite) DVEAlbumDataModel *albumDataModel;
@property (nonatomic, strong, readwrite) DVEAlbumInputData *inputData;
@property (nonatomic, strong, readwrite) DVEAlbumConfigViewModel *configViewModel;

@property (nonatomic, strong, readonly) PHFetchResult *fetchResult;

@property (nonatomic, assign, readonly) DVEAlbumGetResourceType resourceType;
@property (nonatomic, assign, readonly) DVEAlbumVCType vcType;

// photo to video
//@property (nonatomic, strong) id<DVEMVTemplateManagerProtocol> mvTemplateManager;

@property (nonatomic, strong) NSDateFormatter *format;
@property (nonatomic, strong) NSCalendar* calendar;

@property (nonatomic, strong, readonly) NSMutableArray<DVEAlbumAssetModel *> *currentHandleSelectAssetModels;
@property (nonatomic, assign, readwrite) BOOL doNotLimitInternalSelectCount;

@property (nonatomic, strong) NSMutableArray *lastVideoArray; // icloud

@property (nonatomic, assign) BOOL hasRegisterChangeObserver;

@end

@implementation DVEAlbumViewModel

- (void)dealloc
{
    if (self.hasRegisterChangeObserver) {
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    }
}

- (instancetype)initWithAlbumInputData:(DVEAlbumInputData *)inputData
{
    self = [super init];
    if (self) {
        self.inputData = inputData;
        self.albumDataModel = [[DVEAlbumDataModel alloc] init];
        self.configViewModel = [[DVEAlbumConfigViewModel alloc] init];
        _hasRequestAuthorizationForAccessLevel = NO;
        _currentSelectAssets = [NSMutableArray array];
        if (![self enableOptimizeRecordAlbum]) {
            [self p_registerPhotoLibraryChangeObserver];
        }
        [self setupSelectViewModel];
    }
    
    return self;
}

// 已选择的照片的ViewModel
- (void)setupSelectViewModel {
    self.selectedViewModels = [NSMutableArray array];
    DVEAlbumTemplateModel *templateModel = self.inputData.cutSameTemplateModel;
    [templateModel.extraModel.fragments enumerateObjectsUsingBlock:^(DVEAlbumCutSameFragmentModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.duration != nil) {
            [self.selectedViewModels addObject:({
                DVEImportMaterialSelectCollectionViewCellModel *cellModel = [[DVEImportMaterialSelectCollectionViewCellModel alloc] init];
                if (idx == 0) {
                    cellModel.highlight = YES;
                }
                cellModel.duration = obj.duration.doubleValue/1000.0;
                cellModel.shouldShowDuration = YES;

                cellModel;
            })];
        }
    }];
    // 替换素材
    if (self.inputData.singleFragment) {
        [self.selectedViewModels removeAllObjects];
        [self.selectedViewModels addObject:({
            DVEImportMaterialSelectCollectionViewCellModel *cellModel = [[DVEImportMaterialSelectCollectionViewCellModel alloc] init];
            cellModel.highlight = YES;
            cellModel.duration = self.inputData.singleFragment.duration.floatValue/1000.0;
            cellModel.shouldShowDuration = YES;
            cellModel;
        })];
    }
}

// 更新已选择的素材的ViewModel
- (void)reloadSelectModel
{
    [self willChangeValueForKey:@"selectedViewModels"];
    NSMutableArray<DVEAlbumAssetModel *> *tmpAssetModelArray = [NSMutableArray arrayWithArray:self.currentSelectAssetModels];
    NSMutableArray<DVEImportMaterialSelectCollectionViewCellModel *> *nilAssetModel = [NSMutableArray array];
    // 移除不存在于assetModelArray的assetModel
    [self.selectedViewModels enumerateObjectsUsingBlock:^(DVEImportMaterialSelectCollectionViewCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger index = [self.currentSelectAssetModels indexOfObject:obj.assetModel];
        obj.highlight = NO;
        if (index == NSNotFound) {
            obj.assetModel = nil;
        }

        if (obj.assetModel) {
            [tmpAssetModelArray removeObject:obj.assetModel];
        } else {
            [nilAssetModel addObject:obj];
        }
    }];
    // 添加assetModelArray新的assetModel
    [tmpAssetModelArray enumerateObjectsUsingBlock:^(DVEAlbumAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (nilAssetModel.count <= idx) {
            *stop = YES;
        } else {
            nilAssetModel[idx].assetModel = obj;
        }
    }];

    // 寻找第一个空的model
    [self.selectedViewModels enumerateObjectsUsingBlock:^(DVEImportMaterialSelectCollectionViewCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.assetModel == nil) {
            obj.highlight = YES;
            *stop = YES;
        }
    }];
    [self didChangeValueForKey:@"selectedViewModels"];
}

/// 添加素材到底部选择框
- (void)didAddAssetToBottom:(DVEAlbumAssetModel *)model {
    //寻找第一个空的Model
    [self willChangeValueForKey:@"selectedViewModels"];
    NSLog(@"add model: %@", model);
    __block BOOL modelSet = NO;
    // 移除红框
    [self.selectedViewModels enumerateObjectsUsingBlock:^(DVEImportMaterialSelectCollectionViewCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.highlight = NO;
    }];
    // 寻找并添加到第一个空的框
    [self.selectedViewModels enumerateObjectsUsingBlock:^(DVEImportMaterialSelectCollectionViewCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.assetModel == nil) {
            if (modelSet) {
                obj.highlight = YES;
                *stop = YES;
            } else {
                // 设置给第一个空的model
                obj.assetModel = model;
                modelSet = YES;
            }
        }
    }];
    [self didChangeValueForKey:@"selectedViewModels"];
}
/// 从底部框移除素材
- (void)didRemoveAssetFromBottom:(DVEAlbumAssetModel *)model {
    [self willChangeValueForKey:@"selectedViewModels"];
    NSLog(@"remove model: %@", model);
    // 移除红框
    [self.selectedViewModels enumerateObjectsUsingBlock:^(DVEImportMaterialSelectCollectionViewCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.highlight = NO;
    }];
    // 移除model
    [self.selectedViewModels enumerateObjectsUsingBlock:^(DVEImportMaterialSelectCollectionViewCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.assetModel == model) {
            obj.assetModel = nil;
            *stop = YES;
        }
    }];
    // 寻找第一个空的框
    [self.selectedViewModels enumerateObjectsUsingBlock:^(DVEImportMaterialSelectCollectionViewCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.assetModel == nil) {
            obj.highlight = YES;
            *stop = YES;
        }
    }];
    [self didChangeValueForKey:@"selectedViewModels"];
}

- (void)updateAssetModel:(DVEAlbumAssetModel *)model
{
    DVEAlbumAssetModel *ret = [self p_findAssetWithAssetModels:self.currentSelectAssetModels localIdentifier:model.asset.localIdentifier];
    
    if (ret) {
        model.selectedNum = ret.selectedNum;
        model.selectedAmount = ret.selectedAmount;
    } else {
//        model.selectedNum = nil;
    }
}

#pragma mark - Data

- (void)prefetchAlbumListWithCompletion:(void (^)(void))completion
{
    NSInteger needReloadTab = 0;
    DVEAlbumGetResourceType type = DVEAlbumGetResourceTypeVideo;
    for (DVEAlbumVCModel *vcModel in self.inputData.tabsInfo) {
        if (vcModel.resourceType == DVEAlbumGetResourceTypeImage ||
            vcModel.resourceType == DVEAlbumGetResourceTypeVideo ||
            vcModel.resourceType == DVEAlbumGetResourceTypeImageAndVideo) {
            type = vcModel.resourceType;
            needReloadTab++;
        }
    }
    
    if (needReloadTab > 1) {
        type = DVEAlbumGetResourceTypeImageAndVideo;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [DVEPhotoManager getAllAlbumsForMVWithType:type completion:^(NSArray<DVEAlbumModel *> *albumModels) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.albumDataModel.allAlbumModels = albumModels;
                TOCBLOCK_INVOKE(completion);
            });
        }];
    });
}

- (BOOL)enableOptimizeRecordAlbum
{
    return NO;
}

- (void)reloadAssetsDataWithResourceType:(DVEAlbumGetResourceType)resourceType completion:(void (^)(void))completion
{
    if ([self enableOptimizeRecordAlbum]) {
        [self ab_reloadAssetsDataWithResourceType:resourceType completion:completion];
        return;
    }
    if (resourceType == DVEAlbumGetResourceTypeImage && !TOC_isEmptyArray(self.albumDataModel.photoSourceAssetsModels)) {
        TOCBLOCK_INVOKE(completion);
        return;
    }
    
    if (resourceType == DVEAlbumGetResourceTypeVideo && !TOC_isEmptyArray(self.albumDataModel.videoSourceAssetsModels)) {
        TOCBLOCK_INVOKE(completion);
        return;
    }
    
    if (resourceType == DVEAlbumGetResourceTypeImageAndVideo && !TOC_isEmptyArray(self.albumDataModel.mixedSourceAssetsModels)) {
        TOCBLOCK_INVOKE(completion);
        return;
    }
    
    NSInteger needReloadTab = 0;
    for (DVEAlbumVCModel *vcModel in self.inputData.tabsInfo) {
        if (vcModel.resourceType == DVEAlbumGetResourceTypeImage ||
            vcModel.resourceType == DVEAlbumGetResourceTypeVideo ||
            vcModel.resourceType == DVEAlbumGetResourceTypeImageAndVideo) {
            needReloadTab++;
        }
    }
    if (needReloadTab > 1) {
        resourceType = DVEAlbumGetResourceTypeImageAndVideo;
    }
    @weakify(self);
    [self p_reloadAssetsDataWithResourceType:resourceType completion:^(NSArray<DVEAlbumAssetModel *> *assetModelArray, PHFetchResult *result) {
        @strongify(self);
        [self p_updateSourceAssets:assetModelArray fetchResult:result];
        TOCBLOCK_INVOKE(completion);
    }];
}

- (void)ab_reloadAssetsDataWithResourceType:(DVEAlbumGetResourceType)resourceType completion:(void (^)(void))completion
{
    if (resourceType == DVEAlbumGetResourceTypeImage && ([self.albumDataModel.photoSourceAssetsDataModel numberOfObject] > 0)) {
        TOCBLOCK_INVOKE(completion);
        return;
    }

    if (resourceType == DVEAlbumGetResourceTypeVideo && ([self.albumDataModel.videoSourceAssetsDataModel numberOfObject] > 0)) {
        TOCBLOCK_INVOKE(completion);
        return;
    }

    if (resourceType == DVEAlbumGetResourceTypeImageAndVideo && ([self.albumDataModel.mixedSourceAssetsDataModel numberOfObject] > 0)) {
        TOCBLOCK_INVOKE(completion);
        return;
    }
    @weakify(self);
    [self ab_p_reloadAssetsDataWithResourceType:resourceType completion:^(PHFetchResult *result, BOOL (^filterBlock)(PHAsset *phasset)) {
        @strongify(self);
        [self ab_p_updateSourceAssetsWithResourceType:resourceType fetchResult:result filterBlock:filterBlock];
        TOCBLOCK_INVOKE(completion);
        [self p_registerPhotoLibraryChangeObserver];
    }];
}

- (void)reloadAssetsDataWithAlbumCategory:(DVEAlbumModel * _Nullable)albumModel completion:(void (^)(void))completion
{
    if ([self.albumDataModel.albumModel.localIdentifier isEqual:albumModel.localIdentifier]) {
        return;
    }
    
    self.albumDataModel.albumModel = albumModel;
    @weakify(self);
    [self p_doActionForAllAlbumListVcModel:^(DVEAlbumVCModel *vcModel, NSInteger index) {
        @strongify(self);
        DVEAlbumGetResourceType resourceType = vcModel.resourceType;
        if ([self enableOptimizeRecordAlbum]) {
            [self ab_p_reloadAssetsDataWithResourceType:resourceType completion:^(PHFetchResult *result, BOOL (^filter)(PHAsset *phasset)) {
                @strongify(self);
                [self ab_p_updateSourceAssetsWithResourceType:resourceType fetchResult:result filterBlock:filter];
                TOCBLOCK_INVOKE(completion);
            }];
        } else {
            [self p_reloadAssetsDataWithResourceType:resourceType completion:^(NSArray<DVEAlbumAssetModel *> *assetModelArray, PHFetchResult *result) {
                @strongify(self);
                [self p_updateSourceAssets:assetModelArray resourceType:resourceType fetchResult:result];
                TOCBLOCK_INVOKE(completion);
            }];
        }
    }];
}

- (void)p_reloadAssetsDataWithResourceType:(DVEAlbumGetResourceType)resourceType completion:(void (^)(NSArray<DVEAlbumAssetModel *> *assetModelArray, PHFetchResult *result))completion
{
    DVEAlbumModel *targetAlbum = self.albumDataModel.albumModel;
    if (self.albumDataModel.albumModel) {
        for (DVEAlbumModel *item in self.albumDataModel.allAlbumModels) {
            if ([self.albumDataModel.albumModel.localIdentifier isEqual:item.localIdentifier]) {
                targetAlbum = item;
                break;
            }
        }
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (!targetAlbum) {
            [DVEPhotoManager getAssetsWithType:resourceType filterBlock:^BOOL(PHAsset * _Nonnull phAsset) {
                return [self validPixel:phAsset];
            } ascending:self.inputData.ascendingOrder completion:^(NSArray<DVEAlbumAssetModel *> * _Nonnull assetModelArray, PHFetchResult * _Nonnull result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    TOCBLOCK_INVOKE(completion, assetModelArray, result);
                });
            }];
        } else {
            [DVEPhotoManager getAssetsWithAlbum:targetAlbum type:resourceType filterBlock:^ BOOL (PHAsset *phasset) {
                return [self validPixel:phasset] && [self validPHAsset:phasset resourceType:resourceType];
            } completion:^(NSArray<DVEAlbumAssetModel *> *assetModelArray, PHFetchResult *result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    TOCBLOCK_INVOKE(completion, assetModelArray, result);
                });
            }];
        }
    });
}

- (void)ab_p_reloadAssetsDataWithResourceType:(DVEAlbumGetResourceType)resourceType completion:(void (^)(PHFetchResult *result, BOOL (^filter)(PHAsset *phasset)))completion
{
    DVEAlbumModel *targetAlbum = self.albumDataModel.albumModel;
    if (self.albumDataModel.albumModel) {
        for (DVEAlbumModel *item in self.albumDataModel.allAlbumModels) {
            if ([self.albumDataModel.albumModel.localIdentifier isEqual:item.localIdentifier]) {
                targetAlbum = item;
                break;
            }
        }
    }
    if (!targetAlbum) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [DVEPhotoManager getAllAssetsWithType:resourceType  ascending:self.inputData.ascendingOrder completion:^(PHFetchResult * _Nonnull result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    TOCBLOCK_INVOKE(completion, result, nil);
                });
            }];
        });
    } else {
        @weakify(self);
        BOOL (^filterBlock)(PHAsset *phasset) = ^BOOL(PHAsset *phasset){
            @strongify(self);
            return [self validPixel:phasset] && [self validPHAsset:phasset resourceType:resourceType];
        };
        TOCBLOCK_INVOKE(completion, self.albumDataModel.albumModel.result, filterBlock);
    }
}

- (void)ab_p_updateSourceAssetsWithResourceType:(DVEAlbumGetResourceType)resourceType fetchResult:(PHFetchResult *)fetchResult filterBlock:(BOOL(^)(PHAsset *asset))filterBlock
{
    switch (resourceType) {
        case DVEAlbumGetResourceTypeImageAndVideo: {
            self.albumDataModel.fetchResult = fetchResult;
            DVEAlbumAssetModelManager *manager = [DVEAlbumAssetModelManager createWithPHFetchResult:fetchResult];
            self.albumDataModel.mixedSourceAssetsDataModel = [self createAsstDataModelRourceType:resourceType manager:manager filterBlock:filterBlock];
            [self.albumDataModel.resultSourceAssetsSubject sendNext:self.albumDataModel.mixedSourceAssetsDataModel];
        } break;
        case DVEAlbumGetResourceTypeImage: {
            if (!self.albumDataModel.fetchResult) {
                self.albumDataModel.fetchResult = fetchResult;
            }
            DVEAlbumAssetModelManager *manager = [DVEAlbumAssetModelManager createWithPHFetchResult:fetchResult];
            self.albumDataModel.photoSourceAssetsDataModel = [self createAsstDataModelRourceType:DVEAlbumGetResourceTypeImage manager:manager filterBlock:filterBlock];
            [self.albumDataModel.resultSourceAssetsSubject sendNext:self.albumDataModel.photoSourceAssetsDataModel];
        } break;
        case DVEAlbumGetResourceTypeVideo: {
            if (!self.albumDataModel.fetchResult) {
                self.albumDataModel.fetchResult = fetchResult;
            }
            DVEAlbumAssetModelManager *manager = [DVEAlbumAssetModelManager createWithPHFetchResult:fetchResult];
            self.albumDataModel.videoSourceAssetsDataModel = [self createAsstDataModelRourceType:DVEAlbumGetResourceTypeVideo manager:manager filterBlock:filterBlock];
            [self.albumDataModel.resultSourceAssetsSubject sendNext:self.albumDataModel.videoSourceAssetsDataModel];
        } break;
        default:
            break;
    }
    [self ab_p_updateSelectedAssetModels];
}

- (DVEAlbumAssetDataModel *)createAsstDataModelRourceType:(DVEAlbumGetResourceType)resourceType manager:(DVEAlbumAssetModelManager *)manager filterBlock:(BOOL(^)(PHAsset *asset))filterBlock
{
    DVEAlbumAssetDataModel *dataModel = [DVEAlbumAssetDataModel new];
    dataModel.resourceType = resourceType;
    dataModel.assetModelManager = manager;
    if (filterBlock) {
        [dataModel configShowIndexFilterBlock:filterBlock];
    }
    return dataModel;
}

- (void)p_updateSourceAssets:(NSArray<DVEAlbumAssetModel *> *)assetModelArray fetchResult:(PHFetchResult *)fetchResult
{
    NSMutableArray *videoSource = [NSMutableArray array];
    NSMutableArray *photoSource = [NSMutableArray array];
    
    for (DVEAlbumAssetModel *model in assetModelArray) {
        if (model.mediaType == DVEAlbumAssetModelMediaTypePhoto) {
            [photoSource acc_addObject:model];
        }
        
        if (model.mediaType == DVEAlbumAssetModelMediaTypeVideo) {
            [videoSource acc_addObject:model];
        }
    }
    
    [self p_updateSourceAssets:assetModelArray resourceType:DVEAlbumGetResourceTypeImageAndVideo fetchResult:fetchResult];
    [self p_updateSourceAssets:videoSource resourceType:DVEAlbumGetResourceTypeVideo fetchResult:fetchResult];
    [self p_updateSourceAssets:photoSource resourceType:DVEAlbumGetResourceTypeImage fetchResult:fetchResult];
}

- (void)p_updateSourceAssets:(NSArray<DVEAlbumAssetModel *> *)assetModelArray resourceType:(DVEAlbumGetResourceType)resourceType fetchResult:(PHFetchResult *)fetchResult
{
    [self p_updateSelectedAssetModelsWithSourceAssetModels:assetModelArray];
    
    self.albumDataModel.fetchResult = fetchResult;
    if (resourceType == DVEAlbumGetResourceTypeImage) {
        self.albumDataModel.photoSourceAssetsModels = [assetModelArray mutableCopy];
    } else if (resourceType == DVEAlbumGetResourceTypeVideo) {
        self.albumDataModel.videoSourceAssetsModels = [assetModelArray mutableCopy];
    } else if (resourceType == DVEAlbumGetResourceTypeImageAndVideo) {
        self.albumDataModel.mixedSourceAssetsModels = [assetModelArray mutableCopy];
    }
}

- (void)p_updateSelectAssets:(NSMutableArray<DVEAlbumAssetModel *> *)assetModelArray resourceType:(DVEAlbumGetResourceType)resourceType
{
    if (resourceType == DVEAlbumGetResourceTypeImage) {
        self.albumDataModel.photoSelectAssetsModels = assetModelArray;
    } else if (resourceType == DVEAlbumGetResourceTypeVideo) {
        self.albumDataModel.videoSelectAssetsModels = assetModelArray;
    } else if (resourceType == DVEAlbumGetResourceTypeImageAndVideo) {
        self.albumDataModel.mixedSelectAssetsModels = assetModelArray;
    }

}

- (NSArray<DVEAlbumSectionModel *> *)dataSourceWithResourceType:(DVEAlbumGetResourceType)type
{
    NSMutableArray *currentAssetModels;
    
    if (type == DVEAlbumGetResourceTypeImage) {
        currentAssetModels = self.albumDataModel.photoSourceAssetsModels;
    } else if (type == DVEAlbumGetResourceTypeVideo) {
        currentAssetModels = self.albumDataModel.videoSourceAssetsModels;
    } else {
        currentAssetModels = self.albumDataModel.mixedSourceAssetsModels;
    }
    
    return [self p_dataSourceWithAssetsModels:currentAssetModels resourceType:type];
}

- (NSArray<DVEAlbumSectionModel *> *)p_dataSourceWithAssetsModels:(NSMutableArray *)assetModels resourceType:(DVEAlbumGetResourceType)type
{
    if (DVEAlbumNewStyleDefault == self.configViewModel.newStyle || DVEAlbumNewStyleInteraction == self.configViewModel.newStyle) {
        DVEAlbumSectionModel *sectionModel = [DVEAlbumSectionModel new];
        sectionModel.title = @"";
        sectionModel.resourceType = type;
        sectionModel.assetsModels = assetModels;
        return @[sectionModel];
    } else {
        return [self p_dataStructureConvert:assetModels resourceType:type];
    }
}

- (NSArray<DVEAlbumSectionModel *> *)ab_dataSourceWithResourceType:(DVEAlbumGetResourceType)type
{
    DVEAlbumAssetDataModel *dataModel = [self assetDataModelForResourceType:type];
    if (DVEAlbumNewStyleDefault == self.configViewModel.newStyle || DVEAlbumNewStyleInteraction == self.configViewModel.newStyle) {
        DVEAlbumSectionModel *sectionModel = [DVEAlbumSectionModel new];
        sectionModel.title = @"";
        sectionModel.resourceType = type;
        sectionModel.assetDataModel = dataModel;
        return @[sectionModel];
    } else {
        return @[];
    }
}

- (DVEAlbumAssetDataModel *)currentAssetDataModel
{
    return [self assetDataModelForResourceType:self.resourceType];
}

- (DVEAlbumAssetDataModel *)assetDataModelForResourceType:(DVEAlbumGetResourceType)type
{
    DVEAlbumAssetDataModel *dataModel;
    switch (type) {
        case DVEAlbumGetResourceTypeImageAndVideo:
            dataModel = self.albumDataModel.mixedSourceAssetsDataModel;
            break;
        case DVEAlbumGetResourceTypeImage:
            dataModel = self.albumDataModel.photoSourceAssetsDataModel;
            break;
        case DVEAlbumGetResourceTypeVideo:
            dataModel = self.albumDataModel.videoSourceAssetsDataModel;
            break;
        default:
            dataModel = self.albumDataModel.mixedSourceAssetsDataModel;
            break;
    }
    return dataModel;
}

- (DVEAlbumListBlankViewType)blankViewTypeWithResourceType:(DVEAlbumGetResourceType)type
{
    if (type == DVEAlbumGetResourceTypeImage) {
        return DVEAlbumListBlankViewTypeNoPhoto;
    } else if (type == DVEAlbumGetResourceTypeVideo) {
        return DVEAlbumListBlankViewTypeNoVideo;
    } else {
        return DVEAlbumListBlankViewTypeNoVideoAndPhoto;
    }
}

- (NSMutableArray<DVEAlbumAssetModel *> *)p_currentSelectAssetsWithResourceType:(DVEAlbumGetResourceType)resourceType
{
    if (resourceType == DVEAlbumGetResourceTypeImage) {
        return self.albumDataModel.photoSelectAssetsModels;
    } else if (resourceType == DVEAlbumGetResourceTypeVideo) {
        return self.albumDataModel.videoSelectAssetsModels;
    } else if (resourceType == DVEAlbumGetResourceTypeImageAndVideo) {
        return self.albumDataModel.mixedSelectAssetsModels;
    }
    
    return nil;
}

- (BOOL)canMutilSelectedWithResourceType:(DVEAlbumGetResourceType)type
{
    __block BOOL enable = YES;
    [self p_doActionForAllAlbumListVcModel:^(DVEAlbumVCModel *vcModel, NSInteger index) {
        if (type == vcModel.resourceType) {
            enable = vcModel.canMutilSelected;
        }
    }];
    
    return enable;
}

- (BOOL)needAllowMutilButtonWithResourceType:(DVEAlbumGetResourceType)type
{
    if (type == DVEAlbumGetResourceTypeImage) {
        return NO;
    } else if (type == DVEAlbumGetResourceTypeVideo) {
        return !self.configViewModel.enableMixedUploadAB;
    } else {
        return NO;
    }
}

- (BOOL)isExceedMaxDurationForAIVideoClip:(NSTimeInterval)duration resourceType:(DVEAlbumGetResourceType)type
{
    if (type != DVEAlbumGetResourceTypeVideo) {
        return NO;
    }
    
    id<DVEAlbumVideoConfigProtocol> config = nil;
    BOOL exceedMaxDuration = duration > config.videoSelectableMaxSeconds || (self.choosedTotalDuration + duration > config.videoSelectableMaxSeconds);
    BOOL enableAIClipMode = [self.configViewModel enableAIVideoClipMode];
    
    return enableAIClipMode && exceedMaxDuration;
}

- (void)p_updateSelectedAssetModelsWithSourceAssetModels:(NSArray<DVEAlbumAssetModel *> *)assetModelArray
{
    if (TOC_isEmptyArray(self.currentSelectAssetModels) || TOC_isEmptyArray(assetModelArray)) {
        return;
    }
    
    [self.currentSelectAssetModels enumerateObjectsUsingBlock:^(DVEAlbumAssetModel * _Nonnull selectItem, NSUInteger idx, BOOL * _Nonnull stop) {
        [assetModelArray enumerateObjectsUsingBlock:^(DVEAlbumAssetModel * _Nonnull sourceItem, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([selectItem.asset.localIdentifier isEqualToString:sourceItem.asset.localIdentifier]) {
                sourceItem.selectedNum = selectItem.selectedNum;
                sourceItem.selectedAmount = selectItem.selectedAmount;
            }
        }];
    }];
}

- (void)ab_p_updateSelectedAssetModels
{
    if (TOC_isEmptyArray(self.currentSelectAssetModels)) {
        return;
    }
    DVEAlbumAssetDataModel *dataModel = [self assetDataModelForResourceType:self.resourceType];
    [self.currentSelectAssetModels enumerateObjectsUsingBlock:^(DVEAlbumAssetModel * _Nonnull selectItem, NSUInteger idx, BOOL * _Nonnull stop) {
        [dataModel.assetModelManager.fetchResult enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([selectItem.asset.localIdentifier isEqualToString:asset.localIdentifier]) {
                DVEAlbumAssetModel *model = [dataModel.assetModelManager objectIndex:idx];
                model.selectedNum = selectItem.selectedNum;
                model.selectedAmount = selectItem.selectedAmount;
            }
        }];
    }];
}

#pragma mark - DVEAlbumSlidingViewControllerDelegate

- (NSInteger)numberOfControllers:(DVEAlbumSlidingViewController *)slidingController
{
    return self.inputData.tabsInfo.count;
}

- (UIViewController *)slidingViewController:(DVEAlbumSlidingViewController *)slidingViewController viewControllerAtIndex:(NSInteger)index
{
    if (index >= 0 && index < self.inputData.tabsInfo.count) {
        DVEAlbumVCModel *model = [self.inputData.tabsInfo objectAtIndex:index];
        return model.listViewController;
    }

    return nil;
}

- (void)slidingViewController:(DVEAlbumSlidingViewController *)slidingViewController didSelectIndex:(NSInteger)index
{
    if (self.currentSelectedIndex == index) {
        return;
    }
    
    self.currentSelectedIndex = index;
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    @weakify(self);
    [self prefetchAlbumListWithCompletion:^{
        @strongify(self);
        for (DVEAlbumVCModel *item in self.inputData.tabsInfo) {
            [self p_checkPhotoLibraryDidChange:changeInstance resourceType:item.resourceType fetchResult:self.albumDataModel.fetchResult];
        }
    }];
}

- (void)p_checkPhotoLibraryDidChange:(PHChange *)changeInstance resourceType:(DVEAlbumGetResourceType)resourceType fetchResult:(PHFetchResult *)result
{
    PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:result];
    
    if (changeDetails == nil && result) {
        return;
    }
    if ([self enableOptimizeRecordAlbum]) {
        [self ab_p_checkPhotoLibraryDidChange:changeInstance resourceType:resourceType fetchResult:result];
        return;
    }
    
    @weakify(self);
    [self p_reloadAssetsDataWithResourceType:resourceType completion:^(NSArray<DVEAlbumAssetModel *> *assetModelArray, PHFetchResult *result) {
        @strongify(self);
        NSMutableArray *newSelectAssetModelArray = [NSMutableArray array];
        NSMutableArray *deletedAssetModelArray = [NSMutableArray array];
        
        // update assets for delete case
        for (DVEAlbumAssetModel *assetModel in [self p_currentSelectAssetsWithResourceType:resourceType]) {
            __block BOOL assetDeleted = YES;
            [assetModelArray enumerateObjectsUsingBlock:^(DVEAlbumAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([assetModel.asset.localIdentifier isEqualToString:obj.asset.localIdentifier]) {
                    assetDeleted = NO;
                    *stop = YES;
                }
            }];
            if (assetDeleted) {
                [deletedAssetModelArray addObject:assetModel];
            }
        }
        
        for (DVEAlbumAssetModel *assetModel in deletedAssetModelArray) {
            [self didUnselectedAsset:assetModel];
        }
        
        // update assets for selected case
        for (DVEAlbumAssetModel *assetModel in [self p_currentSelectAssetsWithResourceType:resourceType]) {
            [assetModelArray enumerateObjectsUsingBlock:^(DVEAlbumAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([assetModel.asset.localIdentifier isEqualToString:obj.asset.localIdentifier]) {
                    obj.selectedNum = assetModel.selectedNum;
                    obj.selectedAmount = assetModel.selectedAmount;
                    obj.coverImage = assetModel.coverImage;
                    [newSelectAssetModelArray addObject:obj];
                    *stop = YES;
                }
            }];
        }
        if (!TOC_isEmptyArray(newSelectAssetModelArray)) {
            [self p_updateSelectAssets:newSelectAssetModelArray resourceType:resourceType];
        }
        
        [self p_updateSourceAssets:assetModelArray resourceType:resourceType fetchResult:result];
    }];
}

- (void)ab_p_checkPhotoLibraryDidChange:(PHChange *)changeInstance resourceType:(DVEAlbumGetResourceType)resourceType fetchResult:(PHFetchResult *)result
{
    @weakify(self);
    [self ab_p_reloadAssetsDataWithResourceType:resourceType completion:^(PHFetchResult *fetchResult, BOOL (^filter)(PHAsset *phasset)) {
        @strongify(self);
        NSMutableArray *newSelectAssetModelArray = [NSMutableArray array];
        NSMutableArray *deletedAssetModelArray = [NSMutableArray array];

        [self ab_p_updateSourceAssetsWithResourceType:resourceType fetchResult:fetchResult filterBlock:nil];
        // update assets for delete case
        for (DVEAlbumAssetModel *assetModel in [self p_currentSelectAssetsWithResourceType:resourceType]) {
            __block BOOL assetDeleted = YES;
            [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([assetModel.asset.localIdentifier isEqualToString:asset.localIdentifier]) {
                    assetDeleted = NO;
                    *stop = YES;
                }
            }];
            if (assetDeleted) {
                [deletedAssetModelArray addObject:assetModel];
            }
        }

        for (DVEAlbumAssetModel *assetModel in deletedAssetModelArray) {
            [self didUnselectedAsset:assetModel];
        }

        // update assets for selected case
        for (DVEAlbumAssetModel *assetModel in [self p_currentSelectAssetsWithResourceType:resourceType]) {
            [result enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([assetModel.asset.localIdentifier isEqualToString:asset.localIdentifier]) {
                    DVEAlbumAssetModel *obj = [[self assetDataModelForResourceType:self.resourceType].assetModelManager assetModelForPhAsset:asset];
                    obj.selectedNum = assetModel.selectedNum;
                    obj.selectedAmount = assetModel.selectedAmount;
                    obj.coverImage = assetModel.coverImage;
                    if (obj) {
                        [newSelectAssetModelArray addObject:obj];
                    }
                    *stop = YES;
                }
            }];
        }
        if (!TOC_isEmptyArray(newSelectAssetModelArray)) {
            [self p_updateSelectAssets:newSelectAssetModelArray resourceType:resourceType];
        }
        [self ab_p_updateSelectedAssetModels];
    }];
}

#pragma mark - update

- (void)clearSelectedAssetsArray
{
    [self.albumDataModel removeAllAssetsForResourceType:DVEAlbumGetResourceTypeImage];
    [self.albumDataModel removeAllAssetsForResourceType:DVEAlbumGetResourceTypeVideo];
    [self.albumDataModel removeAllAssetsForResourceType:DVEAlbumGetResourceTypeImageAndVideo];
}

- (void)updateCanMutilSelected:(BOOL)canSelected
{
    [self p_doActionForAllAlbumListVcModel:^(DVEAlbumVCModel *vcModel, NSInteger index  ) {
        if (vcModel.resourceType != DVEAlbumGetResourceTypeImage) {
            vcModel.canMutilSelected = canSelected;
        }
    }];
}

//-----由SMCheckProject工具删除-----
//- (void)updateDoNotLimitInternalSelectCount:(BOOL)notLimit
//{
//    self.doNotLimitInternalSelectCount = notLimit;
//}

//-----由SMCheckProject工具删除-----
//- (void)updateHasEnterMomentsVC:(BOOL)hasEnterMomentsVC
//{
//    self.albumDataModel.hasEnterMomentsVC = hasEnterMomentsVC;
//}

//- (void)updateOriginUploadPublishModel:(TOCPublishModel *)originUploadPublishModel
//{
//    self.inputData.originUploadPublishModel = originUploadPublishModel;
//}

- (void)updateNeedEnablePhotoToVideo:(BOOL)needEnablePhotoToVideo
{
    self.inputData.needEnablePhotoToVideo = needEnablePhotoToVideo;
}

- (void)updateCurrentSelectedIndex:(NSInteger)index
{
    self.currentSelectedIndex = index;
}

- (void)updateTimeNextButtonPress:(NSTimeInterval)time
{
    self.albumDataModel.timeNextButtonPress = time;
}

- (void)updateSelectedAssetsNumber
{
    if (self.enableMixedUploading) {
        for (NSInteger i = 0; i < self.currentSelectAssetModels.count; i++) {
            DVEAlbumAssetModel *asset = [self.currentSelectAssetModels acc_objectAtIndex:i];
            asset.selectedNum = @(i + 1);
        }
    } else {
        // udpate selected number
        for (NSInteger i = 0; i < self.albumDataModel.mixedSelectAssetsModels.count; i++) {
            DVEAlbumAssetModel *mixedTmp = self.albumDataModel.mixedSelectAssetsModels[i];
            DVEAlbumAssetModel *photoTmp = [self p_findAssetWithAssetModels:self.albumDataModel.photoSelectAssetsModels localIdentifier:mixedTmp.asset.localIdentifier];
            DVEAlbumAssetModel *videoTmp = [self p_findAssetWithAssetModels:self.albumDataModel.videoSelectAssetsModels localIdentifier:mixedTmp.asset.localIdentifier];
            mixedTmp.selectedNum = @(i + 1);
            photoTmp.selectedNum = @(i + 1);
            videoTmp.selectedNum = @(i + 1);
        }
    }
}

- (void)didSelectedAsset:(DVEAlbumAssetModel *)model
{
    if (!model) {
        return;
    }
    model.selectedAmount += 1;
    [self didAddAssetToBottom:[model copy]];
    if (self.enableMixedUploading) {
        [self p_didSelectedAssetWithMixedUpload:model];
    } else {
        [self p_didSelectedAssetWithoutMixedUpload:model];
    }
}

- (void)didUnselectedAsset:(DVEAlbumAssetModel *)model
{
    if (!model) {
        return;
    }
    if (model.selectedAmount > 0) {
        model.selectedAmount -= 1;
    }

    [self didRemoveAssetFromBottom:model];
    if (self.enableMixedUploading) {
        [self p_didUnselectedAssetWithMixedUpload:model];
    } else {
        [self p_didUnselectedAssetWithoutMixedUpload:model];
    }
}

//- (void)resetLastVideoArray
//{
//    self.lastVideoArray = nil;
//}

- (void)p_didSelectedAssetWithoutMixedUpload:(DVEAlbumAssetModel *)model
{
    // udpate selected number
    model.selectedNum = @(self.currentHandleSelectAssetModels.count + 1);
    model.selectedAmount += 1;
    [self.albumDataModel addAsset:[model copy] forResourceType:self.resourceType];
}

- (void)p_didUnselectedAssetWithoutMixedUpload:(DVEAlbumAssetModel *)model
{
    model.selectedNum = nil;
    model.selectedAmount -= 1;
    DVEAlbumAssetModel *selectModel = [self p_findAssetWithAssetModels:self.currentHandleSelectAssetModels localIdentifier:model.asset.localIdentifier];
    selectModel.selectedNum = nil;
    selectModel.selectedAmount -= 1;
    [self.albumDataModel removeAsset:model forResourceType:self.resourceType];
    
    // udpate selected number
    for (NSInteger i = 0; i < self.currentHandleSelectAssetModels.count; i++) {
        DVEAlbumAssetModel *model = self.currentHandleSelectAssetModels[i];
        model.selectedNum = @(i + 1);
    }
}

- (void)syncSelectedAmount:(DVEAlbumAssetModel *)model {
    
    for (DVEAlbumAssetModel *m in self.albumDataModel.mixedSelectAssetsModels) {
        if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
            m.selectedAmount = model.selectedAmount;
        }
    }
    for (DVEAlbumAssetModel *m in self.albumDataModel.photoSelectAssetsModels) {
        if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
            m.selectedAmount = model.selectedAmount;
        }
    }
    for (DVEAlbumAssetModel *m in self.albumDataModel.videoSelectAssetsModels) {
        if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
            m.selectedAmount = model.selectedAmount;
        }
    }
    for (DVEImportMaterialSelectCollectionViewCellModel *m in self.selectedViewModels) {
        if ([m.assetModel.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
            m.assetModel.selectedAmount = model.selectedAmount;
        }
    }
    
}

- (void)p_didSelectedAssetWithMixedUpload:(DVEAlbumAssetModel *)model
{
    [self syncSelectedAmount:model];
    
    if ([self enableOptimizeRecordAlbum]) {
//        DVEAlbumAssetDataModel *dataModel = [self assetDataModelForResourceType:self.resourceType];
//        DVEAlbumAssetModel *sameModel = [dataModel.assetModelManager objectIndex:[dataModel.assetModelManager indexOfObject:model]];
        model.selectedNum = @([self currentSelectAssetModels].count + 1);
        [self.albumDataModel addAsset:model forResourceType:self.resourceType];
    } else {
//        model = [model copy];
        model.selectedNum = @(self.albumDataModel.mixedSelectAssetsModels.count + 1);
        [self.albumDataModel addAsset:model forResourceType:self.resourceType];
    }
    
    // synchronize selected data
    if (self.resourceType != DVEAlbumGetResourceTypeImageAndVideo) {
        if ([self enableOptimizeRecordAlbum]) {
            [self ab_updateAssetModel:model type:DVEAlbumGetResourceTypeImageAndVideo isSelected:YES];
        } else {
            //
            DVEAlbumAssetModel *mixed = [self p_findAssetWithAssetModels:self.albumDataModel.mixedSourceAssetsModels localIdentifier:model.asset.localIdentifier];
            mixed.selectedNum = [model.selectedNum copy];
            mixed.selectedAmount = model.selectedAmount;
            if (!mixed.coverImage) {
                mixed.coverImage = model.coverImage;
            }
            [self.albumDataModel addAsset:mixed forResourceType:DVEAlbumGetResourceTypeImageAndVideo];
        }
    }
    
    if (self.resourceType != DVEAlbumGetResourceTypeImage) {
        if ([self enableOptimizeRecordAlbum]) {
            [self ab_updateAssetModel:model type:DVEAlbumGetResourceTypeImage isSelected:YES];
        } else {
            //
            DVEAlbumAssetModel *photo = [self p_findAssetWithAssetModels:self.albumDataModel.photoSourceAssetsModels localIdentifier:model.asset.localIdentifier];
            photo.selectedNum = [model.selectedNum copy];
            photo.selectedAmount = model.selectedAmount;
            if (!photo.coverImage) {
                photo.coverImage = model.coverImage;
            }
            [self.albumDataModel addAsset:photo forResourceType:DVEAlbumGetResourceTypeImage];
            [self ab_updateAssetModel:model type:DVEAlbumGetResourceTypeImage isSelected:YES];
        }
    }
    
    if (self.resourceType != DVEAlbumGetResourceTypeVideo) {
        if ([self enableOptimizeRecordAlbum]) {
            [self ab_updateAssetModel:model type:DVEAlbumGetResourceTypeVideo isSelected:YES];
        } else {
            
            DVEAlbumAssetModel *video = [self p_findAssetWithAssetModels:self.albumDataModel.videoSourceAssetsModels localIdentifier:model.asset.localIdentifier];
            video.selectedNum = [model.selectedNum copy];
            video.selectedAmount = model.selectedAmount;
            if (!video.coverImage) {
                video.coverImage = model.coverImage;
            }
            [self.albumDataModel addAsset:video forResourceType:DVEAlbumGetResourceTypeVideo];
            [self ab_updateAssetModel:model type:DVEAlbumGetResourceTypeVideo isSelected:YES];
        }
    }
}

- (void)ab_updateAssetModel:(DVEAlbumAssetModel *)model type:(DVEAlbumGetResourceType)type isSelected:(BOOL)selected
{
    if ([self enableOptimizeRecordAlbum]) {
        DVEAlbumAssetDataModel *dataModel = [self assetDataModelForResourceType:type];
        DVEAlbumAssetModel *sameModel = [dataModel.assetModelManager objectIndex:[dataModel.assetModelManager indexOfObject:model]];
        sameModel.coverImage = model.coverImage;
        sameModel.selectedNum = selected ? [model.selectedNum copy] : nil;
        if (!dataModel && [self checkSameTypeWithModel:model type:type]) {
            sameModel = model;
        }
        if (selected) {
            [self.albumDataModel addAsset:sameModel forResourceType:type];
        } else {
            [self.albumDataModel removeAsset:sameModel forResourceType:type];
        }
    }
}

- (BOOL)checkSameTypeWithModel:(DVEAlbumAssetModel *)model type:(DVEAlbumGetResourceType)type
{
    if (type == DVEAlbumGetResourceTypeImageAndVideo) {
        return model.mediaType == DVEAlbumAssetModelMediaTypeVideo || model.mediaType == DVEAlbumAssetModelMediaTypePhoto;
    } else if (type == DVEAlbumGetResourceTypeImage) {
        return model.mediaType == DVEAlbumAssetModelMediaTypePhoto;
    } else if (type == DVEAlbumGetResourceTypeVideo) {
        return model.mediaType == DVEAlbumAssetModelMediaTypeVideo;
    }
    return NO;
}

- (void)p_didUnselectedAssetWithMixedUpload:(DVEAlbumAssetModel *)model
{
    model.selectedNum = nil;
    if ([self enableOptimizeRecordAlbum]) {
        [self ab_updateAssetModel:model type:DVEAlbumGetResourceTypeImageAndVideo isSelected:NO];
        [self ab_updateAssetModel:model type:DVEAlbumGetResourceTypeImage isSelected:NO];
        [self ab_updateAssetModel:model type:DVEAlbumGetResourceTypeVideo isSelected:NO];
    } else {
        // synchronize unselected data
        [self syncSelectedAmount:model];

        
        if (model.selectedAmount == 0) {
            DVEAlbumAssetModel *mixed = [self p_findAssetWithAssetModels:self.albumDataModel.mixedSelectAssetsModels localIdentifier:model.asset.localIdentifier];
            mixed.selectedNum = nil;
            [self.albumDataModel removeAsset:mixed forResourceType:DVEAlbumGetResourceTypeImageAndVideo];
    
            DVEAlbumAssetModel *photo = [self p_findAssetWithAssetModels:self.albumDataModel.photoSelectAssetsModels localIdentifier:model.asset.localIdentifier];
            photo.selectedNum = nil;
            [self.albumDataModel removeAsset:photo forResourceType:DVEAlbumGetResourceTypeImage];
    
            DVEAlbumAssetModel *video = [self p_findAssetWithAssetModels:self.albumDataModel.videoSelectAssetsModels localIdentifier:model.asset.localIdentifier];
            video.selectedNum = nil;
            [self.albumDataModel removeAsset:video forResourceType:DVEAlbumGetResourceTypeVideo];
        }

    }
    // udpate selected number
    [self.albumDataModel willChangeValueForKey:@"mixedSelectAssetsModels"];
    for (NSInteger i = 0; i < self.albumDataModel.mixedSelectAssetsModels.count; i++) {
        DVEAlbumAssetModel *mixedTmp = self.albumDataModel.mixedSelectAssetsModels[i];
        DVEAlbumAssetModel *photoTmp = [self p_findAssetWithAssetModels:self.albumDataModel.photoSelectAssetsModels localIdentifier:mixedTmp.asset.localIdentifier];
        DVEAlbumAssetModel *videoTmp = [self p_findAssetWithAssetModels:self.albumDataModel.videoSelectAssetsModels localIdentifier:mixedTmp.asset.localIdentifier];
        mixedTmp.selectedNum = @(i + 1);
        photoTmp.selectedNum = @(i + 1);
        videoTmp.selectedNum = @(i + 1);
    }
    [self.albumDataModel didChangeValueForKey:@"mixedSelectAssetsModels"];
}

- (DVEAlbumAssetModel *)p_findAssetWithAssetModels:(NSMutableArray<DVEAlbumAssetModel *> *)models localIdentifier:(NSString *)localIdentifier
{
    if (TOC_isEmptyArray(models) || TOC_isEmptyString(localIdentifier)) {
        return nil;
    }
    
    for (DVEAlbumAssetModel *model in models) {
        if ([model.asset.localIdentifier isEqual:localIdentifier]) {
            return model;
        }
    }
    
    return nil;
}

- (NSIndexPath *)indexPathForOffset:(NSInteger)offset resourceType:(DVEAlbumGetResourceType)type
{
    if (offset <= 0) {
        return [NSIndexPath indexPathForRow:0 inSection:0];
    }
    if ([self enableOptimizeRecordAlbum]) {
        return [self ab_indexPathForOffset:offset resourceType:type];
    }
    NSInteger col = 0;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    for (DVEAlbumSectionModel *section in [self dataSourceWithResourceType:type]) {
        if (offset > section.assetsModels.count) {
            offset = offset - section.assetsModels.count;
            col++;
        } else {
            indexPath = [NSIndexPath indexPathForRow:offset inSection:col];
        }
    }
    
    return indexPath;
}

- (NSIndexPath *)ab_indexPathForOffset:(NSInteger)offset resourceType:(DVEAlbumGetResourceType)type
{
    NSInteger col = 0;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    for (DVEAlbumSectionModel *section in [self ab_dataSourceWithResourceType:type]) {
        if (offset > [section.assetDataModel numberOfObject]) {
            offset = offset - [section.assetDataModel numberOfObject];
            col++;
        } else {
            indexPath = [NSIndexPath indexPathForRow:offset inSection:col];
        }
    }

    return indexPath;
}


#pragma mark - Handle Next Data
//
//- (void)handleSelectedAssets:(NSArray<DVEAlbumAssetModel *> *)assetModelArray
//                  trackBlock:(void(^)(DVEAlbumAssetModel *assetModel))trackBlock
//                  completion:(void (^)(NSMutableArray *assetArray, NSMutableArray *locationInfos))completion
//{
//    //add mask view
//    UIView *maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    maskView.backgroundColor = [UIColor clearColor];
//    [[[UIApplication sharedApplication].delegate window] addSubview:maskView];
//
//    NSMutableArray *assetArray = [NSMutableArray array];
//    NSMutableArray *locationInfos = [NSMutableArray array];
//    self.lastVideoArray = assetArray;
//
//    for (NSInteger i = 0; i < assetModelArray.count; i++) {
//        [assetArray addObject:@1];
//    }
//
//    for (NSInteger i = 0; i < assetModelArray.count; i++) {
//        DVEAlbumAssetModel *assetModel = [[assetModelArray acc_objectAtIndex:i] copy];
//        [locationInfos acc_addObject:assetModel.asset.location];
//
//        PHAsset *sourceAsset = assetModel.asset;
//        const PHAssetMediaType mediaType = sourceAsset.mediaType;
//
//        @weakify(self);
//        if (PHAssetMediaTypeImage == mediaType) {
//            [self p_fetchImageAsset:assetModel completion:^(DVEAlbumAssetModel *model) {
//                if (model) {
//                    [assetArray replaceObjectAtIndex:i withObject:assetModel];
//                    for (id item in assetArray) {
//                        if ([item isKindOfClass:[NSNumber class]]) {
//                            return;
//                        }
//                    }
//
//                    [maskView removeFromSuperview];
//                    TOCBLOCK_INVOKE(completion, assetArray, locationInfos);
//                } else {
//                    [maskView removeFromSuperview];
//                    TOCBLOCK_INVOKE(completion, nil, nil);
//                }
//            }];
//        } else if (PHAssetMediaTypeVideo == mediaType) {
//            [self p_fetchVideoAsset:assetModel completion:^(DVEAlbumAssetModel *model, BOOL isICloud) {
//                @strongify(self);
//                if (!model && isICloud) {
//                    [[DVEAlbumToastImpl new] show:TOCLocalizedString(@"com_mig_videos_are_syncing_from_icloud_please_retry_later", @"部分视频正在从iCloud同步，请稍后再试")];
//                    [self requestAVAssetFromiCloudWithModel:assetModel idx:i videoArr:assetArray locationInfos:locationInfos assetModelArray:assetModelArray completion:completion];
//                    [maskView removeFromSuperview];
//                    return;
//                }
//
//                if (model) {
//                    [assetArray replaceObjectAtIndex:i withObject:assetModel];
//
//                    for (id item in assetArray) {
//                        if ([item isKindOfClass:[NSNumber class]]) {
//                            return;
//                        }
//                    }
//
//                    [maskView removeFromSuperview];
//                    TOCBLOCK_INVOKE(completion, assetArray, locationInfos);
//
//                    if (trackBlock && [assetArray.firstObject isKindOfClass:[DVEAlbumAssetModel class]]) {
//                        DVEAlbumAssetModel *firstAssetModel = (DVEAlbumAssetModel *)assetArray.firstObject;
//                        trackBlock(firstAssetModel);
//                    }
//                    return;
//                }
//
//                [maskView removeFromSuperview];
//                TOCBLOCK_INVOKE(completion, nil, nil);
//            }];
//        }
//    }
//}
//
//- (void)handleSelectedAssetsWithPhotoToVideo:(NSArray<DVEAlbumAssetModel *> *)assetModelArray
//                                  completion:(void (^)(NSMutableArray *assetArray, BOOL success))completion
//{
//    self.mvTemplateManager = nil;
//    self.mvTemplateManager = DVEAutoInline(DVEBaseServiceProvider(),DVEMVTemplateManagerProtocol);
//    if (self.inputData.originUploadPublishModel) {
//        self.mvTemplateManager.publishModel = self.inputData.originUploadPublishModel.copy;
//    } else {
//        self.mvTemplateManager.publishModel = [TOCPublishModel new];
//    }
//    @weakify(self);
//    [self.mvTemplateManager exportMVVideoWithAssetModels:self.currentSelectAssetModels failedBlock:^{
//        TOCBLOCK_INVOKE(completion, nil, NO);
//        [[DVEAlbumToastImpl new] showError:TOCLocalizedString(@"com_mig_there_was_a_problem_with_the_internet_connection_try_again_later_yq455g", @"网络不给力，请稍后重试")];
//    } successBlock:^{
//        @strongify(self);
//        self.mvTemplateManager = nil;
//        TOCBLOCK_INVOKE(completion, nil, YES);
//    }];
//}

- (void)requestAVAssetFromiCloudWithModel:(DVEAlbumAssetModel *)assetModel
                                      idx:(NSUInteger)index
                                 videoArr:(NSMutableArray *)videoArray
                            locationInfos:(NSMutableArray *)locationInfos
                          assetModelArray:(NSArray *)assetModelArray
                               completion:(void (^)(NSMutableArray *assetArray, NSMutableArray *locationInfos))completion
{
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    if (@available(iOS 14.0, *)) {
        options.version = PHVideoRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    }

    //run animation ahead
    assetModel.iCloudSyncProgress = 0.f;
    [self p_updateProgressWithModel:assetModel];
    
    @weakify(self);//icloud download
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if (assetModel && [self topVCIsListVC] && [self.lastVideoArray isEqual:videoArray]) {
                assetModel.iCloudSyncProgress = progress;
                [self p_updateProgressWithModel:assetModel];
            }
        });
    };
    if (@available(iOS 14.0, *)) {
        options.version = PHVideoRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    }

    NSTimeInterval icloudFetchStart = CFAbsoluteTimeGetCurrent();
    PHAsset *sourceAsset = assetModel.asset;
    NSURL *url = [sourceAsset valueForKey:@"ALAssetURL"];
    [[PHImageManager defaultManager] requestAVAssetForVideo:sourceAsset
                                                    options:options
                                              resultHandler:^(AVAsset *_Nullable asset, AVAudioMix *_Nullable audioMix,
                                                              NSDictionary *_Nullable info) {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      @strongify(self);
                                                      if ([self topVCIsListVC]) {
                                                          if (asset) {
                                                              assetModel.avAsset = asset;
                                                              if (TOCSYSTEM_VERSION_LESS_THAN(@"9") && assetModel.mediaSubType == DVEAlbumAssetModelMediaSubTypeVideoHighFrameRate) {
                                                                  AVURLAsset *urlAsset = [AVURLAsset assetWithURL:url];
                                                                  if (urlAsset) {
                                                                      assetModel.avAsset = urlAsset;
                                                                  }
                                                              }
                                                              
                                                              assetModel.info = info;
                                                              if ([videoArray count] > index && assetModel) {
                                                                  [videoArray replaceObjectAtIndex:index withObject:assetModel];
                                                              }
                                                              
                                                              for (id item in videoArray) {
                                                                  if ([item isKindOfClass:[NSNumber class]]) {
                                                                      return;
                                                                  }
                                                              }
                                                              
                                                              if ([assetModelArray count] && [self.lastVideoArray isEqual:videoArray]) {
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      //goto clip page
                                                                      self.lastVideoArray = nil;
                                                                      TOCBLOCK_INVOKE(completion, videoArray, locationInfos);
                                                                  });
                                                              }
                                                              
                                                              //performance track
//                                                              NSMutableDictionary *params = @{}.mutableCopy;
//                                                              params[@"duration"] = @((NSInteger)((CFAbsoluteTimeGetCurrent() - icloudFetchStart) * 1000));
//                                                              params[@"type"] = @(0);
//                                                              __block CGFloat size = 0.f;
//                                                              NSArray<AVAssetTrack *> *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
//                                                              [tracks enumerateObjectsUsingBlock:^(AVAssetTrack * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                                                                  CGFloat rate = ([obj estimatedDataRate] / 8); // convert bits per second to bytes per second
//                                                                  CGFloat seconds = CMTimeGetSeconds([obj timeRange].duration);
//                                                                  size += seconds * rate;
//                                                              }];
//                                                              params[@"size"] = @((NSInteger)size);
//                                                              [params addEntriesFromDictionary:self.inputData.originUploadPublishModel.commonTrackInfoDic?:@{}];
//                                                              [TOCTracker() trackEvent:@"tool_performance_icloud_download" params:params.copy needStagingFlag:NO];
                                                              
                                                          } else {
                                                              //没有获取到照片
                                                              [self p_showRequestAVAssetErrorToastWithInfo:info];
                                                              
//                                                              if (info != nil) {
//                                                                  toclo(AWELogToolTagImport, @"[export] info: %@", info);
//                                                              } else {
//                                                                  AWELogToolError(AWELogToolTagImport, @"[export] info is nil");
//                                                              }
                                                          }
                                                      }
                                                  });
                                              }];
}

//- (void)p_fetchImageAsset:(DVEAlbumAssetModel *)assetModel completion:(void (^)(DVEAlbumAssetModel *model))completion
//{
//    PHAsset *sourceAsset = assetModel.asset;
//    const CGSize imageSize = CGSizeZero;//[AWEVideoRecordOutputParameter maximumImportCompositionSize];
//
//    [DVEPhotoManager getUIImageWithPHAsset:sourceAsset
//                                 imageSize:imageSize
//                      networkAccessAllowed:YES
//                           progressHandler:^(CGFloat progress, NSError *error, BOOL *stop, NSDictionary *info) {}
//                                completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
//        if (isDegraded) {
//            return;
//        }
//
//        if (photo) {
//            NSURL *imageURL = p_outputURLForPHAsset(sourceAsset);
//            NSData *imageData = UIImageJPEGRepresentation(photo, 1.0f);
//            if (imageData && imageURL) {
//                if ([imageData acc_writeToURL:imageURL atomically:YES]) {
//                    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"IESPhoto" ofType:@"bundle"];
//                    NSString *backVideoPath = [bundlePath stringByAppendingPathComponent:@"blankown2.mp4"];
//                    AVURLAsset *placeholderAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:backVideoPath] options:@{ AVURLAssetPreferPreciseDurationAndTimingKey: @(YES)}];
//                    UIImage *thumbImage = photo;
//                    if (thumbImage.size.width > 0 && thumbImage.size.height > 0) {
//                        const CGFloat screenScale = [UIScreen mainScreen].scale;
//                        CGSize thumbImageSize = CGSizeMake(48.0f * screenScale, 56.0f * screenScale);
//                        thumbImage = [thumbImage bd_imageByResizeToSize:thumbImageSize contentMode:UIViewContentModeScaleAspectFill];
//                    }
//                    placeholderAsset.frameImageURL = imageURL;
//                    placeholderAsset.thumbImage = thumbImage;
//                    assetModel.avAsset = placeholderAsset;
//
//                    TOCBLOCK_INVOKE(completion, assetModel);
//                    return;
//                } else {
////                    AWELogToolError2(@"write", AWELogToolTagNone, @"imageData write to imageURL failed.");
//                }
//            }
//        }
//
//        //fetch failed
//        TOCBLOCK_INVOKE(completion, nil);
//    }];
//}
//
//- (void)p_fetchVideoAsset:(DVEAlbumAssetModel *)assetModel completion:(void (^)(DVEAlbumAssetModel *model, BOOL isICloud))completion
//{
//    PHAsset *sourceAsset = assetModel.asset;
//    NSURL *url = [sourceAsset valueForKey:@"ALAssetURL"];
//    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
//    if (@available(iOS 14.0, *)) {
//        options.version = PHVideoRequestOptionsVersionCurrent;
//        options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
//    }
//
//    [[PHImageManager defaultManager] requestAVAssetForVideo:sourceAsset
//                                                    options:options
//                                              resultHandler:^(AVAsset *_Nullable blockAsset, AVAudioMix *_Nullable audioMix, NSDictionary *_Nullable info) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            BOOL isICloud = [info[PHImageResultIsInCloudKey] boolValue];
//            assetModel.isFromICloud = isICloud;
//
//            if (isICloud && !blockAsset) {
//                TOCBLOCK_INVOKE(completion, nil, YES);
//            } else if(blockAsset) {
//                assetModel.avAsset = blockAsset;
//                if (TOCSYSTEM_VERSION_LESS_THAN(@"9") && assetModel.mediaSubType == DVEAlbumAssetModelMediaSubTypeVideoHighFrameRate) {
//                    AVURLAsset *urlAsset = [AVURLAsset assetWithURL:url];
//                    if (urlAsset) {
//                        assetModel.avAsset = urlAsset;
//                    }
//                }
//                assetModel.info = info;
//
//                TOCLogInfo(AWELogToolTagAIClip, @"[export] block asset is not nil, info: %@", info);
//
//                TOCBLOCK_INVOKE(completion, assetModel, NO);
//            } else {
//                //fetch failed
//                [self p_showRequestAVAssetErrorToastWithInfo:info];
//
//                if (info != nil) {
//                    TOCLogError(AWELogToolTagAIClip,@"info: %@", info);
//                } else {
//                    TOCLogError(AWELogToolTagAIClip,@"info is nil");
//                }
//
//                TOCBLOCK_INVOKE(completion, nil, NO);
//            }
//        });
//    }];
//}

- (void)p_showRequestAVAssetErrorToastWithInfo:(NSDictionary *)info
{
    void (^showToastBlock)(NSDictionary *info) = ^(NSDictionary *info) {
        if (!info) {
            [[DVEAlbumToastImpl new] show:TOCLocalizedString(@"error_param", @"出错了")];
            return;
        }
        
        id errorObject = [info objectForKey:PHImageErrorKey];
        if (!errorObject || ![errorObject isKindOfClass:[NSError class]]) {
            [[DVEAlbumToastImpl new] show:TOCLocalizedString(@"error_param", @"出错了")];
            return;
        }
        
        NSError *error = errorObject;
        if (kICloudDiskSpaceLowErrorCode == error.code) {
            [[DVEAlbumToastImpl new] show:TOCLocalizedString(@"not_enough_storage_error_tips", @"出错了")];
        } else {
            [[DVEAlbumToastImpl new] show:TOCLocalizedString(@"error_param", @"出错了")];
        }
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        TOCBLOCK_INVOKE(showToastBlock, info);
    });
}

- (void)p_updateProgressWithModel:(DVEAlbumAssetModel *)assetModel {
    [self.currentSelectAssetModels enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(DVEAlbumAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.asset.localIdentifier && assetModel.asset.localIdentifier && [obj.asset.localIdentifier isEqualToString:assetModel.asset.localIdentifier]) {
            obj.iCloudSyncProgress = assetModel.iCloudSyncProgress;//cell has kvo
            *stop = YES;
        }
    }];
}

- (BOOL)topVCIsListVC
{
    UIViewController *topVC = [DVEAlbumResponder topViewController];
    if ([topVC isKindOfClass:[DVEAlbumListViewController class]]) {
        return YES;
    }
    
    return NO;
}

- (void)onNext {
    TOCBLOCK_INVOKE(self.nextAction);
}

#pragma mark - Time Data

- (NSArray<DVEAlbumSectionModel *> *)p_dataStructureConvert:(NSArray<DVEAlbumAssetModel *> *)originDataSource resourceType:(DVEAlbumGetResourceType)resourceType
{
    NSMutableArray *dataSource = [NSMutableArray array];
    if (originDataSource.count != 0) {
        NSMutableArray<DVEAlbumAssetModel *> *sameDateAssetArr = [[NSMutableArray alloc] init];
        for (DVEAlbumAssetModel *assetModel in originDataSource) {
            if (sameDateAssetArr.count == 0) {
                [sameDateAssetArr addObject:assetModel];
            } else {
                if ([self p_isSameDay:sameDateAssetArr.lastObject.creationDate date2:assetModel.creationDate]) {
                    [sameDateAssetArr addObject:assetModel];
                } else {
                    DVEAlbumSectionModel *sectionModel = [DVEAlbumSectionModel new];
                    sectionModel.title = sameDateAssetArr.firstObject.dateFormatStr;
                    sectionModel.resourceType = resourceType;
                    sectionModel.assetsModels = sameDateAssetArr;
                    [dataSource addObject:sectionModel];
                    
                    sameDateAssetArr = [[NSMutableArray alloc] init];
                    [sameDateAssetArr addObject:assetModel];
                }
            }
            [self p_formatDateToStr:assetModel];
        }
        if ([sameDateAssetArr count] > 0) {
            DVEAlbumSectionModel *sectionModel = [DVEAlbumSectionModel new];
            sectionModel.title = sameDateAssetArr.firstObject.dateFormatStr;
            sectionModel.resourceType = resourceType;
            sectionModel.assetsModels = sameDateAssetArr;
            [dataSource addObject:sectionModel];
        }
    }
    
    return dataSource;
}

- (BOOL)p_isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
    if (![date1 isKindOfClass:[NSDate class]] || ![date2 isKindOfClass:[NSDate class]]){
        return NO;
    }
    NSCalendar* calendar = [NSCalendar currentCalendar];

    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];

    return [comp1 day] == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year]  == [comp2 year];
}

- (void)p_formatDateToStr:(DVEAlbumAssetModel *)assetModel{
    if (self.format == nil) {
        self.format = [[NSDateFormatter alloc] init];
    }
    NSString *dateFormat = @"yyyy/MM/dd";
    
    long year = 0;
    long month = 0;
    long day = 0;
    NSString *week = @"";
    [self p_getNumFromDate:assetModel.creationDate week:&week year:&year month:&month day:&day];
    if (year > 0 && month > 0 && day > 0 && [week length] > 0) {
//        if (![[TOCI18NConfig() currentLanguage] isEqualToString:@"zh"]) {
//            dateFormat = TOCLocalizedString(@"album_date",@"");
//            self.format.dateFormat = dateFormat;
//            if (assetModel.creationDate) {
//                assetModel.dateFormatStr = [self.format stringFromDate:assetModel.creationDate];
//            } else {
//                assetModel.dateFormatStr = @"";
//            }
//            assetModel.dateFormatStr = [NSString stringWithFormat:@"%@, %@",week,assetModel.dateFormatStr];
//            NSRange yRange = [dateFormat rangeOfString:@"y"];
//            NSRange mRange = [dateFormat rangeOfString:@"M"];
//            if (yRange.location == NSNotFound || mRange.location == NSNotFound || yRange.location > mRange.location) {
//                [NSString stringWithFormat:@"%02ld-%ld", month, year];
//            } else {
//                [NSString stringWithFormat:@"%ld-%02ld", year, month];
//            }
//
//        } else {
            assetModel.dateFormatStr = [NSString stringWithFormat:@"%ld年%02ld月%02ld日 %@",year,month,day,week];
            [NSString stringWithFormat:@"%ld年%02ld月", year, month];
//        }
    } else {
        assetModel.dateFormatStr = @"";
    }
}

- (void)p_getNumFromDate:(NSDate *)date week:(NSString **)week year:(long *)year month:(long *)month day:(long *)day{
    if (date == nil){
        return;
    }
    *week = @"";
    if (self.calendar == nil) {
        self.calendar = [NSCalendar currentCalendar];
    }
    
    unsigned unitFlags = NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents* comp = [self.calendar components:unitFlags fromDate:date];
   
    *year = [comp year];
    *month = [comp month];
    *day = [comp day];
    NSInteger weekIndex = [comp weekday];
    switch(weekIndex) {
        case 1:
            *week = TOCLocalizedString(@"album_date_week_Sunday",@"星期日");
            break;
        case 2:
            *week = TOCLocalizedString(@"album_date_week_Monday",@"星期一");
            break;
        case 3:
            *week = TOCLocalizedString(@"album_date_week_Tuesday",@"星期二");
            break;
        case 4:
            *week = TOCLocalizedString(@"album_date_week_Wednesday",@"星期三");
            break;
        case 5:
            *week = TOCLocalizedString(@"album_date_week_Thursday",@"星期四");
            break;
        case 6:
            *week = TOCLocalizedString(@"album_date_week_Friday",@"星期五");
            break;
        case 7:
            *week = TOCLocalizedString(@"album_date_week_Saturday",@"星期六");
            break;
        default:
            *week = @"";
            break;
    }
}

#pragma mark - Utils

- (void)p_registerPhotoLibraryChangeObserver
{
    if ([DVEAlbumDeviceAuth isiOS14PhotoNotDetermined] && YES) {
        return;
    }
    if (!self.hasRegisterChangeObserver) {
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        self.hasRegisterChangeObserver = YES;
    }
}

- (void)p_doActionForAllAlbumListVcModel:(void (^)(DVEAlbumVCModel *vcModel, NSInteger index))actionBlock
{
    for (DVEAlbumVCModel *item in self.inputData.tabsInfo) {
        if ([item.listViewController isKindOfClass:[DVEAlbumListViewController class]]) {
            NSInteger index = [self.inputData.tabsInfo indexOfObject:item];
            TOCBLOCK_INVOKE(actionBlock, item, index);
        }
    }
}

- (void)p_doActionForAllListVcModel:(void (^)(DVEAlbumVCModel *vcModel, NSInteger index))actionBlock
{
    for (DVEAlbumVCModel *item in self.inputData.tabsInfo) {
        NSInteger index = [self.inputData.tabsInfo indexOfObject:item];
        TOCBLOCK_INVOKE(actionBlock, item, index);
    }
}

#pragma mark - Valid

- (BOOL)validPixel:(PHAsset *)phasset
{
    return YES;
}

- (BOOL)validPHAsset:(PHAsset *)phasset resourceType:(DVEAlbumGetResourceType)resourceType
{
    if (resourceType == DVEAlbumGetResourceTypeImage) {
        return phasset.mediaType == PHAssetMediaTypeImage;
    } else if (resourceType == DVEAlbumGetResourceTypeVideo) {
        return phasset.mediaType == PHAssetMediaTypeVideo;
    } else if (resourceType == DVEAlbumGetResourceTypeImageAndVideo) {
        return phasset.mediaType == PHAssetMediaTypeImage || phasset.mediaType == PHAssetResourceTypeVideo;
    }
    return NO;
}

- (NSUInteger)maxSelectionCount
{
    if (self.doNotLimitInternalSelectCount) {
        return NSUIntegerMax;
    }
    
    if (self.vcType == DVEAlbumVCTypeForCutSame || self.vcType == DVEAlbumVCTypeForCutSameChangeMaterial) {
        return self.inputData.maxPictureSelectionCount;
    }
    
    if ([self.configViewModel enableAIVideoClipMode]) {
        return kDVEMaxAssetCountForAIClipMode - self.inputData.initialSelectedPictureCount;
    }
    
    return self.inputData.maxPictureSelectionCount;
}

#pragma mark - Tracker

//- (NSString *)shootWay
//{
//    if (self.inputData.fromShareExtension) {
//        return self.inputData.originUploadPublishModel.referString = @"system_upload";
//    } else if (self.inputData.originUploadPublishModel.referString) {
//        return self.inputData.originUploadPublishModel.referString;
//    } else {
//        return self.inputData.fromStickPointAnchor ? @"upload_anchor" : @"direct_shoot";
//    }
//}

#pragma mark - setter

- (void)setHasRequestAuthorizationForAccessLevel:(BOOL)hasRequestAuthorizationForAccessLevel
{
    _hasRequestAuthorizationForAccessLevel = hasRequestAuthorizationForAccessLevel;

    if (_hasRequestAuthorizationForAccessLevel) {
        [self p_registerPhotoLibraryChangeObserver];
    }
}

#pragma mark - Getter

- (CGFloat)choosedTotalDuration
{
    if (TOC_isEmptyArray(self.currentSelectAssetModels)) {
        return 0;
    }
    
    __block CGFloat duration = 0;
    [self.currentSelectAssetModels enumerateObjectsUsingBlock:^(DVEAlbumAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        duration += obj.asset.duration;
    }];
    
    return duration;
}

- (NSInteger)defaultSelectedIndex
{
    for (DVEAlbumVCModel *model in self.inputData.tabsInfo) {
        if (model.resourceType == self.inputData.defaultResourceType) {
            return [self.inputData.tabsInfo indexOfObject:model];
        }
    }
    
    return 0;
}

- (DVEAlbumGetResourceType)resourceType
{
    DVEAlbumVCModel *model = [self.inputData.tabsInfo acc_objectAtIndex:self.currentSelectedIndex];
    return model.resourceType;
}

- (NSInteger)currentSelectedAssetsCount
{
    return [self currentSelectAssetModels].count;
}

- (NSMutableArray<DVEAlbumAssetModel *> *)currentSourceAssetModels
{
    if (self.resourceType == DVEAlbumGetResourceTypeImage) {
        return self.albumDataModel.photoSourceAssetsModels;
    } else if (self.resourceType == DVEAlbumGetResourceTypeVideo) {
        return self.albumDataModel.videoSourceAssetsModels;
    } else {
        return self.albumDataModel.mixedSourceAssetsModels;
    }
}

- (NSMutableArray<DVEAlbumAssetModel *> *)currentSelectAssetModels
{
    
    NSMutableArray *marray = [NSMutableArray new];
    for (DVEImportMaterialSelectCollectionViewCellModel *model in self.selectedViewModels) {
        if (model.assetModel) {
            [marray addObject:model.assetModel];
        }
    }
    
    return marray;
    
//    if (self.enableMixedUploading) {
//        return self.albumDataModel.mixedSelectAssetsModels;
//    } else {
//        if (self.resourceType == DVEAlbumGetResourceTypeImage) {
//            return self.albumDataModel.photoSelectAssetsModels;
//        } else if (self.resourceType == DVEAlbumGetResourceTypeVideo) {
//            return self.albumDataModel.videoSelectAssetsModels;
//        } else {
//            return self.albumDataModel.mixedSelectAssetsModels;
//        }
//    }
}


//- (NSMutableArray<DVEAlbumAssetModel *> *)ab_currentSelectAssetModels
//{
//    if (self.resourceType == DVEAlbumGetResourceTypeImage) {
//        return self.albumDataModel.photoSelectAssetsModels;
//    } else if (self.resourceType == DVEAlbumGetResourceTypeVideo) {
//        return self.albumDataModel.videoSelectAssetsModels;
//    } else {
//        return self.albumDataModel.mixedSelectAssetsModels;
//    }
//}

- (NSMutableArray<DVEAlbumAssetModel *> *)currentHandleSelectAssetModels
{
    if (self.resourceType == DVEAlbumGetResourceTypeImage) {
        return self.albumDataModel.photoSelectAssetsModels;
    } else if (self.resourceType == DVEAlbumGetResourceTypeVideo) {
        return self.albumDataModel.videoSelectAssetsModels;
    } else {
        return self.albumDataModel.mixedSelectAssetsModels;
    }
}

//- (PHFetchResult *)fetchResult
//{
//    return self.albumDataModel.fetchResult;
//}

- (BOOL)enableMixedUploading
{
    return self.configViewModel.enableMixedUploadAB && self.inputData.enableMixedUpload;
}

- (BOOL)showMomentsTab
{
    return NO;
}

- (BOOL)showAllTab
{
    return [self.configViewModel enableAllTab] && self.enableMixedUploading;
}

- (BOOL)hasSelectedAssets
{
    return self.currentSelectAssetModels.count > 0;
}

- (BOOL)hasSelectedMaxCount
{
    return self.currentSelectAssetModels.count >= [self maxSelectionCount];
}

//- (BOOL)enableNextActionForPhoto
//{
//    return NO;
//}

- (DVEAlbumVCType)vcType
{
    return self.inputData.vcType;
}

- (BOOL)isVideoAndPicMixed
{
    return true;
//    return self.inputData.isVideoAndPicMixed;
}

- (BOOL)hasSelectedVideo
{
    return self.albumDataModel.videoSelectAssetsModels.count > 0;
}

- (BOOL)hasSelectedPhoto
{
    return self.albumDataModel.photoSelectAssetsModels.count > 0;
}

//- (BOOL)isDefault
//{
//    return self.inputData.vcType == DVEAlbumVCTypeForUpload;
//}

- (BOOL)isStory
{
    return NO;
}

- (BOOL)isMV
{
    return NO;
}

//- (BOOL)isPixaloop
//{
//    return NO;
//}

- (BOOL)isAIClip
{
    BOOL photoToAIVideo = self.hasSelectedPhoto && self.configViewModel.enableMutilPhotosToAIVideo && ![self isOnePhoto];
    return (self.hasSelectedVideo || photoToAIVideo);
}

- (BOOL)isAIClipAppend
{
    return NO;
}

- (BOOL)isCutSame
{
    return self.inputData.vcType == DVEAlbumVCTypeForCutSame;
}

- (BOOL)isCutSameChangeMaterial
{
    return self.inputData.vcType == DVEAlbumVCTypeForCutSameChangeMaterial;
}

//- (BOOL)isPhotoToVideo
//{
//    return NO;
//}

- (BOOL)isOnePhoto
{
    return !self.hasSelectedVideo && self.albumDataModel.photoSelectAssetsModels.count == 1;
}

//- (BOOL)isFirstCreative {
//    return NO;
//}

- (DVEAlbumViewUIConfig *)albumViewUIConfig
{
    return self.inputData.albumViewUIConfig;
}

@end


