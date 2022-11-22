//
//  VECPStatusView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECPStatusView.h"

static NSString *VEDurationFormat(NSTimeInterval durationF) {
    int durationN = ceil(durationF);
    if (durationN < 60) {
        return [NSString stringWithFormat:@"00:%02d",(int)durationN];
    } else if (durationN < 3600) {
        int minute = (int)durationN / 60;
        int second = (int)durationN % 60;
        return [NSString stringWithFormat:@"%02d:%02d",minute,second];
    } else {
        int hour = durationN / 3600;
        int seconds = hour % 3600;
        int minute = seconds / 60;
        int second = seconds % 60;
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hour,minute,second];
    }
}
@implementation VECPStatusView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.statusLable];
//        [self addSubview:self.redView];
        
    }
    
    return self;
}

- (void)setDuration:(NSTimeInterval)duration
{
    _duration = duration;
    
    self.redView.hidden = (NSInteger)(duration* 10) % 2;
    
    self.statusLable.text = VEDurationFormat(duration);
}

- (UILabel *)statusLable
{
    if (!_statusLable) {
        _statusLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 113, 30)];
        _statusLable.textColor = [UIColor whiteColor];
        _statusLable.font = [UIFont systemFontOfSize:18];
        _statusLable.textAlignment = NSTextAlignmentCenter;
        _statusLable.centerX = VE_SCREEN_WIDTH * 0.5;
    }
    
    
    return _statusLable;
}

- (UIView *)redView
{
    if (!_redView) {
        _redView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _redView.layer.cornerRadius = 5;
        _redView.backgroundColor = [UIColor redColor];
        _redView.center = _statusLable.center;
        _redView.right = _statusLable.left - 10;
        _redView.hidden = YES;
    }
    
    return _redView;
}

@end
