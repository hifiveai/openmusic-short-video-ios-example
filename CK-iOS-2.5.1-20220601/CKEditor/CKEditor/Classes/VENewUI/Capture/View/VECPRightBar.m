//
//  VECPRightBar.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECPRightBar.h"

@implementation VECPRightBar
@synthesize viewType = _viewType;

- (void)setViewType:(VECPViewType)viewType
{
    _viewType = viewType;
    [self buildLayout];
    
    [self.collecView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(10);
    }];
}

- (void)buildLayout
{
    switch (_viewType) {
        case VECPViewTypeVideo:
        {
            self.dataSourceArr = @[@"翻转",@"比例",@"",@"",];
        }
            break;
        case VECPViewTypePicture:
        {
            self.dataSourceArr = @[@"翻转",@"比例",@"",@"",];
        }
            break;
            
        default:
            break;
    }
}

@end
