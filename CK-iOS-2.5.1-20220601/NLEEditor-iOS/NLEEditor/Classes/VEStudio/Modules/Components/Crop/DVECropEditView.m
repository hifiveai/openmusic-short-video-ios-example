//
//  DVECropEditView.m
//  NLEEditor
//
//  Created by bytedance on 2021/4/12.
//

#import "DVECropEditView.h"
#import "DVECropEditLayer.h"
#import "DVELoggerImpl.h"

@interface DVECropEditView ()

@property (nonatomic, strong) DVECropEditLayer *editLayer;

@property (nonatomic, assign) DVEVideoCropRatio ratio;

@property (nonatomic, assign) DVEVideoCropEditPanPosition position;

@end

@implementation DVECropEditView {
    CGRect _cropRect;
    CGRect _maxCropRect;
    CGPoint _diagonal;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _ratio = DVEVideoCropRatioFree;
        _position = DVEVideoCropEditPanNone;
        _cropRect = CGRectMake(0, 0, 0, 0);
        _maxCropRect = CGRectMake(2, 2, self.frame.size.width - 4, self.frame.size.height - 4);
        _diagonal = CGPointMake(0, 0);
        [self setUpLayout];
        [self setUpGesture];
    }
    return self;
}

- (void)updateEditViewWithRect:(CGRect)rect duration:(NSTimeInterval)duration {
    _cropRect = rect;
    self.gridView.frame = _cropRect;
    [self.editLayer hollowOutWithRect:rect duration:duration];
    [self.editLayer setNeedsDisplay];
}


- (void)setUpLayout {
    self.editLayer.frame = self.bounds;
    [self.layer addSublayer:self.editLayer];
    
    self.gridView.frame = self.bounds;
    [self addSubview:self.gridView];
}

- (DVECropEditLayer *)editLayer {
    if (!_editLayer) {
        _editLayer = [[DVECropEditLayer alloc] init];
    }
    return _editLayer;
}

- (DVECropGridView *)gridView {
    if (!_gridView) {
        _gridView = [[DVECropGridView alloc] init];
    }
    return _gridView;
}

- (CGRect)cropRect {
    return _cropRect;
}

- (void)setCropRect:(CGRect)cropRect {
    _cropRect = cropRect;
    self.gridView.frame = _cropRect;
}

- (CGRect)maxCropRect {
    return _maxCropRect;
}

- (CGFloat)cropRatio {
    if (self.ratio == DVEVideoCropRatioFree) {
        return _cropRect.size.width / _cropRect.size.height;
    }
    return DVE_videoCropRatioValue(self.ratio);
}

- (void)setUpGesture {
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
    gestureRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:gestureRecognizer];
}

- (void)gestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            DVELogInfo(@"editView gesture began");
            break;
        case UIGestureRecognizerStateChanged:
            [self panGestureChanged:recognizer];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self panGestureEnded:recognizer];
            break;
        default:
            break;
    }
    [recognizer setTranslation:CGPointZero inView:self];
}

- (void)panGestureChanged:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer translationInView:self];
    BOOL isFree = (self.ratio == DVEVideoCropRatioFree);
    CGRect rect = CGRectZero;
    switch (self.position) {
        case DVEVideoCropEditPanLeftTop:
            rect = [self panGestureLeftTop:point isFree:isFree];
            break;
        case DVEVideoCropEditPanRightTop:
            rect = [self panGestureRightTop:point isFree:isFree];
            break;
        case DVEVideoCropEditPanLeftBottom:
            rect = [self panGestureLeftBottom:point isFree:isFree];
            break;
        case DVEVideoCropEditPanRightBottom:
            rect = [self panGestureRightBottom:point isFree:isFree];
            break;
        case DVEVideoCropEditPanLeftLine:
            rect = [self panGestureLeftLine:point isFree:isFree];
            break;
        case DVEVideoCropEditPanRightLine:
            rect = [self panGestureRightLine:point isFree:isFree];
            break;
        case DVEVideoCropEditPanTopLine:
            rect = [self panGestureTopLine:point isFree:isFree];
            break;
        case DVEVideoCropEditPanBottomLine:
            rect = [self panGestureBottomLine:point isFree:isFree];
            break;
        default:
            break;
    }
    //delegate
    if (![self.delegate isCurrentEditViewShouldCrop:self
                                           gridView:self.gridView
                                         updateRect:rect
                                         panGesture:recognizer]) {
        return;
    }
    [self updateEditViewWithRect:rect duration:0.0];
}

