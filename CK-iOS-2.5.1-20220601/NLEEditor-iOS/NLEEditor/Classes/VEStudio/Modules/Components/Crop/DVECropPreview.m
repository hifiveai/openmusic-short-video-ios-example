//
//  DVECropPreview.m
//  NLEEditor
//
//  Created by bytedance on 2021/4/8.
//

#import "DVEMacros.h"
#import "DVECropPreview.h"
#import "DVECropVideoPlayer.h"
#import "DVECropEditView.h"
#import "AVAsset+DVE.h"
#import "DVELoggerImpl.h"

@implementation DVECropResource 

- (instancetype)initWithResouceType:(DVECropResourceType)resourceType
                              image:(UIImage *)image
                              video:(AVAsset *)video {
    if (self = [super init]) {
        _resouceType = resourceType;
        _image = [image copy];
        _video = [video copy];
    }
    return self;
}

- (CGSize)resourceSize {
    CGSize size = CGSizeMake(0, 0);
    switch (self.resouceType) {
        case DVECropResourceImage: {
            size = self.image.size;
        }
            break;
        case DVECropResourceVideo: {
            for (AVAssetTrack *track in self.video.tracks) {
                if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
                    size = track.naturalSize;
                    AVCaptureVideoOrientation orientation = [self.video fixedOrientation];
                    if (orientation != AVCaptureVideoOrientationPortrait &&
                        orientation != AVCaptureVideoOrientationPortraitUpsideDown) {
                        size = CGSizeMake(size.height, size.width);
                    }
                    break;
                }
            }
        }
            break;
        default:
            NSAssert(NO, @"resourceType should be valid!!");
            break;
    }
    return size;
}

- (CGSize)resourceShowSizeWithMaxSize:(CGSize)maxSize {
    CGSize size = [self resourceSize];
    return DVE_limitMaxSize(size, maxSize);
}

@end

@interface DVECropPreview () <UIScrollViewDelegate, DVECropEditViewDelegate, DVECropVideoPlayerDelegate>

@property (nonatomic, strong) UIView *container;

@property (nonatomic, strong) UIImageView *imageView;//画幅裁剪的可能是图片

@property (nonatomic, strong) DVECropVideoPlayer *videoPlayer;//画幅剪裁的可能是视频

@property (nonatomic, strong) DVECropResource *cropResource;

@property (nonatomic, strong) DVECropEditView *editView; //裁剪框

@property (nonatomic, strong) UIView *actionView;

@property (nonatomic, assign, getter=isAttaching) BOOL attaching;

@end

@implementation DVECropPreview {
    CGSize _previewSize;
    CGRect _originCropRect;
    CGFloat _angleValue;
    CGFloat _rotateScale;
    CGAffineTransform _transform;
}

- (instancetype)initWithResouce:(DVECropResource *)cropResource {
    if (self = [super init]) {
        _cropResource = cropResource;
        _previewSize = CGSizeMake(0, 0);
        _originCropRect = CGRectMake(0, 0, 0, 0);
        _angleValue = 0.0;
        _rotateScale = 1.0;
        _transform = CGAffineTransformIdentity;
        _attaching = NO;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        return;
    }
    [self setUpCropData];
    [self setUpLayout];
    [self setUpGesture];
}

- (void)setUpCropData {
    CGSize maxsize = CGSizeMake(self.bounds.size.width - 4.0, self.bounds.size.height - 4.0);
    _previewSize = [self.cropResource resourceShowSizeWithMaxSize:maxsize];
    _originCropRect = CGRectMake((self.bounds.size.width - _previewSize.width) / 2, (self.bounds.size.height - _previewSize.height) / 2, _previewSize.width, _previewSize.height);
    DVELogInfo(@"crop preview size:%.10f %.10f", _previewSize.width, _previewSize.height);
    DVELogInfo(@"crop origin crop rect:%.10f %.10f %.10f %.10f", _originCropRect.origin.x, _originCropRect.origin.y, _originCropRect.size.width, _originCropRect.size.height);
}

