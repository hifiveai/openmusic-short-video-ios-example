//
//  VEEBeautyView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEEBeautyView.h"
#import "VEEBeautyViewController.h"
#import <SGPagingView/SGPagingView.h>
#import "VECommonSliderView.h"
#import "VEEMakeupViewController.h"
#import <NLEEditor/DVEEffectValue.h>

@interface VEEBeautyView ()<SGPageTitleViewDelegate,SGPageContentCollectionViewDelegate>


@property (nonatomic, strong) UIButton *compareButton;
@property (nonatomic, strong) UIView *topBackView;
@property (nonatomic, strong) VECommonSliderView *slider;
@property (nonatomic, strong) DVEEffectValue *curValue;


@property (nonatomic, strong) SGPageTitleView *titleView;
@property (nonatomic, strong) SGPageContentCollectionView *contentView;
@property (nonatomic, strong) NSArray <NSString *>*tabNames;
@property (nonatomic, strong) NSArray <VEEBeautyViewController *>*childVCs;
@property (nonatomic, strong) VEEBeautyViewController *curVC;

@property (nonatomic, assign) NSInteger lastIndex;

@end

@implementation VEEBeautyView
@synthesize capManager = _capManager;

- (instancetype)initWithFrame:(CGRect)frame Type:(VEEffectToolViewType)type DismisBlock:(VEEVoidBlock)dismissBlock
{
    if (self = [super initWithFrame:frame Type:type DismisBlock:dismissBlock]) {
        self.slider.hidden = YES;
        self.tabNames = @[CKEditorLocStringWithKey(@"ck_setting_beauty", @"美颜") ,CKEditorLocStringWithKey(@"ck_tab_face_beauty_reshape", @"微整形"),CKEditorLocStringWithKey(@"ck_tab_face_beauty_body", @"美体"),CKEditorLocStringWithKey(@"ck_tab_face_makeup", @"补妆")];
        @weakify(self);
        VEEBeautyCallBackBlock block = ^(DVEEffectValue * _Nonnull evalue,NSUInteger index) {
            @strongify(self);
            self.slider.hidden = NO;
            [self didClickedAt:evalue];
        };
        
        VEEBeautyCloseBlock closeBlock = ^(NSUInteger index,UIButton *btn) {
            @strongify(self);
            
            if (btn.selected) {
                self.slider.hidden = btn.selected;
                [self didClikedCloseAtIndex:index];
            } else {
                [self didClikedOpenAtIndex:index];
            }
            
        };
        
        
        NSMutableArray *vcArr = [NSMutableArray new];
        for (NSInteger i = 0; i < self.tabNames.count; i ++) {
            VEEBeautyViewController *vc = [[VEEBeautyViewController alloc] init];
            if (i == 3) {
                vc = [VEEMakeupViewController new];
            }
            vc.view.backgroundColor = [UIColor blackColor];
            vc.index = i;
            if (i == 0) {
                vc.eyeButton.selected = NO;
            }
            [vcArr addObject:vc];
            
            vc.didSelectedBlock = block;
            vc.closeBlock = closeBlock;
            vc.title = self.tabNames[i];
            vc.parentView = self;
        }
        self.childVCs = vcArr.copy;
    }
    self.curVC = self.childVCs.firstObject;
    [self addSubview:self.topBackView];
    [self addSubview:self.slider];
    [self addSubview:self.compareButton];
    
    
    
    
    return self;
}

- (void)didClickedAt:(DVEEffectValue *)evalue
{
//    if (self.curValue && evalue.beautyType == VEEffectBeautyTypeMakeup) {
//        [self.capManager removeMakeup:self.curValue];
//    }
    self.curValue = evalue;
    [self.capManager setMakeup:evalue];
    self.slider.value = evalue.indesty * 100;
    
}

- (void)setCapManager:(id<VECapProtocol>)capManager
{
    _capManager = capManager;
    [capManager setBeautyFaceWithArr:_curVC.dataSourceArr];
}

- (void)didClikedCloseAtIndex:(NSUInteger)index
{
    
    switch (index) {
        case 0:
            [self.capManager closeBeautyFace];
            break;
        case 1:
            [self.capManager closeBeautyVFace];
            break;
        case 2:
            [self.capManager closeBeautyBody];
            break;
        case 3:
            [self.capManager closeBeautyMakeUp];
            break;
            
        default:
            break;
    }
    
    [self.curVC reLoad];

}

- (void)didClikedOpenAtIndex:(NSUInteger)index
{
    
    switch (index) {
        case 0:
            [self.capManager setBeautyFaceWithArr:self.curVC.dataSourceArr];
            break;
        case 1:
            
            [self.capManager setBeautyVFaceWithArr:self.curVC.dataSourceArr];
            break;
        case 2:
            
            [self.capManager setBeautyBodyWithArr:self.curVC.dataSourceArr];
            break;
        case 3:
            [self.capManager setBeautyMakeupWithArr:self.curVC.dataSourceArr];
            break;
            
        default:
            break;
    }
    

}