- (void)panGestureEnded:(UIPanGestureRecognizer *)recognizer {
    //delegate
    [self.delegate editViewDidEndedCrop:self panGesture:recognizer];
}

#pragma mark - pan gesture recognizer

- (CGRect)panGestureLeftTop:(CGPoint)translation isFree:(BOOL)free {
    CGFloat x = CGRectGetMinX(_cropRect);
    CGFloat y = CGRectGetMinY(_cropRect);
    CGFloat w = CGRectGetWidth(_cropRect);
    CGFloat h = CGRectGetHeight(_cropRect);
    
    if (free) {
        x += translation.x;
        y += translation.y;
        if (x < CGRectGetMinX(_maxCropRect)) {
            x = CGRectGetMinX(_maxCropRect);
        }
        if (y < CGRectGetMinY(_maxCropRect)) {
            y = CGRectGetMinY(_maxCropRect);
        }
        
        w = _diagonal.x - x;
        h = _diagonal.y - y;
        
        if (w < 50) {
            w = 50;
            x = _diagonal.x - w;
        }
        
        if (h < 50) {
            h = 50;
            y = _diagonal.y - h;
        }
        
    } else {
        x += translation.x;
        w = _diagonal.x - x;
        CGFloat ratioValue = DVE_videoCropRatioValue(self.ratio);
        if (translation.x != 0) {
            CGFloat diff = translation.x / ratioValue;
            y += diff;
            h = _diagonal.y - y;
        }
        
        if (x < CGRectGetMinX(_maxCropRect)) {
            x = CGRectGetMinX(_maxCropRect);
            w = _diagonal.x - x;
            h = w / ratioValue;
            y = _diagonal.y - h;
        }
        
        if (y < CGRectGetMinY(_maxCropRect)) {
            y = CGRectGetMinY(_maxCropRect);
            h = _diagonal.y - y;
            w = h * ratioValue;
            x = _diagonal.x - w;
        }
        
        if (w < 50 && h < 50) {
            if (ratioValue >= 1.0) {
                w = 50;
                h = w / ratioValue;
            } else {
                h = 50;
                w = h * ratioValue;
            }
            x = _diagonal.x - w;
            y = _diagonal.y - h;
        }
    }
    
    return CGRectMake(x, y, w, h);
}

- (CGRect)panGestureLeftBottom:(CGPoint)translation isFree:(BOOL)free {
    CGFloat x = CGRectGetMinX(_cropRect);
    CGFloat y = CGRectGetMinY(_cropRect);
    CGFloat w = CGRectGetWidth(_cropRect);
    CGFloat h = CGRectGetHeight(_cropRect);
    
    if (free) {
        x += translation.x;
        y += translation.y;
        if (x < CGRectGetMinX(_maxCropRect)) {
            x = CGRectGetMinX(_maxCropRect);
        }
        if (y + h > CGRectGetMaxY(_maxCropRect)) {
            h = CGRectGetMaxY(_maxCropRect) - y;
        }
        
        w = _diagonal.x - x;
        if (w < 50) {
            w = 50;
            x = _diagonal.x - w;
        }
        
        if (h < 50) {
            h = 50;
        }
        
    } else {
        x += translation.x;
        w = _diagonal.x - x;
        CGFloat ratioValue = DVE_videoCropRatioValue(self.ratio);
        if (translation.x != 0) {
            h = w / ratioValue;
        }
        
        if (x < CGRectGetMinX(_maxCropRect)) {
            x = CGRectGetMinX(_maxCropRect);
            w = _diagonal.x - x;
            h = w / ratioValue;
        }
        
        if (y + h > CGRectGetMaxY(_maxCropRect)) {
            h = CGRectGetMaxY(_maxCropRect) - _diagonal.y;
            w = h * ratioValue;
            x = _diagonal.x - w;
        }
        
        if (w < 50 && h < 50) {
            if (ratioValue >= 1.0) {
                w = 50;
                h = w / ratioValue;
            } else {
                h = 50;
                w = h * ratioValue;
            }
            x = _diagonal.x - w;
            y = _diagonal.y;
        }
    }
    
    return CGRectMake(x, y, w, h);
}


