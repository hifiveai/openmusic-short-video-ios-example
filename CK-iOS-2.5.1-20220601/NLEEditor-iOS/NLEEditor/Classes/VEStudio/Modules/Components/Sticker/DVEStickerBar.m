//
//  VEVCStickerBar.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEStickerBar.h"
#import "DVEStickerItem.h"
#import "DVEViewController.h"
#import "DVEVCContext.h"
#import "DVEBundleLoader.h"
#import <DVETrackKit/UIView+VEExt.h>
#import <DVETrackKit/NLEVideoFrameModel_OC+NLE.h>
#import "DVEUIHelper.h"
#import "NSString+VEToImage.h"
#import "NSString+VEIEPath.h"
#import "DVEEffectsBarBottomView.h"
#import "DVEPickerView.h"
#import "DVEModuleBaseCategoryModel.h"
#import "DVEStickerCategoryCell.h"
#import "DVEStickerPickerUIDefaultConfiguration.h"
#import "DVECustomerHUD.h"
#import "DVELoggerImpl.h"
#import <DVETrackKit/DVEUILayout.h>
#import "DVEReportUtils.h"
#import <YYWebImage/YYWebImage.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>
#import "DVEStickerCropViewController.h"

#define kVEVCStickerItemIdentifier @"kVEVCStickerItemIdentifier"

@interface DVEStickerBar () <DVEPickerViewDelegate, DVEStickerCropViewControllerDelegate,DVEStickerEditAdpterDelegate>

@property (nonatomic, strong) NSArray *filterArr;
///底部区域
@property (nonatomic, strong) UIView *bottomView;
///贴纸区域
@property (nonatomic, strong) DVEPickerView *stickerPickerView;

@property (nonatomic, strong) NLETrackSlot_OC *stickerSlot;

@property (nonatomic, strong) DVEEffectValue *currentSelected;

@property (nonatomic, weak) id<DVECoreStickerProtocol> stickerEditor;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVEResourcePickerProtocol> resourcePicker;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVECoreSlotProtocol> slotEditor;
@end

@implementation DVEStickerBar
DVEAutoInject(self.vcContext.serviceProvider, slotEditor, DVECoreSlotProtocol)
DVEAutoInject(self.vcContext.serviceProvider, stickerEditor, DVECoreStickerProtocol)
DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEOptionalInject(self.vcContext.serviceProvider, resourcePicker, DVEResourcePickerProtocol)

- (void)dealloc
{
    DVELogInfo(@"VEVCStickerBar dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    
    return self;
}

- (void)initView
{
    [self addSubview:self.stickerPickerView];
    [self.stickerPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        id<DVEPickerUIConfigurationProtocol> config = self.stickerPickerView.uiConfig;
        make.height.mas_equalTo(config.effectUIConfig.effectListViewHeight + config.categoryUIConfig.categoryTabListViewHeight);
        make.top.left.right.equalTo(self);
    }];
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stickerPickerView.mas_bottom);
        make.left.right.bottom.equalTo(self);
    }];
}