- (void)setUpLayout {
    self.clipsToBounds = YES;
    //self.backgroundColor = colorWithHex(0xEFEFEF);
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.container];
    self.container.frame = CGRectMake(0, 0, _previewSize.width, _previewSize.height);//
    switch (self.cropResource.resouceType) {
        case DVECropResourceImage: {
            self.imageView.frame = CGRectMake(0, 0, _previewSize.width, _previewSize.height);
            [self.container addSubview:self.imageView];
            self.imageView.image = self.cropResource.image;
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            self.actionView = self.imageView;
        }
            break;
        case DVECropResourceVideo: {
            self.videoPlayer.playerView.frame = CGRectMake(0, 0, _previewSize.width, _previewSize.height);
            [self.container addSubview:self.videoPlayer.playerView];
            self.actionView = self.videoPlayer.playerView;
            CMTime startTime = [self.cropResource startTime];
            self.videoPlayer.playTimeEnd = CMTimeAdd([self.cropResource duration], [self.cropResource timeClip]);
            if (CMTimeCompare(startTime, self.videoPlayer.playTimeEnd) == 1) {
                startTime = self.videoPlayer.playTimeEnd;
            }
            float startSeconds = CMTimeGetSeconds(startTime);
            float endSeconds = CMTimeGetSeconds(self.videoPlayer.playTimeEnd);
            float duration = CMTimeGetSeconds(self.cropResource.video.duration);
            
            if (endSeconds == duration && endSeconds - startSeconds < 0.02f) {
                startSeconds = endSeconds - 0.02f;
                startTime = CMTimeMake(startSeconds * USEC_PER_SEC, USEC_PER_SEC);
            }
            
            DVELogInfo(@"DVECropPreview videoPlayer start:%.10f endSecond:%.10f", startSeconds, endSeconds);
            @weakify(self);
            [self.videoPlayer loadVideoAsset:self.cropResource.video rate:1.0 seekTime:startTime seekTimeCompletion:^(BOOL finished) {
                @strongify(self);
                if (!finished) {
                    DVELogInfo(@"seekToTime error");
                    return;
                }
                CMTime curTime = [self.videoPlayer currentTime];
                [self videoPlayCurrentTime:curTime];
            }];
            [self.videoPlayer pause];
        }
            break;
        default:
            NSAssert(NO, @"the resource type of DVECropPreview invalid!!!");
            break;
    }
    
    [self addSubview:self.editView];
    [self.editView updateEditViewWithRect:_originCropRect duration:0.0];
}

- (void)refreshLayoutWithCropInfo:(DVEResourceCropPointInfo)info {
    //恢复旋转角度
    CGFloat angleValue = DVE_rotatedAngle(info, [self.cropResource resourceSize]);
    [self updateWithNewAngleValue:angleValue];
    _attaching = (DVE_angleToValue(angleValue) < 1.0);
    
    //坐标转换
    [self updateViewRectWithUpperLeftPoint:info.upperLeft lowerRight:info.lowerRight];
    
    CGFloat ratio = DVE_cropRatio(info, [self.cropResource resourceSize]);
    CGRect fixCropRect = [self fixCropRectWithRatio:ratio];
    [self updateCropRect:fixCropRect duration:0.0 isUpdateContentOffset:NO];
}

- (void)updateViewRectWithUpperLeftPoint:(CGPoint)upperLeft lowerRight:(CGPoint)lowerRight {
    CGSize actionViewSize = self.actionView.bounds.size;
    CGPoint ulPoint = CGPointMake(upperLeft.x * actionViewSize.width, upperLeft.y * actionViewSize.height);
    CGPoint lrPoint = CGPointMake(lowerRight.x * actionViewSize.width, lowerRight.y * actionViewSize.height);

    ulPoint = [self.actionView convertPoint:ulPoint toView:self];
    lrPoint = [self.actionView convertPoint:lrPoint toView:self];
    
    DVELogInfo(@"[Crop]:updateViewRectWithUpperLeftPoint ulPoint x:%.10f y:%.10f", ulPoint.x, ulPoint.y);
    DVELogInfo(@"[Crop]:updateViewRectWithUpperLeftPoint lrPoint x:%.10f y:%.10f", lrPoint.x, lrPoint.y);
    
    [self.editView setCropRect:CGRectMake(ulPoint.x, ulPoint.y, lrPoint.x - ulPoint.x, lrPoint.y - ulPoint.y)];
}

