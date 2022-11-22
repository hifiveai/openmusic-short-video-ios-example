//
//  VEEStickerViewController.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEEStickerViewController.h"
#import "VEEStickerItem.h"


#define kVEEStickerItemIdentifier @"kVEEStickerItemIdentifier"

static const NSString *StickerBundleName = @"StickerResource";

@interface VEEStickerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collecView;
@property (nonatomic, strong) NSArray *dataSourceArr;
@property (nonatomic, strong) DVEEffectValue *curValue;
@property (nonatomic, strong) DVEEffectValue *lastValue;

@end

@implementation VEEStickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.collecView];
    [self initDataSource];
}

- (void)initDataSource
{
    
    NSArray *stickerArr = @[@"shuihaimeigeqiutian",@"kongquegongzhu",@"zhaocaimao",@"biaobaiqixi",@"xiatiandefeng",@"zisemeihuo",@"qianduoduo",@"shenshi",@"meihaoxinqing",@"shangke",@"kidmakup",@"shuiliandong",@"konglongceshi",@"kejiganqueaixiong",@"mofabaoshi",@"jiamian",@"gongzhumianju",@"konglongshiguangji",@"huanlongshu",@"huanletuchiluobo",@"eldermakup",@"tiaowuhuoji",@"yanlidoushini",@"xiaribingshuang",@"maobing",@"haoqilongbao",@"nuannuandoupeng",@"huahua",@"jiancedanshenyinyuan",@"zhutouzhuer",@"zhuluojimaoxian",@"wochaotian",@"chitushaonv",@"landiaoxueying",@"lizishengdan",@"katongnan",@"dianjita",@"weilandongrizhuang",@"cinamiheti",@"heimaoyanjing",@"shengrikuaile",@"baibianfaxing",@"mengguiyaotang",@"katongnv"];
    NSArray *stickerNameArr = @[CKEditorLocStringWithKey(@"ck_sticker_tip_shuihaimeigeqiutian",@"张嘴打喷嚏"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_kongquegongzhu",@"张张手秒变孔雀公主"),
                                 @"",
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_biaobaqixi",@"比心试试"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_xiatiandefeng",@"摇头"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_zisemeihuo",@"点头眨眼"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_qianduoduo",@"比手枪"),
                                 @"",
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_meihaoxinqing",@"微笑"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_shangke",@"点头"),
                                 @"",
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_shuiliandong",@"伸手、摇头、点头"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_konglongceshi",@"眨眼点头"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_kejiganqueaixiong",@"眨眼试试"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_mofabaoshi",@"五指张开，握拳"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_jiamian",@"挡脸换面具"),
                                 @"",
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_konglongshiguangji",@"点头"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_huanlonghsu",@"先抬头后张嘴"),
                                 @"",
                                 @"",
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_tiaowuhuoji",@"对着屏幕开一枪试试"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_yanlidoushini",@"眨眼试试"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_xiaribingshuang",@"伸出手掌"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_snap_with_cats",@"和猫一起拍吧"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_haoqilongbao",@"比 OK 手势"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_nuannuandoupeng",@"嘟嘴"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_huahua",@"挑眉试试"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_jiancedanshenyinyuan",@"伸手"),
                                 @"",
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_zhuluojimaoxian",@"摇头变身不同恐龙"),
                                 @"",
                                 @"",
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_landiaoxueying",@"冬天来啦，让我们一起拍起来"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_lizishengdan",@"比心召唤麋鹿"),
                                 @"",
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_dianjita",@"和猫一起"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_weilandongrizhuang",@"眨眼嘟嘴试试哦"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_cinamiheti",@"伸手眨眼"),
                                 @"",
                                 @"",
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_baibianfaxing",@"点头"),
                                 CKEditorLocStringWithKey(@"ck_sticker_tip_mengguiyaotang",@"五指张开"),
                                 @""];

    NSMutableArray *valueArr = [NSMutableArray new];
    for (NSInteger i = 0; i < stickerArr.count; i ++) {
        DVEEffectValue *value = [DVEEffectValue new];
        value.name = stickerNameArr[i];
        value.indesty = 1;
        value.assetImage = [NSString stringWithFormat:@"icon_%@",stickerArr[i]].UI_VEToImage;
        value.sourcePath = [[@"stickers/" stringByAppendingString:stickerArr[i]] pathInBundle:StickerBundleName];
        [valueArr addObject:value];
    }
    
    self.dataSourceArr = valueArr.copy;
    [self.collecView reloadData];
}


- (UICollectionView *)collecView
{
    if (!_collecView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
        _collecView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 156) collectionViewLayout:flowLayout];
        _collecView.showsHorizontalScrollIndicator = NO;
        _collecView.showsVerticalScrollIndicator = NO;
        _collecView.delegate = self;
        _collecView.dataSource = self;
        _collecView.backgroundColor = [UIColor blackColor];
        _collecView.allowsMultipleSelection = NO;
        
        [_collecView registerClass:[VEEStickerItem class] forCellWithReuseIdentifier:kVEEStickerItemIdentifier];
    }
    
    return _collecView;
}



#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceArr.count;
    
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VEEStickerItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVEEStickerItemIdentifier forIndexPath:indexPath];
    
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
    return CGSizeMake(37, 37);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(12, 12, 12,12);
   
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 25;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 25;
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
    id obj = self.dataSourceArr[indexPath.section];
    
    DVEEffectValue *value = nil;
    if ([obj isKindOfClass:[NSArray class]]) {
        value = self.dataSourceArr[indexPath.section][indexPath.row];
    } else {
        value = self.dataSourceArr[indexPath.row];
    }
    
    if (self.lastValue && ![self.lastValue isEqual:value]) {
        self.lastValue.valueState = VEEffectValueStateNone;
    }
    
    if (value.valueState == VEEffectValueStateInUse) {
        value.valueState = VEEffectValueStateNone;
    } else {
        value.valueState = VEEffectValueStateInUse;
    }
    
    self.curValue = value;
    
    if (self.didSelectedBlock) {
        self.didSelectedBlock(value);
    }
    
    self.lastValue = value;
}

- (void)reset
{
    [self.collecView reloadData];
}


@end
