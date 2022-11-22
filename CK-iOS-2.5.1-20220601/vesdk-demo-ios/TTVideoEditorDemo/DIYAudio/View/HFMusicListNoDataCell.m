//
//  HFMusicListNoDataCell.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/27.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "HFMusicListNoDataCell.h"
#import "HFNoDataView.h"

@interface HFMusicListNoDataCell ()

@property (nonatomic ,strong) HFNoDataView *noDataView;

@end

@implementation HFMusicListNoDataCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubviews];
        [self makeLayoutSubviews];
        
    }
    return self;
}

- (void)addSubviews {
    self.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:self.noDataView];
}

- (void)makeLayoutSubviews {
    [self.noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.mas_equalTo(0);
    }];
}

- (void)configWithTitle:(NSString *)title imageName:(NSString *)imageName {
    [self.noDataView updateTitle:title];
    [self.noDataView updateImage:imageName];
}

- (HFNoDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[HFNoDataView alloc] init];
    }
    return _noDataView;
}

@end
