//
//  DVETextColorCell.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVETextColorCell.h"
#import "DVEBundleLoader.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEMacros.h"
#import <DVETrackKit/DVEUILayout.h>
#import "DVETextColorItemCell.h"
#import "DVETextSliderView.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "DVETextConfigBoldView.h"
#import "DVETextConfigShadowView.h"
#import "DVETextConfigArrangeView.h"
#import "NSString+VEIEPath.h"
#import <NLEPlatform/NLEStyleText+iOS.h>

@interface DVETextColorConfigModel : NSObject
@property (nonatomic, assign) DVETextColorConfigType type;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) float sliderValue;
@property (nonatomic, copy) NSArray *dataSourceArr;
@property (nonatomic, copy) NSString *sliderTitle;
@property (nonatomic, assign) DVEFloatRang sliderValueRange;
@end

@implementation DVETextColorConfigModel
@end

static const int8_t kSliderHeight = 50;

@interface DVETextColorCell ()
/// 透明度 / 描边
@property (nonatomic, strong) DVETextSliderView *slider;

/// 共用颜色及 slider 的数据，包括 font, outline, background
@property (nonatomic, copy) NSDictionary< NSNumber *, DVETextColorConfigModel *> *colorModelDict;

@property (nonatomic, strong) DVETextColorConfigModel *shadowModel;

@property (nonatomic, strong) DVETextConfigShadowView *shadowView;
@property (nonatomic, strong) DVETextConfigBoldView *boldView;
@property (nonatomic, strong) DVETextConfigArrangeView *arrangeView;

@property (nonatomic, copy) NSArray *alignDatas;
@end


@implementation DVETextColorCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.functionView];
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collecView.top = self.functionView.bottom + 8;
        self.collecView.height = 50;

        [self.collecView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"3"];
        [self.collecView registerClass:[DVETextColorItemCell class] forCellWithReuseIdentifier:DVETextColorItemCell.description];
        
        [self addSubview:self.slider];
    }
    
    return self;
}

- (void)setVcContext:(DVEVCContext *)context {
    _vcContext = context;
    @weakify(self);
    [[DVEBundleLoader shareManager] textColor:self.vcContext handler:^(NSArray<DVEEffectValue *> * _Nullable datas, NSString * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            self.colorModelDict = [self p_createModelDictWithColorArr:datas];
            DVETextColorConfigModel *m = self.colorModelDict[@(DVETextColorConfigTypeFont)];
            self.dataSourceArr = m.dataSourceArr;
            self.slider.textLabel.text = m.sliderTitle;
        });
    }];
    
    [[DVEBundleLoader shareManager] textAlign:self.vcContext handler:^(NSArray<DVEEffectValue *> * _Nullable datas, NSString * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            self.alignDatas = datas;
        });
    }];
}

- (SGPageTitleView *)functionView
{
    if (!_functionView) {
        SGPageTitleViewConfigure *config = [SGPageTitleViewConfigure pageTitleViewConfigure];
        config.showBottomSeparator = NO;
        config.titleAdditionalWidth = 0;
        config.titleColor = [UIColor lightGrayColor];
        config.titleSelectedColor = [UIColor whiteColor];
        config.indicatorColor = [UIColor clearColor];
        config.titleFont = SCRegularFont([DVEUILayout dve_sizeNumberWithName:DVEUILayoutTextCategoryFontSize]);
        _functionView = [[SGPageTitleView alloc] initWithFrame:CGRectMake(0, 16, self.width, 24) delegate:self titleNames:@[NLELocalizedString(@"ck_font",  @"字体"),NLELocalizedString(@"ck_text_border",@"描边"),NLELocalizedString(@"ck_text_background",@"底色"),NLELocalizedString(@"ck_shadow",@"阴影"),NLELocalizedString(@"ck_arrangement",@"排列"),NLELocalizedString(@"ck_bold_italic",@"粗斜体")] configure:config];
        
        _functionView.backgroundColor = [UIColor clearColor];
        _functionView.selectedIndex = 0;
    }
    
    return _functionView;
}

- (DVETextSliderView *)slider {
    if (!_slider) {
        _slider = [[DVETextSliderView alloc] initWithFrame:CGRectMake(0, self.collecView.bottom, VE_SCREEN_WIDTH, kSliderHeight)];
        [_slider setValueRange:DVEMakeFloatRang(0, 100)
               defaultProgress:100];
        
        @weakify(self);
        [[self.slider rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            if (x) {
                [self p_callback];
            }
        }];
    }
    return _slider;
}

