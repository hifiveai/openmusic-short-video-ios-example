//
//  DVETextTemplatePickerCategoryCell.m
//  NLEEditor
//
//  Created by bytedance on 2021/4/9.
//

#import "DVETextTemplatePickerCategoryCell.h"
#import "DVEMacros.h"
#import <Masonry/Masonry.h>

@interface DVETextTemplatePickerCategoryCell()

@property(nonatomic,strong)UILabel* titleLabel;

@end

@implementation DVETextTemplatePickerCategoryCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        UILabel* label = [UILabel new];
        label.font = SCRegularFont(14);
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        
        self.titleLabel = label;
        [self setSelected:NO];
    }
    return self;
}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.titleLabel.alpha = selected ? 1.0f : 0.5f;
}

-(void)setCategoryModel:(id<DVEPickerCategoryModel>)categoryModel {
    [super setCategoryModel:categoryModel];
    self.titleLabel.text = categoryModel.name;
}

@end
