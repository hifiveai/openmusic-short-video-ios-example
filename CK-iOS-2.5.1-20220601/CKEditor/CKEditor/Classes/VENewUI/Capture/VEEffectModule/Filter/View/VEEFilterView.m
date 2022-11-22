//
//  VEEFilterView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEEFilterView.h"
#import "VECommonSliderView.h"
#import "VEEFliteItem.h"
#import <NLEEditor/DVEToast.h>
#import <NLEEditor/DVEEffectValue.h>

#define kVEEFliteItemIdentifier @"kVEEFliteItemIdentifier"

static const NSString *FilterBundleName = @"FilterResource";

@interface VEEFilterView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collecView;
@property (nonatomic, strong) VECommonSliderView *slider;
@property (nonatomic, strong) NSArray *dataSourceArr;
@property (nonatomic, strong) DVEEffectValue *curValue;
@property (nonatomic, strong) DVEEffectValue *lastValue;

@end

@implementation VEEFilterView


- (instancetype)initWithFrame:(CGRect)frame Type:(VEEffectToolViewType)type DismisBlock:(VEEVoidBlock)dismissBlock
{
    if (self = [super initWithFrame:frame Type:type DismisBlock:dismissBlock]) {
        [self addSubview:self.collecView];
        [self addSubview:self.slider];
        self.collecView.bottom = self.bottomBar.top;
        self.slider.bottom = self.collecView.top;
        
        [self initDataSource];
    }
    
    return self;
}

- (void)initDataSource
{
    NSArray *filterCNName = @[
        @"Filter_0_0",
        @"Filter_01_38",
        @"Filter_02_14",
        @"Filter_03_20",
        @"Filter_04_12",
        @"Filter_05_10",
        @"Filter_06_03",
        @"Filter_07_06",
        @"Filter_08_17",
        @"Filter_09_19",
        @"Filter_10_11",
        @"Filter_11_09",
        @"Filter_12_08",
        @"Filter_13_02",
        @"Filter_14_15",
        @"Filter_15_07",
        @"Filter_16_13",
        @"Filter_17_04",
        @"Filter_18_18",
        @"Filter_19_37",
        @"Filter_20_05",
        @"Filter_21_01",
        @"Filter_22_16",
        @"Filter_23_Po1",
        @"Filter_24_Po2",
        @"Filter_25_Po3",
        @"Filter_26_Po4",
        @"Filter_27_Po5",
        @"Filter_28_Po6",
        @"Filter_29_Po7",
        @"Filter_30_Po8",
        @"Filter_31_Po9",
        @"Filter_32_Po10",
        @"Filter_33_L1",
        @"Filter_34_L2",
        @"Filter_35_L3",
        @"Filter_36_L4",
        @"Filter_37_L5",
        @"Filter_38_F1",
        @"Filter_39_F2",
        @"Filter_40_F3",
        @"Filter_41_F4",
        @"Filter_42_F5",
        @"Filter_43_S1",
        @"Filter_44_S2",
        @"Filter_45_S3",
        @"Filter_46_S4",
        @"Filter_47_S5",

    ];
    NSArray *filterNameKeys = @[
        @"ck_filter_normal",
        @"ck_filter_chalk",
        @"ck_filter_cream",
        @"ck_filter_oxgen",
        @"ck_filter_campan",
        @"ck_filter_lolita",
        @"ck_filter_mitao",
        @"ck_filter_makalong",
        @"ck_filter_paomo",
        @"ck_filter_yinhua",
        @"ck_filter_musi",
        @"ck_filter_wuyu",
        @"ck_filter_beihaidao",
        @"ck_filter_riza",
        @"ck_filter_xiyatu",
        @"ck_filter_jingmi",
        @"ck_filter_jiaopian",
        @"ck_filter_nuanyang",
        @"ck_filter_jiuri",
        @"ck_filter_hongchun",
        @"ck_filter_julandiao",
        @"ck_filter_tuise",
        @"ck_filter_heibai",
        @"ck_filter_wenrou",
        @"ck_filter_lianaichaotian",
        @"ck_filter_chujian",
        @"ck_filter_andiao",
        @"ck_filter_naicha",
        @"ck_filter_soft",
        @"ck_filter_xiyang",
        @"ck_filter_lengyang",
        @"ck_filter_haibianrenxiang",
        @"ck_filter_gaojihui",
        @"ck_filter_haidao",
        @"ck_filter_qianxia",
        @"ck_filter_yese",
        @"ck_filter_hongzong",
        @"ck_filter_qingtou",
        @"ck_filter_ziran2",
        @"ck_filter_suda",
        @"ck_filter_jiazhou",
        @"ck_filter_shise",
        @"ck_filter_chuanwei",
        @"ck_filter_meishijiaopian",
        @"ck_filter_hongsefugu",
        @"ck_filter_lvtu",
        @"ck_filter_nuanhuang",
        @"ck_filter_landiaojiaopian",
        @"ck_filter_S5",
    ];
    
    NSArray *imgArr = @[@"iconFilterziran",@"iconFilterroubai",@"iconFilternaiyou",@"iconFilteryangqi",@"iconFilterjugeng",@"iconFilterluolita",@"iconFiltermitao",@"iconFiltermakalong",@"iconFilterpaomo",@"iconFilteryinghua",@"iconFilterqiannuan",@"iconFilterwuyu",@"iconFilterbeihaidao",@"iconFilterriza",@"iconFilterxiyatu",@"iconFilterjingmi",@"iconFilterjiaopian",@"iconFilternuanyang",@"iconFilterjiuri",@"iconFilterhongchun",@"iconFilterjulandiao",@"iconFiltertuise",@"iconFilterheibai",@"iconFilterwenrou",@"iconFilterlianaichaotian",@"iconFilterchujian",@"iconFilterandiao",@"iconFilternaicha",@"iconFiltersoft",@"iconFilterxiyang",@"iconFilterlengyang",@"iconFilterhaibianrenxiang",@"iconFiltergaojihui",@"iconFilterhaidao",@"iconFilterqianxia",@"iconFilteryese",@"iconFilterhongzong",@"iconFilterqingtou",@"iconFilterziran2",@"iconFiltersuda",@"iconFilterjiazhou",@"iconFiltershise",@"iconFilterchuanwei",@"iconFiltermeishijiaopian",@"iconFilterhongsefugu",@"iconFilterlutu",@"iconFilternuanhuang",@"iconFilterlandiaojiaopian",];
    
    NSArray *nameArr = @[
        @"自然",
        @"柔白",@"奶油",@"氧气",@"桔梗",@"洛丽塔",@"蜜桃",@"马卡龙",@"泡沫",@"樱花",@"浅暖",
        @"物语",@"北海道",@"日杂",@"西雅图",@"静谧",@"胶片",@"暖阳",@"旧日",@"红唇",@"橘蓝调",
        @"褪色",@"黑白",@"温柔",@"恋爱超甜",@"初见",@"暗调",@"奶茶",@"soft",@"夕阳",@"冷氧",
        @"海边人像",@"高级灰",@"海岛",@"浅夏",@"夜色",@"红棕",@"清透",@"自然2",@"苏打",@"加州",
        @"食色",@"川味",@"美式胶片",@"红色复古",@"旅途",@"暖黄",@"蓝调胶片",];

    
    NSMutableArray *valueArr = [NSMutableArray new];
    for (NSInteger i = 0; i < filterCNName.count; i ++) {
        NSInteger n = [filterCNName[i] componentsSeparatedByString:@"_"][1].integerValue;
        DVEEffectValue *value = [DVEEffectValue new];
        value.name = CKEditorLocStringWithKey(filterNameKeys[n], nameArr[n]);
        value.indesty = 0.8;
        value.assetImage = [imgArr[n] UI_VEToImage];
        value.sourcePath = [[@"Filter/" stringByAppendingString:filterCNName[i]] pathInBundle:FilterBundleName];
        
        if (i == 0) {
            value.valueState = VEEffectValueStateShuntDown;
        }
       
        [valueArr addObject:value];
    }
    
    self.dataSourceArr = valueArr.copy;
    [self.collecView reloadData];
}


