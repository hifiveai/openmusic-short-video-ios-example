//
//  DVETextAnimationView.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/29.
//

#import "DVETextAnimationView.h"
#import "DVEAnimationSliderView.h"
#import "DVEAnimationBar.h"
#import "DVEAnimationListView.h"
#import <SGPagingView/SGPagingView.h>
#import "DVEMacros.h"


@interface DVETextAnimationView() <DVEAnimationListViewDelegate, SGPageTitleViewDelegate, DVERangeSliderDelegate>

@property (nonatomic, strong) DVEAnimationListView *listView;
@property (nonatomic, strong) SGPageTitleView *segmentView;

@property (nonatomic, assign) DVEAnimationType ta_type;

@end


@implementation DVETextAnimationView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupLayout];
        [self setupStyle];
        self.backgroundColor = [UIColor blackColor];
    }
    
    return self;
}

- (void)setupLayout {
    [self addSubview:self.listView];
    [self addSubview:self.segmentView];
    [self addSubview:self.sliderView];
}

- (void)setupStyle {
    _ta_type = DVEAnimationTypeIn;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (!hidden) {
        [self reloadAnimations];
        [self reloadSliders];
    }
}

- (void)setSlot:(NLETrackSlot_OC *)slot{
    _slot = slot;
    CMTime time = slot.duration;
    
    NLESegmentSticker_OC *textSeg = (NLESegmentSticker_OC *)slot.segment;
    if (textSeg.stickerAnimation.loop && CMTimeGetSeconds(textSeg.stickerAnimation.inDuration) > 0) {
        _loopAnimation = [[DVETextAnimationModel alloc] init];
        _loopAnimation.type = DVEAnimationTypeLoop;
        _loopAnimation.path = textSeg.stickerAnimation.inAnimation.resourceFile;
        _loopAnimation.name = textSeg.stickerAnimation.inAnimation.name;
        _loopDuration = CMTimeGetSeconds(textSeg.stickerAnimation.inDuration);
        _loopAnimation.duration = self.loopDuration;
    } else {
        if (textSeg.stickerAnimation.inAnimation && CMTimeGetSeconds(textSeg.stickerAnimation.inDuration) > 0) {
            _inAnimation = [[DVETextAnimationModel alloc] init];
            _inAnimation.type = DVEAnimationTypeIn;
            _inAnimation.path = textSeg.stickerAnimation.inAnimation.resourceFile;
            _inAnimation.name = textSeg.stickerAnimation.inAnimation.name;
            _inDuration = CMTimeGetSeconds(textSeg.stickerAnimation.inDuration);
            _inAnimation.duration = self.inDuration;
        }
        if (textSeg.stickerAnimation.outAnimation && CMTimeGetSeconds(textSeg.stickerAnimation.outDuration) > 0) {
            _outAnimation = [[DVETextAnimationModel alloc] init];
            _outAnimation.type = DVEAnimationTypeOut;
            _outAnimation.path = textSeg.stickerAnimation.outAnimation.resourceFile;
            _outAnimation.name = textSeg.stickerAnimation.outAnimation.name;
            _outDuration = CMTimeGetSeconds(textSeg.stickerAnimation.outDuration);
            _outAnimation.duration = self.outDuration;
        }
    }
}
- (void)reloadAnimations {
    DVETextAnimationModel *model;
    if (_ta_type == DVEAnimationTypeIn) {
        model = _inAnimation;
    }
    if (_ta_type == DVEAnimationTypeOut) {
        model = _outAnimation;
    }
    if (_ta_type == DVEAnimationTypeLoop) {
        model = _loopAnimation;
    }
    
    [self.dataSource animationView:self requestForAnimationResource:_ta_type handler:^(NSArray<DVEEffectValue *> * _Nullable datas, NSString * _Nullable error) {
        // Maybe DVETextAnimationModel is not necessary.
        NSMutableArray *models = [NSMutableArray array];
        for (DVEEffectValue *value in datas) {
            DVETextAnimationModel *model = [[DVETextAnimationModel alloc] init];
            model.name = value.name;
            model.path = value.sourcePath;
            model.icon = [value.imageURL path];
            [models addObject:model];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.listView showAnimations:models selectedAnimation:model];
        });
    }];
}

