//
//  DVEImportSelectBottomView.m
//  CutSameIF
//
//  Created by bytedance on 2020/3/13.

//
#import "UIView+DVEAlbumMasonry.h"
#import "DVEImportSelectBottomView.h"
#import "DVEAlbumResourceUnion.h"
#import "DVEAlbumLanguageProtocol.h"
#import <Masonry/View+MASAdditions.h>

@interface DVEImportSelectBottomView ()

//@property (nonatomic, strong) UIView *seperatorLineView;

@end

@implementation DVEImportSelectBottomView
@synthesize titleLabel = _titleLabel;
@synthesize nextButton = _nextButton;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
//        _seperatorLineView = [[UIView alloc] init];
//        _seperatorLineView.backgroundColor = TOCResourceColor(TOCColorLineReverse2);
//        [self addSubview:_seperatorLineView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:13.0f];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 1;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_titleLabel];
        
        _nextButton = [[UIButton alloc] init];
        [_nextButton setTitleColor:TOCResourceColor(TOCColorTextPrimary) forState:UIControlStateNormal];
        [_nextButton setTitleColor:TOCResourceColor(TOCColorTextPrimary) forState:UIControlStateDisabled];
        [_nextButton setTitle:TOCLocalizedString(@"next", @"") forState:UIControlStateNormal];
        _nextButton.titleLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightMedium];
        _nextButton.layer.cornerRadius = 16.0f;
        _nextButton.clipsToBounds = YES;
        [self addSubview:_nextButton];
        
//        DVEAlbumMasMaker(_seperatorLineView, {
//            make.leading.trailing.top.equalTo(@(0.0f));
//            make.height.equalTo(@(0.5f));
//        });
        
//        DVEAlbumMasMaker(_titleLabel, {
//            make.leading.equalTo(@(16.0f));
//            make.top.equalTo(@(0));
//            make.height.equalTo(@(52.0f));
//            make.trailing.equalTo(_nextButton.mas_leading).offset(-16.0f);
//        });
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(93, 24));
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.equalTo(self).offset(11.0);
        }];
        
        //CGSize sizeFits = [_nextButton sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        DVEAlbumMasMaker(_nextButton, {
            make.top.equalTo(@(8.0f));
            make.height.equalTo(@(32.0f));
            make.trailing.equalTo(@(-16.0f));
            make.width.equalTo(@(73.0f));
        });
        
        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [_nextButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        // Disable the next button by default.
        _nextButton.enabled = NO;
        _nextButton.backgroundColor = TOCResourceColor(TOCColorTextReverse4);
    }
    return self;
}

- (void)updateNextButtonWithStatus:(BOOL)enable {
    _nextButton.enabled = enable;
    _nextButton.backgroundColor = enable ? [UIColor colorWithRed:0.996 green:0.401 blue:0.274 alpha:1] : TOCResourceColor(TOCColorTextReverse4);
}

@end


@implementation DVEImportMaterialSelectBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.titleLabel removeFromSuperview];
        self.backgroundColor = TOCResourceColor(TOCColorBGCreation);
//        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 15)];
//        [_addButton setTitle:@"选择" forState:UIControlStateNormal];
//        _addButton.titleLabel.font = [UIFont systemFontOfSize:14];
//        [_addButton setTitleColor:TOCResourceColor(TOCColorTextPrimary) forState:UIControlStateNormal];
//        [_addButton setImage:TOCResourceImage(@"icon_album_add") forState:UIControlStateNormal];
//        [_addButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, -8)];
//        [self addSubview:_addButton];
//        DVEAlbumMasMaker(_addButton, {
//            make.left.equalTo(self).offset(17);
//            make.centerY.equalTo(self.nextButton.mas_centerY);
//            make.width.equalTo(@(50));
//        });
    }

    return self;

}

@end
