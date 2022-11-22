//
//  DVEAudioSelectView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEAudioSelectView.h"
#import "DVEAudioSourceView.h"
#import <SGPagingView/SGPagingView.h>
#import "DVEMacros.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEVCContext.h"
#import "DVEEffectsBarBottomView.h"
#import "NSString+VEToImage.h"
#import "DVEBundleLoader.h"
#import "DVELoggerImpl.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>

@interface DVEAudioSelectView ()<SGPageTitleViewDelegate,UIScrollViewDelegate>

@property (nonatomic, copy) DVESelectAudioBlock selectBlock;

@property (nonatomic, strong) UIImageView *topBgIcon;
@property (nonatomic, strong) SGPageTitleView *titleView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray<id<DVEResourceCategoryModelProtocol>>* category;
@property (nonatomic, assign) NSInteger currentIndex;

///底部区域
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic) NSString *lastSelect;
@property (nonatomic) NSString *curSelect;
@property (nonatomic) BOOL isValueChanged;




@end

@implementation DVEAudioSelectView

- (void)dealloc
{
    DVELogInfo(@"VEVCAudioSelectView dealloc");
}

+ (DVEAudioSelectView*)showAudioSelectViewInView:(UIView *)view context:(DVEVCContext*)context withSelectAudioBlock:(DVESelectAudioBlock)selectAudioBlock
{
    DVEAudioSelectView *audioview = [[DVEAudioSelectView alloc] initWithFrame:CGRectMake(0, (40 - VETopMargnValue) + VETopMargn, VE_SCREEN_WIDTH, VE_SCREEN_HEIGHT - ((40 - VETopMargnValue) + VETopMargn)) context:context];
    audioview.selectBlock = selectAudioBlock;

    [audioview showInView:view animation:YES];

    return audioview;
}

- (instancetype)initWithFrame:(CGRect)frame context:(DVEVCContext*)context
{
    if (self = [super initWithFrame:frame]) {
        self.vcContext = context;
        [self buildLayout];
        [self initData];
    }
    return self;
}

- (void)buildLayout
{
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(50 + VEBottomMargn);
    }];
}

- (void)buildList
{
    if(self.titleView){
        [self addSubview:self.topBgIcon];
        [self addSubview:self.titleView];
        CGFloat w = 130;
        [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset((VE_SCREEN_WIDTH - w) * 0.5);
            make.right.equalTo(self).offset(-(VE_SCREEN_WIDTH - w) * 0.5);
            make.top.mas_equalTo(34);
            make.height.mas_equalTo(30);
        }];
        
        [self addSubview:self.scrollView];
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self.titleView.mas_bottom);
            make.bottom.equalTo(self.bottomView.mas_top);
        }];
        [self initView];
        if(self.category.count > 0){
            self.currentIndex = self.category.count - 1;
            self.titleView.selectedIndex = self.currentIndex;
            [self scrollToIndex:self.currentIndex animated:NO];
        }
    }
}

- (void)initData
{
    @weakify(self);
    [[DVEBundleLoader shareManager] musicCategory:self.vcContext handler:^(NSArray<DVEEffectCategory *> * _Nullable categorys, NSString * _Nullable error) {
        @strongify(self);
        self.category = categorys;
        if(self.category.count > 0){
            [self performSelectorOnMainThread:@selector(buildList) withObject:nil waitUntilDone:NO];
        }
    }];
}

- (void)initView
{
    for(int i=0;i<self.category.count;i++){
        [self loadView:i];
        [self loadData:i];
    }
}

- (void)reloadAll
{
    for(int i=0;i<self.category.count;i++){
        DVEAudioSourceView* view = [self viewForIndex:i];
        [view reloadData];
    }
}

- (UIScrollView *)scrollView
{
    if(!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
        
    }
    return _scrollView;
}