- (CGRect)panGestureRightTop:(CGPoint)translation isFree:(BOOL)free {
    CGFloat x = CGRectGetMinX(_cropRect);
    CGFloat y = CGRectGetMinY(_cropRect);
    CGFloat w = CGRectGetWidth(_cropRect);
    CGFloat h = CGRectGetHeight(_cropRect);
    
    if (free) {
        y += translation.y;
        w += translation.x;
        if (y < CGRectGetMinY(_maxCropRect)) {
            y = CGRectGetMinY(_maxCropRect);
        }
        if (x + w > CGRectGetMaxX(_maxCropRect)) {
            w = CGRectGetMaxX(_maxCropRect) - _diagonal.x;
        }
        
        h = _diagonal.y - y;
        
        if (w < 50) {
            w = 50;
        }
        
        if (h < 50) {
            h = 50;
            y = _diagonal.y - h;
        }
        
    } else {
        w += translation.x;
        CGFloat ratioValue = DVE_videoCropRatioValue(self.ratio);
        if (translation.x != 0) {
            CGFloat diff = translation.x / ratioValue;
            y -= diff;
            h = _diagonal.y - y;
        }
        
        if (y < CGRectGetMinX(_maxCropRect)) {
            y = CGRectGetMinX(_maxCropRect);
            h = _diagonal.y - y;
            w = h * ratioValue;
        }
        
        if (x + w < CGRectGetMaxY(_maxCropRect)) {
            w = CGRectGetMaxY(_maxCropRect) - _diagonal.x;
            h = w / ratioValue;
            y = _diagonal.y - h;
        }
        
        if (w < 50 && h < 50) {
            if (ratioValue >= 1.0) {
                w = 50;
                h = w / ratioValue;
            } else {
                h = 50;
                w = h * ratioValue;
            }
            x = _diagonal.x;
            y = _diagonal.y - h;
        }
    }
    
    return CGRectMake(x, y, w, h);
}

- (CGRect)panGestureRightBottom:(CGPoint)translation isFree:(BOOL)free {
    CGFloat x = CGRectGetMinX(_cropRect);
    CGFloat y = CGRectGetMinY(_cropRect);
    CGFloat w = CGRectGetWidth(_cropRect);
    CGFloat h = CGRectGetHeight(_cropRect);
    
    if (free) {
        w += translation.x;
        h += translation.y;
        if (x + w > CGRectGetMaxX(_maxCropRect)) {
            w = CGRectGetMaxX(_maxCropRect) - _diagonal.x;
        }
        if (y + h > CGRectGetMaxY(_maxCropRect)) {
            h = CGRectGetMaxY(_maxCropRect) - _diagonal.y;
        }
        
        if (w < 50) {
            w = 50;
        }
        
        if (h < 50) {
            h = 50;
        }
        
    } else {
        w += translation.x;
        CGFloat ratioValue = DVE_videoCropRatioValue(self.ratio);
        if (translation.x != 0) {
            h = w / ratioValue;
        }
        
        if (x + w > CGRectGetMaxX(_maxCropRect)) {
            w = CGRectGetMaxX(_maxCropRect) - _diagonal.x;
            h = w / ratioValue;
        }
        
        if (y + h > CGRectGetMaxY(_maxCropRect)) {
            h = CGRectGetMaxY(_maxCropRect) - _diagonal.y;
            w = h * ratioValue;
        }
        
        if (w < 50 && h < 50) {
            if (ratioValue >= 1.0) {
                w = 50;
                h = w / ratioValue;
            } else {
                h = 50;
                w = h * ratioValue;
            }
            x = _diagonal.x;
            y = _diagonal.y;
        }
    }
    
    return CGRectMake(x, y, w, h);
}


