//
//  DVEAlbumAssetListCell.m
//  CameraClient
//
//  Created by bytedance on 2020/6/30.
//

#import "DVEAlbumAssetListCell.h"
#import <Photos/Photos.h>
#import <KVOController/KVOController.h>
#import "DVEAlbumMacros.h"
#import "DVEAlbumResourceUnion.h"
#import "DVECircularProgressView.h"
#import "DVEAlbumGradientView.h"
#import "DVEPhotoManager.h"
#import "UIView+DVEAlbumUIKit.h"
#import "UIImage+DVEAlbumAdditions.h"
#import <Masonry/Masonry.h>


@interface DVEAlbumAssetListCell()

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *thumbnailImageView;

@property (nonatomic, strong) UIImageView *selectedImageView;
@property (nonatomic, strong) DVEAlbumGradientView *selectedGradientView;

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIView *selectPhotoView;
@property (nonatomic, strong) UIImageView *unCheckImageView;
@property (nonatomic, strong) UIImageView *numberBackGroundImageView;
@property (nonatomic, strong) UILabel *numberLabel;

@property (nonatomic, assign) int32_t imageRequestID;
@property (nonatomic, assign) CGFloat screenScale;

@property (nonatomic, strong) DVECircularProgressView *circularProgressView;
@property (nonatomic, assign) BOOL animationFinished;

@property (nonatomic, assign) BOOL isCellAnimating;
@property (nonatomic, strong) UILabel *checkedLabel;

@property (nonatomic, strong) UILabel *gifLabel;

@end


@implementation DVEAlbumAssetListCell

- (CGFloat)checkImageHeight
{
    return 14;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = TOCResourceColor(TOCUIColorConstBGContainer);
        self.clipsToBounds = YES;
        
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        if (screenScale >= 2) {
            screenScale = 2;
        }
        if (TOC_SCREEN_WIDTH > 700) {
            screenScale = 1.5;
        }
        self.screenScale = screenScale;
        
        UIImageView *thumbnailImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        thumbnailImageView.backgroundColor = TOCResourceColor(TOCUIColorConstBGInput);
        thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        thumbnailImageView.clipsToBounds = YES;
        thumbnailImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth;
        _thumbnailImageView = thumbnailImageView;
        [self.contentView addSubview:thumbnailImageView];

        UILabel *label = [[UILabel alloc] init];
        label.textColor = TOCResourceColor(TOCUIColorConstTextInverse);
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentRight;
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        label.shadowOffset = CGSizeMake(0, 1);
        label.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.15];
        [self.contentView addSubview:label];
        _timeLabel = label;

//        _selectedGradientView = [[DVEAlbumGradientView alloc] init];
//        _selectedGradientView.gradientLayer.startPoint = CGPointMake(0, 0);
//        _selectedGradientView.gradientLayer.endPoint = CGPointMake(0, 1);
//        _selectedGradientView.gradientLayer.locations = @[@0, @1];
//        _selectedGradientView.gradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
//                                                       (__bridge id)TOCResourceColor(TOCUIColorConstSDSecondary).CGColor];
//        [self.contentView insertSubview:_selectedGradientView aboveSubview:_thumbnailImageView];

//        _selectedImageView = [[UIImageView alloc] initWithImage:TOCResourceImage(@"icon_album_selected_check")];
//        [self.contentView addSubview:_selectedImageView];

        _maskView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        _maskView.backgroundColor = TOCResourceColor(TOCUIColorSDTertiary2);
        _maskView.hidden = YES;
        [self.contentView addSubview:_maskView];
        
        self.selectPhotoView = [[UIView alloc] init];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectAssetButtonClick:)];
        [self.selectPhotoView addGestureRecognizer:tapGesture];
        [self.contentView addSubview:self.selectPhotoView];
        
        CGFloat checkImageHeight = [self checkImageHeight];
        _unCheckImageView = [[UIImageView alloc] initWithImage:TOCResourceImage(@"icon_album_unselect")];
        [_selectPhotoView addSubview:_unCheckImageView];

        UIImage *cornerImage = [UIImage acc_imageWithSize:CGSizeMake(checkImageHeight, checkImageHeight) cornerRadius:checkImageHeight * 0.5 backgroundColor:TOCResourceColor(TOCColorPrimary)];
        _numberBackGroundImageView = [[UIImageView alloc] initWithImage:cornerImage];
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.font = [UIFont systemFontOfSize:13];
        _numberLabel.textColor = TOCResourceColor(TOCUIColorConstTextInverse);
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        [_numberBackGroundImageView addSubview:_numberLabel];
        [_selectPhotoView addSubview:_numberBackGroundImageView];

        self.circularProgressView = [[DVECircularProgressView alloc] init];
        self.circularProgressView.progressBackgroundColor = [TOCResourceColor(TOCUIColorConstBGContainer) colorWithAlphaComponent:0.3];
        self.circularProgressView.progressTintColor = TOCResourceColor(TOCUIColorConstBGContainer);
        self.circularProgressView.lineWidth = 2.0;
        self.circularProgressView.backgroundWidth = 3.0;
        self.circularProgressView.hidden = YES;
        [self.contentView addSubview:self.circularProgressView];
        
        [self showAlreadySelectedHint:NO];
        [self setupUI];
    }
    return self;
}

