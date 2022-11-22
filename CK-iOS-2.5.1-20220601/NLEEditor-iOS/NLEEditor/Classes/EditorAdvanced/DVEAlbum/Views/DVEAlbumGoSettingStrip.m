//
//  DVEAlbumGoSettingStrip.m
//  CutSameIF
//
//  Created by bytedance on 2020/9/12.
//

#import "DVEAlbumGoSettingStrip.h"
#import "DVEAlbumResourceUnion.h"
#import "DVEAlbumMacros.h"
#import "DVEAlbumLanguageProtocol.h"

static BOOL DVEAlbumGoSettingStripClosedByUser;

@interface DVEAlbumGoSettingStrip ()

@property (nonatomic, strong) UIView *topLine;

@end

@implementation DVEAlbumGoSettingStrip

+ (BOOL)closedByUser
{
    return DVEAlbumGoSettingStripClosedByUser;
}

+ (void)setClosedByUser
{
    DVEAlbumGoSettingStripClosedByUser = YES;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = TOCResourceColor(TOCUIColorConstBGContainer);
        _topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
        _topLine.backgroundColor = TOCResourceColor(TOCUIColorConstLineSecondary);
        [self addSubview:_topLine];
        CGFloat widthScaleFactor = TOC_SCREEN_WIDTH / 375;
        // label
        _label = [[UILabel alloc] initWithFrame:CGRectMake(16 * widthScaleFactor, 10, 313 * widthScaleFactor, 20)];
        NSString *text1 = TOCLocalizedString(@"authorization_gotosettings", @"点击%@切换至允许访问所有照片");
        NSRange specifierRange = [text1 rangeOfString:@"%@"];
        NSAssert(specifierRange.length > 0, @"provided text should containt one specifier");
        NSString *text2 = TOCLocalizedString(@"authorization_gotosetting", @"去设置");
        NSString *text = [NSString stringWithFormat:text1, text2];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text];
        NSRange range1 = NSMakeRange(0, specifierRange.location);
        [attrString setAttributes:@{
            NSForegroundColorAttributeName:TOCResourceColor(TOCColorTextReverse),
            NSFontAttributeName:[UIFont systemFontOfSize:14]
        } range:range1];
        NSRange range2 = NSMakeRange(specifierRange.location, text2.length);
        [attrString setAttributes:@{
            NSForegroundColorAttributeName:TOCResourceColor(TOCColorPrimary),
            NSFontAttributeName:[UIFont systemFontOfSize:14]
        } range:range2];
        NSRange range3 = NSMakeRange(specifierRange.location + text2.length, text.length - (specifierRange.location + text2.length));
        [attrString setAttributes:@{
            NSForegroundColorAttributeName:TOCResourceColor(TOCColorTextReverse),
            NSFontAttributeName:[UIFont systemFontOfSize:14]
        } range:range3];
        _label.attributedText = [attrString copy];
        _label.userInteractionEnabled = YES;
        [self addSubview:_label];
        // closeButton
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(351 * widthScaleFactor, 12, 16, 16)];
        [_closeButton setImage:TOCResourceImage(@"iconAlbumGoSettingStripClose") forState:UIControlStateNormal];
        [self addSubview:_closeButton];

    }
    return self;
}

@end