- (NSDictionary<NSNumber *,DVETextColorConfigModel *> *)p_createModelDictWithColorArr:(NSArray *)colorArr {
    DVETextColorConfigModel *fontM = [DVETextColorConfigModel new];
    fontM.type = DVETextColorConfigTypeFont;
    fontM.sliderTitle = NLELocalizedString(@"ck_text_sticker_transparency",  @"透明度");
    fontM.sliderValue = 100;
    fontM.dataSourceArr = colorArr;
    fontM.sliderValueRange = DVEMakeFloatRang(0, 100);
    fontM.selectedIndex = 0;
    
    /// 空的颜色
    DVEEffectValue *value = [DVEEffectValue new];
    value.valueState = VEEffectValueStateShuntDown;
    value.assetImage = @"text_nocolor".dve_toImage;
    NSArray *colorHasWu = [@[value] arrayByAddingObjectsFromArray:colorArr];
    
    DVETextColorConfigModel *outlineM = [DVETextColorConfigModel new];
    outlineM.sliderTitle = NLELocalizedString(@"ck_text_sticker_outline_width",@"描边粗细");
    outlineM.type = DVETextColorConfigTypeOutline;
    outlineM.sliderValue = 40;
    outlineM.dataSourceArr = colorHasWu;
    outlineM.sliderValueRange = DVEMakeFloatRang(0, 100);
    
    DVETextColorConfigModel *bgM = [DVETextColorConfigModel new];
    bgM.sliderTitle = NLELocalizedString(@"ck_text_sticker_transparency",@"透明度");
    bgM.type = DVETextColorConfigTypeBackground;
    bgM.sliderValue = 100;
    bgM.dataSourceArr = colorHasWu;
    bgM.sliderValueRange = DVEMakeFloatRang(0, 100);
    
    _shadowModel = [DVETextColorConfigModel new];
    _shadowModel.dataSourceArr = colorHasWu;
    _shadowModel.sliderTitle = NLELocalizedString(@"ck_text_sticker_transparency",@"透明度");
    
    return @{ @(DVETextColorConfigTypeFont) : fontM,
         @(DVETextColorConfigTypeOutline) : outlineM,
         @(DVETextColorConfigTypeBackground) : bgM };
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [DVEUILayout dve_sizeWithName:DVEUILayoutTextColorItemSize];
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10,10);
   
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return [DVEUILayout dve_sizeNumberWithName:DVEUILayoutTextColorItemInset];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return [DVEUILayout dve_sizeNumberWithName:DVEUILayoutTextColorItemInset];
}