- (void)initData
{
    
    DVEViewController *parentVC = (DVEViewController *)self.parentVC;
    parentVC.stickerEditAdatper.delegate = self;
    
    NSMutableArray<DVEEffectValue *> *values = [NSMutableArray array];
    if ([self.resourcePicker respondsToSelector:@selector(pickSingleCropImageResourceWithCompletion:)]) {
        DVEEffectValue *localValue = [[DVEEffectValue alloc] init];
        localValue.name = @"local";
        UIImage* image = [@"icon_select" dve_toImage];
        UIImage* resizeIcon = [image yy_imageByResizeToSize:[DVEUILayout dve_sizeWithName:DVEUILayoutStickerItemSize] contentMode:UIViewContentModeCenter];
        localValue.assetImage = resizeIcon;
        localValue.identifier = localValue.name;
        [values addObject:localValue];
    }

    self.actionService.isNeedHideUnReDo = YES;
    [self.stickerPickerView updateLoading];
    @weakify(self);
    [[DVEBundleLoader shareManager] sticker:self.vcContext handler:^(NSArray<DVEEffectValue *> * _Nullable datas, NSString * _Nullable error) {
        @strongify(self);
        DVEModuleBaseCategoryModel *categoryModel = [DVEModuleBaseCategoryModel new];
        DVEEffectCategory* category = [DVEEffectCategory new];
        [values addObjectsFromArray:datas];
        category.models = values;
        categoryModel.category = category;
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if(!error){
                self.filterArr = @[categoryModel];
                [self.stickerPickerView updateCategory:self.filterArr];
                [self.stickerPickerView updateFetchFinish];
            }else{
                [DVECustomerHUD showMessage:error];
                [self.stickerPickerView updateFetchError];
            }
        });
    }];
}

- (void)dismiss:(BOOL)animation {
    [super dismiss:animation];
    DVEViewController *parentVC = (DVEViewController *)self.parentVC;
    parentVC.stickerEditAdatper.delegate = parentVC;
}

- (UIView*)bottomView
{
    if(!_bottomView) {
        @weakify(self);
        _bottomView = [DVEEffectsBarBottomView newActionBarWithTitle:NLELocalizedString(@"ck_image_sticker",@"贴纸") action:^{
            @strongify(self);
            [self dismiss:YES];
            [self.actionService refreshUndoRedo];
            self.vcContext.mediaContext.selectTextSlot = self.stickerSlot;
        }];
        
        [(DVEEffectsBarBottomView *)_bottomView setResetButtonHidden:YES];
    }
    return _bottomView;
}

- (DVEPickerView *)stickerPickerView {
    
    if(!_stickerPickerView) {
        _stickerPickerView = [[DVEPickerView alloc] initWithUIConfig:[DVEStickerPickerUIDefaultConfiguration new]];
        _stickerPickerView.delegate = self;
        _stickerPickerView.backgroundColor = [UIColor clearColor];
    }
    return _stickerPickerView;
}

#pragma mark - AWEStickerPickerViewDelegate

- (BOOL)pickerView:(DVEPickerView *)pickerView
        isSelected:(DVEEffectValue*)sticker{
    return NO;
}

- (void)pickerView:(DVEPickerView *)pickerView
  didSelectSticker:(DVEEffectValue*)sticker
          category:(id<DVEPickerCategoryModel>)category
         indexPath:(NSIndexPath *)indexPath {
    
    if(sticker.status == DVEResourceModelStatusDefault){
        self.currentSelected = sticker;
        
        switch (indexPath.row) {
            case 0: {
                if ([self.resourcePicker respondsToSelector:@selector(pickSingleCropImageResourceWithCompletion:)]) {
                    @weakify(self);
                    [self.resourcePicker pickSingleCropImageResourceWithCompletion:^(NSArray<id<DVEResourcePickerModel>> * _Nonnull resources, NSError * _Nullable error, BOOL cancel) {
                        @strongify(self);
                        if (resources.count <= 0) {
                            return;
                        }
                        
                        id<DVEResourcePickerModel> resource = [resources firstObject];
                        
                        DVEStickerCropViewController *vc = [[DVEStickerCropViewController alloc] initWithImagePath:[[resource URL] path]];
                        vc.modalPresentationStyle = UIModalPresentationFullScreen;
                        vc.delegate = self;
                        [self.parentVC presentViewController:vc animated:YES completion:nil];
                    }];
                    [DVEReportUtils logEvent:@"video_edit_local_sticker_click" params:@{}];
                    return;;
                }
            }
            default: {
                DVEEffectValue *stickerValue = (DVEEffectValue*)sticker;
                NSString* path = stickerValue.imageURL.fileURL ? stickerValue.imageURL.path : stickerValue.imageURL.absoluteString;
                self.stickerSlot = [self.stickerEditor addStickerWithPath:stickerValue.sourcePath identifier:stickerValue.identifier iconURL:path];
                [pickerView updateSelectedStickerForId:stickerValue.identifier];
                break;
            }
        }

        [pickerView currentCategorySelectItemAtIndexPath:indexPath
                                                animated:YES
                                          scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        [pickerView updateSelectedStickerForId:sticker.identifier];
        return;
    } else if(sticker.status == DVEResourceModelStatusNeedDownlod || sticker.status == DVEResourceModelStatusDownlodFailed){
        @weakify(self);
        [sticker downloadModel:^(id<DVEResourceModelProtocol>  _Nonnull model) {
            [pickerView updateStickerStatusForId:model.identifier];
            if(model.status != DVEResourceModelStatusDefault) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self pickerView:pickerView didSelectSticker:sticker category:category indexPath:indexPath];
            });
        }];
    }
    [pickerView updateStickerStatusForId:sticker.identifier];
}