- (void)dealloc {
    [self.circularProgressView unobserveAll];
}

- (void)setupUI
{
    self.timeLabel.frame = CGRectMake(0, self.contentView.frame.size.height - 18,  CGRectGetMaxX(self.contentView.frame) - 5, 13);
    
    self.selectedGradientView.frame = CGRectMake(0, self.contentView.frame.size.height * 0.5, self.contentView.frame.size.width, self.contentView.frame.size.height * 0.5);
    
    self.selectedImageView.frame = CGRectMake(6, self.timeLabel.center.x - 5.5, 11, 11);
    
    self.selectPhotoView.frame = CGRectMake(CGRectGetMaxX(self.contentView.frame) - 44, 0, 44, 44);
    
    CGFloat checkImageHeight = [self checkImageHeight];
    
    self.unCheckImageView.frame = CGRectMake(38 - checkImageHeight, 4, checkImageHeight, checkImageHeight);
    self.numberBackGroundImageView.frame = self.unCheckImageView.frame;
    self.numberLabel.frame = self.numberBackGroundImageView.bounds;
    
    self.circularProgressView.frame = CGRectMake(self.contentView.acc_right - 16, self.contentView.acc_bottom - 16, 12, 12);
    
    if (self.useForAmericaRecordOptim) {
        self.unCheckImageView.frame = CGRectMake(14, 6, 24, 24);
        self.numberBackGroundImageView.frame = self.unCheckImageView.frame;
        self.numberLabel.frame = self.numberBackGroundImageView.bounds;
    }
    
    [self addSubview:self.gifLabel];
    [self.gifLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(24, 16));
        make.left.equalTo(self);
        make.bottom.equalTo(self).offset(-4);
    }];
    
    self.gifLabel.hidden = YES;
}

- (void)selectAssetButtonClick:(UIButton *)button
{
    if (self.isCellAnimating ||
        !self.assetModel.canSelect ||
        ![self isAssetsMatchLimitDurationWithAssetModel:self.assetModel]) {
        return;
    }
    
    self.assetModel.isSelected = !self.assetModel.isSelected;
    if (!self.assetModel.isSelected) {
        self.unCheckImageView.hidden = NO;
        self.numberBackGroundImageView.hidden = YES;
        self.maskView.hidden = YES;
        self.thumbnailImageView.transform = CGAffineTransformIdentity;
    }
    
    TOCBLOCK_INVOKE(self.didSelectedAssetBlock, self, self.assetModel.selectedNum ? YES : NO);
}

