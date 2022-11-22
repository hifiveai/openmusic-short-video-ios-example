//
//  DVEMaskBar.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/3/31.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "DVEMaskBar.h"
#import "DVEMaskItem.h"
#import "NSString+DVEToPinYin.h"
#import "DVEBundleLoader.h"
#import "DVEVCContext.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEUIHelper.h"
#import "NSString+VEToImage.h"
#import <NLEPlatform/NLETrackSlot+iOS.h>
#import <NLEPlatform/NLEEditor+iOS.h>
#import <NLEPlatform/NLEVideoAnimation+iOS.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>
#import <PocketSVG/PocketSVG.h>
#import "NSString+VEToImage.h"
#import "DVEViewController.h"
#import "DVEMaskConfigModel.h"
#import "DVEVideoCutBaseViewController+Private.h"
#import "DVECanvasVideoBorderView.h"
#import "DVEPickerView.h"
#import "DVEModuleBaseCategoryModel.h"
#import "DVEMaskUIConfiguration.h"
#import "DVELoggerImpl.h"
#import "DVEEffectsBarBottomView.h"

#define kVEVCMaskItemIdentifier @"kVEVCMaskItemIdentifier"

@interface DVEMaskBar () <DVEPickerViewDelegate>

@property (nonatomic, strong) DVEPickerView *pickerView;
@property (nonatomic, strong) NSArray<DVEEffectValue *> *maskModels;
@property (nonatomic, strong) DVEEffectValue *selectedModel;
@property (nonatomic, assign) BOOL isValueChanged;

@property (nonatomic, strong) UILabel *maskLabel;
///底部区域
@property (nonatomic, strong) DVEEffectsBarBottomView *bottomView;

@property (nonatomic, strong) DVEMaskConfigModel *vcConfigModel;

@property (nonatomic, weak) id<DVECoreMaskProtocol> maskEditor;
@property (nonatomic, weak) id<DVECoreKeyFrameProtocol> keyframeEditor;

@end

@implementation DVEMaskBar

DVEAutoInject(self.vcContext.serviceProvider, maskEditor, DVECoreMaskProtocol)
DVEAutoInject(self.vcContext.serviceProvider, keyframeEditor, DVECoreKeyFrameProtocol)

- (void)dealloc
{
    DVELogInfo(@"VEVCMaskBar dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        [self initSliderControlEvent];
    }
    return self;
}

- (void)setupUI
{
    [self addSubview:self.pickerView];
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        id<DVEPickerUIConfigurationProtocol> config = self.pickerView.uiConfig;
        make.height.mas_equalTo(config.effectUIConfig.effectListViewHeight + config.categoryUIConfig.categoryTabListViewHeight);
        make.left.right.equalTo(self);
        make.top.equalTo(self).offset(80);
    }];

    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pickerView.mas_bottom);
        make.left.right.bottom.equalTo(self);
    }];

    CGFloat sliderY = 37;
    CGFloat sliderWidth = CGRectGetWidth(self.frame) * 0.75;

    self.maskLabel.frame = CGRectMake(16, sliderY, 30, 20);
    [self addSubview:self.maskLabel];

    [self.slider removeFromSuperview];
    self.slider = [[DVEStepSlider alloc] initWithStep:1 defaultValue:0 frame:CGRectMake(self.maskLabel.right + 10, sliderY, sliderWidth, 20)];
    [self addSubview:self.slider];
    [self setActionHidden:YES];
    [self.slider setValueRange:DVEMakeFloatRang(0, 100) defaultProgress:0];
}

- (void)initSliderControlEvent
{
    @weakify(self);
    [[self.slider rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        DVELogInfo(@"-----------%@",x);
        if (x) {
            [self maskEditAdpter].disableKeyframeUpdate = YES;
            [self updateMaskIndensity:NO];
        }
    }];

    [[self.slider rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        DVELogInfo(@"-----------%@",x);
        if (x) {
            [self maskEditAdpter].disableKeyframeUpdate = NO;
            [self updateMaskIndensity:YES];
        }
    }];
}

#pragma mark - DVEPickerViewDelegate

- (BOOL)pickerView:(DVEPickerView *)pickerView isSelected:(DVEEffectValue*)sticker
{
    DVEEffectValue *model = (DVEEffectValue*)sticker;
    return [self.selectedModel.identifier isEqualToString:model.identifier];
}

