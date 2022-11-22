//
//  DVEScaleSlider.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "DVEScaleSlider.h"
#import "DVEMacros.h"
#import <DVETrackKit/UIView+VEExt.h>
#import <Masonry/Masonry.h>

@implementation DVEScaleValue

- (instancetype)initWithCount:(NSInteger)count title:(NSString *)title
{
    if (self = [self init]) {
        self.count = count;
        self.title = title;
    }
    
    return self;
}

@end

@implementation DVEScaleSlider

- (instancetype)initWithStep:(float)step defaultValue:(float)defaultvalue frame:(CGRect)frame;
{
    if (self = [super initWithStep:step defaultValue:defaultvalue frame:frame]) {
        self.scaleContainerView = [[UIView alloc] initWithFrame:self.bounds];
        self.clipsToBounds = NO;
        self.color = RGBCOLOR(68, 68, 68);
        [self buildUI];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    
    return self;
}

- (void)buildUI
{
    self.slider.label.hidden = YES;
    self.sliderHeight = 1.0;
    self.minimumTrackTintColor = self.color;
    self.maximumTrackTintColor = self.color;
    
    self.scaleContainerView.backgroundColor = self.color;
    [self insertSubview:self.scaleContainerView atIndex:0];
    
//    [_scaleContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self).inset(5);
//        //make.right.equalTo(self.snp.right)
//        make.height.mas_equalTo(1.0);
//        make.centerY.equalTo(self);
//    }];

    
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    self.minimumTrackTintColor = color;
    self.maximumTrackTintColor = color;
    self.scaleContainerView.backgroundColor = color;
    for (UIView *scaleView in self.scaleViews) {
        scaleView.backgroundColor = color;
    }
    
    
}

- (void)showScalesWithArr:(NSArray *)scales
{
    UIColor *color = HEXRGBCOLOR(0xd8d8d8);
    for (UIView *view in self.scaleViews) {
        [view removeFromSuperview];
    }
    [self.scaleViews removeAllObjects];
    
    for (UILabel *view in self.scaleLabels) {
        [view removeFromSuperview];
    }
    [self.scaleLabels removeAllObjects];
    
    NSMutableDictionary *linesInfo = [NSMutableDictionary new];
    __block NSInteger lineCount = 0;
    [scales enumerateObjectsUsingBlock:^(DVEScaleValue *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        linesInfo[@(lineCount)] = obj.title;
        lineCount += obj.count;
    }];
    
    for (NSInteger i = 0; i < lineCount; i ++) {
        UIView *scaleView = [self normalScaleView];
        BOOL isContains = false;
        NSString *title = linesInfo[@(i)];
        if (title.length > 0) {
            isContains = true;
        }
        
        CGFloat height = isContains ? 11 : 4.6;
        scaleView.backgroundColor = color;
        [self.scaleContainerView addSubview:scaleView];
        [self.scaleViews addObject:scaleView];
        
        
        if (i == 0) {
            scaleView.centerX = 0;
        } else {
            scaleView.centerX = (self.scaleContainerView.width *((float)i / (float)(lineCount - 1)));
            
        }
        scaleView.centerY = self.scaleContainerView.height * 0.5;
        scaleView.width = 1.0;
        scaleView.height = height;
        
        
        if (isContains) {
            UILabel *scaleLabel = [self normalScaleLabel];
            scaleLabel.text = title;
            [self.scaleContainerView addSubview:scaleLabel];
            [self.scaleLabels addObject:scaleLabel];
            [scaleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(scaleView.mas_bottom).offset(17.0);
                make.centerX.equalTo(scaleView);
            }];
            
        }
    }
    
    self.minimumTrackTintColor = UIColor.clearColor;
    self.maximumTrackTintColor = UIColor.clearColor;
    self.scaleContainerView.backgroundColor = UIColor.clearColor;
}

- (UIView *)normalScaleView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor = self.color;
    return view;
}

- (UILabel *)normalScaleLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = SCRegularFont(12);
    return label;
}

@end