- (CGRect)panGestureLeftLine:(CGPoint)translation isFree:(BOOL)free {
    CGFloat x = CGRectGetMinX(_cropRect);
    CGFloat y = CGRectGetMinY(_cropRect);
    CGFloat w = CGRectGetWidth(_cropRect);
    CGFloat h = CGRectGetHeight(_cropRect);
    
    if (free) {
        x += translation.x;
        if (x < CGRectGetMinX(_maxCropRect)) {
            x = CGRectGetMinX(_maxCropRect);
        }
        
        w = _diagonal.x - x;
        
        if (w < 50) {
            w = 50;
            x = _diagonal.x - w;
        }
        
    } else {
        CGFloat ratioValue = DVE_videoCropRatioValue(self.ratio);
        x += translation.x;
        w = _diagonal.x - x;
        if (translation.x != 0) {
            CGFloat diff = translation.x / ratioValue;
            y += diff / 2;
            h = (_diagonal.y - y) * 2;
        }
        
        if (x < CGRectGetMinX(_maxCropRect)) {
            x = CGRectGetMinX(_maxCropRect);
            w = _diagonal.x - x;
            h = w / ratioValue;
            y = _diagonal.y - h / 2.0;
        }
        
        if (y < CGRectGetMinY(_maxCropRect)) {
            y = CGRectGetMinY(_maxCropRect);
            h = (_diagonal.y - y) * 2;
            w = h * ratioValue;
            x = _diagonal.x - w;
        }
        
        if (w < 50 && h < 50) {
            if (ratioValue >= 1.0) {
                w = 50;
                h = w / ratioValue;
            } else {
                h = 50;
                w = h * ratioValue;
            }
            x = _diagonal.x - w;
            y = _diagonal.y - h / 2.0;
        }
    }
    
    return CGRectMake(x, y, w, h);
}


- (CGRect)panGestureRightLine:(CGPoint)translation isFree:(BOOL)free {
    CGFloat x = CGRectGetMinX(_cropRect);
    CGFloat y = CGRectGetMinY(_cropRect);
    CGFloat w = CGRectGetWidth(_cropRect);
    CGFloat h = CGRectGetHeight(_cropRect);
    
    if (free) {
        w += translation.x;
        if (x + w > CGRectGetMaxX(_maxCropRect)) {
            w = CGRectGetMaxX(_maxCropRect) - _diagonal.x;
        }
        
        if (w < 50) {
            w = 50;
        }
        
    } else {
        w += translation.x;
        CGFloat ratioValue = DVE_videoCropRatioValue(self.ratio);
        if (translation.x != 0) {
            CGFloat diff = translation.x / ratioValue;
            y -= diff / 2;
            h = (_diagonal.y - y) * 2;
        }
        
        if (y < CGRectGetMinY(_maxCropRect)) {
            y = CGRectGetMinY(_maxCropRect);
            h = (_diagonal.y - y) * 2;
            w = h * ratioValue;
        }
        
        if (x + w > CGRectGetMaxX(_maxCropRect)) {
            w = CGRectGetMaxX(_maxCropRect) - _diagonal.x;
            h = w / ratioValue;
            y = _diagonal.y - h / 2.0;
        }
        
        
        if (w < 50 && h < 50) {
            if (ratioValue >= 1.0) {
                w = 50;
                h = w / ratioValue;
            } else {
                h = 50;
                w = h * ratioValue;
            }
            x = _diagonal.x;
            y = _diagonal.y - h / 2.0;
        }
    }
    
    return CGRectMake(x, y, w, h);
}