- (void)calculateResourceInfoUpperLeftPoint:(CGPoint *)upperLeftPoint
                            upperRightPoint:(CGPoint *)upperRightPoint
                             lowerLeftPoint:(CGPoint *)lowerLeftPoint
                            lowerRightPoint:(CGPoint *)lowerRightPoint {
    CGRect cropRect = [self.editView cropRect];
    DVELogInfo(@"[Crop]:calculateResourceInfoXLeftPoint crop origin x:%.10f y:%.10f ", cropRect.origin.x, cropRect.origin.y);
    DVELogInfo(@"[Crop]:calculateResourceInfoXLeftPoint crop size width:%.10f height:%.10f", cropRect.size.width, cropRect.size.height);
    
    CGPoint upperLeft = [self convertPoint:cropRect.origin toView:self.actionView];
    CGPoint upperRight = [self convertPoint:CGPointMake(CGRectGetMaxX(cropRect), CGRectGetMinY(cropRect)) toView:self.actionView];
    CGPoint lowerLeft = [self convertPoint:CGPointMake(CGRectGetMinX(cropRect), CGRectGetMaxY(cropRect)) toView:self.actionView];
    CGPoint lowerRight = [self convertPoint:CGPointMake(CGRectGetMaxX(cropRect), CGRectGetMaxY(cropRect)) toView:self.actionView];

    upperLeft = [self fixPointWithRect:self.actionView.bounds point:upperLeft];
    upperRight = [self fixPointWithRect:self.actionView.bounds point:upperRight];
    lowerLeft = [self fixPointWithRect:self.actionView.bounds point:lowerLeft];
    lowerRight = [self fixPointWithRect:self.actionView.bounds point:lowerRight];

    if (upperLeft.x == upperRight.x ||
        upperLeft.y == lowerLeft.y ||
        CGSizeEqualToSize(self.actionView.bounds.size, CGSizeZero)) {
        NSAssert(NO, @"resource info point calc error");
        DVEResourceCropPointInfo defaultInfo = DVE_defaultCropPointInfo();
        *upperLeftPoint = defaultInfo.upperLeft;
        *upperRightPoint = defaultInfo.upperRight;
        *lowerLeftPoint = defaultInfo.lowerLeft;
        *lowerRightPoint = defaultInfo.lowerRight;
        return;
    }
    
    DVELogInfo(@"[Crop]:calculateResourceInfoXLeftPoint upperLeft x:%.10f y:%.10f", upperLeft.x, upperLeft.y);
    DVELogInfo(@"[Crop]:calculateResourceInfoXLeftPoint upperRight x:%.10f y:%.10f", upperRight.x, upperRight.y);
    DVELogInfo(@"[Crop]:calculateResourceInfoXLeftPoint lowerLeft x:%.10f y:%.10f", lowerLeft.x, lowerLeft.y);
    DVELogInfo(@"[Crop]:calculateResourceInfoXLeftPoint lowerRight x:%.10f y:%.10f", lowerRight.x, lowerRight.y);

    CGSize actionViewSize = self.actionView.bounds.size;
    *upperLeftPoint = CGPointMake(upperLeft.x / actionViewSize.width, upperLeft.y / actionViewSize.height);
    *upperRightPoint = CGPointMake(upperRight.x / actionViewSize.width, upperRight.y / actionViewSize.height);
    *lowerLeftPoint = CGPointMake(lowerLeft.x / actionViewSize.width, lowerLeft.y / actionViewSize.height);
    *lowerRightPoint = CGPointMake(lowerRight.x / actionViewSize.width, lowerRight.y / actionViewSize.height);
    
}

- (void)videoPlayIfNeed {
    if (self.videoPlayer) {
        [self.videoPlayer play];
    }
}

- (void)videoPauseIfNeed {
    if (self.videoPlayer) {
        [self.videoPlayer pause];
    }
}

- (void)videoRestartIfNeed {
    if (self.videoPlayer) {
        [self.videoPlayer resetPlay];
        //重置回轨道被折叠的开始时间
        [self.videoPlayer seekToTime:[self.cropResource timeClip]];
        [self.videoPlayer play];
    }
}

- (void)setUpGesture {
    UIRotationGestureRecognizer *recognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateGestureRecognizer:)];
    [self.scrollView addGestureRecognizer:recognizer];
}

- (void)rotateGestureRecognizer:(UIRotationGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            recognizer.rotation = _angleValue;
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat angleValue = recognizer.rotation;
            if (angleValue < -M_PI_4) {
                angleValue = -M_PI_4;
            } else if (angleValue > M_PI_4) {
                angleValue = M_PI_4;
            }
            if (fabs(DVE_valueToAngle(angleValue)) < 1.0) {
                if (_attaching) {
                    return;
                }
                _attaching = YES;
                if (@available(iOS 10.0, *)) {
                    UISelectionFeedbackGenerator *generator = [[UISelectionFeedbackGenerator alloc] init];
                    [generator selectionChanged];
                }
                angleValue = 0;
            } else {
                _attaching = NO;
            }
            [self updateWithNewAngleValue:angleValue];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self panGestureEnded:recognizer];
            break;
        default:
            break;
    }
}

