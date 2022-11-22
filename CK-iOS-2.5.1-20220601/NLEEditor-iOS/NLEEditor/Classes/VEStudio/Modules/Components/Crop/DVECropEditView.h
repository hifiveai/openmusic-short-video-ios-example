//
//  DVECropEditView.h
//  NLEEditor
//
//  Created by bytedance on 2021/4/12.
//

#import <UIKit/UIKit.h>
#import "DVECropGridView.h"

NS_ASSUME_NONNULL_BEGIN

@class DVECropEditView;
@protocol DVECropEditViewDelegate <NSObject>

- (BOOL)isCurrentEditViewShouldCrop:(DVECropEditView *)editView
                           gridView:(DVECropGridView *)gridView
                         updateRect:(CGRect)updateRect
                         panGesture:(UIPanGestureRecognizer *)panGesture;


- (void)editViewDidEndedCrop:(DVECropEditView *)editView
                  panGesture:(UIPanGestureRecognizer *)panGesture;

- (void)editDidEnd;

@end

@interface DVECropEditView : UIView

@property (nonatomic, weak) id<DVECropEditViewDelegate> delegate;

@property (nonatomic, strong) DVECropGridView *gridView;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)updateEditViewWithRect:(CGRect)rect duration:(NSTimeInterval)duration;

- (CGRect)cropRect;

- (void)setCropRect:(CGRect)cropRect;

- (CGRect)maxCropRect;

- (CGFloat)cropRatio;

@end

NS_ASSUME_NONNULL_END