- (CGRect)panGestureTopLine:(CGPoint)translation isFree:(BOOL)free {
    CGFloat x = CGRectGetMinX(_cropRect);
    CGFloat y = CGRectGetMinY(_cropRect);
    CGFloat w = CGRectGetWidth(_cropRect);
    CGFloat h = CGRectGetHeight(_cropRect);
    
    if (free) {
        y += translation.y;
        if (y < CGRectGetMinY(_maxCropRect)) {
            y = CGRectGetMinY(_maxCropRect);
        }
        
        h = _diagonal.y - y;
        
        if (h < 50) {
            h = 50;
            y = _diagonal.y - h;
        }
        
    } else {
        y += translation.y;
        h = _diagonal.y - y;
        CGFloat ratioValue = DVE_videoCropRatioValue(self.ratio);
        if (translation.y != 0) {
            CGFloat diff = translation.y / ratioValue;
            x += diff / 2;
            w = (_diagonal.x - x) * 2;
        }
        
        if (x < CGRectGetMinX(_maxCropRect)) {
            x = CGRectGetMinX(_maxCropRect);
            w = (_diagonal.x - x ) * 2.0;
            h = w / ratioValue;
            y = _diagonal.y - h;
        }
        
        if (y < CGRectGetMinY(_maxCropRect)) {
            y = CGRectGetMinY(_maxCropRect);
            h = _diagonal.y - y;
            w = h * ratioValue;
            x = _diagonal.x - w / 2.0;
        }
        
        if (w < 50 && h < 50) {
            if (ratioValue >= 1.0) {
                w = 50;
                h = w / ratioValue;
            } else {
                h = 50;
                w = h * ratioValue;
            }
            x = _diagonal.x - w / 2.0;
            y = _diagonal.y - h;
        }
    }
    
    return CGRectMake(x, y, w, h);
}

- (CGRect)panGestureBottomLine:(CGPoint)translation isFree:(BOOL)free {
    CGFloat x = CGRectGetMinX(_cropRect);
    CGFloat y = CGRectGetMinY(_cropRect);
    CGFloat w = CGRectGetWidth(_cropRect);
    CGFloat h = CGRectGetHeight(_cropRect);
    
    if (free) {
        h += translation.y;
        if (y + h > CGRectGetMaxY(_maxCropRect)) {
            h = CGRectGetMaxY(_maxCropRect) - _diagonal.y;
        }
        
        if (h < 50) {
            h = 50;
        }
        
    } else {
        h += translation.y;
        CGFloat ratioValue = DVE_videoCropRatioValue(self.ratio);
        if (translation.y != 0) {
            CGFloat diff = translation.y * ratioValue;
            y -= diff / 2;
            w = (_diagonal.x - x) * 2;
        }
        
        if (y < CGRectGetMinY(_maxCropRect)) {
            y = CGRectGetMinY(_maxCropRect);
            h = _diagonal.y - y;
            w = h * ratioValue;
            x = _diagonal.x - w / 2.0;
        }
        
        if (y + h > CGRectGetMaxY(_maxCropRect)) {
            h = CGRectGetMaxY(_maxCropRect) - _diagonal.y;
            w = h * ratioValue;
            x = _diagonal.x - w / 2.0;
        }
        
        if (w < 50 && h < 50) {
            if (ratioValue >= 1.0) {
                w = 50;
                h = w / ratioValue;
            } else {
                h = 50;
                w = h * ratioValue;
            }
            x = _diagonal.x - w / 2.0;
            y = _diagonal.y;
        }
    }
    
    return CGRectMake(x, y, w, h);
}