//preview手势旋转
- (void)panGestureEnded:(UIRotationGestureRecognizer *)recognizer {
    [self.delegate cropDidEnd];
}

- (CGFloat)rotateAngleValue {
    return _angleValue;
}

- (CGFloat)cropScale {
    return [self.editView cropRatio];
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = colorWithHex(0x101010);
        _scrollView.clipsToBounds = NO;
        _scrollView.frame = self.bounds;
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 100.0;
        _scrollView.zoomScale = 1.0;
        _scrollView.bounces = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(_previewSize.width, _previewSize.height);
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _scrollView;
}

- (DVECropEditView *)editView {
    if (!_editView) {
        _editView = [[DVECropEditView alloc] initWithFrame:self.bounds];
        _editView.delegate = self;
    }
    return _editView;
}

- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    return _container;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (DVECropVideoPlayer *)videoPlayer {
    if (!_videoPlayer) {
        _videoPlayer = [[DVECropVideoPlayer alloc] init];
        _videoPlayer.delegate = self;
    }
    return _videoPlayer;
}

- (void)updateWithNewAngleValue:(CGFloat)value {
    CGFloat changValue = value - _angleValue;
    _angleValue = value;
    CGFloat newScale = DVE_rotatedScale(_angleValue, _previewSize);
    CGFloat changeScale = newScale / _rotateScale;
    _rotateScale = newScale;
    CGAffineTransform rotateTransform = CGAffineTransformRotate(_transform, changValue);
    _transform = CGAffineTransformScale(rotateTransform, changeScale, changeScale);
    self.actionView.transform = _transform;
    //手势旋转的同时，角度旋转栏也要联动
    [self.delegate rotateCropPreview:self rotateValue:self->_angleValue];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.container;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView.zoomScale < scrollView.minimumZoomScale) {
        scrollView.zoomScale = scrollView.minimumZoomScale;
    }
}

#pragma mark - Delegate

- (BOOL)isCurrentEditViewShouldCrop:(DVECropEditView *)editView
                           gridView:(DVECropGridView *)gridView
                         updateRect:(CGRect)updateRect
                         panGesture:(UIPanGestureRecognizer *)panGesture {
    CGRect bounds = self.actionView.bounds;
    CGFloat maxX = CGRectGetMaxX(updateRect);
    CGFloat maxY = CGRectGetMaxY(updateRect);
    CGFloat minX = CGRectGetMinX(updateRect);
    CGFloat minY = CGRectGetMinY(updateRect);
    CGPoint upperLeft = [self convertPoint:updateRect.origin toView:self.actionView];
    CGPoint upperRight = [self convertPoint:CGPointMake(maxX, minY) toView:self.actionView];
    CGPoint lowerLeft = [self convertPoint:CGPointMake(minX, maxY) toView:self.actionView];
    CGPoint lowerRight = [self convertPoint:CGPointMake(maxX, maxY) toView:self.actionView];
    
    BOOL isUpperLeftContain = [self isPointContained:upperLeft rect:bounds];
    BOOL isUpperRightContain = [self isPointContained:upperRight rect:bounds];
    BOOL isLowerLeftContain = [self isPointContained:lowerLeft rect:bounds];
    BOOL isLowerRightContain = [self isPointContained:lowerRight rect:bounds];
    
    return isUpperLeftContain && isUpperRightContain && isLowerLeftContain && isLowerRightContain;
}

- (void)editViewDidEndedCrop:(DVECropEditView *)editView
                  panGesture:(UIPanGestureRecognizer *)panGesture {
    self.scrollView.contentInset = [self scrollViewContentInset:[editView cropRect]];
    CGRect fixCropRect = [self fixCropRectWithRatio:[self.editView cropRatio]];
    [self updateCropRect:fixCropRect duration:0.25 isUpdateContentOffset:NO];
    [self editDidEnd];
}


- (BOOL)isPointContained:(CGPoint)point rect:(CGRect)rect {
    CGFloat threshold = 1.0;
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    if (point.x >= minX - threshold &&
        point.x <= maxX + threshold &&
        point.y >= minY - threshold &&
        point.y <= maxY + threshold) {
        return YES;
    }
    return NO;
}