- (void)doSelectedAnimation
{
    if (!self.assetModel.isSelected) {
        return;
    }
    
    self.isCellAnimating = YES;
    UIView *fromView = nil;
    UIView *toView = nil;
    if (self.assetModel.selectedAmount > 0) {
        // select
        if (!self.checkMarkSelectedStyle) {
            self.numberLabel.text = [NSString stringWithFormat:@"%@", @([self.assetModel.selectedNum integerValue])];
        } else {
            self.numberBackGroundImageView.image = TOCResourceImage(@"icon_album_cut_same_selected");
            // 已选label
            //[self.contentView addSubview:self.checkedLabel];
            [self.numberBackGroundImageView layoutIfNeeded];
            
        }
        fromView = self.unCheckImageView;
        toView = self.numberBackGroundImageView;

        self.maskView.hidden = NO;
        self.maskView.alpha = 0;
        self.thumbnailImageView.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:0.3 animations:^{
            self.thumbnailImageView.transform = CGAffineTransformMakeScale(1.1, 1.1);
            self.maskView.alpha = 1.0;
        }];

    } else {
        // unselect
        self.numberLabel.text = nil;
        toView = self.unCheckImageView;
        fromView = self.numberBackGroundImageView;
        // 已选label
        //[self.checkedLabel removeFromSuperview];
        self.maskView.hidden = NO;
        self.maskView.alpha = 1.0;
        self.thumbnailImageView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        [UIView animateWithDuration:0.3 animations:^{
            self.thumbnailImageView.transform = CGAffineTransformIdentity;
            self.maskView.alpha = 0;
        }];

    }
    
    CGFloat firstAnimationDuration = 0.05;
    CGFloat secondAnimationDuration = 0.3;

    fromView.hidden = NO;
    fromView.transform = CGAffineTransformIdentity;
    fromView.alpha = 1;
    [UIView animateWithDuration:firstAnimationDuration animations:^{
        fromView.transform = CGAffineTransformMakeScale(0.3, 0.3);
        fromView.alpha = 0;
    } completion:^(BOOL finished) {
        fromView.hidden = YES;
        fromView.alpha = 1;
        fromView.transform = CGAffineTransformIdentity;
        
        toView.hidden = NO;
        toView.alpha = 0;
        toView.transform = CGAffineTransformMakeScale(0.3, 0.3);
        [UIView animateWithDuration:secondAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            toView.alpha = 1;
            toView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.isCellAnimating = NO;
        }];
    }];
    
}

- (void)updateSelectStatus
{
    if (!self.assetModel.isSelected) {
        return;
    }
    
    if (self.assetModel.selectedAmount > 0) {
        self.contentView.alpha = 1;
        // select
        if (!self.checkMarkSelectedStyle) {
            self.numberLabel.text = [NSString stringWithFormat:@"%@", @([self.assetModel.selectedNum integerValue])];
        } else {
            self.numberBackGroundImageView.image = TOCResourceImage(@"icon_album_cut_same_selected");
            //[self.contentView addSubview:self.checkedLabel];
        }

        self.unCheckImageView.hidden = YES;
        self.numberBackGroundImageView.hidden = NO;
        self.maskView.hidden = NO;
        self.maskView.alpha = 1.0;
    } else {
        // unselect
        //[self.checkedLabel removeFromSuperview];
        //self.checkedLabel = nil;
        self.unCheckImageView.hidden = NO;
        self.numberBackGroundImageView.hidden = YES;
        self.numberLabel.text = nil;
        self.maskView.hidden = YES;
    }
}

- (void)showAlreadySelectedHint:(BOOL)show
{
//    if (show) {
//        if (!self.checkedLabel.superview) {
//            [self.contentView addSubview:self.checkedLabel];
//            self.checkedLabel.hidden = NO;
//        }
//    } else {
//        [self.checkedLabel removeFromSuperview];
//    }
//    self.selectedGradientView.hidden = !show;
//    self.selectedImageView.hidden = !show;
}

//-----由SMCheckProject工具删除-----
//- (void)configureCellWithAsset:(AWEAssetModel *)assetModel greyMode:(BOOL)greyMode showRightTopIcon:(BOOL)showRightTopIcon
//{
//    [self configureCellWithAsset:assetModel greyMode:greyMode showRightTopIcon:showRightTopIcon alreadySelect:NO];
//}

