//
//  DVEImportSelectCollectionViewCell.m
//  CutSameIF
//
//  Created by bytedance on 2020/3/5.
//

#import "DVEImportSelectCollectionViewCell.h"
#import "DVEAlbumMacros.h"
#import "DVEAlbumLanguageProtocol.h"
#import "DVEAlbumResourceUnion.h"

static CGFloat const DVEImportMaterialSelectDeleteBtnWH = 14.5;


@interface DVEImportSelectCollectionViewCell ()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIImageView *thumbnailImageView;

@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation DVEImportSelectCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI
{
    [self.contentView addSubview:self.bgView];
    
    [self.contentView addSubview:self.thumbnailImageView];
    [self.contentView addSubview:self.deleteButton];
    
    [self.contentView addSubview:self.timeLabel];
}

- (void)bindModel:(DVEImportMaterialSelectCollectionViewCellModel *)cellModel
{
    _cellModel = cellModel;
    self.timeLabel.text = [NSString stringWithFormat:TOCLocalizedString(@"mv_footage_duration", @"%.1fs"), cellModel.duration];
    if (cellModel.assetModel.coverImage) {
        self.thumbnailImageView.hidden = NO;
        self.deleteButton.hidden = NO;
        self.thumbnailImageView.image = cellModel.assetModel.coverImage;
        self.timeLabel.textColor = TOCResourceColor(TOCColorConstTextInverse2);
    } else {
        self.thumbnailImageView.hidden = YES;
        self.deleteButton.hidden = YES;
        self.timeLabel.textColor = TOCResourceColor(TOCColorConstTextInverse2);
        if (cellModel.highlight) {
            self.bgView.layer.borderColor = TOCResourceColor(TOCColorPrimary).CGColor;
            self.bgView.layer.borderWidth = 2.0;
        } else {
            self.bgView.layer.borderColor = [UIColor clearColor].CGColor;
            self.bgView.layer.borderWidth = 0.0;
        }
    }
    self.timeLabel.hidden = !cellModel.shouldShowDuration;
}

- (void)onDeleteAction:(UIButton *)sender
{
    TOCBLOCK_INVOKE(self.deleteAction, self);
}

#pragma mark - Lazy load properties
- (UIView *)bgView
{
    if (!_bgView) {
        CGRect frame = CGRectInset(self.bounds, 5, 5);
        _bgView = [[UIView alloc] initWithFrame:frame];
        _bgView.backgroundColor = TOCResourceColor(TOCColorBGInputReverse);
        _bgView.layer.cornerRadius = 2.0;
        _bgView.clipsToBounds = YES;
    }
    
    return _bgView;
}

- (UIImageView *)thumbnailImageView
{
    if (!_thumbnailImageView) {
        CGRect frame = CGRectInset(self.bounds, 5, 5);
        _thumbnailImageView = [[UIImageView alloc] initWithFrame:frame];
        _thumbnailImageView.userInteractionEnabled = YES;
//        _thumbnailImageView.layer.cornerRadius = 2.0;
        _thumbnailImageView.clipsToBounds = YES;
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return _thumbnailImageView;
}

- (UIButton *)deleteButton
{
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(self.bounds.size.width-DVEImportMaterialSelectDeleteBtnWH, 0,
                                         DVEImportMaterialSelectDeleteBtnWH, DVEImportMaterialSelectDeleteBtnWH);
        _deleteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
//        _deleteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 10, 0);
        [_deleteButton setImage:TOCResourceImage(@"icSelectedDelete") forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(onDeleteAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _deleteButton;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 20, self.bounds.size.width - 9, 13)];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = [UIFont systemFontOfSize:10.0];
        _timeLabel.textColor = TOCResourceColor(TOCColorTextPrimary);
    }
    
    return _timeLabel;
}

@end
