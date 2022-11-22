//
//  VETwoLableButton.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VETwoLableButton.h"

@interface VETwoLableButton ()

@property (nonatomic, strong) UILabel *titLable;
@property (nonatomic, strong) UILabel *desLable;

@end

@implementation VETwoLableButton

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title des:(NSString *)des
{
    if (self = [self initWithFrame:frame]) {
        [self addSubview:self.titLable];
        [self addSubview:self.desLable];
        self.titLable.text = title;
        self.desLable.text = des;
    }
    
    return self;
}


- (UILabel *)titLable
{
    if (!_titLable) {
        _titLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, self.height)];
        _titLable.textAlignment = NSTextAlignmentCenter;
        _titLable.font = SCRegularFont(12);
        _titLable.textColor = [UIColor whiteColor];
    }
    
    return _titLable;
}


- (UILabel *)desLable
{
    if (!_desLable) {
        _desLable = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, self.width - 60, self.height)];
        _desLable.textAlignment = NSTextAlignmentCenter;
        _desLable.font = SCRegularFont(12);
        _desLable.textColor = [UIColor orangeColor];
    }
    
    return _desLable;
}


- (void)updateDes:(NSString *)des
{
    _desLable.text = des;
}

@end