- (void)pickerView:(DVEPickerView *)pickerView
  didSelectSticker:(DVEEffectValue*)sticker
          category:(id<DVEPickerCategoryModel>)category
         indexPath:(NSIndexPath *)indexPath
{
    if (sticker.status == DVEResourceModelStatusDefault) {
        if ([self.selectedModel.identifier isEqualToString:sticker.identifier]) {
            return;
        }
        [self setActionHidden:indexPath.row == 0];
        DVEViewController *vc = (DVEViewController *)self.parentVC;
        [self dealWithIndex:indexPath];

        DVEEffectValue *model = (DVEEffectValue*)sticker;
        self.selectedModel = model;
        [pickerView currentCategorySelectItemAtIndexPath:indexPath
                                                animated:NO
                                          scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        [pickerView updateSelectedStickerForId:model.identifier];
        
        model.indesty = self.slider.value * 0.01;
        self.vcConfigModel.feather = self.slider.value * 0.01;

        if (model.valueState == VEEffectValueStateShuntDown) {
            [vc dismissEditMaskView];
            [self.maskEditor deletCurMaskEffectValueNeedCommit:YES];
        } else {
            [vc showEditMaskViewConfigModel:self.vcConfigModel withBar:self];
            [self updateRatio];
            [self.maskEditor addOrChangeMaskWithEffectValue:self.vcConfigModel needCommit:YES];
        }

        self.isValueChanged = YES;
        return;
    } else if (sticker.status == DVEResourceModelStatusNeedDownlod || sticker.status == DVEResourceModelStatusDownlodFailed) {
        @weakify(self);
        [sticker downloadModel:^(id<DVEResourceModelProtocol>  _Nonnull model) {
            [pickerView updateStickerStatusForId:model.identifier];
            if (model.status != DVEResourceModelStatusDefault) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self pickerView:pickerView didSelectSticker:sticker category:category indexPath:indexPath];
            });
        }];
    }
    [pickerView updateStickerStatusForId:sticker.identifier];
}

- (void)pickerViewDidClearSticker:(DVEPickerView *)pickerView
{

}

#pragma mark - Private

- (void)updateRatio
{
    NSString *svgFilePath = self.vcConfigModel.svgFilePath;
    if (svgFilePath.length > 0) {
        NSArray *paths = [SVGBezierPath pathsFromSVGAtURL:[NSURL fileURLWithPath:svgFilePath]];
        UIBezierPath *combinedPath = [UIBezierPath bezierPath];
        [paths enumerateObjectsUsingBlock:^(SVGBezierPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [combinedPath appendPath:obj];
            obj.lineWidth = 1.2;
        }];
        CGSize size = combinedPath.bounds.size;
        self.vcConfigModel.aspectRatio = size.width / size.height;
    }
}

- (void)dealWithIndex:(NSIndexPath *)indexPath
{
    DVEEffectValue *maskModel = self.maskModels[indexPath.row];
    self.vcConfigModel.curValue = maskModel;
    self.vcConfigModel.type = indexPath.row;
}

- (void)showInView:(UIView *)view animation:(BOOL)animation
{
    [super showInView:view animation:(BOOL)animation];
    [self setUpData];
    DVEViewController *vc = (DVEViewController *)self.parentVC;
    [vc.videoView.preview.canvasBorderView updateRoation:-[self.vcContext.mediaContext currentBlendVideoSlot].rotation];
}

