//
// Created by bytedance on 2021/6/21.
//

#import "DVECurveSpeedCanvas.h"
#import "DVECurveSpeedNode.h"
#import "DVECurveSpeedPathUtil.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <math.h>
#import "DVELoggerImpl.h"
#import "DVEMacros.h"

@interface DVECurveSpeedCanvas() {
    CGFloat _preX;
    CGFloat _velocity;
}
/// 白色竖线
@property (nonatomic, strong) UIView *line;
/// 可移动范围
@property (nonatomic, assign) UIEdgeInsets edge;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) UIBezierPath *curve;
/// 点数组
@property (nonatomic, strong) NSMutableArray<DVECurveSpeedNode *> *nodes;
/// 当前选中点
@property (nonatomic, strong) DVECurveSpeedNode *currentNode;
/// 是否在拖动点
@property (nonatomic, assign) BOOL movingNode;
/// 新增点插入位置
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UILabel *maxLabel;
@property (nonatomic, strong) UILabel *minLabel;
@property (nonatomic, assign) BOOL touching;


@end

@implementation DVECurveSpeedCanvas

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;

        [self.layer addSublayer:self.shapeLayer];
        [self addSubview:self.line];
        self.edge = UIEdgeInsetsMake(0, 0, frame.size.height, frame.size.width);
        [self updateCurve];

        // 0.1 X; 10X;
        self.maxLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 25, 18)];
        self.maxLabel.text = @"10 X";
        self.maxLabel.font = [UIFont systemFontOfSize:10];
        self.maxLabel.textColor = [UIColor.whiteColor colorWithAlphaComponent:0.5];
        [self addSubview:self.maxLabel];
        self.minLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 25, 18)];
        self.minLabel.text = @"0.1 X";
        self.minLabel.font = [UIFont systemFontOfSize:10];
        self.minLabel.textColor = [UIColor.whiteColor colorWithAlphaComponent:0.5];
        [self addSubview:self.minLabel];
        _velocity = 0;


    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGSize size = self.bounds.size;
    // 边框
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(2, 2)];
    borderPath.lineWidth = 2.0;
    [[UIColor.whiteColor colorWithAlphaComponent:0.2] setStroke];
    [borderPath stroke];
    // 虚线
    UIBezierPath *dashLine = [UIBezierPath bezierPath];
    dashLine.lineWidth = 1.0f;
    CGFloat patten[] = {6.0f, 2.0f};
    [dashLine setLineDash:patten count:2 phase:3];
    for (int i = 1; i < 4; i++) {
        [dashLine moveToPoint:CGPointMake(0, size.height*i/4.0f)];
        [dashLine addLineToPoint:CGPointMake(size.width, size.height*i/4.0f)];
        [dashLine stroke];
        [dashLine removeAllPoints];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setBounds:(CGRect)bounds {
    if (!CGRectEqualToRect(bounds, self.bounds)) {
        [super setBounds:bounds];
        // update 0.1x y
        CGRect minLabelFrame = self.minLabel.frame;
        minLabelFrame.origin.y = self.bounds.size.height - minLabelFrame.size.height - 2;
        self.minLabel.frame = minLabelFrame;
        // update line height
        [self updateLinePosition:self.line.center.x];
        // update Curve
        [self updateCurveWithPoints:self.currentPoints];
    } else {
        [super setBounds:bounds];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // find selected node
    self.touching = YES;
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    point.x = MAX(0, point.x);
    point.x = MIN(self.frame.size.width, point.x);
    self.currentNode = nil;
    self.movingNode = NO;
    for (DVECurveSpeedNode *node in self.nodes) {
        node.selected = NO;
        if (CGRectContainsPoint(node.frame, point)) {
            node.selected = YES;
            self.currentNode = node;
            self.movingNode = YES;
            CGPoint center = self.line.center;
            center.x = point.x;
            self.line.center = center;
        }
    }
    
    for (DVECurveSpeedNode *node in self.nodes) {
        if (self.line.center.x > node.frame.origin.x && self.line.center.x < node.frame.origin.x + node.frame.size.width) {
            node.selected = YES;
        }
    }

    [self updateRange];
    

    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    _velocity = point.x - _preX;
    // 更新竖线位置
    [self updateLineAndProgress:point.x];
    // 拖动线时候更新选中点
    [self updateNodeSelectionWithPosition:point];
    // 更新速度
    if (self.currentNode && self.movingNode) {
        [self updateCurve];
    }
    // 更新顶部速度标识
    [self updateSpeed];
    _preX = point.x;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    point.x = self.line.center.x;
    [self updateNodeSelectionWithPosition:point];
    self.touching = NO;
    
    if (self.movingNode) {
        self.currentPoints = [self points];
        
        [self updateProgressFromLinePositon];
        self.movingNode = NO;
    }
}

- (nullable UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    for (DVECurveSpeedNode *node in self.nodes) {
        if (CGRectContainsPoint(node.frame, point)) {
            return node;
        }
    }

    return [super hitTest:point withEvent:event];
}
// frame外依然相应事件，第一个和最后一个点
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (point.y < self.frame.size.height && point.y > 0) {
        return YES;
    }
    return [super pointInside:point withEvent:event];
}

- (void)reset {
    if (self.originPoints) {
        [self updateCurveWithPoints:self.originPoints];
    }
}

/// 1. 横坐标的数值范围为0-1，表示播放器的播放进度。纵坐标的数值范围为0.1到10，表示速度的倍速。
- (void)updateCurveWithPoints:(NSArray<NSValue *> *)points {
    /// 如果originPoints空，设置为初始点
    if (!self.originPoints) {
        self.originPoints = points;
    }
    self.currentPoints = points;
    [self clearPoints];
    for (NSValue *point in points) {
        CGPoint p = point.CGPointValue;
        [self addNodeAtPoint:p];
    }

    [self updateCurve];

    // 更新选中点
    CGPoint lineCenter = self.line.center;
    lineCenter.y = 0;
    [self updateNodeSelectionWithPosition:lineCenter];
}

// 变速前的点
- (NSArray<NSValue *> *)points {
    NSMutableArray *ps = [NSMutableArray new];
    for (DVECurveSpeedNode *node in self.nodes) {
        NSValue *pValue = [NSValue valueWithCGPoint:[self pointFromViewPoint:node.center]];
        [ps addObject:pValue];
    }
    return ps.copy;
}

// 转换点
- (NSArray<NSValue *> *)transferedPointsFromOriginPoints:(NSArray<NSValue *> *)points {
    return [NLECurveSpeedCalculator_OC segmentPToSequenceP:points];
//    NSArray *orgPoints = points;
//    NSMutableArray *xArray = [NSMutableArray new];
//    NSMutableArray *yArray = [NSMutableArray new];
//    [orgPoints enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        CGPoint p = [(NSValue *)obj CGPointValue];
//        [xArray addObject:[NSNumber numberWithFloat:p.x]];
//        [yArray addObject:[NSNumber numberWithFloat:p.y]];
//    }];
//
//    NSArray *ps = [VECurveTransUtils transferVideoPointXtoPlayPointX:xArray curveSpeedPointY:yArray];
//    NSMutableArray *parray = [NSMutableArray new];
//    [orgPoints enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        CGPoint p = [(NSValue *)obj CGPointValue];
//        NSNumber *xnumber = ps[idx];
//        p.x = xnumber.floatValue;
//        [parray addObject:[NSValue valueWithCGPoint:p]];
//    }];
//    return parray;
}

// 变速后的点
- (NSArray<NSValue *> *)transferedPoints {
    
    return [self transferedPointsFromOriginPoints:self.points];
}


/// 添加或删除点； 根据有(无)选中点，删除(添加)点
- (void)action {
    self.currentNode ? [self deleteNode] : [self addNode];
}

- (void)updateLineAndProgress:(CGFloat)x {
    [self updateLinePosition:x];
    [self updateProgressFromLinePositon];
}


// 更新竖线位置
- (void)updateLinePosition:(CGFloat)x {
    x = MAX(x, self.edge.left);
    x = MIN(x, self.edge.right);
    self.line.frame = CGRectMake(x, 0, 1, self.bounds.size.height);
}

- (void)updateProgressFromLinePositon {
    CGFloat progress = [self transXToPlayTime:self.line.center.x];
//    CGFloat playDuration = NSEC_PER_MSEC * (self.editingSlot.duration.value) / self.editingSlot.duration.timescale;
//    CGFloat playDuration = NSEC_PER_MSEC * (self.editingSlot.duration.value / self.transUtil.avgSpeedRatio) / self.editingSlot.duration.timescale;
//    progress /= playDuration;
    progress = MAX(0, progress);
    progress = MIN(1, progress);
    self.progress = progress;
}

//
- (void)updateSpeed {
    if (self.currentNode) {
        self.updatingSpeed = [self pointFromViewPoint:self.currentNode.center].y;
    } else {
        self.updatingSpeed = 0;
    }
}

// 更新选中的点
- (void)updateNodeSelectionWithPosition:(CGPoint)point {
    // 在移动node，不更新选中点
    if (self.movingNode) return;
    self.currentNode = nil;
    // 查询是否选中点, 更新当前index
    CGFloat x = point.x;
    x = MAX(x, self.edge.left);
    x = MIN(x, self.edge.right);

    for (DVECurveSpeedNode *node in self.nodes) {
        node.selected = NO;
    }

    for (int i = 0; i < self.nodes.count; i++) {
        DVECurveSpeedNode *node = _velocity > 0 ? self.nodes[i] : self.nodes[self.nodes.count-i-1];
        // 更新选中状态
        if (x > node.frame.origin.x && x < (node.frame.origin.x + node.frame.size.width)) {
            self.currentNode = node;
            node.selected = YES;
            break;
        }
    }
}

// 更新可移动范围
- (void)updateRange {
    DVECurveSpeedNode *left = self.nodes.firstObject;
    DVECurveSpeedNode *right = self.nodes.lastObject;
    // 有选中Node
    if (self.currentNode) {
        NSInteger i = [self.nodes indexOfObject:self.currentNode];
        if (i > 0) {
            left = self.nodes[i-1];
        }
        if (i < self.nodes.count - 1) {
            right = self.nodes[i+1];
        }

        if (i == 0) {
            left = self.nodes.firstObject;
            right = left;
        }
        if (i == self.nodes.count - 1) {
            left = self.nodes.lastObject;
            right = left;
        }
        UIEdgeInsets edge = self.edge;
        edge.bottom = self.bounds.size.height;
        if (left != right) {
            // 中间的点，可以移动范围为左右两边的点之间
            edge.left = left.center.x + left.frame.size.width/2;
            edge.right = right.center.x - right.frame.size.width/2;
        } else if (right == self.nodes.firstObject) {
            //最左边的点 [0, right.center.x]
            edge.left = 0;
            edge.right = right.center.x;
        } else {
            // 最右边的点 [left.center.x, self.frame.size.width]
            edge.left = left.center.x;
            edge.right = self.frame.size.width;
        }
        self.edge = edge;
        self.currentNode.edge = self.edge;
    } else {
        // 未选中Node
        self.edge = UIEdgeInsetsMake(0, 0, self.bounds.size.height, self.bounds.size.width);
    }
}

// draw curve and add node
- (void)updateCurve {
    if (self.nodes.count > 1) {
        self.curve = nil;
        CGPoint pointA = self.nodes[0].center;
        CGPoint pointB;
        for (int i = 1; i < self.nodes.count; i++) {
            pointB = self.nodes[i].center;
            [self.curve appendPath:[DVECurveSpeedPathUtil pathFromPointA:pointA toPointB:pointB]];
            pointA = pointB;
        }
        self.shapeLayer.path = self.curve.CGPath;
    }

    for (DVECurveSpeedNode *node in self.nodes) {
        if (!node.superview) {
            [self addSubview:node];
        }
    }
    if (!self.movingNode) {
        self.currentPoints = [self points];
    }
}

// 在竖线处添加点
- (void)addNode {
    if (self.currentNode) return;
    CGPoint thePoint = self.line.center;
    if (self.index > 0 && self.index < self.nodes.count) {
        // get points
        CGPoint pointA = self.nodes[self.index-1].center;
        CGPoint pointB = self.nodes[self.index].center;
        CGFloat diffX = fabs(pointB.x-pointA.x);
        CGPoint ctrlA = CGPointMake(pointA.x + diffX * 0.5, pointA.y);
        CGPoint ctrlB = CGPointMake(pointA.x + diffX * 0.5, pointB.y);
        NSArray *points = @[
                [NSValue valueWithCGPoint:pointA],
                [NSValue valueWithCGPoint:ctrlA],
                [NSValue valueWithCGPoint:ctrlB],
                [NSValue valueWithCGPoint:pointB]
        ];
        // find node position
        NSArray<NSValue *> *pointsOnPath = [DVECurveSpeedPathUtil getBezierPathWithPoints:points];
        thePoint = pointsOnPath.firstObject.CGPointValue;
        CGFloat lineX = self.line.center.x;
        // 寻找最近的点
        for (NSValue *pValue in pointsOnPath) {
            thePoint = fabs(pValue.CGPointValue.x - lineX) < fabs(thePoint.x - lineX) ? pValue.CGPointValue : thePoint;
        }
    }

    DVECurveSpeedNode *newNode = [[DVECurveSpeedNode alloc] init];
    thePoint.x = self.line.center.x;
    newNode.center = thePoint;
    [self.nodes insertObject:newNode atIndex:self.index];
    newNode.selected = YES;
    self.currentNode = newNode;
    [self updateCurve];
    
    self.progress = self.progress;
}

/// @param point 归一化点
- (void)addNodeAtPoint:(CGPoint)point {
    CGPoint viewPoint = [self viewPointFromPoint:point];
    DVECurveSpeedNode *node = [[DVECurveSpeedNode alloc] init];
    node.center = viewPoint;

    // 可以用二分，但没必要
    BOOL insertFlag = false;
    for (int i = 0; i < self.nodes.count; i++) {
        DVECurveSpeedNode *tmpNode = self.nodes[i];

        if (node.center.x < tmpNode.center.x) {
            [self.nodes insertObject:node atIndex:i];
            insertFlag = true;
            break;
        }
    }
    if (!insertFlag) {
        [self.nodes addObject:node];
    }
}


- (void)deleteNode {
    if (self.currentNode && self.currentNode != self.nodes.firstObject && self.currentNode != self.nodes.lastObject) {
        [self.nodes removeObject:self.currentNode];
        [self.currentNode removeFromSuperview];
        self.currentNode = nil;
        [self updateCurve];
        
        self.progress = self.progress;
    }
}

- (void)clearPoints {
    for (UIView *node in self.nodes) {
        [node removeFromSuperview];
    }
    self.currentNode = nil;
    [self.nodes removeAllObjects];
    
    self.progress = self.progress;
}

- (CGPoint)viewPointFromPoint:(CGPoint)point {
//    CGFloat y = log10(point.y * 10)/2 * self.frame.size.height; // log
// linear
    CGFloat y = 0;
    CGFloat halfH = self.bounds.size.height * 0.5;
    if (point.y < 1) {
        y = halfH + (halfH / 9) * (1 - point.y) * 10; // 下半部分分为9份,注意坐标翻转
    } else {
        y = halfH - (halfH / 9) * (point.y - 1); // 上半部分分为9份
    }

    CGFloat xStep = self.frame.size.width;
    return CGPointMake(point.x*xStep, y);
}

- (CGPoint)pointFromViewPoint:(CGPoint)point {
//    CGFloat unit = point.y/self.frame.size.height;
//    unit = 1 - unit;
//    CGFloat y = pow(10, unit*2)/10;
    CGFloat halfH = self.bounds.size.height * 0.5;
    CGFloat y = 0;
    if (point.y > halfH) {
        y = 1 - 0.1 * (point.y - halfH) / (halfH / 9);
    } else {
        y = 1 + (halfH - point.y) / (halfH / 9);
    }

    CGFloat xStep = self.frame.size.width;
    if (xStep == 0) return CGPointZero;
    return CGPointMake(point.x/xStep, y);
}

- (CGFloat)transPlayTimeToX:(CMTime)currentTime duration:(CMTime)duration {
    int64_t currentIntTime = currentTime.value * USEC_PER_SEC / currentTime.timescale;
    // 转换时间
//    int64_t transTime = [self.transUtil transPlayTimeToVideoTime:currentIntTime];
    int64_t transTime = [self.transUtil sequenceDelToSegmentDel:currentIntTime seqDurationUs:self.seqDurationUs];
    
//    NSLog(@"当前倍数: %f", [self.transUtil getCurveSpeedRatioWithPlayTime:currentIntTime]);


    CGFloat x = (transTime * duration.timescale * 1.0f) / (NSEC_PER_MSEC * duration.value);
//    NSLog(@"当前progress倍数: %f", [self.transUtil getCurveSpeedRatioWithPlayTime:x*self.editingSlot.duration.value]);

//        CGFloat x = (currentTime.value*duration.timescale*1.0f) / (currentTime.timescale*duration.value);
    x *= self.bounds.size.width;

    return x;
}

- (CGFloat)transXToPlayTime:(CGFloat)x {
    CGFloat progress = x / self.frame.size.width;
    
//    NSLog(@"当前倍数: %f", [self.transUtil getCurveSpeedRatioWithPlayTime:progress*self.editingSlot.duration.value]);

    return progress;
    if (self.editingSlot.duration.timescale == 0 ) { return progress; }
    
    int64_t videoTime = progress * [DVEAutoInline(self.vcContext.serviceProvider, DVECoreVideoProtocol)
                                    currentSrcDuration];
    
//    return [self.transUtil transVideoTimeToPlayTime:videoTime];
    return [self.transUtil segmentDelToSequenceDel:videoTime seqDurationUs:self.seqDurationUs];
}

#pragma mark - Setters && Getters

- (int64_t)seqDurationUs {
    int64_t ussec = CMTimeGetSeconds(self.editingSlot.duration) * USEC_PER_SEC;
    return ussec;
}

- (void)setCurrentPoints:(NSArray<NSValue *> *)currentPoints {
    if (_currentPoints != currentPoints) {
        self.currentTransFomedPoints = [self transferedPointsFromOriginPoints:currentPoints];
        if (currentPoints.count > 1) {
            self.transUtil = [[NLECurveSpeedCalculator_OC alloc] initWithSegPoints:currentPoints];
        }
        _currentPoints = currentPoints;
        // 更新播放时间
//        [self updateProgressFromLinePositon];
    }
}

- (void)setCurrentTransFomedPoints:(NSArray<NSValue *> *)currentTransFomedPoints {
//    NSMutableArray *xPoints = [[NSMutableArray alloc] init];
//    NSMutableArray *yPoints = [[NSMutableArray alloc] init];
//    [currentTransFomedPoints enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSNumber *xValue = [NSNumber numberWithFloat:obj.CGPointValue.x];
//        NSNumber *yValue = [NSNumber numberWithFloat:obj.CGPointValue.y];
//        [xPoints addObject:xValue];
//        [yPoints addObject:yValue];
//    }];
//    CMTime d = self.vcContext.mediaContext.duration;
//    if (d.timescale > 0) {
//        int64_t duration = d.value * NSEC_PER_MSEC / d.timescale;
//        int64_t duration = [DVEAutoInline(self.vcContext.serviceProvider, DVECoreVideoProtocol) srcDurationWithSlot:self.editingSlot];
//        self.transUtil = [[VECurveTransUtils alloc] initWithPoints:xPoints yPoints:yPoints srcDuration:duration];
//    }

    _currentTransFomedPoints = currentTransFomedPoints;
}

- (void)setVcContext:(DVEVCContext *)vcContext {
    [super setVcContext:vcContext];
    // 监听进度变化
    @weakify(self);
    [RACObserve(self.vcContext.playerService, currentPlayerTime) subscribeNext:^(id y) {
        @strongify(self);
        if (self.touching) { return; }
        // 播放导致的变化
        // 清除选中状态
        self.movingNode = nil;
        self.currentNode = nil;
        [self updateRange];
        
        CMTime currentTime = CMTimeMake(self.vcContext.playerService.currentPlayerTime*USEC_PER_SEC, USEC_PER_SEC);

        if (currentTime.timescale == 0) {
            return;
        }
        
        currentTime = CMTimeSubtract(currentTime, self.editingSlot.startTime);
        
        // 获取原始时长
        int64_t srcDuration = [(NLESegmentAudio_OC *)self.editingSlot.segment getDurationWithoutCurveSpeed];
        // 计算x
        CGFloat x = [self transPlayTimeToX:currentTime duration:CMTimeMake(srcDuration, USEC_PER_SEC)];
        
        [self updateLinePosition:x];
        // 更新选中点
        [self updateNodeSelectionWithPosition:CGPointMake(x, 0)];
        // 更新顶部速度label
        [self updateSpeed];
        
    }];
}

- (NSInteger)index {
    // 更新插入位置
    NSInteger i = 0;
    CGFloat x = self.line.center.x;
    for (DVECurveSpeedNode *node in self.nodes) {
        if (x > node.center.x) {
            i++;
        }
    }
    return i;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.bounds.size.height)];
        _line.backgroundColor = UIColor.whiteColor;
    }

    return _line;
}


- (UIBezierPath *)curve {
    if (!_curve) {
        _curve = [UIBezierPath bezierPath];
        _curve.lineWidth = 1.0f;
    }

    return _curve;
}

- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.frame = self.bounds;
        _shapeLayer.strokeColor = HEXRGBCOLOR(0xFE6646).CGColor;
        _shapeLayer.fillColor = UIColor.clearColor.CGColor;
        _shapeLayer.lineWidth = 1.0f;
    }

    return _shapeLayer;
}

- (NSMutableArray *)nodes {
    if (!_nodes) {
        _nodes = [[NSMutableArray alloc] init];
    }
    return _nodes;
}

- (DVECurveSpeedCanvasActionType)actionType {
    if (self.currentNode == self.nodes.firstObject || self.currentNode == self.nodes.lastObject) {
        return DVECurveSpeedCanvasActionDisable;
    }
    if (self.currentNode == nil) {
        return DVECurveSpeedCanvasActionAdd;
    }
    return DVECurveSpeedCanvasActionDelete;
}

@end