- (SGPageTitleView *)titleView
{
    if (!_titleView) {
        NSMutableArray* titles = [NSMutableArray arrayWithCapacity:self.category.count];
        for(id<DVEResourceCategoryModelProtocol> c in self.category){
            [titles addObject:c.name];
        }
        SGPageTitleViewConfigure *config = [SGPageTitleViewConfigure pageTitleViewConfigure];
        config.showBottomSeparator = NO;
        config.titleAdditionalWidth = 0;
        config.titleColor = HEXRGBACOLOR(0xFFFFFF, 0.5);
        config.titleSelectedColor = [UIColor whiteColor];
        config.indicatorColor = HEXRGBCOLOR(0xFE6646);
        config.titleFont = SCRegularFont(14);

        _titleView = [[SGPageTitleView alloc] initWithFrame:CGRectMake(0, 20, 130, 30) delegate:self titleNames:titles configure:config];
        _titleView.backgroundColor = [UIColor clearColor];
    }
    
    return _titleView;
}

- (UIImageView *)topBgIcon
{
    if (!_topBgIcon) {
        _topBgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, 64)];
        UIImage *icon = @"bg_icon_audiosound".dve_toImage;
        
        [icon resizableImageWithCapInsets:UIEdgeInsetsMake(VE_SCREEN_WIDTH * 0.5, 64 * 0.5, 64 * 0.5 -1, VE_SCREEN_WIDTH * 0.5 - 1) resizingMode:UIImageResizingModeTile];
        _topBgIcon.image = icon;
    }
    
    return _topBgIcon;
}

- (UIView*)bottomView
{
    if(!_bottomView) {
        @weakify(self);
        _bottomView = [DVEEffectsBarBottomView newActionBarWithTitle:NLELocalizedString(@"ck_audio",@"音频") action:^{
            @strongify(self);
            if (self.isValueChanged) {
                self.isValueChanged = NO;
            }

            [self dismiss:YES];
        }];
        _bottomView.backgroundColor = HEXRGBCOLOR(0x181718);
    }
    return _bottomView;
}

- (void)loadView:(NSInteger)index
{
    DVEAudioSourceView* view = [self viewForIndex:index];
    if(view == nil){
        view = [DVEAudioSourceView new];
        view.vcContext = self.vcContext;
        @weakify(self);
        view.selectBlock = ^(id  _Nullable audio, BOOL isLocal, NSString *audioName) {
            @strongify(self);
            if (![self.lastSelect isEqualToString:audio]) {
                self.isValueChanged = YES;
            }
            if (self.selectBlock) {
                self.selectBlock(audio ,audioName);
            }
            [self removeFromSuperview];
        };
        view.tag = index + 1000;
        [self.scrollView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.bottom.top.equalTo(self.scrollView);
            make.left.equalTo(self.scrollView).offset(self.width * index);
            make.right.equalTo(self.scrollView.mas_right).offset(-(self.category.count - index - 1) * self.width);
        }];
    }
}

- (void)loadData:(NSInteger)index
{
    DVEAudioSourceView* view = [self viewForIndex:index];
    view.data = [self.category objectAtIndex:index];
}

- (DVEAudioSourceView*)viewForIndex:(NSInteger)index
{
    return (DVEAudioSourceView*)[self.scrollView viewWithTag:index + 1000];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated
{
    [self.scrollView setContentOffset:CGPointMake(index*self.scrollView.width, 0) animated:animated];
}

#pragma mark -- SGPageTitleViewDelegate

- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex
{
    [self reloadAll];
    self.currentIndex = selectedIndex;
    [self scrollToIndex:self.currentIndex animated:NO];
}


#pragma mark -- UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 根据scrollView的滚动位置决定pageControl显示第几页
    CGFloat contentOffX =self.scrollView.contentOffset.x;
    CGFloat scrollViewW =self.scrollView.frame.size.width;
    
    int pageIndex = roundf(contentOffX/scrollViewW);
    if(self.titleView.selectedIndex != pageIndex && pageIndex < self.category.count){
        self.titleView.selectedIndex = pageIndex;
        self.titleView.resetSelectedIndex = pageIndex;
        self.currentIndex = pageIndex;
        [self reloadAll];
    }
}
@end
