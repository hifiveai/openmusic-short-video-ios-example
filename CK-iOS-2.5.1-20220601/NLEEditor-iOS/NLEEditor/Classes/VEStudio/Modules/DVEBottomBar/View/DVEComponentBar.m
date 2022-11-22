//
//   DVEComponentBar.m
//   NLEEditor
//
//   Created  by ByteDance on 2021/6/1.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//


#import "DVEComponentBar.h"
#import "DVEModuleItem.h"
#import "DVEComponentAction.h"
#import <DVETrackKit/DVEUILayout.h>
#import "DVELoggerImpl.h"
#import "DVEReportUtils.h"
#import <SDWebImage/SDWebImage.h>
#import <ReactiveObjC/ReactiveObjC.h>

#define ItemWidth 64

@interface DVEComponentBar()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UICollectionView *collecView;
@property (nonatomic, strong) NSArray<id<DVEBarComponentProtocol>> *dataSource;
@property (nonatomic, strong) id<DVEBarComponentProtocol> currentBackComponent;
@end

@implementation DVEComponentBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (instancetype)init
{
    if(self = [super init]) {
        [self initView];
    }
    return self;
}

-(void)initView
{
    [self addSubview:self.collecView];
}

-(void)buildLayout
{
    NSMutableArray* show = [NSMutableArray array];
    for(id<DVEBarComponentProtocol> cop in self.component.subComponents){
        if([self componentStatus:cop] != DVEBarComponentViewStatusHidden && (cop.componentGroup & self.component.currentSubGroup || (cop.componentGroup == 0 && self.component.currentSubGroup == 0))){
            [show addObject:cop];
        }
    }
    self.dataSource = show;
    
    if(self.currentBackComponent){
        [self setupBackButton:YES];
        DVEUILayoutAlignment aligment = [DVEUILayout dve_alignmentWithName:DVEUILayoutSecondBarAlignStyle];
        switch (aligment) {
            case DVEUILayoutAlignmentLeft: {
                if ((self.dataSource.count * ItemWidth) > (VE_SCREEN_WIDTH - ItemWidth)) {
                    self.collecView.frame = CGRectMake(ItemWidth, 0, VE_SCREEN_WIDTH - ItemWidth, ItemWidth);
                } else {
                    self.collecView.frame = CGRectMake(ItemWidth, 0, self.dataSource.count * ItemWidth, ItemWidth);
                }
                break;
            }
            case DVEUILayoutAlignmentCenter: {
                self.collecView.frame = CGRectMake((VE_SCREEN_WIDTH - self.dataSource.count * ItemWidth) / 2, 0, self.dataSource.count * ItemWidth, ItemWidth);
                break;
            }
            case DVEUILayoutAlignmentRight: {
                if ((self.dataSource.count * ItemWidth) > (VE_SCREEN_WIDTH - ItemWidth)) {
                    self.collecView.frame = CGRectMake(ItemWidth,0, VE_SCREEN_WIDTH - ItemWidth, ItemWidth);
                } else {
                    self.collecView.frame = CGRectMake(VE_SCREEN_WIDTH - self.dataSource.count * ItemWidth,0, self.dataSource.count * ItemWidth, ItemWidth);
                }
                break;
            }
            default:
                NSAssert(NO, @"aligment type invaild!!!");
                break;
        }
    }else{
        [self setupBackButton:NO];
        if ((self.dataSource.count * ItemWidth) > VE_SCREEN_WIDTH) {
            self.collecView.frame = CGRectMake(0,0, VE_SCREEN_WIDTH, ItemWidth);
        } else {
            self.collecView.frame = CGRectMake(VE_SCREEN_WIDTH - self.dataSource.count * ItemWidth,0, self.dataSource.count * ItemWidth, ItemWidth);
        }
    }
    
    [self.collecView reloadData];
}

- (NSMutableDictionary<NSNumber *,id<DVEBarComponentProtocol>> *)backComponentDic
{
    if (!_backComponentDic) {
        _backComponentDic = [NSMutableDictionary dictionary];
    }
    return _backComponentDic;
}

- (id<DVEBarComponentProtocol>)currentBackComponent
{
    if (self.component.parent.componentType != DVEBarComponentTypeRoot ||
        self.component.currentSubGroup == DVEBarSubComponentGroupEdit) {
        //返回带有二级返回icon的component
        return self.backComponentDic[@(DVEBarSubComponentGroupEdit)];
    } else {
        //返回带有一级返回icon的component
        return self.backComponentDic[@(DVEBarSubComponentGroupAdd)];
    }
}