- (UICollectionView *)collecView
{
    if (!_collecView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collecView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 74 + 35) collectionViewLayout:flowLayout];
        _collecView.showsHorizontalScrollIndicator = NO;
        _collecView.showsVerticalScrollIndicator = NO;
        _collecView.delegate = self;
        _collecView.dataSource = self;
        _collecView.backgroundColor = [UIColor blackColor];
        
        [_collecView registerClass:[VEEFliteItem class] forCellWithReuseIdentifier:kVEEFliteItemIdentifier];
    }
    
    return _collecView;
}

- (VECommonSliderView *)slider
{
    if (!_slider) {
        _slider = [[VECommonSliderView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, 50)];
        _slider.hidden = YES;
        @weakify(self);
        [RACObserve(_slider, value) subscribeNext:^(NSNumber *x) {
            @strongify(self);
            float indensty = x.floatValue;
            if (self.curValue) {
                self.curValue.indesty = indensty * 0.01;
                
                [self.capManager setFliter:self.curValue];
            }
            
        }];
        [_slider.slider setMaximumValue:100];
        [_slider.slider setMinimumValue:0];
//        _slider.slider.value = 80;
        _slider.value = 80;
    }
    
    return _slider;
}


#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceArr.count;
    
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VEEFliteItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVEEFliteItemIdentifier forIndexPath:indexPath];
    
    id obj = self.dataSourceArr[indexPath.section];
    
    DVEEffectValue *value = nil;
    if ([obj isKindOfClass:[NSArray class]]) {
        value = self.dataSourceArr[indexPath.section][indexPath.row];
    } else {
        value = self.dataSourceArr[indexPath.row];
    }
    cell.eValue = value;
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSourceArr.count > 0 ? 1 : 0;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    
    return nil;
}


#pragma mark -- UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50, 74);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(13, 15, 22,15);
   
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 15;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 15;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}

#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.slider.hidden = indexPath.row == 0;
    
    id obj = self.dataSourceArr[indexPath.section];
    
    DVEEffectValue *value = nil;
    if ([obj isKindOfClass:[NSArray class]]) {
        value = self.dataSourceArr[indexPath.section][indexPath.row];
    } else {
        value = self.dataSourceArr[indexPath.row];
    }
    
    if (self.lastValue && ![self.lastValue isEqual:value] && self.lastValue.valueState == VEEffectValueStateInUse) {
        self.lastValue.valueState = VEEffectValueStateNone;
    }
    
    value.indesty = _slider.value * 0.01;
    
    if (value.valueState == VEEffectValueStateNone) {
        value.valueState = VEEffectValueStateInUse;
    } else if (value.valueState == VEEffectValueStateInUse) {

    } else {
        
    }
    
    self.curValue = value;
    
    
    [self.capManager setFliter:value];
    
    self.lastValue = value;
}


@end