- (void)reloadSliders
{
    if (self.ta_type == DVEAnimationTypeIn || self.ta_type == DVEAnimationTypeOut) {
        self.sliderView.hidden = self.inAnimation == nil && self.outAnimation == nil;
    }
    if (self.ta_type == DVEAnimationTypeLoop) {
        self.sliderView.hidden = self.loopAnimation == nil;
    }
    _sliderView.slider.maxValue = [self.dataSource animationView:self maxAnimationDuration:_ta_type];
    // update slider ui
    if (_inAnimation || _loopAnimation) {
        [_sliderView.slider showLeftSlider];
    } else {
        [_sliderView.slider hiddenLeftSlider];
    }
    if (_outAnimation && _ta_type != DVEAnimationTypeLoop) {
        [_sliderView.slider showRightSlider];
    } else {
        [_sliderView.slider hiddenRightSlider];
    }
    // update slider value
    if (!_inAnimation) {
        _inDuration = 0;
    } else if (_inDuration == 0) {
        _inDuration = [self.dataSource animationView:self defaultAnimationDuration:DVEAnimationTypeIn];
    }
    if (!_outAnimation) {
        _outDuration = 0;
    } else if (_outDuration == 0) {
        _outDuration = [self.dataSource animationView:self defaultAnimationDuration:DVEAnimationTypeOut];
    }
    if (!_loopAnimation) {
        _loopDuration = 0;
    } else if (_loopDuration == 0) {
        _loopDuration = [self.dataSource animationView:self defaultAnimationDuration:DVEAnimationTypeLoop];
    }
    if (_ta_type == DVEAnimationTypeIn || _ta_type == DVEAnimationTypeOut) {
        [_sliderView.slider setLeftValue:_inDuration];
        [_sliderView.slider setRightValue:_outDuration];
        [_sliderView hiddenRangeLabel];
    }
    if (_ta_type == DVEAnimationTypeLoop) {
        [_sliderView.slider setLeftValue:_loopDuration];
        [_sliderView showRangeLabel];
    }
}
#pragma mark - getter
- (SGPageTitleView *)segmentView {
    if (!_segmentView) {
        SGPageTitleViewConfigure *config = [SGPageTitleViewConfigure pageTitleViewConfigure];
        config.showBottomSeparator = NO;
        config.showIndicator = NO;
        config.titleAdditionalWidth = 0;
        config.titleColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        config.titleSelectedColor = [UIColor whiteColor];
        config.titleFont = SCRegularFont(14);
        _segmentView = [[SGPageTitleView alloc] initWithFrame:CGRectMake(13, 20, 240, 24) delegate:self titleNames:@[NLELocalizedString(@"ck_text_anim_in", @"入场动画") , NLELocalizedString(@"ck_text_anim_out",@"出场动画"), NLELocalizedString(@"ck_text_anim_loop",@"循环动画")] configure:config];
        _segmentView.backgroundColor = UIColor.clearColor;
    }
    return _segmentView;
}
- (DVEAnimationListView *)listView {
    if (!_listView) {
        _listView = [[DVEAnimationListView alloc] init];
        _listView.delegate = self;
        _listView.frame = CGRectMake(17, 54, VE_SCREEN_WIDTH - 17, 100);
        _listView.backgroundColor = UIColor.clearColor;
    }
    return _listView;
}
- (DVEAnimationSliderView *)sliderView {
    if (!_sliderView) {
        _sliderView = [[DVEAnimationSliderView alloc] initWithFrame:CGRectMake(15, 154, VE_SCREEN_WIDTH - 15, 40)];
        _sliderView.slider.delegate = self;
        _sliderView.backgroundColor = UIColor.clearColor;
    }
    return _sliderView;
}

#pragma mark - DVEPickerViewDelegate
- (void)listView:(DVEAnimationListView *)listView didSelectAnimation:(DVETextAnimationModel *)animation {
    if (_ta_type == DVEAnimationTypeIn) {
        animation.duration = _inDuration;
        _inAnimation = animation;
        _loopAnimation = nil;
        _loopDuration = 0;
    }
    if (_ta_type == DVEAnimationTypeOut) {
        animation.duration = _outDuration;
        _outAnimation = animation;
        _loopAnimation = nil;
        _loopDuration = 0;
    }
    if (_ta_type == DVEAnimationTypeLoop) {
        animation.duration = _loopDuration;
        _loopAnimation = animation;
        _inAnimation = nil;
        _outAnimation = nil;
        _inDuration = 0;
        _outDuration = 0;
    }
    [self reloadSliders];
    [self.delegate textAnimationView:self didChangeAnimationWithType:_ta_type];
}
#pragma mark - SGPageTitleViewDelegate
- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex {
    DVEAnimationType type = selectedIndex;
    
    if (type == _ta_type) {
        return;
    }
    _ta_type = type;
    [self reloadAnimations];
    [self reloadSliders];
    [self.delegate textAnimationView:self didChangeAnimationWithType:_ta_type];
}
#pragma mark - DVERangeSliderDelegate
- (void)slider:(DVERangeSlider *)slider leftValueChange:(CGFloat)left {
    if (_ta_type == DVEAnimationTypeIn || _ta_type == DVEAnimationTypeOut) {
        _inDuration = left;
        _inAnimation.duration = left;
        [self.delegate textAnimationView:self didChangeAnimationWithType:DVEAnimationTypeIn];
    }else if (_ta_type == DVEAnimationTypeLoop) {
        _loopDuration = left;
        _loopAnimation.duration = left;
        [self.delegate textAnimationView:self didChangeAnimationWithType:DVEAnimationTypeLoop];
    }
}
- (void)slider:(DVERangeSlider *)slider rightValueChange:(CGFloat)right {
    _outDuration = right;
    _outAnimation.duration = right;
    [self.delegate textAnimationView:self didChangeAnimationWithType:DVEAnimationTypeOut];
}
@end