- (void)showInView:(UIView *)view
{
    [super showInView:view];
    
    if (!_titleView) {
        [self.topBackView addSubview:self.titleView];
    }
    
    if (!_contentView) {
        [self.topBackView addSubview:self.contentView];
    }
    
    
    self.topBackView.bottom = self.bottomBar.top;
    self.slider.bottom = self.topBackView.top;
    
    self.compareButton.centerY = self.slider.top + self.slider.height * 0.5 ;
    self.compareButton.right = VE_SCREEN_WIDTH - 10;
}

#pragma mark - delegate
- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex
{
    [_contentView setPageContentCollectionViewCurrentIndex:selectedIndex];
    self.curVC = self.childVCs[selectedIndex];
    
    if (self.lastIndex != selectedIndex) {
        self.slider.hidden = YES;
        [self.curVC reLoad];
    }
    
    self.lastIndex = selectedIndex;
    
}

- (void)pageContentCollectionView:(SGPageContentCollectionView *)pageContentCollectionView progress:(CGFloat)progress originalIndex:(NSInteger)originalIndex targetIndex:(NSInteger)targetIndex
{
    [_titleView setPageTitleViewWithProgress:progress originalIndex:originalIndex targetIndex:targetIndex];
}


#pragma mark - setter

#pragma mark - getter

- (VECommonSliderView *)slider
{
    if (!_slider) {
        _slider = [[VECommonSliderView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, 50)];
        @weakify(self);
        [RACObserve(_slider, value) subscribeNext:^(NSNumber *x) {
            @strongify(self);
            float indensty = x.floatValue;
            self.curValue.indesty = indensty * 0.01;
            
            [self.capManager updateMakeup:self.curValue];
        }];
        [_slider.slider setMaximumValue:100];
        [_slider.slider setMinimumValue:0];
//        _slider.slider.value = 80;
        _slider.value = 80;
    }
    
    return _slider;
}

- (UIView *)topBackView
{
    if (!_topBackView) {
        _topBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, 110)];
        _topBackView.backgroundColor = [UIColor blackColor];
    }
    
    return _topBackView;
}



- (UIButton *)compareButton
{
    if (!_compareButton) {
        _compareButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        [_compareButton setImage:@"icon_beauty_compar".UI_VEToImage forState:UIControlStateNormal];
        @weakify(self);
        [[_compareButton rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self.capManager dismissMakeUp];
        }];
        [[_compareButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self.capManager showMakeUp];
        }];
    }
    
    return _compareButton;
}



- (SGPageTitleView *)titleView
{
    if (!_titleView) {
        SGPageTitleViewConfigure *config = [SGPageTitleViewConfigure pageTitleViewConfigure];
        config.showBottomSeparator = NO;
        config.titleAdditionalWidth = 0;
        config.titleColor = [UIColor whiteColor];
        config.titleSelectedColor = [UIColor whiteColor];
        config.indicatorColor = HEXRGBCOLOR(0xFE6646);
        config.titleFont = Font(16);
        
        _titleView = [[SGPageTitleView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, 30) delegate:self titleNames:self.tabNames configure:config];
        _titleView.backgroundColor = [UIColor blackColor];
    }
    
    
    return _titleView;
}

- (SGPageContentCollectionView *)contentView
{
    if (!_contentView) {
        _contentView = [[SGPageContentCollectionView alloc] initWithFrame:CGRectMake(0, 40, VE_SCREEN_WIDTH, 53) parentVC:self.firstAvailableUIViewController childVCs:[self childVCs]];
        _contentView.isScrollEnabled = NO;
        _contentView.isAnimated = YES;
        _contentView.backgroundColor = [UIColor blackColor];
        _contentView.delegatePageContentCollectionView = self;
        
    }
    
    return _contentView;
}

- (void)reset
{
    [self dealReset];    
}

- (void)dealReset
{
    self.slider.hidden = YES;
    [self.curVC reset];
    switch (self.curVC.index) {
        case 0:
            [self.capManager setBeautyFaceWithArr:self.curVC.dataSourceArr];
            break;
        case 1:
            [self.capManager setBeautyVFaceWithArr:self.curVC.dataSourceArr];
            break;
        case 2:
            [self.capManager setBeautyBodyWithArr:self.curVC.dataSourceArr];
            break;
        case 3:
            [self.capManager setBeautyMakeupWithArr:self.curVC.dataSourceArr];
            break;
    }
}

@end
