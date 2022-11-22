//
//  DVECropPreview.h
//  NLEEditor
//
//  Created by bytedance on 2021/4/8.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DVECropDefines.h"

NS_ASSUME_NONNULL_BEGIN


@class DVECropPreview;
@protocol DVECropPreviewDelegate <NSObject>
- (void)rotateCropPreview:(DVECropPreview *)preview rotateValue:(CGFloat)value;
- (void)videoPlayTime:(NSTimeInterval)time duration:(NSTimeInterval)duration;
- (void)videoPlayToEnd;
- (void)cropDidEnd;
@end

@interface DVECropResource : NSObject

@property (nonatomic, strong, readonly) UIImage *image;

@property (nonatomic, strong, readonly) AVAsset *video;

@property (nonatomic, assign, readonly) DVECropResourceType resouceType;

@property (nonatomic, assign) CMTime startTime;

@property (nonatomic, assign) CMTime duration;

@property (nonatomic, assign) CMTime timeClip;

- (instancetype)initWithResouceType:(DVECropResourceType)resourceType
                              image:(UIImage * _Nullable)image
                              video:(AVAsset * _Nullable)video;

- (CGSize)resourceShowSizeWithMaxSize:(CGSize)maxSize;

- (CGSize)resourceSize;

@end


@interface DVECropPreview : UIView

@property (nonatomic, weak) id<DVECropPreviewDelegate> delegate;

@property (nonatomic, strong) UIScrollView *scrollView;//图片或视频可以放大缩小

- (instancetype)initWithResouce:(DVECropResource *)cropResource;

- (void)updateWithNewAngleValue:(CGFloat)value;

- (void)refreshLayoutWithCropInfo:(DVEResourceCropPointInfo)info;

- (CGFloat)rotateAngleValue;

- (CGFloat)cropScale;

- (void)calculateResourceInfoUpperLeftPoint:(CGPoint *)upperLeftPoint
                            upperRightPoint:(CGPoint *)upperRightPoint
                             lowerLeftPoint:(CGPoint *)lowerLeftPoint
                            lowerRightPoint:(CGPoint *)lowerRightPoint;

- (void)videoPlayIfNeed;

- (void)videoPauseIfNeed;

- (void)videoRestartIfNeed;

@end


NS_ASSUME_NONNULL_END
