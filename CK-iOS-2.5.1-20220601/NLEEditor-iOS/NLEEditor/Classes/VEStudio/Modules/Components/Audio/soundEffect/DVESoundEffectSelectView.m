//
//  DVESoundEffectSelectView.m
//  NLEEditor
//
//  Created by bytedance on 2021/7/4.
//

#import "DVESoundEffectSelectView.h"
#import "DVESoundSourceView.h"
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


@interface DVESoundEffectSelectView ()<SGPageTitleViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UIButton *coverButton;

@property (nonatomic, copy) DVESelectSoundEffectBlock selectBlock;

@property (nonatomic, strong) SGPageTitleView *titleView;
@property (nonatomic, strong) UIImageView *topBgIcon;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray<id<DVEResourceCategoryModelProtocol>>* category;
@property (nonatomic, assign) NSInteger currentIndex;

///底部区域
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic) NSString *lastSelect;
@property (nonatomic) NSString *curSelect;
@property (nonatomic) BOOL isValueChanged;




@end

@implementation DVESoundEffectSelectView

- (void)dealloc
{
    DVELogInfo(@"DVESoundEffectSelectView dealloc");
}

+ (DVESoundEffectSelectView*)showSoundEffectSelectViewInView:(UIView *)view context:(DVEVCContext*)context withSelectAudioBlock:(DVESelectSoundEffectBlock)selectAudioBlock
{
    DVESoundEffectSelectView *audioview = [[DVESoundEffectSelectView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, VE_SCREEN_HEIGHT) context:context];
    audioview.selectBlock = selectAudioBlock;

    [audioview showInView:view animation:YES];

    return audioview;
}

- (instancetype)initWithFrame:(CGRect)frame context:(DVEVCContext*)context
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
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
    [self addSubview:self.coverButton];
    [self addSubview:self.topBgIcon];
    [self addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.width.mas_equalTo(30);
        make.top.mas_equalTo(313);
        make.height.mas_equalTo(36);
    }];
    
    [self addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.titleView.mas_bottom);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
    
    [self pageTitleView:self.titleView selectedIndex:0];
}

- (void)initData
{
    @weakify(self);
    [[DVEBundleLoader shareManager] soundCategory:self.vcContext handler:^(NSArray<DVEEffectCategory *> * _Nullable categorys, NSString * _Nullable error) {
        @strongify(self);
        self.category = categorys;
        [self performSelectorOnMainThread:@selector(buildList) withObject:nil waitUntilDone:NO];
    }];
}

- (UIScrollView *)scrollView
{
    if(!_scrollView) {
        _scrollView = [UIScrollView new];
        [_scrollView setPagingEnabled:YES];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
        
    }
    return _scrollView;
}

- (UIButton *)coverButton
{
    if (!_coverButton) {
        _coverButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, VE_SCREEN_HEIGHT)];
       
        @weakify(self);
        [[_coverButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self dismiss:YES];
        }];
    }
    
    return _coverButton;
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
        config.titleFont = SCRegularFont(14);
        NSMutableArray* titles = [NSMutableArray arrayWithCapacity:self.category.count];
        for(id<DVEResourceCategoryModelProtocol> c in self.category){
            [titles addObject:c.name];
        }
        _titleView = [[SGPageTitleView alloc] initWithFrame:CGRectMake(0, 20, 130, 30) delegate:self titleNames:titles configure:config];
        _titleView.backgroundColor = [UIColor clearColor];
    }
    
    
    return _titleView;
}

- (UIImageView *)topBgIcon
{
    if (!_topBgIcon) {
        _topBgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 300, VE_SCREEN_WIDTH, 64)];
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
        _bottomView = [DVEEffectsBarBottomView newActionBarWithTitle:NLELocalizedString(@"ck_sound_effect",@"音效") action:^{
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

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    [self loadView:MIN(self.category.count - 1, currentIndex + 1)];
    [self loadView:currentIndex];
    [self loadView:MAX(0, currentIndex - 1)];
    [self loadData:currentIndex];
}

- (void)loadView:(NSInteger)index
{
    DVESoundSourceView* view = [self viewForIndex:index];
    if(view == nil){
        view = [DVESoundSourceView new];
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
    DVESoundSourceView* view = [self viewForIndex:index];
    view.data = [self.category objectAtIndex:index];
}

- (DVESoundSourceView*)viewForIndex:(NSInteger)index
{
    return (DVESoundSourceView*)[self.scrollView viewWithTag:index + 1000];
}

- (void)scrollToIndex:(NSInteger)index
{
    [self.scrollView setContentOffset:CGPointMake(index*self.scrollView.width, 0) animated:YES];
}

#pragma mark -- SGPageTitleViewDelegate

- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex
{
    self.currentIndex = selectedIndex;
    [self scrollToIndex:self.currentIndex];
}


#pragma mark -- UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 根据scrollView的滚动位置决定pageControl显示第几页
    CGFloat contentOffX =self.scrollView.contentOffset.x;
    CGFloat scrollViewW =self.scrollView.frame.size.width;
    
    int pageIndex = (contentOffX +0.5*scrollViewW)/scrollViewW;
    if(self.titleView.selectedIndex != pageIndex){
        self.titleView.selectedIndex = pageIndex;
        self.titleView.resetSelectedIndex = pageIndex;
        self.currentIndex = pageIndex;
    }
}

@end