- (CGRect)fixCropRectWithRatio:(CGFloat)ratio {
    CGRect maxCropRect = [self.editView maxCropRect];
    CGSize size = DVE_limitMaxSize(CGSizeMake(ratio, 1.0), maxCropRect.size);
    CGFloat x = CGRectGetMinX(maxCropRect) + (maxCropRect.size.width - size.width) / 2.0;
    CGFloat y = CGRectGetMinY(maxCropRect) + (maxCropRect.size.height - size.height) / 2.0;
    return CGRectMake(x, y, size.width, size.height);
}

- (void)updateCropRect:(CGRect)rect duration:(NSTimeInterval)duration isUpdateContentOffset:(BOOL)isUpdate {
    CGRect cropRect = [self.editView cropRect];
    CGFloat scale = cropRect.size.width / rect.size.width;
    
    CGFloat dx = -CGRectGetMinX(rect) * scale;
    CGFloat dy = -CGRectGetMinY(rect) * scale;
    
    CGRect convertZoomRect = CGRectInset(cropRect, dx, dy);
    CGRect zoomRect = [self convertRect:convertZoomRect toView:self.container];
    
    UIEdgeInsets contentInset = [self scrollViewContentInset:rect];
    CGPoint contentOffset = [self convertPoint:cropRect.origin toView:self.container];
    contentOffset.x = -contentInset.left + contentOffset.x * self.scrollView.zoomScale;
    contentOffset.y = -contentInset.top + contentOffset.y * self.scrollView.zoomScale;
    
    self.scrollView.minimumZoomScale = [self scrollViewMinZoomScaleWithSize:rect.size];
    [self setUserInteractionEnabled:NO];
    [self layoutIfNeeded];
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (isUpdate) {
            [self.scrollView setContentOffset:contentOffset animated:YES];
        }
        
        self.scrollView.contentInset = contentInset;
        [self.scrollView zoomToRect:zoomRect animated:NO];
        [self.editView updateEditViewWithRect:rect duration:duration];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self layoutIfNeeded];
        [self setUserInteractionEnabled:YES];
    }];
}


- (CGFloat)scrollViewMinZoomScaleWithSize:(CGSize)size {
    CGFloat len = 0.0;
    CGFloat baseLen = 0.0;
    CGFloat width = 0.0;
    CGFloat baseWidth = 0.0;
    
    if (size.width > size.height) {
        len = size.width;
        baseLen = _originCropRect.size.width;
        width = size.height;
        baseWidth = _originCropRect.size.height;
    } else {
        len = size.height;
        baseLen = _originCropRect.size.height;
        width = size.width;
        baseWidth = _originCropRect.size.width;
    }
    
    CGFloat minZoomScale = len / baseLen;
    CGFloat scaleWidth = baseWidth * minZoomScale;
    if (scaleWidth < width) {
        minZoomScale = width / baseWidth;
    }
    
    return minZoomScale;
}

- (UIEdgeInsets)scrollViewContentInset:(CGRect)cropRect {
    CGFloat top = CGRectGetMinY(cropRect);
    CGFloat bottom = self.bounds.size.height - CGRectGetMaxY(cropRect);
    CGFloat left = CGRectGetMinX(cropRect);
    CGFloat right = self.bounds.size.width - CGRectGetMaxX(cropRect);
    return UIEdgeInsetsMake(top, left, bottom, right);
}


- (CGPoint)fixPointWithRect:(CGRect)rect point:(CGPoint)point {
    CGFloat x = point.x;
    CGFloat y = point.y;
    
    if (x < CGRectGetMinX(rect)) {
        x = CGRectGetMinX(rect);
    }
    if (y < CGRectGetMinY(rect)) {
        y = CGRectGetMinY(rect);
    }
    if (x > CGRectGetMaxX(rect)) {
        x = CGRectGetMaxX(rect);
    }
    if (y > CGRectGetMaxY(rect)) {
        y = CGRectGetMaxY(rect);
    }
    return CGPointMake(x, y);
}

- (void)videoPlayer:(DVECropVideoPlayer *)videoPlayer error:(NSError *)error {
    
}

- (void)videoPlayerReadyToPlay:(DVECropVideoPlayer *)videoPlayer {
    
}

- (void)videoPlayCurrentTime:(CMTime)time {
    NSTimeInterval currentTime = CMTimeGetSeconds(CMTimeSubtract(time, self.cropResource.timeClip));
    NSTimeInterval duration = CMTimeGetSeconds(self.cropResource.duration);
    [self.delegate videoPlayTime:currentTime duration:duration];
}

- (void)videoPlayToEnd {
    [self.delegate videoPlayToEnd];
}

- (void)editDidEnd {
    [self.delegate cropDidEnd];
}

@end