#pragma mark - Override

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return [self isTouchNeedsHandledWithPoint:point];
}

- (BOOL)isTouchNeedsHandledWithPoint:(CGPoint)point {
    CGFloat halfScope = 50.0 / 2;
    CGRect frame = self->_cropRect;
    CGRect posInsetRect = CGRectInset(frame, halfScope, halfScope);
    CGRect negInsetRect = CGRectInset(frame, -halfScope, -halfScope);
    if (CGRectContainsPoint(posInsetRect, point) ||
        !CGRectContainsPoint(negInsetRect, point)) {
        return NO;
    }
    return [self isTouchValidWithPoint:point frame:frame];
}

- (BOOL)isTouchValidWithPoint:(CGPoint)point frame:(CGRect)frame {
    CGFloat halfScope = 50.0 / 2;
    CGFloat x = CGRectGetMinX(frame);
    CGFloat y = CGRectGetMinY(frame);
    CGFloat w = CGRectGetWidth(frame);
    CGFloat h = CGRectGetHeight(frame);
    CGFloat maxX = CGRectGetMaxX(frame);
    CGFloat maxY = CGRectGetMaxY(frame);
    
    CGRect ltRect = CGRectMake(x - halfScope, y - halfScope, 50.0, 50.0);
    CGRect lbRect = CGRectMake(x - halfScope, maxY - halfScope, 50.0, 50.0);
    CGRect rtRect = CGRectMake(maxX - halfScope, y - halfScope, 50.0, 50.0);
    CGRect rbRect = CGRectMake(maxX - halfScope, maxY - halfScope, 50.0, 50.0);
    
    if (CGRectContainsPoint(ltRect, point)) {
        self.position = DVEVideoCropEditPanLeftTop;
        self->_diagonal = CGPointMake(maxX, maxY);
    } else if (CGRectContainsPoint(lbRect, point)) {
        self.position = DVEVideoCropEditPanLeftBottom;
        self->_diagonal = CGPointMake(maxX, y);
    } else if (CGRectContainsPoint(rtRect, point)) {
        self.position = DVEVideoCropEditPanRightTop;
        self->_diagonal = CGPointMake(x, maxY);
    } else if (CGRectContainsPoint(rbRect, point)) {
        self.position = DVEVideoCropEditPanRightBottom;
        self->_diagonal = CGPointMake(x, y);
    } else {
        CGFloat midX = CGRectGetMidX(frame);
        CGFloat midY = CGRectGetMidY(frame);
        CGRect leftLineRect = CGRectMake(x - halfScope, y + halfScope, 50.0, h - 50.0);
        CGRect rightLineRect = CGRectMake(maxX - halfScope, y + halfScope, 50.0, h - 50.0);
        CGRect topLineRect = CGRectMake(x + halfScope, y - halfScope, w - 50.0, 50.0);
        CGRect bottomLineRect = CGRectMake(x + halfScope, maxY - halfScope, w - 50.0, 50.0);
        
        if (CGRectContainsPoint(leftLineRect, point)) {
            self.position = DVEVideoCropEditPanLeftLine;
            self->_diagonal = CGPointMake(maxX, midY);
        } else if (CGRectContainsPoint(rightLineRect, point)) {
            self.position = DVEVideoCropEditPanRightLine;
            self->_diagonal = CGPointMake(x, midY);
        } else if (CGRectContainsPoint(topLineRect, point)) {
            self.position = DVEVideoCropEditPanTopLine;
            self->_diagonal = CGPointMake(midX, maxY);
        } else if (CGRectContainsPoint(bottomLineRect, point)) {
            self.position = DVEVideoCropEditPanBottomLine;
            self->_diagonal = CGPointMake(midX, y);
        } else {
            self.position = DVEVideoCropEditPanNone;
            return NO;
        }
        
    }
    
    return YES;
}

@end