#pragma mark -- UICollectionViewDelegate
/// 切换颜色
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DVEEffectValue *model = self.dataSourceArr[indexPath.row];
    if(model.status == DVEResourceModelStatusDefault){
        // 选中颜色后，该颜色需要左右居中
        [collectionView scrollToItemAtIndexPath:indexPath
                             atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                    animated:YES];
        // 选中颜色，出现 slider
        switch (_colorType) {
            case DVETextColorConfigTypeFont:
            case DVETextColorConfigTypeBackground:
            case DVETextColorConfigTypeOutline:
            {
                DVETextColorConfigModel *m = _colorModelDict[@(_colorType)];
                if (!m) {
                    break;
                }
                m.selectedIndex = indexPath.row;
                self.slider.hidden = NO;
                self.slider.textLabel.text = m.sliderTitle;
                self.slider.value = m.sliderValue;
            }
                break;
            case DVETextColorConfigTypeShadow:
            {
                DVETextColorConfigModel *m = _shadowModel;
                m.selectedIndex = indexPath.row;
                self.shadowView.hidden = NO;
            }
                break;
            default:
                break;
        }
        [self p_callback];
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
/// 切换选项
- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex
{
    pageTitleView.selectedIndex = selectedIndex;
    self.colorType = selectedIndex;
    
    switch (_colorType) {
        case DVETextColorConfigTypeFont:
        case DVETextColorConfigTypeBackground:
        case DVETextColorConfigTypeOutline:
        {
            DVETextColorConfigModel *m = _colorModelDict[@(_colorType)];
            if (!m) {
                break;
            }
            self.collecView.hidden = NO;
            self.dataSourceArr = m.dataSourceArr;
            
            self.slider.hidden = _colorType != DVETextColorConfigTypeFont;
            [self.slider setValueRange:m.sliderValueRange defaultProgress:m.sliderValue];
            self.slider.textLabel.text = m.sliderTitle;
            self.slider.value = m.sliderValue;
            
            _shadowView.hidden = YES;
            _boldView.hidden = YES;
            _arrangeView.hidden = YES;
        }
            break;
        case DVETextColorConfigTypeShadow:
        {
            self.collecView.hidden = NO;
            self.slider.hidden = YES;
            self.dataSourceArr = _shadowModel.dataSourceArr;
            _arrangeView.hidden = YES;
            _boldView.hidden = YES;
            
            if (!_shadowView) {
                [self addSubview:self.shadowView];
            }
            
            self.shadowView.hidden = _shadowModel.selectedIndex == 0;
        }
            break;
        case DVETextColorConfigTypeArrange:
        {
            self.collecView.hidden = YES;
            self.slider.hidden = YES;
            _shadowView.hidden = YES;
            _boldView.hidden = YES;
            
            if (!_arrangeView) {
                [self addSubview:self.arrangeView];
            }
            self.arrangeView.dataList = _alignDatas;
            self.arrangeView.hidden = NO;
        }
            break;
        case DVETextColorConfigTypeBlod:
        {
            self.collecView.hidden = YES;
            self.slider.hidden = YES;
            _shadowView.hidden = YES;
            _arrangeView.hidden = YES;
            
            if (!_boldView) {
                [self addSubview:self.boldView];
            }
            self.boldView.hidden = NO;
        }
            break;
        default:
            break;
    }
}

#pragma mark -- UICollectionViewDataSource
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DVETextColorItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DVETextColorItemCell.description forIndexPath:indexPath];
    DVEEffectValue *value = self.dataSourceArr[indexPath.row];
    cell.model = value;
    
    return cell;
}

#pragma mark - Private

- (void)p_callback {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    DVEEffectValue *value = [DVEEffectValue new];
    switch (_colorType) {
        case DVETextColorConfigTypeFont: {
            DVETextColorConfigModel *m = _colorModelDict[@(_colorType)];
            if (!m) {
                break;
            }
            if (m.selectedIndex >= 0) {
                DVEEffectValue *tmpV = self.dataSourceArr[m.selectedIndex];
                float sliderValue = self.slider.value;
                m.sliderValue = sliderValue;
                NSMutableArray *c = [tmpV.color mutableCopy];
                if (c.count == 4) { // alpha
                    c[3] = @(m.sliderValueRange.length > 0 ? m.sliderValue / m.sliderValueRange.length : 1.0);
                    value.color = c;
                }
            }
        }
            break;
        case DVETextColorConfigTypeBackground:
        {
            DVETextColorConfigModel *m = _colorModelDict[@(_colorType)];
            if (!m || m.selectedIndex < 0) {
                break;
            }
            DVEEffectValue *tmpV = self.dataSourceArr[m.selectedIndex];
            float sliderValue = self.slider.value;
            m.sliderValue = sliderValue;
            NSMutableArray *c = [tmpV.color mutableCopy];
            if (c.count == 4) { // alpha
                c[3] = @(m.sliderValueRange.length > 0 ? m.sliderValue / m.sliderValueRange.length : 1.0);
                value.color = c;
            }
        }
            break;
        case DVETextColorConfigTypeOutline:
        {
            DVETextColorConfigModel *m = _colorModelDict[@(_colorType)];
            value = self.dataSourceArr[m.selectedIndex];
            float sliderValue = self.slider.value;
            m.sliderValue = sliderValue;
            dict[@"outlineWidth"] = @(sliderValue * 0.15 / self.slider.valueRange.length);
        }
            break;
            
        case DVETextColorConfigTypeShadow:
        {
            DVETextColorConfigModel *m = _shadowModel;
            DVEEffectValue *tmpV = self.dataSourceArr[m.selectedIndex];
            NSMutableArray *c = [tmpV.color mutableCopy];
            if (c.count == 4) { // alpha
                c[3] = @(_shadowView.alphaSlider.value / 100.0);
                value.color = c;
            }
            CGPoint point = _shadowView.shadowOffset;
            dict[@"shadowOffset"] = @[@(point.x/18.0), @(point.y/18.0)];//ve接口需要除以18
            dict[@"shadowSmoothing"] = @(_shadowView.blurSlider.value / (100.0 * 18.0) * 3.0);//ve接口需要除以18
        }
            break;
        case DVETextColorConfigTypeArrange:
        {
            value = _arrangeView.selectedValue;
            dict[@"charSpacing"] = @(_arrangeView.charSpacingSlider.value / 20.0);
            dict[@"lineGap"] = @(_arrangeView.lineGapSlider.value / 20.0);
        }
            break;
        case DVETextColorConfigTypeBlod:
        {
            dict[@"boldWidth"] = @(_boldView.boldWidth);
            dict[@"italicDegree"] = @(_boldView.italicDegree);
            dict[@"underline"] = @(_boldView.underline);
        }
            break;
        default:
            break;
    }
    
    if (self.colorBlock) {
        self.colorBlock(value, self.colorType, dict);
    }
}

