//
//  HFSearchBarView.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/21.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "HFSearchBarView.h"
#import "HFConfigModel.h"

@interface HFSearchBarView ()<UITextFieldDelegate>

@property (nonatomic ,strong) UIButton *cancelButton;

@property (nonatomic ,strong) UIImageView *searchImageView;

@property (nonatomic ,strong) UIButton *clearButton;

@end

@implementation HFSearchBarView

+ (HFSearchBarView *)configWithFrame:(CGRect)frame searchImage:(NSString *)searchImageName placeHolder:(NSString *)placeHolder {
    HFSearchBarView *searchBar = [[HFSearchBarView alloc] initWithFrame:frame];
    searchBar.searchImageView.image = [UIImage imageNamed:searchImageName];
    searchBar.searchTextFieldView.placeholder = placeHolder;
    searchBar.searchTextFieldView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolder attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5],NSFontAttributeName:[UIFont systemFontOfSize:17]}];
    return searchBar;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubViews];
        [self makeLayoutSubviews];
        [self configUI];
        [self addActions];
    }
    return self;
}

- (void)addSubViews {
    [self addSubview:self.searchTextFieldView];
    [self addSubview:self.cancelButton];
}

- (void)makeLayoutSubviews {
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(0);
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(70);
    }];
    [self.searchTextFieldView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.mas_equalTo(20);
        make.height.mas_equalTo(36);
        make.trailing.equalTo(self.cancelButton.mas_leading);
    }];
    [self.searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 22));
    }];
    [self.clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(36, 36));
    }];
    self.searchImageView.contentMode = UIViewContentModeScaleAspectFit;
}
- (void)configUI {
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[HFConfigModel usingBackColor] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [HFConfigModel palyViewNameFont];
    [self.clearButton setImage:[UIImage imageNamed:@"clear_icon"] forState:UIControlStateNormal];
    self.searchTextFieldView.leftView = self.searchImageView;
    self.searchTextFieldView.leftViewMode = UITextFieldViewModeAlways;
    self.searchTextFieldView.rightView = self.clearButton;
    self.searchTextFieldView.rightViewMode = UITextFieldViewModeWhileEditing;
    self.searchTextFieldView.returnKeyType = UIReturnKeySearch;
    self.searchTextFieldView.font = [HFConfigModel palyViewNameFont];
    self.searchTextFieldView.textColor = [HFConfigModel mainTitleColor];
    self.searchTextFieldView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.08];
    self.searchTextFieldView.layer.cornerRadius = 8;
    self.searchTextFieldView.layer.masksToBounds = YES;
    
    
}

- (void)addActions {
    [self.cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    self.searchTextFieldView.delegate = self;
    [self.clearButton addTarget:self action:@selector(clearBtnAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)cancelAction:(UIButton *)btn {
    if (self.cancelBtnBlock) {
        self.cancelBtnBlock();
    }
}
- (void)clearBtnAction:(UIButton *)btn {
    self.searchTextFieldView.text = @"";
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.searchActionBlock) {
        self.searchActionBlock(textField.text);
    }
    return NO;
}


- (UITextField *)searchTextFieldView {
    if (!_searchTextFieldView) {
        _searchTextFieldView = [[UITextField alloc] init];
    }
    return _searchTextFieldView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _cancelButton;
}

- (UIImageView *)searchImageView {
    if (!_searchImageView) {
        _searchImageView = [[UIImageView alloc] init];
    }
    return _searchImageView;
}

- (UIButton *)clearButton {
    if (!_clearButton) {
        _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _clearButton;
}
@end
