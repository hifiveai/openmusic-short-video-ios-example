//
//  VEEMakeupViewController.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "VEEMakeupViewController.h"
#import "VEEBeautyItem.h"
#import "VEEBeautyDataSource.h"
#import "VEEMakeUpSelectBar.h"

#define kVEEBeautyItemIdentifier @"kVEEBeautyItemIdentifier"

@interface VEEMakeupViewController ()
<UICollectionViewDelegate,UICollectionViewDataSource>



@property (nonatomic, strong) UICollectionView *collecView;
@property (nonatomic, strong) DVEEffectValue *curValue;
@property (nonatomic, strong) DVEEffectValue *lastValue;
@property (nonatomic, strong) NSIndexPath *lastIndex;

@property (nonatomic, strong) NSArray *blushArr;
@property (nonatomic, strong) NSArray *lipArr;
@property (nonatomic, strong) NSArray *facialArr;
@property (nonatomic, strong) NSArray *pupilArr;
@property (nonatomic, strong) NSArray *hairArr;
@property (nonatomic, strong) NSArray *eyeshadowArr;
@property (nonatomic, strong) NSArray *eyebrowArr;

@property (nonatomic, strong) VEEMakeUpSelectBar *selectBar;



@end

@implementation VEEMakeupViewController
@synthesize index = _index;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.collecView];
    [self.view addSubview:self.eyeButton];

}

- (void)setIndex:(NSUInteger)index
{
    _index = index;
    [self initMakeupDataSource];
        
}

- (void)initMakeupDataSource
{
    
    self.dataSourceArr = [[NSMutableArray alloc] initWithArray:[VEEBeautyDataSource shareManager].makeupSourceArr copyItems:YES];
    [self reLoad];
    self.blushArr = [[NSMutableArray alloc] initWithArray:[VEEBeautyDataSource shareManager].blushArr copyItems:YES];
    self.lipArr = [[NSMutableArray alloc] initWithArray:[VEEBeautyDataSource shareManager].lipArr copyItems:YES];
    self.facialArr = [[NSMutableArray alloc] initWithArray:[VEEBeautyDataSource shareManager].facialArr copyItems:YES];
    self.pupilArr = [[NSMutableArray alloc] initWithArray:[VEEBeautyDataSource shareManager].pupilArr copyItems:YES];
    self.hairArr = [[NSMutableArray alloc] initWithArray:[VEEBeautyDataSource shareManager].hairArr copyItems:YES];
    self.eyebrowArr = [[NSMutableArray alloc] initWithArray:[VEEBeautyDataSource shareManager].eyebrowArr copyItems:YES];
    self.eyeshadowArr = [[NSMutableArray alloc] initWithArray:[VEEBeautyDataSource shareManager].eyeshadowArr copyItems:YES];
    
}

-(VEEMakeUpSelectBar *)selectBar
{
    if (!_selectBar) {
        _selectBar = [[VEEMakeUpSelectBar alloc] initWithFrame:CGRectMake(0, VE_SCREEN_HEIGHT - 90 - 185, VE_SCREEN_WIDTH, 90)];
        @weakify(self);
        _selectBar.didSelectedBlock = ^(DVEEffectValue * _Nonnull evalue, NSUInteger index) {
            @strongify(self);
            [self dealWithValue:evalue index:self.lastIndex];
        };
    }
    
    return _selectBar;
}

- (UICollectionView *)collecView
{
    if (!_collecView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
        _collecView = [[UICollectionView alloc] initWithFrame:CGRectMake(64, 0, self.view.frame.size.width - 64, 53) collectionViewLayout:flowLayout];
        _collecView.showsHorizontalScrollIndicator = NO;
        _collecView.showsVerticalScrollIndicator = NO;
        _collecView.delegate = self;
        _collecView.dataSource = self;
        _collecView.backgroundColor = [UIColor blackColor];
        
        [_collecView registerClass:[VEEBeautyItem class] forCellWithReuseIdentifier:kVEEBeautyItemIdentifier];
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
    VEEBeautyItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVEEBeautyItemIdentifier forIndexPath:indexPath];
    
    DVEEffectValue *value = self.dataSourceArr[indexPath.row];
    
    cell.eValue = value;
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSourceArr.count > 0 ? 1 : 0;
}



#pragma mark -- UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(80, 53);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0,0);
   
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
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
    if (self.eyeButton.selected) {
        [self.eyeButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    id obj = self.dataSourceArr[indexPath.section];
    
    DVEEffectValue *value = nil;
    if ([obj isKindOfClass:[NSArray class]]) {
        value = self.dataSourceArr[indexPath.section][indexPath.row];
    } else {
        value = self.dataSourceArr[indexPath.row];
    }
    self.curValue = value;
    self.lastIndex = indexPath;
    NSArray *datasourceArr = nil;
    switch (indexPath.row) {
        case 0:
            datasourceArr = self.blushArr;
            break;
        case 1:
            datasourceArr = self.lipArr;
            break;
        case 2:
            datasourceArr = self.facialArr;
            break;
        case 3:
            datasourceArr = self.pupilArr;
            break;
        case 4:
            datasourceArr = self.hairArr;
            break;
        case 5:
            datasourceArr = self.eyeshadowArr;
            break;
        case 6:
            datasourceArr = self.eyebrowArr;
            break;
            
            
        default:
            break;
    }
    self.selectBar.dataSourceArr = datasourceArr;
    [self.parentView addSubview:self.selectBar];    
    self.selectBar.subSelectIndex = self.curValue.subSelectIndex;
    [self dealWithValue:self.curValue index:[NSIndexPath indexPathForRow:self.curValue.subSelectIndex inSection:0]];
}

- (void)dealWithValue:(DVEEffectValue *)value index:(NSIndexPath *)indexPath
{
    if (value.valueState == VEEffectValueStateNone) {
        value.valueState = VEEffectValueStateInUse;
    } else {

    }
    
    self.curValue.name = value.name;
    self.curValue.sourcePath = value.sourcePath;
    
    self.curValue.subSelectIndex = value.subSelectIndex;
    
    if (self.didSelectedBlock) {
        self.didSelectedBlock(self.curValue,self.index);
    }
//    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    
    
    self.lastValue = value;
    self.lastIndex = indexPath;
}

- (void)reset
{
    self.index = self.index;
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);        
        self.eyeButton.selected = NO;
    });
    
}

- (void)reLoad
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.collecView reloadData];
    [CATransaction commit];
    
    
}

@end