- (void)configureCellWithAsset:(DVEAlbumAssetModel *)assetModel greyMode:(BOOL)greyMode showRightTopIcon:(BOOL)showRightTopIcon alreadySelect:(BOOL)alreadySelect
{
    [self updateSelectStatus:(assetModel.canSelect && [self isAssetsMatchLimitDurationWithAssetModel:assetModel])];
    [self updateGIFLabelIfNeedWithAssetModel:assetModel];
    if (self.imageRequestID > 0) {
        return;
    }
    
    if (self.useForAmericaRecordOptim) {
        self.unCheckImageView.image = TOCResourceImage(@"icon_checkbox_inactive");

        UIImage *cornerImage = [UIImage acc_imageWithSize:CGSizeMake(14, 14) cornerRadius:14 * 0.5 backgroundColor:TOCResourceColor(TOCColorPrimary)];
        self.numberBackGroundImageView.image = cornerImage;

        self.numberLabel.font = [UIFont systemFontOfSize:13];
        self.timeLabel.font = [UIFont systemFontOfSize:13];
    }
    
    [self removeiCloudKVOObservor];
    self.assetModel = assetModel;
    [self addiCloudKVOObservor];
    
    PHAsset *asset = self.assetModel.asset;
    if (asset.mediaType == PHAssetMediaTypeImage) {
        self.timeLabel.hidden = YES;
    } else {
        self.timeLabel.hidden = NO;
        self.timeLabel.text = self.assetModel.videoDuration;
    }

    [self showAlreadySelectedHint:alreadySelect && !self.useForAmericaRecordOptim];

    if (showRightTopIcon) {
        self.selectPhotoView.hidden = NO;
        [self updatePhotoSelectedWithNum:assetModel.selectedNum greyMode:greyMode selected:assetModel.isSelected];
    } else {
        self.selectPhotoView.hidden = YES;
    }
    
    if (assetModel.coverImage && !assetModel.isDegraded) {
        self.thumbnailImageView.image = assetModel.coverImage;
        return;
    }
    
    CGSize size = self.thumbnailImageView.bounds.size;

    CGFloat imageSizeWidth = size.width * self.screenScale;
    CGFloat imageSizeHeight = size.height * self.screenScale;

    CGSize imageSize = CGSizeMake(imageSizeWidth, imageSizeHeight);
    NSTimeInterval start = CFAbsoluteTimeGetCurrent();
    int32_t imageRequestID = [DVEPhotoManager getUIImageWithPHAsset:asset
                                                          imageSize:imageSize
                                               networkAccessAllowed:NO
                                                    progressHandler:^(CGFloat progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {}
                                                         completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                                                             if (assetModel == self.assetModel) {
                                                                 if (photo) {
                                                                     self.thumbnailImageView.image = photo;
                                                                     assetModel.coverImage = photo;
                                                                     assetModel.isDegraded = isDegraded;
                                                                     TOCBLOCK_INVOKE(self.didFetchThumbnailBlock,CFAbsoluteTimeGetCurrent() - start);
                                                                 }
                                                             } else {
                                                                 [DVEPhotoManager cancelImageRequest:self.imageRequestID];
                                                             }
                                                             if (!isDegraded) {
                                                                 self.imageRequestID = 0;
                                                                 self.thumbnailImageView.image = self.assetModel.coverImage;
                                                             }
                                                         }];
    
    if (imageRequestID && self.imageRequestID && self.imageRequestID != imageRequestID) {
        [DVEPhotoManager cancelImageRequest:self.imageRequestID];
    }
    self.imageRequestID = imageRequestID;
}

- (void)updatePhotoSelectedWithNum:(NSNumber *)number greyMode:(BOOL)greyMode selected:(BOOL)isSelected
{
    if (number && isSelected) {
        self.contentView.alpha = 1;
        //check
        self.unCheckImageView.hidden = YES;
        self.numberBackGroundImageView.hidden = NO;
        if (!self.checkMarkSelectedStyle) {
            self.numberLabel.text = [NSString stringWithFormat:@"%@", @([number integerValue])];
        } else {
            self.numberBackGroundImageView.image = TOCResourceImage(@"icon_album_cut_same_selected");
            [self.numberBackGroundImageView layoutIfNeeded];
        }
        //mask
        self.maskView.hidden = NO;
        self.maskView.alpha = 1.0;
        self.thumbnailImageView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } else {
//        if (greyMode) {
//            self.contentView.alpha = 0.5;
//        } else {
//            self.contentView.alpha = 1;
//        }
        //check
        self.unCheckImageView.hidden = NO;
        self.numberBackGroundImageView.hidden = YES;
        self.numberLabel.text = nil;
        //mask
        self.maskView.hidden = YES;
        self.maskView.alpha = 0;
        self.thumbnailImageView.transform = CGAffineTransformIdentity;
    }
}

- (void)updateGIFLabelIfNeedWithAssetModel:(DVEAlbumAssetModel *)assetModel {
    if (assetModel.mediaSubType == DVEAlbumAssetModelMediaSubTypePhotoGif) {
        self.gifLabel.hidden = NO;
    } else {
        self.gifLabel.hidden = YES;
    }
}

- (UILabel *)gifLabel {
    if (!_gifLabel) {
        _gifLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 20, 24, 16)];
        _gifLabel.backgroundColor = [UIColor colorWithRed:0.106 green:0.11 blue:0.125 alpha:1];
        _gifLabel.textColor = [UIColor whiteColor];
        _gifLabel.textAlignment = NSTextAlignmentCenter;
        _gifLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:8];
        _gifLabel.text = @"gif";
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:_gifLabel.bounds
                                                   byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(7, 7)];
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.frame = _gifLabel.bounds;
        layer.path = path.CGPath;
        _gifLabel.layer.mask = layer;
    }
    return _gifLabel;
}

