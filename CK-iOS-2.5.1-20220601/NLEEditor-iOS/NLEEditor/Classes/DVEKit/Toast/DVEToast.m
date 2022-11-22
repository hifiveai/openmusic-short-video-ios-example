//
//  DVEToast.m
//  IESVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2019 Gavin. All rights reserved.
//

#import "DVEToast.h"
#import "DVEUIHelper.h"
#import "DVEMacros.h"
#import <DVETrackKit/UIView+VEExt.h>

@interface DVEToast ()

@property (nonatomic, strong) UILabel *toastLabel;

@end

@implementation DVEToast

- (void)dealloc {
    [self.toastLabel removeFromSuperview];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _toastLabel                     = [[UILabel alloc] init];
        _toastLabel.backgroundColor     = RGBACOLOR(24, 23, 24, 0.9);
        _toastLabel.font                = SCRegularFont(12);
        _toastLabel.textColor           = [UIColor whiteColor];
        _toastLabel.textAlignment       = NSTextAlignmentCenter;
        _toastLabel.numberOfLines       = 0;
        _toastLabel.layer.cornerRadius  = 6.0;
        _toastLabel.layer.masksToBounds = YES;
        _toastLabel.layer.borderColor = RGBACOLOR(227, 110, 85, 1).CGColor;
        _toastLabel.layer.borderWidth = SINGLE_LINE_WIDTH;
        [[UIView currentWindow] addSubview:_toastLabel];
    }
    return self;
}

+ (instancetype)shared {
    static id singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}

+ (void)showInfo:(NSString *)format, ... {
    if (!format) {
        return;
    }
    va_list args;
    va_start(args, format);
    NSString *info = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    UILabel *label = [DVEToast shared].toastLabel;

    label.text = [NSString stringWithFormat:@"%@", info];
    label.font = [UIFont systemFontOfSize:16];
    [label sizeToFit];

    label.width = 170;
    label.centerX = UIScreen.mainScreen.bounds.size.width * 0.5;
    label.top     = 250 + DVEUIHelper.topBarMargn;
    label.height  = 40.0;
    label.alpha       = 1.0;

    [label.superview bringSubviewToFront:label];

    static NSInteger infoCounter = 0;
    ++infoCounter;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        --infoCounter;
        if (!infoCounter) {
            label.alpha = 0.0;
        }
    });
}


@end
