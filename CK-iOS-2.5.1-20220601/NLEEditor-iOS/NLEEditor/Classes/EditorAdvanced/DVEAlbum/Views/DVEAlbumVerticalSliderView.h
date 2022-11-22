//
//  DVEAlbumVerticalSliderView.h
//  AWEStudio
//
//  Created by bytedance on 2020/3/12.
//

#import <UIKit/UIKit.h>
//#import "TOCPublishModel.h"

NS_ASSUME_NONNULL_BEGIN

@class DVEAlbumVerticalSliderView;
@protocol DVEAlbumVerticalSliderViewDelegate <NSObject>

- (void)verticalSliderViewWillScroll:(DVEAlbumVerticalSliderView *)sliderView;
- (void)verticalSliderViewDidScroll:(DVEAlbumVerticalSliderView *)sliderView withScrollPosition:(CGFloat)position;
- (void)verticalSliderViewFinishScroll:(DVEAlbumVerticalSliderView *)sliderView;

@end

@interface DVEAlbumVerticalSliderView : UIView

@property (nonatomic, weak) id<DVEAlbumVerticalSliderViewDelegate> delegate;

@property (nonatomic, assign) CGFloat topBoundary;
@property (nonatomic, assign) CGFloat bottomBoundary;

@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, assign) BOOL showAnimation;
@property (nonatomic, assign) BOOL stretchedAnimation;

@property (nonatomic, strong) NSDictionary *trackExtraDict;

- (void)appearAnimation;
- (void)disappearAnimation;

@end

NS_ASSUME_NONNULL_END
