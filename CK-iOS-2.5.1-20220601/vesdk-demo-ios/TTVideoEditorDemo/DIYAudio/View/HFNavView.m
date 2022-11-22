//
//  HFNavView.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/13.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "HFNavView.h"
#import <Masonry/Masonry.h>
#import "HFConfigModel.h"


@interface HFNavView ()

@property (nonatomic ,strong) UIButton *closeButton;
@property (nonatomic ,strong) UILabel *titleLabel;
@property (nonatomic ,strong) UIButton *searchButton;
@property (nonatomic ,strong) UIButton *backButon;

@end

@implementation HFNavView

+ (HFNavView *)configWithFrame:(CGRect)frame title:(NSString *)title closeImage:(NSString *)imageName searchImage:(NSString *)searchName backImage:(NSString *)backName {
    HFNavView *nav = [[HFNavView alloc] initWithFrame:frame];
    nav.titleLabel.text = title;
    [nav.closeButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [nav.searchButton setImage:[UIImage imageNamed:searchName] forState:UIControlStateNormal];
    [nav.backButon setImage:[UIImage imageNamed:backName] forState:UIControlStateNormal];
    return nav;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubViews];
        [self makeLayoutSubviews];
        [self addActions];
    }
    return self;
}

- (void)addSubViews {
    [self addSubview:self.closeButton];
    [self addSubview:self.titleLabel];
    [self addSubview:self.searchButton];
    [self addSubview:self.backButon];
}

- (void)makeLayoutSubviews {
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
    }];
    
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-20);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    [self.backButon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
}

- (void)addActions {
    [self.closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.backButon addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.searchButton addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)closeAction {
    if (self.closeActionBlock) {
        self.closeActionBlock();
    }
}
- (void)backAction {
    if (self.backActionBlock) {
        self.backActionBlock();
    }
}
- (void)searchAction {
    if (self.searchActionBlock) {
        self.searchActionBlock();
    }
}

- (UIButton *)backButon {
    if (!_backButon) {
        _backButon = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _backButon;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _closeButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [HFConfigModel mainTitleColor];
    }
    return _titleLabel;
}
- (UIButton *)searchButton {
    if (!_searchButton) {
        _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _searchButton;
}

@end
