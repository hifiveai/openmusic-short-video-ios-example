//
//  DVECropGridView.m
//  NLEEditor
//
//  Created by bytedance on 2021/4/12.
//

#import "DVECropGridView.h"
#import <DVETrackKit/UIView+VEExt.h>
#import <Masonry/Masonry.h>

@implementation DVECropGridVertexView

- (instancetype)initWithFrame:(CGRect)frame
                         type:(DVECropGridVertexViewType)type {
    if (self = [super initWithFrame:frame]) {
        _type = type;
        [self addBorderWithType:type];
    }
    return self;
}

- (void)addBorderWithType:(DVECropGridVertexViewType)type {
    CAShapeLayer *vBorderLayer = [[CAShapeLayer alloc] init];
    CAShapeLayer *hBorderLayer = [[CAShapeLayer alloc] init];
    vBorderLayer.backgroundColor = [UIColor whiteColor].CGColor;
    hBorderLayer.backgroundColor = [UIColor whiteColor].CGColor;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    switch (self.type) {
        case DVECropGridVertexLeftTop: {
            vBorderLayer.frame = CGRectMake(0, 0, 16, 3);
            hBorderLayer.frame = CGRectMake(0, 0, 3, 16);
        }
            break;
        case DVECropGridVertexRightTop: {
            vBorderLayer.frame = CGRectMake(width - 16, 0, 16, 3);
            hBorderLayer.frame = CGRectMake(width - 3, 0, 3, 16);
        }
            break;
        case DVECropGridVertexLeftBottom: {
            vBorderLayer.frame = CGRectMake(0, height - 3, 16, 3);
            hBorderLayer.frame = CGRectMake(0, height - 16, 3, 16);
        }
            break;
        case DVECropGridVertexRightBottom: {
            vBorderLayer.frame = CGRectMake(width - 16, height - 3, 16, 3);
            hBorderLayer.frame = CGRectMake(width - 3, height - 16, 3, 16);
        }
            break;
        default:
            NSAssert(NO, @"DVECropGridVertexViewType should be vaild!!!");
            break;
    }
    [self.layer addSublayer:vBorderLayer];
    [self.layer addSublayer:hBorderLayer];
}

@end

@interface DVECropGridView ()

@property (nonatomic, strong) DVECropGridVertexView *leftTopVertex;

@property (nonatomic, strong) DVECropGridVertexView *rightTopVertex;

@property (nonatomic, strong) DVECropGridVertexView *leftBottomVertex;

@property (nonatomic, strong) DVECropGridVertexView *rightBottomVertex;

@end

static const NSInteger gridLineCount = 4;

@implementation DVECropGridView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setUpCirclesView];
        [self setUpHorizontalLine];
        [self setUpVerticalLines];
    }
    return self;
}

- (DVECropGridVertexView *)leftTopVertex {
    if (!_leftTopVertex) {
        _leftTopVertex = [[DVECropGridVertexView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) type:DVECropGridVertexLeftTop];
    }
    return _leftTopVertex;
}

- (DVECropGridVertexView *)rightTopVertex {
    if (!_rightTopVertex) {
        _rightTopVertex = [[DVECropGridVertexView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) type:DVECropGridVertexRightTop];
    }
    return _rightTopVertex;
}


- (DVECropGridVertexView *)leftBottomVertex {
    if (!_leftBottomVertex) {
        _leftBottomVertex = [[DVECropGridVertexView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) type:DVECropGridVertexLeftBottom];
    }
    return _leftBottomVertex;
}

- (DVECropGridVertexView *)rightBottomVertex {
    if (!_rightBottomVertex) {
        _rightBottomVertex = [[DVECropGridVertexView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) type:DVECropGridVertexRightBottom];
    }
    return _rightBottomVertex;
}


- (void)setUpCirclesView {
    [self addSubview:self.leftTopVertex];
    CGSize size = CGSizeMake(50, 50);
    [_leftTopVertex mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
        make.left.mas_equalTo(self).offset(-2);
        make.top.mas_equalTo(self).offset(-2);
    }];
    
    [self addSubview:self.rightTopVertex];
    [_rightTopVertex mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
        make.right.mas_equalTo(self).offset(2);
        make.top.mas_equalTo(self).offset(-2);
    }];
    
    [self addSubview:self.leftBottomVertex];
    [_leftBottomVertex mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
        make.left.mas_equalTo(self).offset(-2);
        make.bottom.mas_equalTo(self).offset(2);
    }];
    
    [self addSubview:self.rightBottomVertex];
    [_rightBottomVertex mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
        make.right.mas_equalTo(self).offset(2);
        make.bottom.mas_equalTo(self).offset(2);
    }];
}


- (void)setUpHorizontalLine {
    CGFloat dw = 0.0;
    for (NSInteger i = 0; i < gridLineCount; i++) {
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor whiteColor];
        [self addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1.0);
            make.left.mas_equalTo(self.left);
            make.right.mas_offset(self.right);
        }];
        
        if (i == 0) {
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.top);
            }];
        } else if (i == 3) {
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.bottom);
            }];
        } else {
            line.alpha = 0.5;
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.centerY).multipliedBy(dw / 0.5);
            }];
        }
        dw += 1.0 / (CGFloat)(gridLineCount - 1);
    }
    
}

- (void)setUpVerticalLines {
    CGFloat dw = 0.0;
    for (NSInteger i = 0; i < gridLineCount; i++) {
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor whiteColor];
        [self addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(1.0);
            make.top.mas_equalTo(self.top);
            make.bottom.mas_offset(self.bottom);
        }];
        
        if (i == 0) {
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.left);
            }];
        } else if (i == 3) {
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.right);
            }];
        } else {
            line.alpha = 0.5;
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.centerX).multipliedBy(dw / 0.5);
            }];
        }
        dw += 1.0 / (CGFloat)(gridLineCount - 1);
    }
    
    
}


@end
