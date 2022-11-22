//
//  DVEAlbumInputData.m
//  CameraClient
//
//  Created by bytedance on 2020/6/16.
//

#import "DVEAlbumInputData.h"
#import "NSArray+DVEAlbumAdditions.h"

@implementation DVEAlbumInputData

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scrollToBottom = YES;
        self.ascendingOrder = YES;
        self.enablePicture = YES;
        self.enableMixedUpload = YES;
        
        self.maxPictureSelectionCount = 1;
        self.minPictureSelectionCount = 1;
        self.defaultResourceType = -1;
    }
    return self;
}

- (NSArray *)titles
{
    NSMutableArray *array = [NSMutableArray array];
    for (DVEAlbumVCModel *item in self.tabsInfo) {
        [array acc_addObject:item.title];
    }
    
    return [array copy];
}

- (NSArray<UIViewController *> *)listViewControllers
{
    NSMutableArray *array = [NSMutableArray array];
    for (DVEAlbumVCModel *item in self.tabsInfo) {
        [array acc_addObject:item.listViewController];
    }
    
    return [array copy];
}

#pragma mark - Setter

- (void)setCutSameTemplateModel:(DVEAlbumTemplateModel *)cutSameTemplateModel
{
    _cutSameTemplateModel = cutSameTemplateModel;
    
    if (cutSameTemplateModel) {
        _maxPictureSelectionCount = cutSameTemplateModel.fragmentCount;
    }
}

- (void)setSingleFragment:(DVEAlbumCutSameFragmentModel *)singleFragment
{
    _singleFragment = singleFragment;
    
    if (singleFragment) {
        _maxPictureSelectionCount = 1;
    }
}

@end
