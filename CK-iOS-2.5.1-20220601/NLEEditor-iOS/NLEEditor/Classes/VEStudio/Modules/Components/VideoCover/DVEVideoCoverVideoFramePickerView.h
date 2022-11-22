//
//  DVEVideoCoverVideoFramePickerView.h
//  NLEEditor
//
//  Created by bytedance on 2021/6/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DVEVideoCoverVideoFramePickerDelegate <NSObject>

- (void)updatePreviewWithCurrentTimeRatio:(CGFloat)timeRatio;

@end

@interface DVEVideoCoverVideoFramePickerItem : UICollectionViewCell

@end

@interface DVEVideoCoverVideoFramePickerView : UIView

@property (nonatomic, weak) id<DVEVideoCoverVideoFramePickerDelegate> delegate;

- (void)updateVideoFrames:(NSArray<UIImage *> *)frames;

- (void)updateCurrentTimeRatio:(CGFloat)ratio;

@end

NS_ASSUME_NONNULL_END
