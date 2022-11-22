//
//  HFCollectionViewCell.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/14.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "HFPlaylistCollectionViewCell.h"
#import <SDWebImage/SDWebImage.h>
#import "HFPlaylistCollectionCellModel.h"
#import "HFConfigModel.h"

@interface HFPlaylistCollectionViewCell ()

@property (nonatomic ,strong) UIImageView *picImageView;
@property (nonatomic ,strong) UILabel *nameLabel;

@property (nonatomic ,strong) HFPlaylistCollectionCellModel *model;

@end

@implementation HFPlaylistCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
        [self makeLayoutSubviews];
        [self addActions];
    }
    return self;
}

- (void)addSubviews {
    [self.contentView addSubview:self.picImageView];
    [self.contentView addSubview:self.nameLabel];
}

- (void)makeLayoutSubviews {
    [self.picImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-44);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(40);
    }];
}

- (void)addActions {
    
}


- (void)configWith:(HFPlaylistCollectionCellModel *)model {
    [self.picImageView sd_setImageWithURL:[NSURL URLWithString:model.picUrl]];
    self.nameLabel.text = model.listName;
    self.model = model;
}

- (UIImageView *)picImageView {
    if (!_picImageView) {
        _picImageView = [[UIImageView alloc] init];
        _picImageView.backgroundColor = [UIColor whiteColor];
    }
    return _picImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.numberOfLines = 2;
        _nameLabel.textColor = [HFConfigModel subodyColor];
        _nameLabel.font = [HFConfigModel subBodyFont];
    }
    return _nameLabel;
}
@end
