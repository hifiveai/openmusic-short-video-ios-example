//
//  DVECurveSpeedBar.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVECurveSpeedBar.h"
#import "DVECurveItem.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEPickerView.h"
#import "NSString+VEToImage.h"
#import "DVEEffectsBarBottomView.h"
#import "DVEModuleBaseCategoryModel.h"
#import "DVECurveSpeedUIConfiguration.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "DVECurveSpeedEditBar.h"
#import "DVEBundleLoader.h"
#import "DVEResourceCurveSpeedModelProtocol.h"
#import "DVEComponentViewManager.h"
#import "DVEViewController.h"

#define kVEVCCurveItemIdentifier @"kVEVCCurveItemIdentifier"

@interface DVECurveSpeedBar () <DVEPickerViewDelegate>

@property (nonatomic, strong) DVEPickerView *pickerView;

///底部区域
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) DVEModuleBaseCategoryModel *currentCategoryModel;

@property (nonatomic, strong) id<DVEResourceCurveSpeedModelProtocol> curValue;
@property (nonatomic) BOOL isValueChanged;
@property (nonatomic, strong) NSMutableDictionary<NSString *, DVECurveSpeedEditBar*> *editBarDict;
@property (nonatomic, weak) id<DVECoreVideoProtocol> videoEditor;

@end

@implementation DVECurveSpeedBar

DVEAutoInject(self.vcContext.serviceProvider, videoEditor, DVECoreVideoProtocol)

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self buildLayout];
    }
    
    return self;
}

- (void)buildLayout
{
    [self.slider removeFromSuperview];
    [self addSubview:self.pickerView];
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        id<DVEPickerUIConfigurationProtocol> config = self.pickerView.uiConfig;
        make.height.mas_equalTo(config.effectUIConfig.effectListViewHeight + config.categoryUIConfig.categoryTabListViewHeight);
        make.left.right.equalTo(self);
        make.top.equalTo(self);
    }];
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pickerView.mas_bottom).offset(11);
        make.height.equalTo(@50);
        make.left.right.equalTo(self);
    }];
    
}

- (void)initData
{
    [self.pickerView updateLoading];
    
    @weakify(self);
    [DVEBundleLoader.shareManager curveSpeed:self.vcContext handler:^(NSArray<id<DVEResourceCurveSpeedModelProtocol>> * _Nullable datas, NSError * _Nullable error) {

        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            DVEModuleBaseCategoryModel *categoryModel = [DVEModuleBaseCategoryModel new];
            // 无变速点
            DVEEffectValue *noneValue = [DVEEffectValue new];
            noneValue.name = NLELocalizedString(@"ck_none", @"无");
            noneValue.identifier = noneValue.name;
            noneValue.assetImage = @"iconFilterwu".dve_toImage;

            
            NSMutableArray *effects = [NSMutableArray arrayWithArray:@[noneValue]];
            // 转换datas的speedPoint为NSValue
            [datas enumerateObjectsUsingBlock:^(id<DVEResourceCurveSpeedModelProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableArray *points = [NSMutableArray new];
                if ([obj respondsToSelector:@selector(speedPoints)]) {
                    [obj.speedPoints enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSDictionary *dict = (NSDictionary *)obj;
                        NSValue *pvalue = [NSValue valueWithCGPoint:CGPointMake([dict[@"x"] floatValue], [dict[@"y"] floatValue])];
                        [points addObject:pvalue];
                    }];
                }
                obj.speedPoints = points;
            }];
            [effects addObjectsFromArray:datas];
            
            DVEEffectCategory* category = [DVEEffectCategory new];
            
            category.models = effects;
            categoryModel.category = category;
            
            self.currentCategoryModel = categoryModel;
            
            [self.pickerView updateCategory:@[categoryModel]];
            [self.pickerView updateFetchFinish];
            
            id<DVEResourceCurveSpeedModelProtocol> curveSpeedInfo = [self.videoEditor currentCurveSpeedPoints];
            if (curveSpeedInfo) {
                // 有曲线信息，更新选中点
                self.editingSlot = self.editingSlot;
            } else {
                [self pickerView:self.pickerView didSelectSticker:noneValue category:categoryModel indexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
            
        });
    }];
}

- (void)touchOutSide {
    [self dismiss:YES];
}

- (void)showInView:(UIView *)view animation:(BOOL)animation {
    [super showInView:view animation:animation];
    DVEViewController *vc = (DVEViewController *)self.parentVC;
    vc.videoPreview.userInteractionEnabled = NO;//禁止预览区交互，防止编辑曲线变速点的时候，点击预览区导致底部BottomBar切换
    self.vcContext.mediaContext.disableUpdateSelectedVideoSegment = YES;
}

- (void)dismiss:(BOOL)animation {
    [super dismiss:animation];
    [self.vcContext.playerService pause];
    DVEViewController *vc = (DVEViewController *)self.parentVC;
    vc.videoPreview.userInteractionEnabled = YES;
    self.vcContext.mediaContext.disableUpdateSelectedVideoSegment = NO;
}

- (void)setVcContext:(DVEVCContext *)vcContext
{
    [super setVcContext:vcContext];
    [self initData];
    [DVEAutoInline(vcContext.serviceProvider, DVECoreActionServiceProtocol) addUndoRedoListener:self];
}

- (void)undoRedoClikedByUser
{
    // 还原选中slot
    NLETrackSlot_OC *slot = [self.vcContext.mediaContext currentBlendVideoSlot];
    
    dispatch_after(DISPATCH_TIME_NOW + 0.1, dispatch_get_main_queue(), ^{
        [self setEditingSlot:slot];
    });
}