- (void)pickerView:(DVEPickerView *)pickerView
 didSelectTabIndex:(NSInteger)index{

}


- (void)pickerViewDidClearSticker:(DVEPickerView *)pickerView {
    
}

- (void)showInView:(UIView *)view animation:(BOOL)animation
{
    [super showInView:view animation:(BOOL)animation];
    [self initData];
}

- (NSInteger)pickerView:(DVEPickerView *)pickerView numberOfItemsInComponent:(NSInteger)component
{
    return 4;
}

- (void)cropViewController:(DVEStickerCropViewController *)viewController didFinishProcessingImage:(NSString *)imagePath
{
    DVEEffectValue *sticker = self.currentSelected;
    if (!sticker) {
        return;
    }
    
    sticker.sourcePath = imagePath;
    
    self.stickerSlot = [self.stickerEditor addNewRandomPositionImageSitckerWithPath:sticker.sourcePath];
    if (!self.stickerSlot) {
        return;
    }
    NSString *slotId = self.stickerSlot.nle_nodeId;
    DVEViewController *vc = (DVEViewController *)self.parentVC;
    [vc.stickerEditAdatper addEditBoxForSticker:slotId];
    
    [self.stickerPickerView updateSelectedStickerForId:nil];
    [self.stickerPickerView updateStickerStatusForId:sticker.identifier];
}

#pragma mark - DVEStickerEditAdpterDelegate

- (BOOL)triggerAction:(DVEEditCornerType)type segmentId:(NSString *)segmentId {
    
    DVEViewController *parentVC = (DVEViewController *)self.parentVC;

    if (type == DVECornrDelete) {
        [parentVC.stickerEditAdatper removeStickerBox:segmentId];
        NLETrackSlot_OC *slot = [self.nleEditor.nleModel slotOf:segmentId];
        BOOL mainEdit = slot ? YES : NO;
        if (!slot) {
            slot = [self.nleEditor.nleModel.coverModel slotOf:segmentId];
        }

        [self.slotEditor removeSlot:segmentId needCommit:YES isMainEdit:mainEdit];
        [DVEAutoInline(self.vcContext.serviceProvider, DVECoreActionServiceProtocol) refreshUndoRedo];
        return YES;
    }else if (type == DVECornerCopy) {
        self.stickerSlot = [self.slotEditor copyForSlot:segmentId needCommit:YES];
        [parentVC.stickerEditAdatper refreshEditBox:segmentId];
        return YES;
    } else if(type == DVECornerMirror) {
        [self.stickerEditor setStickerFilpX:segmentId];
        return YES;
    }
    return NO;
}

- (BOOL)stickerTransform:(NSString *)segmentId offsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY angle:(CGFloat)angle scale:(CGFloat)scale {
    [self.stickerEditor setSticker:segmentId offsetX:offsetX offsetY:offsetY angle:angle scale:scale isCommitNLE:NO];
    return YES;
}

@end
