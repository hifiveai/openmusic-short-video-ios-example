//
//  DVECanvasColorItem.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/3.
//

#import "DVECanvasColorItem.h"
#import "DVEMacros.h"

@interface DVECanvasColorItem ()

@property (nonatomic, strong) UIView *view;

@end

@implementation DVECanvasColorItem

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.view];
    }
    return self;
}

- (UIView *)view {
    if (!_view) {
        _view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _view.layer.cornerRadius = _view.frame.size.width / 2;
    }
    return _view;
}

- (void)setStickerSelected:(BOOL)stickerSelected animated:(BOOL)animated {
    [super setStickerSelected:stickerSelected animated:animated];
}

- (void)setModel:(DVEEffectValue *)model {
    [super setModel:model];
    
    NSArray<NSNumber *> *color = model.color;
    self.view.backgroundColor = [UIColor colorWithRed:[color[0] floatValue]
                                                green:[color[1] floatValue]
                                                 blue:[color[2] floatValue]
                                                alpha:[color[3] floatValue]];
}

@end