- (void)setEditingSlot:(NLETrackSlot_OC *)editingSlot {
    _editingSlot = editingSlot;
    // 还原曲线状态
    NSArray *curveSpeedPoints = [self.videoEditor currentCurveSpeedPoints];
    NSString *curveSpeedName = [self.videoEditor currentCurveSpeedName];
    id<DVEResourceCurveSpeedModelProtocol> sourceInfo;
    for (id<DVEResourceCurveSpeedModelProtocol> info in self.currentCategoryModel.category.models) {
        if ([curveSpeedName isEqualToString:info.identifier]) {
            sourceInfo = info;
            break;
        }
    }
    if (sourceInfo && [sourceInfo respondsToSelector:@selector(speedPoints)]) {
        self.curValue = sourceInfo;
        DVECurveSpeedEditBar *editBar = [self createEditBarWithModel:sourceInfo];
        editBar.currentPoints = curveSpeedPoints;
    } else {
        self.curValue = (id<DVEResourceCurveSpeedModelProtocol>)self.currentCategoryModel.category.models.firstObject;
    }
    
    [self.pickerView reloadData];
    
    [self seekToSlotStartTimeAndPlay];
}

- (void)seekToSlotStartTimeAndPlay {
    // todo 第一次打开时候可能不播放
    @weakify(self);
    [self.vcContext.playerService seekToTime:self.editingSlot.startTime isSmooth:YES completionHandler:^(BOOL finished) {
        @strongify(self);
        if (finished) {
            [self.vcContext.playerService play];
//            CGFloat duration = CMTimeGetSeconds(self.editingSlot.duration);
            self.vcContext.playerService.needPausePlayerTime = CMTimeGetSeconds(self.editingSlot.endTime);//CMTimeGetSeconds(self.editingSlot.startTime) + duration;

        }
    }];
}

- (UIView*)bottomView
{
    if(!_bottomView) {
        @weakify(self);
        _bottomView = [DVEEffectsBarBottomView newActionBarWithTitle:NLELocalizedString(@"ck_curve_speed", @"曲线变速")  action:^{
            @strongify(self);
            if (self.isValueChanged) {
                self.isValueChanged = NO;
                
            }
            [self dismiss:YES];
            [DVEAutoInline(self.vcContext.serviceProvider, DVECoreActionServiceProtocol) refreshUndoRedo];

        }];

    }
    return _bottomView;
}

- (DVEPickerView *)pickerView {
    if (!_pickerView) {
        DVECurveSpeedUIConfiguration *config = [[DVECurveSpeedUIConfiguration alloc] init];
        _pickerView = [[DVEPickerView alloc] initWithUIConfig:config];
        _pickerView.delegate = self;
    }
    return _pickerView;
}

- (DVECurveSpeedEditBar *)createEditBarWithModel:(id<DVEResourceCurveSpeedModelProtocol>)model {
    if (![model respondsToSelector:@selector(speedPoints)]) return nil;
    DVECurveSpeedEditBar *editBar = self.editBarDict[model.identifier];
    if (!editBar) {
        CGFloat height = [DVEComponentViewManager sharedManager].componentViewBarHeight + 238 + 50;
        editBar = [[DVECurveSpeedEditBar alloc] initWithFrame:CGRectMake(0, VE_SCREEN_HEIGHT - height, VE_SCREEN_WIDTH, height)
];
        editBar.originPoints = model.speedPoints;
        self.editBarDict[model.identifier] = editBar;
    }
    
    return editBar;
}

#pragma mark -- DVEPickerViewDelegate

- (void)pickerView:(DVEPickerView *)pickerView didSelectTabIndex:(NSInteger)index {
    
}

- (BOOL)pickerView:(DVEPickerView *)pickerView isSelected:(DVEEffectValue*)sticker {
    return [self.curValue.identifier isEqualToString:sticker.identifier];
}

- (void)pickerViewDidClearSticker:(DVEPickerView *)pickerView {
    
}

- (void)pickerView:(DVEPickerView *)pickerView
willDisplaySticker:(DVEEffectValue*)sticker
         indexPath:(NSIndexPath *)indexPath {
    
}

- (void)pickerView:(DVEPickerView *)pickerView
  didSelectSticker:(DVEEffectValue*)sticker
          category:(id<DVEPickerCategoryModel>)category
         indexPath:(NSIndexPath *)indexPath {
    id<DVEResourceCurveSpeedModelProtocol> model = (id<DVEResourceCurveSpeedModelProtocol>)sticker;
    
    if ([self.curValue.identifier isEqualToString:model.identifier] && self.curValue && indexPath.row != 0) {
        // 进入编辑视图
        DVECurveSpeedEditBar *editBar = [self createEditBarWithModel:model];
        editBar.vcContext = self.vcContext;
        [editBar showInView:self.superview animation:YES];
        editBar.isMainTrack = self.isMainTrack;
        editBar.editingSlot = self.editingSlot;
        editBar.curValue = self.curValue;
        return;
    }
    
    // 切换曲线
    self.slider.hidden = NO;
    self.curValue = model;
    [pickerView currentCategorySelectItemAtIndexPath:indexPath
                                            animated:NO
                                      scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    [pickerView updateSelectedStickerForId:model.identifier];

    [self.videoEditor updateVideoCurveSpeedInfo:self.curValue slot:self.editingSlot isMain:self.isMainTrack shouldCommit:YES];
    self.isValueChanged = YES;
    
    [self seekToSlotStartTimeAndPlay];
}

- (NSMutableDictionary<NSString *, DVECurveSpeedEditBar *> *)editBarDict {
    if (!_editBarDict) {
        _editBarDict = [[NSMutableDictionary alloc] init];
    }

    return _editBarDict;
}

@end
