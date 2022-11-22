//
//  DVEPickerOverlayView.m
//  Cam21qeraClient
//
//  Created by bytedance on 2020/4/26.
//

#import "DVEPickerOverlayView.h"
#import <Masonry/View+MASAdditions.h>

@implementation DVEPickerOverlayView

- (void)showOnView:(UIView *)view {
    [view addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

- (void)dismiss {
    [self removeFromSuperview];
}

@end
