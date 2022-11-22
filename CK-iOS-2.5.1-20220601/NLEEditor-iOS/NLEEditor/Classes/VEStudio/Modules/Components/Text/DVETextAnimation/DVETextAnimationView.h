//
//  DVETextAnimationView.h
//  NLEEditor
//
//  Created by bytedance on 2021/6/29.
//

#import <UIKit/UIKit.h>
#import "DVETextAnimationModel.h"
#import "DVEAnimationSliderView.h"
#import "DVEVCContext.h"
#import <NLEPlatform/NLEEditor+iOS.h>
#import "DVEBundleLoader.h"

NS_ASSUME_NONNULL_BEGIN

@class DVETextAnimationView;

@protocol DVEAnimationViewDataSource <NSObject>

- (float)animationView:(DVETextAnimationView *)animationView defaultAnimationDuration:(DVEAnimationType)type;

- (float)animationView:(DVETextAnimationView *)animationView maxAnimationDuration:(DVEAnimationType)type;

- (void)animationView:(DVETextAnimationView *)animationView requestForAnimationResource:(DVEAnimationType)type handler:(DVEModuleModelHandler)handler;

@end

@protocol DVEAnimationViewDelegate <NSObject>

- (void)textAnimationView:(DVETextAnimationView *)ta_view didChangeAnimationWithType:(DVEAnimationType)ta_type;

@end


@interface DVETextAnimationView : UIView

@property (nonatomic, weak) id<DVEAnimationViewDelegate> delegate;
@property (nonatomic, weak) id<DVEAnimationViewDataSource> dataSource;

@property (nonatomic, strong) DVEAnimationSliderView *sliderView;
@property (nonatomic, strong) NLETrackSlot_OC *slot;
@property (nonatomic, assign) CGFloat sliderMaxValue;

@property (nonatomic, strong) DVETextAnimationModel *inAnimation;
@property (nonatomic, strong) DVETextAnimationModel *outAnimation;
@property (nonatomic, strong) DVETextAnimationModel *loopAnimation;
@property (nonatomic, assign) CGFloat inDuration;
@property (nonatomic, assign) CGFloat loopDuration;
@property (nonatomic, assign) CGFloat outDuration;
@end

NS_ASSUME_NONNULL_END
