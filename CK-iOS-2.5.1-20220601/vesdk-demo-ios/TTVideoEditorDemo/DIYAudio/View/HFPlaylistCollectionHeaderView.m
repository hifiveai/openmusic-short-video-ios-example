//
//  HFMusicCollectionHeaderView.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/20.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "HFPlaylistCollectionHeaderView.h"
#import "HFConfigModel.h"

@implementation HFPlaylistCollectionHeaderView

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
    [self addSubview:self.titleLable];
}

- (void)makeLayoutSubviews {
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.trailing.mas_equalTo(-20);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
}

- (UILabel *)titleLable {
    if (!_titleLable) {
        _titleLable = [[UILabel alloc] init];
        _titleLable.font = [HFConfigModel mainTitleFont];
        _titleLable.textColor = [HFConfigModel mainTitleColor];
    }
    return _titleLable;
}

@end
