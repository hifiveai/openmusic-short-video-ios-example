//
//  DVEStickerActionObjectBar.m
//  NLEEditor
//
//  Created by bytedance on 2021/8/10.
//

#import "DVEStickerActionObjectBar.h"
#import "DVETextAnimationView.h"
#import "DVEEffectsBarBottomView.h"
#import <Masonry/Masonry.h>

@interface DVEStickerActionObjectBar()<DVEAnimationViewDelegate, DVEAnimationViewDataSource>
 
@property (nonatomic, strong) DVETextAnimationView *animationView;

@property (nonatomic, strong) DVEEffectsBarBottomView *bottomView;

@property (nonatomic, strong) NLEStyStickerAnimation_OC *animation;

@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@end

@implementation DVEStickerActionObjectBar

DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildLayout];
        self.backgroundColor = HEXRGBCOLOR(0x181718);
    }
    
    return self;
}

- (void)buildLayout
{
    [self addSubview:self.animationView];
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(204);
        make.top.left.right.equalTo(self);
    }];
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.animationView.mas_bottom);
        make.left.right.bottom.equalTo(self);
    }];
}

#pragma mark baseBar overwrite
- (void)showInView:(UIView *)view animation:(BOOL)animation
{
    [super showInView:view animation:animation];
        
    self.animationView.slot = self.vcContext.mediaContext.selectTextSlot;
    
    // just for triggering「reloadAnimations」
    self.animationView.hidden = NO;
}

#pragma mark lazy load
- (DVETextAnimationView *)animationView
{
    if (!_animationView) {
        _animationView = [[DVETextAnimationView alloc] init];
        _animationView.frame = CGRectMake(0, 0, VE_SCREEN_WIDTH, 254);
        _animationView.backgroundColor = [UIColor clearColor];
        _animationView.delegate = self;
        _animationView.dataSource = self;
    }
    
    return _animationView;
}

- (DVEEffectsBarBottomView *)bottomView
{
    if(!_bottomView) {
        @weakify(self);
        _bottomView = [DVEEffectsBarBottomView newActionBarWithTitle:NLELocalizedString(@"ck_sticker_animation", @"贴纸动画") action:^{
            @strongify(self);

            [self dismiss:YES];
            
            [self.actionService commitNLE:YES];
            
            NLETrackSlot_OC *slot = self.vcContext.mediaContext.selectTextSlot;
            
            [self.nle setStickerPreviewMode:slot previewMode:0];
        }];
        _bottomView.backgroundColor = [UIColor clearColor];
    }
        
    return _bottomView;
}

#pragma mark DVEAnimationViewDelegate
- (void)textAnimationView:(DVETextAnimationView *)ta_view didChangeAnimationWithType:(DVEAnimationType)ta_type
{
    if (!_animation) {
        _animation = [[NLEStyStickerAnimation_OC alloc] init];
    }
    
    if (ta_type == DVEAnimationTypeIn || ta_type == DVEAnimationTypeOut) {
        _animation.inAnimation = [ta_view.inAnimation toResourceNode];
        _animation.inDuration = CMTimeMakeWithSeconds(ta_view.inDuration, USEC_PER_SEC);

        _animation.outAnimation = [ta_view.outAnimation toResourceNode];;
        _animation.outDuration = CMTimeMakeWithSeconds(ta_view.outDuration, USEC_PER_SEC);
        
        _animation.loop = NO;
    } else if (ta_type == DVEAnimationTypeLoop) {
        _animation.inAnimation = [ta_view.loopAnimation toResourceNode];
        _animation.inDuration = CMTimeMakeWithSeconds(ta_view.loopDuration, USEC_PER_SEC);
        _animation.loop = ta_view.loopAnimation ? YES : NO;
    }
    
    [self animationDidUpdate:_animation type:ta_type];
}

- (void)animationDidUpdate:(NLEStyStickerAnimation_OC *)animation type:(NSUInteger)type
{
    NLETrackSlot_OC *slot = self.vcContext.mediaContext.selectTextSlot;
    if (slot) {
        NLESegmentSticker_OC *seg = (NLESegmentSticker_OC *)slot.segment;
        seg.stickerAnimation = animation;
        
        [self.actionService commitNLE:NO];
        
        [self.delegate animationDidUpdate];
    }
    
    if (CMTimeGetSeconds(animation.inDuration) > 0 || CMTimeGetSeconds(animation.outDuration) > 0) {
        [self.nle setStickerPreviewMode:slot previewMode:0];
        [self.nle setStickerPreviewMode:slot previewMode:(int)type + 1];
    }
}

#pragma mark DVEAnimationViewDataSource
- (float)animationView:(DVETextAnimationView *)animationView defaultAnimationDuration:(DVEAnimationType)type
{
    if (type == DVEAnimationTypeIn || type == DVEAnimationTypeOut) {
        return 0.1f;
    } else if (type == DVEAnimationTypeLoop) {
        return 0.6f;
    }
    
    return 0;
}

- (float)animationView:(DVETextAnimationView *)animationView maxAnimationDuration:(DVEAnimationType)type
{
    float maxValue = CMTimeGetSeconds(self.vcContext.mediaContext.selectTextSlot.duration);
    if (type == DVEAnimationTypeLoop) {
        maxValue -= 0.2f;
    }
    
    return maxValue;
}

- (void)animationView:(DVETextAnimationView *)animationView requestForAnimationResource:(DVEAnimationType)type handler:(DVEModuleModelHandler)handler
{
    [[DVEBundleLoader shareManager] stickerAnimation:self.vcContext type:type handler:handler];
}

@end
