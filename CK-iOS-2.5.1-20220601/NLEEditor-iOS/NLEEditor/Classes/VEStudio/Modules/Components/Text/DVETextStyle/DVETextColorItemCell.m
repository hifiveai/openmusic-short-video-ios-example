//
//  DVETextColorItemCell.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/22.
//

#import "DVETextColorItemCell.h"

@implementation DVETextColorItemCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.imageView.layer.cornerRadius = frame.size.height/2;
        self.imageView.layer.borderWidth = 0;
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected
{
    
}
@end