- (void)undoRedoClikedByUser
{
    NLEMask_OC *findMask = [[self.vcContext.mediaContext currentBlendVideoSlot] getMask].firstObject;
    DVEViewController *vc = (DVEViewController *)self.parentVC;
    [vc dismissEditMaskView];
    if (findMask) {
        NLESegmentMask_OC *maskSegment = findMask.segmentMask;
        NLEResourceNode_OC* effectSDKMask = maskSegment.effectSDKMask;
        NSInteger index = 0;
        NSString *name = effectSDKMask.resourceFile.lastPathComponent;
        for (NSInteger i = 0; i < self.maskModels.count; i ++) {
            DVEEffectValue *maskValue = self.maskModels[i];
            if ([maskValue.sourcePath.lastPathComponent isEqualToString:name]) {
                index = i;
                self.selectedModel = self.maskModels[i];
                DVELogInfo(@"NLEMask_OC----undo--%@-%zd",maskValue.name,i);
                break;
            }
        }
        
        if (index > 0) {
            self.selectedModel = self.maskModels[index];
            [self.pickerView currentCategorySelectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
                                                         animated:YES
                                                   scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
            self.vcConfigModel.width = maskSegment.width;
            self.vcConfigModel.height = maskSegment.height;
            self.vcConfigModel.feather = maskSegment.feather;
            self.vcConfigModel.center = CGPointMake(maskSegment.centerX, maskSegment.centerY);
            self.vcConfigModel.roundCorner = maskSegment.roundCorner;
            self.vcConfigModel.rotation = maskSegment.rotation;
            self.vcConfigModel.curValue  = self.selectedModel;
            self.vcConfigModel.invert = maskSegment.invert;
            self.vcConfigModel.type = index;
            
            
            [vc showEditMaskViewConfigModel:self.vcConfigModel withBar:self];
            [self setActionHidden:NO];
            self.slider.value = self.vcConfigModel.feather * 100;
        } else {
            [self setActionHidden:YES];
        }
        
    } else {
        [self setActionHidden:YES];
        [self.pickerView reloadData];
        self.selectedModel = self.maskModels[0];
        [self.pickerView currentCategorySelectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                                     animated:YES
                                               scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        [self.pickerView updateSelectedStickerForId:self.maskModels[0].identifier];
        [vc dismissEditMaskView];
    }
}

- (BOOL)initSelectMask
{
    NLETrackSlot_OC* slot = [self.vcContext.mediaContext currentBlendVideoSlot];
    NLEMask_OC *findMask = [slot getMask].firstObject;
    DVEViewController *vc = (DVEViewController *)self.parentVC;
    [vc dismissEditMaskView];
    if (findMask) {
        NLESegmentMask_OC *maskSegment = findMask.segmentMask;
        NLEResourceNode_OC* effectSDKMask = maskSegment.effectSDKMask;
        NSInteger index = 0;
        NSString *name = effectSDKMask.resourceFile.lastPathComponent;
        for (NSInteger i = 0; i < self.maskModels.count; i ++) {
            DVEEffectValue *maskValue = self.maskModels[i];
            if ([maskValue.sourcePath.lastPathComponent isEqualToString:name]) {
                index = i;
                self.selectedModel = self.maskModels[i];
                DVELogInfo(@"NLEMask_OC----undo--%@-%zd",maskValue.name,i);
                break;
            }
        }
        if (index > 0) {
            [self.pickerView currentCategorySelectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
                                                         animated:YES
                                                   scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
            [self.pickerView updateSelectedStickerForId:self.selectedModel.identifier];

            self.vcConfigModel.width = maskSegment.width;
            self.vcConfigModel.height = maskSegment.height;
            self.vcConfigModel.feather = maskSegment.feather;
            self.vcConfigModel.center = CGPointMake(maskSegment.centerX, maskSegment.centerY);
            self.vcConfigModel.roundCorner = maskSegment.roundCorner;
            self.vcConfigModel.rotation = maskSegment.rotation;
            self.vcConfigModel.curValue  = self.selectedModel;
            self.vcConfigModel.invert = maskSegment.invert;
            self.vcConfigModel.type = index;
            
            
            [vc showEditMaskViewConfigModel:self.vcConfigModel withBar:self];
            [self setActionHidden:NO];
            self.slider.value = self.vcConfigModel.feather * 100;
        } else {
            [self setActionHidden:YES];
        }
        
    } else {
        [self setActionHidden:YES];
        [self.pickerView reloadData];
        self.selectedModel = self.maskModels[0];
        [self.pickerView currentCategorySelectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                                     animated:YES
                                               scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        [self.pickerView updateSelectedStickerForId:self.maskModels[0].identifier];
        [vc dismissEditMaskView];
    }
    return NO;
}

- (void)refreshBar
{
    self.slider.value = self.vcConfigModel.feather * 100;
}

- (void)updateMaskIndensity:(BOOL)needCommit
{
    if (self.selectedModel) {
        self.isValueChanged = YES;
        self.selectedModel.indesty = self.slider.value * 0.01;
        self.vcConfigModel.feather = self.slider.value * 0.01;
        [self.maskEditor updateOneMaskWithEffectValue:self.vcConfigModel needCommit:needCommit];
    }
}

- (void)revertNow
{
    if (self.selectedModel) {
        self.isValueChanged = YES;
        self.vcConfigModel.invert = !self.vcConfigModel.invert;
        [self.maskEditor updateOneMaskWithEffectValue:self.vcConfigModel needCommit:YES];
    }
}

- (void)setUpData
{
    @weakify(self);
    [[DVEBundleLoader shareManager] mask:self.vcContext handler:^(NSArray<DVEEffectValue *> * _Nullable datas, NSString * _Nullable error) {
        if (!error) {
            NSMutableArray *effectValues = [NSMutableArray new];

            DVEEffectValue *value = [DVEEffectValue new];
            value.indesty = 0.8;
            value.name = NLELocalizedString(@"ck_none", @"无");
            value.valueState = VEEffectValueStateShuntDown;
            value.assetImage = @"iconFilterwu".dve_toImage;
            value.identifier = @"none";
            [effectValues addObject:value];
            [effectValues addObjectsFromArray:datas];

            DVEModuleBaseCategoryModel *categoryModel = [DVEModuleBaseCategoryModel new];
            DVEEffectCategory* category = [DVEEffectCategory new];
            category.models = effectValues;
            categoryModel.category = category;

            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                self.maskModels = effectValues;
                [self.pickerView updateCategory:@[categoryModel]];
                [self.pickerView updateFetchFinish];
                [self.pickerView performBatchUpdates:^{

                } completion:^(BOOL finished) {
                    @strongify(self);
                    if (finished) {
                        [self performSelectorOnMainThread:@selector(initSelectMask) withObject:nil waitUntilDone:NO];
                    }
                }];
            });

        }
    }];
}

- (void)setActionHidden:(BOOL)hidden
{
    [self.bottomView setResetButtonHidden:hidden];
    self.slider.hidden = hidden;
    self.maskLabel.hidden = hidden;
}

#pragma mark - Setter

- (void)setVcContext:(DVEVCContext *)vcContext
{
    [super setVcContext:vcContext];
    [DVEAutoInline(vcContext.serviceProvider, DVECoreActionServiceProtocol) addUndoRedoListener:self];
}

#pragma mark - Getter

- (DVEMaskEditAdpter*)maskEditAdpter
{
    return ((DVEViewController*)self.parentVC).maskEditAdpter;
}

- (DVEPickerView *)pickerView
{
    if (!_pickerView) {
        DVEMaskUIConfiguration *config = [[DVEMaskUIConfiguration alloc] init];
        _pickerView = [[DVEPickerView alloc] initWithUIConfig:config];
        _pickerView.delegate = self;
    }
    return _pickerView;
}

- (DVEMaskConfigModel *)vcConfigModel
{
    if (!_vcConfigModel) {
        CGSize curBorderSize = [self curBorderSize];
        _vcConfigModel = [[DVEMaskConfigModel alloc] initWithBorderSize:curBorderSize];
    }
    return _vcConfigModel;
}

- (UILabel *)maskLabel
{
    if (!_maskLabel) {
        _maskLabel = [[UILabel alloc] init];
        _maskLabel.text = NLELocalizedString(@"ck_video_mask_feather",@"羽化");
        _maskLabel.font = SCRegularFont(12);
        _maskLabel.textColor = [UIColor whiteColor];
        _maskLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _maskLabel;
}

- (DVEEffectsBarBottomView*)bottomView
{
    if (!_bottomView) {
        @weakify(self);
        _bottomView = [DVEEffectsBarBottomView newActionBarWithTitle:NLELocalizedString(@"ck_video_mask",@"蒙版") action:^{
            @strongify(self);
            if (self.isValueChanged) {
                self.isValueChanged = NO;
            }

            [self dismiss:YES];
            [DVEAutoInline(self.vcContext.serviceProvider, DVECoreActionServiceProtocol) refreshUndoRedo];
            DVEViewController *vc = (DVEViewController *)self.parentVC;
            [vc dismissEditMaskView];
        }];

        [_bottomView setupResetBlock:^{
            @strongify(self);
            [self revertNow];
        }];
        
        [_bottomView setResetTitle:NLELocalizedString(@"ck_flip",@"翻转")];
        [_bottomView setResetIcon:nil];
    }
    return _bottomView;
}

- (CGSize)curBorderSize
{
    CGSize curBorderSize = CGSizeZero;

    CGFloat curW = 0;
    CGFloat curH = 0;

    DVEViewController *vc = (DVEViewController *)self.parentVC;
    CGSize normalBorderSize = vc.videoView.preview.canvasBorderView.bounds.size;

    CGFloat rotation = -[self.vcContext.mediaContext currentBlendVideoSlot].rotation;

    if (rotation == 0) {
        curW = normalBorderSize.width;
        curH = normalBorderSize.height;
    } else if (rotation == 90) {
        curW = normalBorderSize.height;
        curH = normalBorderSize.width;
    } else if (rotation == 180) {
        curW = normalBorderSize.width;
        curH = normalBorderSize.height;
    } else if (rotation == 270) {
        curW = normalBorderSize.height;
        curH = normalBorderSize.width;
    } else {
        curW = normalBorderSize.width;
        curH = normalBorderSize.height;
    }

    curBorderSize = CGSizeMake(curW, curH);

    return curBorderSize;
}

@end
