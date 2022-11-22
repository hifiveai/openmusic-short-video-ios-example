//
//  HFNoDataView.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/27.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "HFNoDataView.h"
#import "HFConfigModel.h"

@interface HFNoDataView ()

@property (nonatomic ,strong) UIImageView *noDataImageView;
@property (nonatomic ,strong) UILabel *titleLabel;

@end

@implementation HFNoDataView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
        [self makeLayoutSubviews];
        
    }
    return self;
}

- (void)addSubviews {
    [self addSubview:self.noDataImageView];
    [self addSubview:self.titleLabel];
}

- (void)makeLayoutSubviews {
    [self.noDataImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(180, 180));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.noDataImageView);
        make.top.equalTo(self.noDataImageView.mas_bottom).offset(24);
        make.leading.trailing.mas_equalTo(0);
    }];
}

- (void)updateTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)updateImage:(NSString *)name {
    self.noDataImageView.image = [UIImage imageNamed:name];
}

- (UIImageView *)noDataImageView {
    if (!_noDataImageView) {
        _noDataImageView = [[UIImageView alloc] init];
        _noDataImageView.image = [UIImage imageNamed:@"noData"];
    }
    return _noDataImageView;;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [HFConfigModel mainTitleColor];
        _titleLabel.font = [HFConfigModel palyViewNameFont];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

@end
