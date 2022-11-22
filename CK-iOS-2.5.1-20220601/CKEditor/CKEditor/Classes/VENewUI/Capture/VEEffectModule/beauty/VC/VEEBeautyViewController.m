//
//  VEEBeautyViewController.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEEBeautyViewController.h"
#import "VEEBeautyItem.h"
#import "VEEBeautyDataSource.h"

#define kVEEBeautyItemIdentifier @"kVEEBeautyItemIdentifier"


@interface VEEBeautyViewController ()
<UICollectionViewDelegate,UICollectionViewDataSource>



@property (nonatomic, strong) UICollectionView *collecView;
@property (nonatomic, strong) DVEEffectValue *curValue;
@property (nonatomic, strong) DVEEffectValue *lastValue;
@property (nonatomic, strong) NSIndexPath *lastIndex;

@end

@implementation VEEBeautyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.collecView];
    [self.view addSubview:self.eyeButton];

}

- (void)setIndex:(NSUInteger)index
{
    _index = index;
    switch (index) {
        case 0:
        {
            [self initFaceDataSource];
        }
            break;
        case 1:
        {
            [self initVFaceDataSource];
        }
            break;
        case 2:
        {
            [self initBodyDataSource];
        }
            break;
        case 3:
        {
            [self initMakeupDataSource];
        }
            break;
            
        default:
            break;
    }
}

- (void)initFaceDataSource
{
    
    self.dataSourceArr = [[NSMutableArray alloc] initWithArray:[VEEBeautyDataSource shareManager].faceSourceArr copyItems:YES];
    [self reLoad];
}

- (void)initVFaceDataSource
{
    
    self.dataSourceArr = [[NSMutableArray alloc] initWithArray:[VEEBeautyDataSource shareManager].vFaceSourceArr copyItems:YES];
    [self reLoad];
}

- (void)initBodyDataSource
{
    
    self.dataSourceArr = [[NSMutableArray alloc] initWithArray:[VEEBeautyDataSource shareManager].bodySourceArr copyItems:YES];
    [self reLoad];
}

- (void)initMakeupDataSource
{
    
    self.dataSourceArr = [[NSMutableArray alloc] initWithArray:[VEEBeautyDataSource shareManager].makeupSourceArr copyItems:YES];
    [self reLoad];
}

- (UIButton *)eyeButton
{
    if (!_eyeButton) {
        _eyeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 53)];
        [_eyeButton setBackgroundColor:[UIColor blackColor]];
        [_eyeButton setImage:@"icon_beauty_eye_close".UI_VEToImage forState:UIControlStateNormal];
        [_eyeButton setImage:@"icon_beauty_eye_open".UI_VEToImage forState:UIControlStateSelected];
        [_eyeButton setTitle:CKEditorLocStringWithKey(@"ck_close",@"关闭")  forState:UIControlStateNormal];
        [_eyeButton setTitle:CKEditorLocStringWithKey(@"ck_enable",@"打开") forState:UIControlStateSelected];
        _eyeButton.titleLabel.font = SCRegularFont(12);
        [_eyeButton VElayoutWithType:VEButtonLayoutTypeImageTop space:3];
        _eyeButton.selected = YES;
        
        @weakify(self);
        [[_eyeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            x.selected = !x.selected;
            if (self.closeBlock) {
                self.closeBlock(self.index, x);
            }
            
            
        }];
    }
    
    return _eyeButton;
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
    id obj = self.dataSourceArr[indexPath.section];
    
    DVEEffectValue *value = nil;
    if ([obj isKindOfClass:[NSArray class]]) {
        value = self.dataSourceArr[indexPath.section][indexPath.row];
    } else {
        value = self.dataSourceArr[indexPath.row];
    }
    
    
    
    if (value.valueState == VEEffectValueStateNone) {
        value.valueState = VEEffectValueStateInUse;
    } else {

    }
    self.curValue = value;
    
    
//    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    if (self.eyeButton.selected) {
        [self.eyeButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.didSelectedBlock) {
        self.didSelectedBlock(value,self.index);
    }
    
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