- (UIImage *)thumbnailImage
{
    return self.thumbnailImageView.image;
}

- (UILabel *)checkedLabel {
    if (!_checkedLabel) {
        _checkedLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 4, 31, 14)];
        _checkedLabel.text = @"已选";
        _checkedLabel.font = [UIFont systemFontOfSize:8];
        _checkedLabel.textAlignment = NSTextAlignmentCenter;
        _checkedLabel.textColor = TOCResourceColor(TOCUIColorConstTextInverse);
        _checkedLabel.backgroundColor = TOCResourceColor(TOCColorPrimary);
        _checkedLabel.layer.cornerRadius = 7;
        _checkedLabel.layer.masksToBounds = YES;
    }
    
    return _checkedLabel;
}

#pragma mark - icloud methods

- (void)runScaleAnimationWithCallback:(void(^)())callback {
    if (self.animationFinished) {
        TOCBLOCK_INVOKE(callback);
        return;
    }
    if (self.circularProgressView.hidden) {//only run animation one time
        self.timeLabel.hidden = YES;
        self.circularProgressView.hidden = NO;
        self.animationFinished = NO;
        self.circularProgressView.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
        [UIView animateWithDuration:0.25f animations:^{
            self.circularProgressView.transform = CGAffineTransformMakeScale(1.f, 1.f);
        } completion:^(BOOL finished) {
            self.circularProgressView.transform = CGAffineTransformIdentity;
            self.animationFinished = YES;
            self.circularProgressView.progress = self.assetModel.iCloudSyncProgress;
            TOCBLOCK_INVOKE(callback);
        }];
    } else {
        TOCBLOCK_INVOKE(callback);
    }
}

- (void)removeiCloudKVOObservor {
    if (self.KVOController.observer) {
        [self.KVOController unobserve:self.assetModel];
    }
}

- (void)addiCloudKVOObservor {
    self.timeLabel.hidden = NO;
    self.circularProgressView.hidden = YES;
    @weakify(self);
    [self.KVOController observe:self.assetModel keyPath:FBKVOClassKeyPath(DVEAlbumAssetModel,iCloudSyncProgress) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        if (self.assetModel.mediaType == DVEAlbumAssetModelMediaTypeVideo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //CGFloat oldValue = [change[NSKeyValueChangeOldKey] floatValue];
                CGFloat newValue = [change[NSKeyValueChangeNewKey] floatValue];
                
                if (newValue == 0.f && self.circularProgressView.hidden) {//多选-cell执行动画-同步中-取消-再多选-cell执行动画-同步中
                    self.animationFinished = NO;
                }
                
                [self runScaleAnimationWithCallback:^{
                    @strongify(self);
                    self.circularProgressView.progress = newValue;
                    
                    if (self.assetModel.iCloudSyncProgress >= 1.f || newValue >= 1.f) {
                        [self.KVOController unobserve:self.assetModel];
                        if (!self.circularProgressView.hidden) {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                self.timeLabel.hidden = NO;
                                self.circularProgressView.hidden = YES;
                            });
                        }
                    }
                }];
            });
        }
    }];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageRequestID = 0;
}

#pragma mark - identifier

+ (NSString *)identifier
{
    return NSStringFromClass([self class]);
}

- (void)updateSelectedButtonWithStatus:(BOOL)singleSelected {
    if (singleSelected) {
        [self.selectPhotoView removeFromSuperview];
    }
}

- (void)updateSelectStatus:(BOOL)canSelect {
    if (!canSelect) {
        self.contentView.alpha = 0.5;
    } else {
        self.contentView.alpha = 1.0;
    }
}

- (BOOL)isAssetsMatchLimitDurationWithAssetModel:(DVEAlbumAssetModel *)assetModel {
    NSInteger assetDuation = (NSInteger)(assetModel.asset.duration * NSEC_PER_USEC);
    return self.limitDuration <= 0 || assetModel.mediaType == DVEAlbumAssetModelMediaTypePhoto || (assetDuation >= self.limitDuration && assetModel.mediaType == DVEAlbumAssetModelMediaTypeVideo);
}

@end