#pragma mark - Getters and setters

- (DVETextConfigShadowView *)shadowView {
    if (!_shadowView) {
        _shadowView = [[DVETextConfigShadowView alloc] initWithFrame: CGRectMake(0, self.slider.top, VE_SCREEN_WIDTH, kSliderHeight*4)];
        [_shadowView.alphaSlider setValueRange:DVEMakeFloatRang(0, 100) defaultProgress:75];
        [_shadowView.blurSlider setValueRange:DVEMakeFloatRang(0, 100) defaultProgress:40];
        [_shadowView.distanceSlider setValueRange:DVEMakeFloatRang(0, 100) defaultProgress:15];
        [_shadowView.angleSlider setValueRange:DVEMakeFloatRang(-180, 180) defaultProgress:45];
        @weakify(self)
        [[RACObserve(_shadowView.alphaSlider, value) skip:1].distinctUntilChanged subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            if (x) {
                [self p_callback];
            }
        }];
        
        [[RACObserve(_shadowView.blurSlider, value) skip:1].distinctUntilChanged subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            if (x) {
                [self p_callback];
            }
        }];
        
        [[RACObserve(_shadowView.distanceSlider, value) skip:1].distinctUntilChanged subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            if (x) {
                [self p_callback];
            }
        }];
        
        [[RACObserve(_shadowView.angleSlider, value) skip:1].distinctUntilChanged subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            if (x) {
                [self p_callback];
            }
        }];
    }
    return _shadowView;
}

- (DVETextConfigBoldView *)boldView {
    if (!_boldView) {
        _boldView = [[DVETextConfigBoldView alloc] initWithFrame: CGRectMake(0, 63, VE_SCREEN_WIDTH, 45)];
        @weakify(self);
        [[RACObserve(_boldView, boldWidth) skip:1].distinctUntilChanged subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            if (x) {
                [self p_callback];
            }
        }];
        [[RACObserve(_boldView, italicDegree) skip:1].distinctUntilChanged subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            if (x) {
                [self p_callback];
            }
        }];
        [[RACObserve(_boldView, underline) skip:1].distinctUntilChanged subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            if (x) {
                [self p_callback];
            }
        }];
        // 恢复数据
        NLEStyleText_OC *style = [DVEAutoInline(self.vcContext.serviceProvider, DVECoreStickerProtocol) currentStyle];
        _boldView.boldWidth = style.boldWidth;
        _boldView.italicDegree = style.italicDegree;
        _boldView.underline = style.underline;
    }
    return _boldView;
}

- (DVETextConfigArrangeView *)arrangeView {
    if (!_arrangeView) {
        _arrangeView = [[DVETextConfigArrangeView alloc] initWithFrame: CGRectMake(0, 40 + 8, VE_SCREEN_WIDTH, kSliderHeight*3)];
        @weakify(self);
        _arrangeView.selectedBlock = ^(DVEEffectValue * _Nonnull selectedValue) {
            @strongify(self);
            [self p_callback];
        };
         
        [[RACObserve(_arrangeView.charSpacingSlider, value) skip:1].distinctUntilChanged subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            if (x) {
                [self p_callback];
            }
        }];
        
        [[RACObserve(_arrangeView.lineGapSlider, value) skip:1].distinctUntilChanged subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            if (x) {
                [self p_callback];
            }
        }];
    }
    return _arrangeView;
}

@end
