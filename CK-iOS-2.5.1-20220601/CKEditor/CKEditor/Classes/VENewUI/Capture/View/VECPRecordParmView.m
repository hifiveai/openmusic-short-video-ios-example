//
//  VECPRecordParmView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECPRecordParmView.h"

@interface VECPRecordParmView ()


@end

@implementation VECPRecordParmView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.rateButton];
        [self addSubview:self.timeButton];
        [self addSubview:self.rateControl];
        [self addSubview:self.timeControl];
        
        self.rateControl.hidden = YES;
        self.timeControl.hidden = YES;
        
        @weakify(self);
        [[_rateButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            x.selected = !x.selected;
            
            if (x.selected) {
                self.timeButton.hidden = YES;
                self.rateControl.hidden = NO;
                self.timeControl.hidden = YES;
            } else {
                self.timeButton.hidden = NO;
                self.rateControl.hidden = YES;
                self.timeControl.hidden = YES;
                if (self.capManager.currentPreviewType == VECPCurrentPreViewTypeDuet) {
                    self.timeButton.hidden = YES;
                } else {
                    self.timeButton.hidden = NO;
                }
            }
            
        }];
        
        [[_timeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            
            x.selected = !x.selected;
            
            if (x.selected) {
                self.rateButton.hidden = YES;
                self.rateControl.hidden = YES;
                self.timeControl.hidden = NO;
                self.timeButton.transform = CGAffineTransformMakeTranslation(- 120, 0);
            } else {
                self.rateButton.hidden = NO;
                self.rateControl.hidden = YES;
                self.timeControl.hidden = YES;
                self.timeButton.transform = CGAffineTransformMakeTranslation(0, 0);
            }
            
        }];
        
        [[_rateControl rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(__kindof UISegmentedControl * _Nullable x) {
            @strongify(self);
            if (self.capManager.currentPreviewType == VECPCurrentPreViewTypeDuet) {
                self.timeButton.hidden = YES;
            } else {
                self.timeButton.hidden = NO;
            }
            self.rateControl.hidden = YES;
            
            NSArray *items = @[CKEditorLocStringWithKey(@"ck_speed_extremely_slow", @"极慢") ,CKEditorLocStringWithKey(@"ck_speed_slower", @"慢速"),CKEditorLocStringWithKey(@"ck_speed_normal", @"正常"),CKEditorLocStringWithKey(@"ck_speed_faster", @"快速"),CKEditorLocStringWithKey(@"ck_speed_extremely_quick", @"极快")];
            [self.rateButton updateDes:items[x.selectedSegmentIndex]];
            switch (x.selectedSegmentIndex) {
                case 0:
                {
                    self.capManager.recordRate = 0.33;
                }
                    break;
                case 1:
                {
                    self.capManager.recordRate = 0.5;
                }
                    break;
                case 2:
                {
                    self.capManager.recordRate = 1;
                }
                    break;
                case 3:
                {
                    self.capManager.recordRate = 2;
                }
                    break;
                case 4:
                {
                    self.capManager.recordRate = 3;
                }
                    break;
                    
                default:
                    break;
            }
        }];
        
        [[_timeControl rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(__kindof UISegmentedControl * _Nullable x) {
            @strongify(self);
            self.timeControl.hidden = YES;
            self.timeButton.transform = CGAffineTransformMakeTranslation(0, 0);
            self.rateButton.hidden = NO;
            
            
            NSArray *items = @[@"15S",@"60S",CKEditorLocStringWithKey(@"ck_free_duration", @"自由时长") ];
            [self.timeButton updateDes:items[x.selectedSegmentIndex]];
            switch (x.selectedSegmentIndex) {
                case 0:
                {
                    self.capManager.durationType = VECPRecordDurationType15s;
                }
                    break;
                case 1:
                {
                    self.capManager.durationType = VECPRecordDurationType60s;
                }
                    break;
                case 2:
                {
                    self.capManager.durationType = VECPRecordDurationTypeFree;
                }
                    break;
                    
                default:
                    break;
            }
        }];
        
    }
    
    return self;
}


- (VETwoLableButton *)rateButton
{
    if (!_rateButton) {
        _rateButton = [[VETwoLableButton alloc] initWithFrame:CGRectMake(10, 0, 110, 30) title:CKEditorLocStringWithKey(@"ck_speed",@"速度") des:CKEditorLocStringWithKey(@"ck_speed_normal",@"正常")];
    }
    
    return _rateButton;
}

- (VETwoLableButton *)timeButton
{
    if (!_timeButton ) {
        _timeButton = [[VETwoLableButton alloc] initWithFrame:CGRectMake(150, 0, 110, 30) title:CKEditorLocStringWithKey(@"ck_duration",@"时长") des:CKEditorLocStringWithKey(@"ck_free_duration",@"自由时长")];
    }
    
    return _timeButton;
}


- (UISegmentedControl *)rateControl
{
    if (!_rateControl) {
        NSArray *items = @[CKEditorLocStringWithKey(@"ck_speed_extremely_slow", @"极慢") ,CKEditorLocStringWithKey(@"ck_speed_slower", @"慢速"),CKEditorLocStringWithKey(@"ck_speed_normal", @"正常"),CKEditorLocStringWithKey(@"ck_speed_faster", @"快速"),CKEditorLocStringWithKey(@"ck_speed_extremely_quick", @"极快")];;
        _rateControl = [[UISegmentedControl alloc] initWithItems:items];
        _rateControl.frame = CGRectMake(100, 0, VE_SCREEN_WIDTH - 100 - 25, 30);
        _rateControl.selectedSegmentIndex = 2;
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:HEXRGBCOLOR(0x898989),NSForegroundColorAttributeName,nil];
        [_rateControl setTitleTextAttributes:dic forState:UIControlStateNormal];
        dic = [NSDictionary dictionaryWithObjectsAndKeys:HEXRGBCOLOR(0xFE6646),NSForegroundColorAttributeName,nil];
        [_rateControl setTitleTextAttributes:dic forState:UIControlStateSelected];
        [_rateControl setBackgroundImage:[UIImage new]
                                             forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [_rateControl setBackgroundImage:[UIImage new]
                                             forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    }
    
    return _rateControl;
}

- (UISegmentedControl *)timeControl
{
    if (!_timeControl) {
        _timeControl = [[UISegmentedControl alloc] initWithItems:@[@"15S",@"60S",CKEditorLocStringWithKey(@"ck_free_duration", @"自由时长") ]];
        _timeControl.frame = CGRectMake(130, 0, VE_SCREEN_WIDTH - 100 - 30, 30);
        _timeControl.selectedSegmentIndex = 2;
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:HEXRGBCOLOR(0x898989),NSForegroundColorAttributeName,nil];
        [_timeControl setTitleTextAttributes:dic forState:UIControlStateNormal];
        dic = [NSDictionary dictionaryWithObjectsAndKeys:HEXRGBCOLOR(0xFE6646),NSForegroundColorAttributeName,nil];
        [_timeControl setTitleTextAttributes:dic forState:UIControlStateSelected];
        
        [_timeControl setBackgroundImage:[UIImage new]
                                             forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [_timeControl setBackgroundImage:[UIImage new]
                                             forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    }
    
    return _timeControl;
}

@end
