//
//  VECircleProgressView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECircleProgressView.h"

static CGFloat endPointMargin = 1.0f;

@interface VECircleProgressView ()

@property (nonatomic, strong) CAShapeLayer *trackLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UIImageView *endPoint;

@end

@implementation VECircleProgressView

-(instancetype)initWithFrame:(CGRect)frame lineWidth:(float)lineWidth
{
    self = [super initWithFrame:frame];
    if (self) {
        _lineWidth = lineWidth;
        if (lineWidth <= 0) {
            _lineWidth = 3;
        }
        
        [self buildLayout];
    }
    return self;
}

-(void)buildLayout
{
    float centerX = self.bounds.size.width/2.0;
    float centerY = self.bounds.size.height/2.0;
    //半径
    float radius = (self.bounds.size.width-_lineWidth)/2.0;
    
    //创建贝塞尔路径
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX, centerY) radius:radius startAngle:(-0.5f*M_PI) endAngle:1.5f*M_PI clockwise:YES];
    
    //添加背景圆环

    _trackLayer = [CAShapeLayer layer];
    _trackLayer.frame = self.bounds;
    _trackLayer.fillColor =  [[UIColor clearColor] CGColor];
    _trackLayer.strokeColor  = [UIColor whiteColor].CGColor;
    _trackLayer.lineWidth = _lineWidth;
    _trackLayer.path = [path CGPath];
    _trackLayer.strokeEnd = 1;
    [self.layer addSublayer:_trackLayer];
    
    //创建进度layer
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.frame = self.bounds;
    _progressLayer.fillColor =  [[UIColor clearColor] CGColor];
    //指定path的渲染颜色
    _progressLayer.strokeColor  = [[UIColor blackColor] CGColor];
    _progressLayer.lineCap = kCALineCapRound;
    _progressLayer.lineWidth = _lineWidth;
    _progressLayer.path = [path CGPath];
    _progressLayer.strokeEnd = 0;
    
    //设置渐变颜色
    CAGradientLayer *gradientLayer =  [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    [gradientLayer setColors:[NSArray arrayWithObjects:(id)[HEXRGBCOLOR(0xFE6646) CGColor],(id)[HEXRGBCOLOR(0xFE6646) CGColor], nil]];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    [gradientLayer setMask:_progressLayer]; //用progressLayer来截取渐变层
    [self.layer addSublayer:gradientLayer];
    
    
//    //用于显示结束位置的小点
//    _endPoint = [[UIImageView alloc] init];
//    _endPoint.frame = CGRectMake(0, 0, _lineWidth - endPointMargin*2,_lineWidth - endPointMargin*2);
//    _endPoint.hidden = true;
//    _endPoint.backgroundColor = [UIColor blackColor];
//    _endPoint.image = [UIImage imageNamed:@"endPoint"];
//    _endPoint.layer.masksToBounds = true;
//    _endPoint.layer.cornerRadius = _endPoint.bounds.size.width/2;
//    [self addSubview:_endPoint];
}

-(void)setProgress:(float)progress
{
    _progress = progress;
    
    _progressLayer.strokeEnd = progress;
//    [self updateEndPoint];
    [_progressLayer removeAllAnimations];
    
    if (_progress >= 0.99) {
        _progress = 0.0;
        _progressLayer.strokeStart = 0;
        _progressLayer.strokeEnd = 0;
        [_progressLayer removeAllAnimations];
    }
}

//更新小点的位置
-(void)updateEndPoint
{
    //转成弧度
    CGFloat angle = M_PI*2*_progress;
    float radius = (self.bounds.size.width-_lineWidth)/2.0;
    int index = (angle)/M_PI_2;//用户区分在第几象限内
    float needAngle = angle - index*M_PI_2;//用于计算正弦/余弦的角度
    float x = 0,y = 0;//用于保存_dotView的frame
    switch (index) {
        case 0:
            NSLog(@"第一象限");
            x = radius + sinf(needAngle)*radius;
            y = radius - cosf(needAngle)*radius;
            break;
        case 1:
            NSLog(@"第二象限");
            x = radius + cosf(needAngle)*radius;
            y = radius + sinf(needAngle)*radius;
            break;
        case 2:
            NSLog(@"第三象限");
            x = radius - sinf(needAngle)*radius;
            y = radius + cosf(needAngle)*radius;
            break;
        case 3:
            NSLog(@"第四象限");
            x = radius - cosf(needAngle)*radius;
            y = radius - sinf(needAngle)*radius;
            break;
            
        default:
            break;
    }
    
    //更新圆环的frame
    CGRect rect = _endPoint.frame;
    rect.origin.x = x + endPointMargin;
    rect.origin.y = y + endPointMargin;
    _endPoint.frame = rect;
    //移动到最前
    [self bringSubviewToFront:_endPoint];
    _endPoint.hidden = YES;
    if (_progress == 0 || _progress == 1) {
        _endPoint.hidden = true;
    }
}

@end
