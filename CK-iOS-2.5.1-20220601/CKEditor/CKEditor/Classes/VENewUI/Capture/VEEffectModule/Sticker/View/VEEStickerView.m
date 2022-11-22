//
//  VEEStickerView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEEStickerView.h"
#import "VEEStickerViewController.h"
#import <SGPagingView/SGPagingView.h>
#import "DVECustomerHUD.h"


@interface VEEStickerView ()<SGPageTitleViewDelegate,SGPageContentCollectionViewDelegate>

@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UIView *topBackView;

@property (nonatomic, strong) SGPageTitleView *titleView;
@property (nonatomic, strong) SGPageContentCollectionView *contentView;
@property (nonatomic, strong) NSArray <NSString *>*tabNames;
@property (nonatomic, strong) NSArray <VEEStickerViewController *>*childVCs;
@property (nonatomic, strong) DVEEffectValue *curValue;
@property (nonatomic, strong) VEEStickerViewController *curVC;

@end

@implementation VEEStickerView

- (instancetype)initWithFrame:(CGRect)frame Type:(VEEffectToolViewType)type DismisBlock:(VEEVoidBlock)dismissBlock
{
    if (self = [super initWithFrame:frame Type:type DismisBlock:dismissBlock]) {
        self.tabNames = @[CKEditorLocStringWithKey(@"ck_image_sticker", @"贴纸")];
        @weakify(self);
        VEEStickerCallBackBlock block = ^(DVEEffectValue * _Nonnull evalue) {
            @strongify(self);
            [self didClickedAt:evalue];
            self.curValue = evalue;
            if(evalue.name.length > 0){
                [DVECustomerHUD showMessage:evalue.name afterDele:1];
            }
        };
        
        
        NSMutableArray *vcArr = [NSMutableArray new];
        for (NSInteger i = 0; i < self.tabNames.count; i ++) {
            VEEStickerViewController *vc = [VEEStickerViewController new];
            vc.index = i;
            [vcArr addObject:vc];
            
            vc.didSelectedBlock = block;
        }
        self.childVCs = vcArr.copy;
    }
    
    [self addSubview:self.topBackView];
    
    
    
    return self;
}

- (void)didClickedAt:(DVEEffectValue *)evalue
{
    [self.capManager setSticker:evalue];
}

- (void)showInView:(UIView *)view
{
    [super showInView:view];
    
    if (!_clearButton) {
        [self.topBackView addSubview:self.clearButton];
    }
    
    if (!_titleView) {
        [self.topBackView addSubview:self.titleView];
    }
    
    if (!_contentView) {
        [self addSubview:self.contentView];
    }
    
    self.contentView.bottom = self.bottomBar.top;
    self.topBackView.bottom = self.contentView.top;
   
}

#pragma mark - delegate
- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex
{
    [_contentView setPageContentCollectionViewCurrentIndex:selectedIndex];
    self.curVC = self.childVCs[selectedIndex];
}

- (void)pageContentCollectionView:(SGPageContentCollectionView *)pageContentCollectionView progress:(CGFloat)progress originalIndex:(NSInteger)originalIndex targetIndex:(NSInteger)targetIndex
{
    [_titleView setPageTitleViewWithProgress:progress originalIndex:originalIndex targetIndex:targetIndex];
}


#pragma mark - setter

#pragma mark - getter

- (UIView *)topBackView
{
    if (!_topBackView) {
        _topBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, 40)];
        _topBackView.backgroundColor = [UIColor blackColor];
    }
    
    return _topBackView;
}

- (UIButton *)clearButton
{
    if (!_clearButton) {
        _clearButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
        [_clearButton setBackgroundColor:[UIColor blackColor]];
        [_clearButton setImage:@"icon_sticker_clear".UI_VEToImage forState:UIControlStateNormal];
        @weakify(self);
        [[_clearButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self.capManager removeSticker];
            self.curValue.valueState = VEEffectValueStateNone;
            [self.curVC reset];

        }];
    }
    
    return _clearButton;
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
        
        _titleView = [[SGPageTitleView alloc] initWithFrame:CGRectMake(80, 5, 120, 30) delegate:self titleNames:self.tabNames configure:config];
        _titleView.backgroundColor = [UIColor blackColor];
        _titleView.selectedIndex = 0;
    }
    
    
    return _titleView;
}

- (SGPageContentCollectionView *)contentView
{
    if (!_contentView) {
        _contentView = [[SGPageContentCollectionView alloc] initWithFrame:CGRectMake(0, 40, VE_SCREEN_WIDTH, 156) parentVC:self.firstAvailableUIViewController childVCs:[self childVCs]];
        _contentView.isScrollEnabled = YES;
        _contentView.isAnimated = YES;
        _contentView.backgroundColor = [UIColor blackColor];
        _contentView.delegatePageContentCollectionView = self;
        
    }
    
    return _contentView;
}

@end
