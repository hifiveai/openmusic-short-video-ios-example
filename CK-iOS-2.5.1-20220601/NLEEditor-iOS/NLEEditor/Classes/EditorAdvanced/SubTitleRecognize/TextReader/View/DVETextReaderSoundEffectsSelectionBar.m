//
//  DVETextReaderSoundEffectsSelectionBar.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/27.
//

#import "DVETextReaderSoundEffectsSelectionBar.h"
#import "DVETextReaderEffectCell.h"
#import "DVEVCContext.h"
#import "DVEBundleLoader.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "NSString+VEToImage.h"
#import "DVEEffectsBarBottomView.h"
#import "DVEPickerView.h"
#import "DVEModuleBaseCategoryModel.h"
#import "DVETextReaderPickerUIDefaultConfiguration.h"
#import "DVECustomerHUD.h"
#import "DVETextToAudioAlertController.h"
#import "DVETextReaderServiceImpl.h"
#import "DVELoggerImpl.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

#define kVEVCFilterItemIdentifier @"kVEVCFilterItemIdentifier"

@interface DVETextReaderSoundEffectsSelectionBar ()<DVEPickerViewDelegate>

///滤镜数据源
@property (nonatomic, strong) NSArray<DVEModuleBaseCategoryModel *> *filterDataSource;
///当前选中滤镜
@property (nonatomic, strong) id<DVETextReaderModelProtocol> curValue;
///滤镜区域
@property (nonatomic, strong) DVEPickerView *filterPickerView;
///底部区域
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) id<DVETextReaderServiceProtocol> textReaderService;

@end


@implementation DVETextReaderSoundEffectsSelectionBar

- (void)dealloc
{
    DVELogInfo(@"DVETextReaderSoundEffectsSelectionBar dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _textReaderService = DVEAutoInline(self.vcContext.serviceProvider, DVETextReaderServiceProtocol);
        if(_textReaderService == nil){
            _textReaderService = [DVETextReaderServiceImpl new];
        }
        [self initView];
    }
    
    return self;
}

- (void)showInView:(UIView *)view animation:(BOOL)animation
{
    [super showInView:view animation:(BOOL)animation];
    [self initData];
}

- (void)setCurValue:(id<DVETextReaderModelProtocol>)curValue
{
    _curValue = curValue;
}

#pragma mark - private Method

- (void)initView
{
    self.slider.top = 0;

    [self addSubview:self.filterPickerView];
    [self.filterPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        id<DVEPickerUIConfigurationProtocol> config = self.filterPickerView.uiConfig;
        make.height.mas_equalTo(config.effectUIConfig.effectListViewHeight + config.categoryUIConfig.categoryTabListViewHeight);
        make.top.equalTo(self);
        make.left.right.equalTo(self);
    }];
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.filterPickerView.mas_bottom);
        make.left.right.bottom.equalTo(self);
    }];
}



- (void)initData
{
    self.slider.hidden = YES;
    _curValue = nil;
    @weakify(self);
    [[DVEBundleLoader shareManager] textReaderSoundEffectList:self.vcContext
                                                      handler:^(NSArray<id<DVETextReaderModelProtocol>> * _Nullable datas, NSError * _Nullable error) {
        @strongify(self);
        DVEModuleBaseCategoryModel* categoryModel = [DVEModuleBaseCategoryModel new];
        DVEEffectCategory* category = [DVEEffectCategory new];
        category.models = datas;
        categoryModel.category = category;

        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if(!error){
                self.filterDataSource = @[categoryModel];
                [self.filterPickerView updateCategory:self.filterDataSource];
                [self.filterPickerView updateFetchFinish];
                [self.filterPickerView performBatchUpdates:^{
                    
                } completion:^(BOOL finished) {
                    @strongify(self);
                    if(finished){
                        [self performSelectorOnMainThread:@selector(initSelectFilter) withObject:nil waitUntilDone:NO];
                    }
                }];
            } else {
                [DVECustomerHUD showMessage:error.localizedDescription];
                [self.filterPickerView updateFetchError];
            }
        });
    }];
}

- (BOOL)initSelectFilter
{
    NSArray* models = self.filterDataSource.firstObject.models;
    for (NSInteger i = 0; i < models.count; i ++) {
        id<DVETextReaderModelProtocol> model = (id<DVETextReaderModelProtocol>)models[i];
        if (model.isNone) {
            self.curValue = model;
            return YES;
        }
    }
    return NO;
}

- (void)undoRedoClikedByUser:(NLEEditor_OC *)editor
{
    [self.filterPickerView reloadData];
}

- (void)showReplaceAlert
{
    DVETextToAudioAlertController *alertVC = [[DVETextToAudioAlertController alloc] init];
    [self.parentVC presentViewController:alertVC animated:NO completion:nil];
}

#pragma mark - layz Method

- (UIView*)bottomView
{
    if (!_bottomView) {
        @weakify(self);
        _bottomView = [DVEEffectsBarBottomView newActionBarWithTitle:@"音色选择" action:^{
            @strongify(self);
            [self.textReaderService stopPlayDemo];

            [self dismiss:YES];
            [DVEAutoInline(self.vcContext.serviceProvider, DVECoreActionServiceProtocol) refreshUndoRedo];

            if (self.vcContext.mediaContext.selectTextSlot && self.curValue && !self.curValue.isNone) {
                [DVEAutoInline(self.vcContext.serviceProvider, DVECoreTextProtocol) showAlertForReplaceTextAudio:self.curValue
                                                                forSlot:self.vcContext.mediaContext.selectTextSlot
                                                       inViewController:self.parentVC];
            }
        }];
    }
    return _bottomView;
}

- (DVEPickerView *)filterPickerView {

    if (!_filterPickerView) {
        _filterPickerView = [[DVEPickerView alloc] initWithUIConfig:[DVETextReaderPickerUIDefaultConfiguration new]];
        _filterPickerView.delegate = self;
        _filterPickerView.backgroundColor = [UIColor clearColor];
    }
    return _filterPickerView;
}

#pragma mark - AWEStickerPickerViewDelegate

- (BOOL)pickerView:(DVEPickerView *)pickerView isSelected:(DVEEffectValue*)sticker
{
    return [sticker.identifier isEqualToString:self.curValue.identifier];
}

- (void)pickerView:(DVEPickerView *)pickerView
  didSelectSticker:(DVEEffectValue*)sticker
          category:(id<DVEPickerCategoryModel>)category
         indexPath:(NSIndexPath *)indexPath
{
    if (sticker.status == DVEResourceModelStatusDefault) {
        NLESegmentTextSticker_OC *textSegment = (NLESegmentTextSticker_OC *)self.vcContext.mediaContext.selectTextSlot.segment;
        if (!textSegment) {
            return;
        }
        id<DVETextReaderModelProtocol> readerModel = (id<DVETextReaderModelProtocol>)sticker;
        if (self.curValue == readerModel) return;
        self.curValue = readerModel;
        
        [pickerView updateSelectedStickerForId:self.curValue.identifier];
        if (!self.curValue.isNone) {
            [self.textReaderService beginPlayDemo:@[textSegment.content] voiceInfo:self.curValue];
        } else {
            [self.textReaderService stopPlayDemo];
        }
        
        return;
    } else if (sticker.status == DVEResourceModelStatusNeedDownlod || sticker.status == DVEResourceModelStatusDownlodFailed) {
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

- (void)pickerView:(DVEPickerView *)pickerView didSelectTabIndex:(NSInteger)index
{
    
}

- (void)pickerViewDidClearSticker:(DVEPickerView *)pickerView
{
    
}

@end
