//
//  DVEAlbumFactoryManager.m
//  AWEStudio-Pods-Aweme
//
//  Created by bytedance on 2020/8/12.
//

#import "DVEAlbumFactoryManager.h"
#import "DVEAlbumLanguageProtocol.h"

@implementation DVEAlbumFactoryManager


+ (UIViewController<DVEAlbumSelectAlbumAssetsComponetProtocol> *)albumControllerWithAlbumInputData:(DVEAlbumInputData *)input
{
    DVEAlbumViewModel *viewModel = [[DVEAlbumViewModel alloc] initWithAlbumInputData:input];
    input.tabsInfo = [DVEAlbumFactoryManager configTabsInfoWithViewModel:viewModel inputData:input];
    
    DVEStudioAlbumViewController *vc = [[DVEStudioAlbumViewController alloc] initWithAlbumViewModel:viewModel];
    
    [input.tabsInfo enumerateObjectsUsingBlock:^(DVEAlbumVCModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.listViewController conformsToProtocol:@protocol(DVEAlbumListViewControllerProtocol)]) {
            ((UIViewController<DVEAlbumListViewControllerProtocol> *)obj.listViewController).vcDelegate = vc;
        }
    }];
    
    return vc;
}

+ (DVEAlbumVCModel *)albumListVCModelWithResourceType:(DVEAlbumGetResourceType)type viewModel:(DVEAlbumViewModel *)viewModel
{
    DVEAlbumListViewController *listVC = [[DVEAlbumListViewController alloc] initWithResourceType:type];
    listVC.viewModel = viewModel;
    DVEAlbumVCModel *vcModel = [[DVEAlbumVCModel alloc] init];
    vcModel.listViewController = listVC;
    vcModel.resourceType = type;
    
    switch (type) {
        case DVEAlbumGetResourceTypeImage:
            vcModel.title = TOCLocalizedString(@"ck_all_image", @"图片");
            break;
        case DVEAlbumGetResourceTypeVideo:
            vcModel.title = TOCLocalizedString(@"ck_all_video",@"视频");
            break;
        case DVEAlbumGetResourceTypeImageAndVideo:
            vcModel.title = TOCLocalizedString(@"ck_all_dir_name",@"所有内容");
            break;
            
        default:
            break;
    }
    
    return vcModel;
}

#pragma mark - Config

+ (NSArray<DVEAlbumVCModel *> *)configTabsInfoWithViewModel:(DVEAlbumViewModel *)viewModel inputData:(DVEAlbumInputData *)inputData
{
    DVEAlbumVCModel *mixedModel = [DVEAlbumFactoryManager albumListVCModelWithResourceType:DVEAlbumGetResourceTypeImageAndVideo viewModel:viewModel];
    DVEAlbumVCModel *videoModel = [DVEAlbumFactoryManager albumListVCModelWithResourceType:DVEAlbumGetResourceTypeVideo viewModel:viewModel];
    DVEAlbumVCModel *photoModel = [DVEAlbumFactoryManager albumListVCModelWithResourceType:DVEAlbumGetResourceTypeImage viewModel:viewModel];
    
    NSArray *tabsInfo = nil;
    switch (inputData.vcType) {
        default:
        {
            tabsInfo = [DVEAlbumFactoryManager configDefaultTabsInfoWithViewModel:viewModel
                                                                        inputData:inputData
                                                                       mixedModel:mixedModel
                                                                       videoModel:videoModel
                                                                       photoModel:photoModel];
        }
            break;
    }
    
    return tabsInfo;
}

+ (NSArray<DVEAlbumVCModel *> *)configDefaultTabsInfoWithViewModel:(DVEAlbumViewModel *)viewModel
                                                          inputData:(DVEAlbumInputData *)inputData
                                                         mixedModel:(DVEAlbumVCModel *)mixedModel
                                                         videoModel:(DVEAlbumVCModel *)videoModel
                                                         photoModel:(DVEAlbumVCModel *)photoModel;
{
    videoModel.canMutilSelected = viewModel.enableMixedUploading;
    mixedModel.canMutilSelected = viewModel.enableMixedUploading;
    photoModel.canMutilSelected = YES;
    
    BOOL enabledMixedUploadingForAIVideoClip = NO;

    NSMutableArray *tabsInfo;
    if (viewModel.inputData.enablePicture || enabledMixedUploadingForAIVideoClip) {
        tabsInfo = @[videoModel, photoModel].mutableCopy;
        
        if (viewModel.showAllTab) {
            tabsInfo = @[mixedModel, videoModel, photoModel].mutableCopy;
        }
        
//        if (viewModel.showMomentsTab && [ACCAlbumExteranl() respondsToSelector:@selector(externalAlbumVCModels)] && [ACCAlbumExteranl() externalAlbumVCModels]) {
//            NSArray *externalVcModels = [ACCAlbumExteranl() externalAlbumVCModels];
//            [tabsInfo addObjectsFromArray:externalVcModels];
//
//            if (viewModel.inputData.landMomentsTab) {
//                inputData.defaultResourceType = DVEAlbumGetResourceTypeMoments;
//            }
//        }
        
        inputData.isStoryMode = NO;
    } else {
        tabsInfo = @[videoModel].mutableCopy;
        
        videoModel.canMutilSelected = NO;
        inputData.needBottomView = YES;
    }
    
    if (inputData.defaultResourceType == DVEAlbumGetResourceTypeImage) {
        [tabsInfo removeObjectsInArray:@[mixedModel, videoModel]];
    } else if (inputData.defaultResourceType == DVEAlbumGetResourceTypeVideo) {
        [tabsInfo removeObjectsInArray:@[mixedModel, photoModel]];
    }
    
    return tabsInfo.copy;
}

@end
