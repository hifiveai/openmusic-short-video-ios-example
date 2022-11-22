//
// Created by bytedance on 2021/6/21.
//

#import "DVECurveSpeedNode.h"
#import "DVEMacros.h"

@interface DVECurveSpeedNode() {
    CGFloat _width;
}

@end

@implementation DVECurveSpeedNode

- (instancetype)init {
    _width = 18;
    return [self initWithFrame:CGRectMake(0, 0, _width, _width)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.blackColor;
        self.layer.cornerRadius = _width/2;
        self.layer.borderWidth = 1;
        self.layer.borderColor = UIColor.whiteColor.CGColor;
    }
    return self;
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self.superview];
    point.x = MAX(point.x, self.edge.left);
    point.x = MIN(point.x, self.edge.right);
    point.y = MAX(point.y, self.edge.top);
    point.y = MIN(point.y, self.edge.bottom);
    self.center = point;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    self.backgroundColor = selected ? HEXRGBCOLOR(0xFE6646) : UIColor.blackColor;
    self.layer.borderColor = selected ? HEXRGBCOLOR(0xFE6646).CGColor : UIColor.whiteColor.CGColor;
}

@end