-(DVEBarComponentViewStatus)componentStatus:(id<DVEBarComponentProtocol>)cop
{
    
    NSNumber* result = [[DVEComponentAction shareManager] callMethod:cop.statusActionName withArgument:@[self.component]];
    if(result == nil){
        return DVEBarComponentViewStatusNormal;
    }
    
    return [result integerValue];

}

- (void)setupBackButton:(BOOL)setup
{
    if(setup){
        if(!self.backButton){
            self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, ItemWidth, ItemWidth)];
            
            @weakify(self);
            [[self.backButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                [self clickToBack];
            }];
            
            [self addSubview:self.backButton];
        }
        
        id<DVEBarComponentViewModelProtocol> viewModel = self.currentBackComponent.viewModel;
        if(viewModel.imageURL != nil){
            [self.backButton sd_setImageWithURL:viewModel.imageURL forState:UIControlStateNormal];
        }else {
            [self.backButton setImage:viewModel.localAssetImage forState:UIControlStateNormal];
        }
    }else{
        [self.backButton removeFromSuperview];
        self.backButton = nil;
    }
}

-(void)clickToBack
{
    [self.vcContext.playerService pause];
    [[DVEComponentAction shareManager] callMethod:self.currentBackComponent.clickActionName withArgument:@[self.component]];
}

-(void)showInView:(UIView *)view animation:(BOOL)animation
{
    [super showInView:view animation:animation];
    [self buildLayout];
}

- (UICollectionView *)collecView
{
    if (!_collecView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collecView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collecView.showsHorizontalScrollIndicator = NO;
        _collecView.showsVerticalScrollIndicator = NO;
        _collecView.delegate = self;
        _collecView.dataSource = self;
        
        _collecView.backgroundColor = [UIColor clearColor];
        
        if (@available(iOS 11.0, *)) {
            _collecView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            
            
        }
        
        
        [_collecView registerClass:[DVEModuleItem class] forCellWithReuseIdentifier:NSStringFromClass(DVEModuleItem.class)];
    }
    
    return _collecView;
}

- (void)refreshBar
{
    [super refreshBar];
    [self buildLayout];
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
    
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DVEModuleItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(DVEModuleItem.class) forIndexPath:indexPath];
    id<DVEBarComponentProtocol> model = self.dataSource[indexPath.row];
    id<DVEBarComponentViewModelProtocol> viewModel = model.viewModel;
    cell.titleLable.text = viewModel.title;

    [cell.iconView sd_setImageWithURL:viewModel.imageURL placeholderImage:viewModel.localAssetImage];
    
    if([self componentStatus:model] == DVEBarComponentViewStatusNormal){
        cell.iconView.alpha = 1.0;
        cell.titleLable.enabled = YES;
    }else{
        cell.iconView.alpha = 0.5;
        cell.titleLable.enabled = NO;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSource.count > 0 ? 1 : 0;
}


- (NSInteger)panelType
{
    return self.component.componentType;
}

#pragma mark -- UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(ItemWidth, ItemWidth);
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
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.vcContext.playerService pause];
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    id<DVEBarComponentProtocol> model = self.dataSource[indexPath.row];
    [DVEReportUtils logComponentClick:self.vcContext currentComponent:self.component clickComponent:model];
    [[DVEComponentAction shareManager] callMethod:model.clickActionName withArgument:@[model]];
    
//    SEL sel = NSSelectorFromString(model.clickActionName);
//    if(sel && [[DVEComponentAction shareManager] respondsToSelector:sel]){
//        ///TODO 这里Relase模式下， id obj = 获取返回值，在执行deleteAudio:的action时会莫名其妙crash
//        [DVEReportUtils logComponentClick:self.vcContext currentComponent:self.component clickComponent:model];
//        [[DVEComponentAction shareManager] performSelector:sel withObject:model];
//    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<DVEBarComponentProtocol> model = self.dataSource[indexPath.row];
    SEL sel = NSSelectorFromString(model.clickActionName);
    if(sel && [[DVEComponentAction shareManager] respondsToSelector:sel]){
        
        if([self componentStatus:model] == DVEBarComponentViewStatusDisable){
            return NO;
        }
        return YES;
    }else{
        [[DVEComponentAction shareManager] actionNotFound:model];
    }
    return NO;
}

@end
